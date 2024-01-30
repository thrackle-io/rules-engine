// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/protocol/economic/ruleProcessor/RuleCodeData.sol";
import "src/protocol/economic/IRuleProcessor.sol";
import "src/protocol/economic/ruleProcessor/ActionEnum.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";
import "src/client/application/AppManager.sol";
import "src/common/IProtocolERC721Pricing.sol";
import "src/common/IProtocolERC20Pricing.sol";
import "src/client/token/HandlerTypeEnum.sol";
import "src/client/token/ITokenInterface.sol";
import {IApplicationHandlerEvents, ICommonApplicationHandlerEvents} from "src/common/IEvents.sol";
import {IZeroAddressError, IInputErrors, IAppHandlerErrors} from "src/common/IErrors.sol";

/**
 * @title Protocol Application Handler Contract
 * @notice This contract is the rules handler for all application level rules. It is implemented via the AppManager
 * @dev This contract is injected into the appManagers.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ProtocolApplicationHandler is Ownable, RuleAdministratorOnly, IApplicationHandlerEvents, ICommonApplicationHandlerEvents, IInputErrors, IZeroAddressError, IAppHandlerErrors {
    string private constant VERSION="1.1.0";
    AppManager appManager;
    address public appManagerAddress;
    IRuleProcessor immutable ruleProcessor;

    /// Risk Rule Ids
    uint32 private accountMaxValueByRiskScoreId;
    uint32 private accountMaxTransactionValueByRiskScoreId;
    /// Risk Rule on-off switches
    bool private accountMaxValueByRiskScoreActive;
    bool private accountMaxTransactionValueByRiskScoreActive;
    /// AccessLevel Rule Ids
    uint32 private accountMaxValueByAccessLevelId;
    uint32 private accountMaxValueOutByAccessLevelId;
    /// AccessLevel Rule on-off switches
    bool private accountMaxValueByAccessLevelActive;
    bool private AccountDenyForNoAccessLevelRuleActive;
    bool private accountMaxValueOutByAccessLevelActive;
    /// Pause Rule on-off switch
    bool private pauseRuleActive; 

    /// Pricing Module interfaces
    IProtocolERC20Pricing erc20Pricer;
    IProtocolERC721Pricing nftPricer;
    address public erc20PricingAddress;
    address public nftPricingAddress;

    /// MaxTxSizePerPeriodByRisk data
    mapping(address => uint128) usdValueTransactedInRiskPeriod;
    mapping(address => uint64) lastTxDateRiskRule;
    /// AdminMinTokenBalanceRule data
    mapping(address => uint128) usdValueTotalWithrawals;

    /**
     * @dev Initializes the contract setting the AppManager address as the one provided and setting the ruleProcessor for protocol access
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress) {
        if (_ruleProcessorProxyAddress == address(0) || _appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = AppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_appManagerAddress);
        emit ApplicationHandlerDeployed(_appManagerAddress);
    }

    /**
     * @dev checks if any of the Application level rules are active
     * @return true if one or more rules are active  
     */
    function requireApplicationRulesChecked() public view returns (bool) {
        return pauseRuleActive ||
               accountMaxValueByRiskScoreActive || accountMaxTransactionValueByRiskScoreActive || 
               accountMaxValueByAccessLevelActive || accountMaxValueOutByAccessLevelActive || AccountDenyForNoAccessLevelRuleActive;
    }

    /**
     * @dev Check Application Rules for valid transaction.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount amount of tokens to be transferred 
     * @param _nftValuationLimit number of tokenID's per collection before checking collection price vs individual token price
     * @param _tokenId tokenId of the NFT token
     * @param _action Action to be checked. This param is intentially added for future enhancements.
     * @param _handlerType the type of handler, used to direct to correct token pricing
     * @return success Returns true if allowed, false if not allowed
     */
    function checkApplicationRules(address _tokenAddress, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external onlyOwner returns (bool) {
        _action;
        uint128 balanceValuation;
        uint128 price;
        uint128 transferValuation;

        if (pauseRuleActive) ruleProcessor.checkPauseRules(appManagerAddress);
        /// Based on the Handler Type retrieve pricing valuations 
        if (_handlerType == HandlerTypes.ERC20HANDLER) {
            balanceValuation = uint128(getAccTotalValuation(_to, 0));
            price = uint128(_getERC20Price(_tokenAddress));
            transferValuation = uint128((price * _amount) / (10 ** IToken(_tokenAddress).decimals()));
        } else if (_handlerType == HandlerTypes.ERC721HANDLER) {
            balanceValuation = uint128(getAccTotalValuation(_to, _nftValuationLimit));
            transferValuation = uint128(nftPricer.getNFTPrice(_tokenAddress, _tokenId));
        }
        if (accountMaxValueByAccessLevelActive || AccountDenyForNoAccessLevelRuleActive || accountMaxValueOutByAccessLevelActive) {
            _checkAccessLevelRules(_from, _to, balanceValuation, transferValuation);
        }
        if (accountMaxValueByRiskScoreActive || accountMaxTransactionValueByRiskScoreActive) {
            _checkRiskRules(_from, _to, balanceValuation, transferValuation);
        }
        return true;
    }

    /**
     * @dev This function consolidates all the Risk rules that utilize application level Risk rules. 
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceValuation recepient address current total application valuation in USD with 18 decimals of precision
     * @param _transferValuation valuation of the token being transferred in USD with 18 decimals of precision
     */
    function _checkRiskRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal {
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (accountMaxValueByRiskScoreActive) {
            ruleProcessor.checkAccountMaxValueByRiskScore(accountMaxValueByRiskScoreId, _to, riskScoreTo, _balanceValuation, _transferValuation);
        }
        if (accountMaxTransactionValueByRiskScoreActive) {
            usdValueTransactedInRiskPeriod[_from] = ruleProcessor.checkAccountMaxTxValueByRiskScore(
                accountMaxTransactionValueByRiskScoreId,
                usdValueTransactedInRiskPeriod[_from],
                _transferValuation,
                lastTxDateRiskRule[_from],
                riskScoreFrom
            );
            if (_to != address(0)) {
                lastTxDateRiskRule[_from] = uint64(block.timestamp);
                usdValueTransactedInRiskPeriod[_to] = ruleProcessor.checkAccountMaxTxValueByRiskScore(
                    accountMaxTransactionValueByRiskScoreId,
                    usdValueTransactedInRiskPeriod[_to],
                    _transferValuation,
                    lastTxDateRiskRule[_to],
                    riskScoreTo
                );
                lastTxDateRiskRule[_to] = uint64(block.timestamp);
            }
        }
    }

    /**
     * @dev This function consolidates all the application level AccessLevel rules.
     * @param _to address of the to account
     * @param _balanceValuation recepient address current total application valuation in USD with 18 decimals of precision
     * @param _transferValuation valuation of the token being transferred in USD with 18 decimals of precision
     */
    function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal {
        uint8 score = appManager.getAccessLevel(_to);
        uint8 fromScore = appManager.getAccessLevel(_from);
        /// Check if sender is not AMM and then check sender access level
        if (AccountDenyForNoAccessLevelRuleActive && !appManager.isRegisteredAMM(_from)) ruleProcessor.checkAccountDenyForNoAccessLevel(fromScore);
        /// Check if receiver is not an AMM or address(0) and then check the recipient access level. Exempting address(0) allows for burning.
        if (AccountDenyForNoAccessLevelRuleActive && !appManager.isRegisteredAMM(_to) && _to != address(0)) ruleProcessor.checkAccountDenyForNoAccessLevel(score);
        /// Check that the recipient is not address(0). If it is we do not check this rule as it is a burn.
        if (accountMaxValueByAccessLevelActive && _to != address(0))
            ruleProcessor.checkAccountMaxValueByAccessLevel(accountMaxValueByAccessLevelId, score, _balanceValuation, _transferValuation);
        if (accountMaxValueOutByAccessLevelActive) {
            usdValueTotalWithrawals[_from] = ruleProcessor.checkAccountMaxValueOutByAccessLevel(accountMaxValueOutByAccessLevelId, fromScore, usdValueTotalWithrawals[_from], _transferValuation);
        }
    }

    /// -------------- Pricing Module Configurations ---------------
    /**
     * @dev sets the address of the nft pricing contract and loads the contract.
     * @param _address Nft Pricing Contract address.
     */
    function setNFTPricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        nftPricingAddress = _address;
        nftPricer = IProtocolERC721Pricing(_address);
        emit ERC721PricingAddressSet(_address);
    }

    /**
     * @dev sets the address of the erc20 pricing contract and loads the contract.
     * @param _address ERC20 Pricing Contract address.
     */
    function setERC20PricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress) {
        if (_address == address(0)) revert ZeroAddress();
        erc20PricingAddress = _address;
        erc20Pricer = IProtocolERC20Pricing(_address);
        emit ERC20PricingAddressSet(_address);
    }

    /**
     * @dev Get the account's balance in dollars. It uses the registered tokens in the app manager.
     * @notice This gets the account's balance in dollars.
     * @param _account address to get the balance for
     * @return totalValuation of the account in dollars
     */
    function getAccTotalValuation(address _account, uint256 _nftValuationLimit) public view returns (uint256 totalValuation) {
        address[] memory tokenList = appManager.getTokenList();
        uint256 tokenAmount;
        /// check if _account is zero address. If zero address we return a valuation of zero to allow for burning tokens when rules that need valuations are active.
        if (_account == address(0)) {
            return totalValuation;
        } else {
            /// Loop through all Nfts and ERC20s and add values to balance for account valuation
            for (uint256 i; i < tokenList.length; ) {
                /// First check to see if user owns the asset
                tokenAmount = (IToken(tokenList[i]).balanceOf(_account));
                if (tokenAmount > 0) {
                    try IERC165(tokenList[i]).supportsInterface(0x80ac58cd) returns (bool isERC721) {
                        if (isERC721 && tokenAmount >= _nftValuationLimit) totalValuation += _getNFTCollectionValue(tokenList[i], tokenAmount);
                        else if (isERC721 && tokenAmount < _nftValuationLimit) totalValuation += _getNFTValuePerCollection(tokenList[i], _account, tokenAmount);
                        else {
                            uint8 decimals = ERC20(tokenList[i]).decimals();
                            totalValuation += (_getERC20Price(tokenList[i]) * (tokenAmount)) / (10 ** decimals);
                        }
                    } catch {
                        uint8 decimals = ERC20(tokenList[i]).decimals();
                        totalValuation += (_getERC20Price(tokenList[i]) * (tokenAmount)) / (10 ** decimals);
                    }
                }
                unchecked {
                    ++i;
                }
            }
        }
    }

    /**
     * @dev Get the value for a specific ERC20. This is done by interacting with the pricing module
     * @notice This gets the token's value in dollars.
     * @param _tokenAddress the address of the token
     * @return price the price of 1 in dollars
     */
    function _getERC20Price(address _tokenAddress) internal view returns (uint256) {
        if (erc20PricingAddress != address(0)) {
            return erc20Pricer.getTokenPrice(_tokenAddress);
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }

    /**
     * @dev Get the value for a specific ERC721. This is done by interacting with the pricing module
     * @notice This gets the token's value in dollars.
     * @param _tokenAddress the address of the token
     * @param _account of the token holder
     * @param _tokenAmount amount of NFTs from _tokenAddress contract
     * @return totalValueInThisContract in whole USD
     */
    function _getNFTValuePerCollection(address _tokenAddress, address _account, uint256 _tokenAmount) internal view returns (uint256 totalValueInThisContract) {
        if (nftPricingAddress != address(0)) {
            for (uint i; i < _tokenAmount; ) {
                totalValueInThisContract += nftPricer.getNFTPrice(_tokenAddress, IERC721Enumerable(_tokenAddress).tokenOfOwnerByIndex(_account, i));
                unchecked {
                    ++i;
                }
            }
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }

    /**
     * @dev Get the total value for all tokens held by wallet for specific collection. This is done by interacting with the pricing module
     * @notice This function gets the total token value in dollars of all tokens owned in each collection by address.
     * @param _tokenAddress the address of the token
     * @param _tokenAmount amount of NFTs from _tokenAddress contract
     * @return totalValueInThisContract total valuation of tokens by collection in whole USD
     */
    function _getNFTCollectionValue(address _tokenAddress, uint256 _tokenAmount) private view returns (uint256 totalValueInThisContract) {
        if (nftPricingAddress != address(0)) {
            totalValueInThisContract = _tokenAmount * uint256(nftPricer.getNFTCollectionPrice(_tokenAddress));
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }


    /**
     * @dev Set the accountMaxValueByRiskScoreRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMaxValueByRiskScore(_ruleId);
        accountMaxValueByRiskScoreId = _ruleId;
        accountMaxValueByRiskScoreActive = true;
        emit ApplicationRuleApplied(BALANCE_BY_RISK, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxValueByRiskScoreActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(BALANCE_BY_RISK);
        } else {
            emit ApplicationHandlerDeactivated(BALANCE_BY_RISK);
        }
    }

    /**
     * @dev Tells you if the accountMaxValueByRiskScoreRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxValueByRiskScoreActive() external view returns (bool) {
        return accountMaxValueByRiskScoreActive;
    }

    /**
     * @dev Retrieve the accountMaxValueByRiskScoreRule id
     * @return accountMaxValueByRiskScoreId rule id
     */
    function getAccountMaxValueByRiskScoreId() external view returns (uint32) {
        return accountMaxValueByRiskScoreId;
    }

    /**
     * @dev Set the accountMaxValueByAccessLevelRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxValueByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMaxValueByAccessLevel(_ruleId);
        accountMaxValueByAccessLevelId = _ruleId;
        accountMaxValueByAccessLevelActive = true;
        emit ApplicationRuleApplied(ACC_MAX_VALUE_BY_ACCESS_LEVEL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxValueByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxValueByAccessLevelActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACC_MAX_VALUE_BY_ACCESS_LEVEL);
        } else {
            emit ApplicationHandlerDeactivated(ACC_MAX_VALUE_BY_ACCESS_LEVEL);
        }
    }

    /**
     * @dev Tells you if the accountMaxValueByAccessLevelRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxValueByAccessLevelActive() external view returns (bool) {
        return accountMaxValueByAccessLevelActive;
    }

    /**
     * @dev Retrieve the accountMaxValueByAccessLevel rule id
     * @return accountMaxValueByAccessLevelId rule id
     */
    function getAccountMaxValueByAccessLevelId() external view returns (uint32) {
        return accountMaxValueByAccessLevelId;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountDenyForNoAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        AccountDenyForNoAccessLevelRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACCESS_LEVEL_0);
        } else {
            emit ApplicationHandlerDeactivated(ACCESS_LEVEL_0);
        }
    }

    /**
     * @dev Tells you if the AccountDenyForNoAccessLevel Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountDenyForNoAccessLevelActive() external view returns (bool) {
        return AccountDenyForNoAccessLevelRuleActive;
    }

    /**
     * @dev Set the accountMaxValueOutByAccessLevelRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxValueOutByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMaxValueOutByAccessLevel(_ruleId);
        accountMaxValueOutByAccessLevelId = _ruleId;
        accountMaxValueOutByAccessLevelActive = true;
        emit ApplicationRuleApplied(ACC_MAX_VALUE_OUT_ACCESS_LEVEL, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAccountMaxValueOutByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxValueOutByAccessLevelActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACC_MAX_VALUE_OUT_ACCESS_LEVEL);
        } else {
            emit ApplicationHandlerDeactivated(ACC_MAX_VALUE_OUT_ACCESS_LEVEL);
        }
    }

    /**
     * @dev Tells you if the accountMaxValueOutByAccessLevelRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAccountMaxValueOutByAccessLevelActive() external view returns (bool) {
        return accountMaxValueOutByAccessLevelActive;
    }

    /**
     * @dev Retrieve the accountMaxValueOutByAccessLevelRule rule id
     * @return accountMaxValueOutByAccessLevelId rule id
     */
    function getAccountMaxValueOutByAccessLevelId() external view returns (uint32) {
        return accountMaxValueOutByAccessLevelId;
    }

    /**
     * @dev Retrieve the AccountMaxTransactionValueByRiskScore rule id
     * @return accountMaxTransactionValueByRiskScoreId rule id for specified token
     */
    function getAccountMaxTxValueByRiskScoreId() external view returns (uint32) {
        return accountMaxTransactionValueByRiskScoreId;
    }

    /**
     * @dev Set the AccountMaxTransactionValueByRiskScoreRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAccountMaxTxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAccountMaxTxValueByRiskScore(_ruleId);
        accountMaxTransactionValueByRiskScoreId = _ruleId;
        accountMaxTransactionValueByRiskScoreActive = true;
        emit ApplicationRuleApplied(ACC_MAX_TX_VALUE_BY_RISK_SCORE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */

    function activateAccountMaxTxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        accountMaxTransactionValueByRiskScoreActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ACC_MAX_TX_VALUE_BY_RISK_SCORE);
        } else {
            emit ApplicationHandlerDeactivated(ACC_MAX_TX_VALUE_BY_RISK_SCORE);
        }
    }

    /**
     * @dev Tells you if the accountMaxTransactionValueByRiskScoreRule is active or not.
     * @return boolean representing if the rule is active for specified token
     */
    function isAccountMaxTxValueByRiskScoreActive() external view returns (bool) {
        return accountMaxTransactionValueByRiskScoreActive;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * This function does not use ruleAdministratorOnly modifier, the onlyOwner modifier checks that the caller is the appManager contract. 
     * @notice This function uses the onlyOwner modifier since the appManager contract is calling this function when adding a pause rule or removing the final pause rule of the array. 
     * @param _on boolean representing if a rule must be checked or not.
     */

    function activatePauseRule(bool _on) external onlyOwner {
        pauseRuleActive = _on; 
        if (_on) {
            emit ApplicationHandlerActivated(PAUSE_RULE);
        } else {
            emit ApplicationHandlerDeactivated(PAUSE_RULE);
        }
    }

    /**
     * @dev Tells you if the pause rule check is active or not.
     * @return boolean representing if the rule is active for specified token
     */
    function isPauseRuleActive() external view returns (bool) {
        return pauseRuleActive;
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}

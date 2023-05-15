// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

/**
 * @title Base NFT Handler Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC721 that implements it.
 *      Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.
 * @notice This contract is the interaction point for the application ecosystem to the protocol
 */
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "../economic/ITokenRuleRouter.sol";
import "../application/IAppManager.sol";
import "../economic/AppAdministratorOnly.sol";
import "../pricing/IProtocolERC721Pricing.sol";
import "../pricing/IProtocolERC20Pricing.sol";
import "../application/TokenStorage.sol";
import {ITokenHandlerEvents} from "../interfaces/IEvents.sol";
import "../economic/ruleStorage/RuleCodeData.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ProtocolERC721Handler is Ownable, ITokenHandlerEvents, AppAdministratorOnly {
    /**
     * Functions added so far:
     * minAccountBalance
     * Min Max Balance
     * Oracle
     * Trade Counter
     * Balance By AccessLevel
     */
    address public appManagerAddress;
    address public erc721Address;
    /// RuleIds for implemented tagged rules of the ERC721
    uint32 private minMaxBalanceRuleId;
    uint32 private minBalByDateRuleId;
    uint32 private minAccountRuleId;
    uint32 private oracleRuleId;
    uint32 private tradeCounterRuleId;
    uint32 private transactionLimitByRiskRuleId;
    uint32 private adminWithdrawalRuleId;
    /// on-off switches for rules
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;
    bool private tradeCounterRuleActive;
    bool private transactionLimitByRiskRuleActive;
    bool private minBalByDateRuleActive;
    bool private adminWithdrawalActive;

    /// Trade Counter data
    // map the tokenId of this NFT to the number of trades in the period
    mapping(uint256 => uint256) tradesInPeriod;
    // map the tokenId of this NFT to the last transaction timestamp
    mapping(uint256 => uint64) lastTxDate;

    ITokenRuleRouter ruleRouter;
    IAppManager appManager;
    // Pricing Module interfaces
    IProtocolERC20Pricing erc20Pricer;
    IProtocolERC721Pricing nftPricer;
    address public erc20PricingAddress;
    address public nftPricingAddress;

    error PricingModuleNotConfigured(address _erc20PricingAddress, address nftPricingAddress);
    error CannotTurnOffAccessLevel0WithAccessLevelBalanceActive();

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _tokenRuleRouterAddress Address of token rule router proxy
     * @param _appManagerAddress Address of App Manager
     */
    constructor(address _tokenRuleRouterAddress, address _appManagerAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleRouter = ITokenRuleRouter(_tokenRuleRouterAddress);
        emit ITokenHandlerEvents.HandlerDeployed(address(this), _appManagerAddress);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point to protocol.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param amount number of tokens transferred
     * @param tokenId the token's specific ID
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return Success equals true if all checks pass
     */
    function checkAllRules(
        uint256 balanceFrom,
        uint256 balanceTo,
        address _from,
        address _to,
        uint256 amount,
        uint256 tokenId,
        ApplicationRuleProcessorDiamondLib.ActionTypes _action
    ) external returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromAdmin && !isToAdmin) {
            uint128 balanceValuation;
            uint128 transferValuation;
            if (appManager.areAccessLevelOrRiskRulesActive()) {
                balanceValuation = uint128(getAccTotalValuation(_to));
                transferValuation = uint128(nftPricer.getNFTPrice(msg.sender, tokenId));
            }
            appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
            _checkTaggedRules(balanceFrom, balanceTo, _from, _to, amount, tokenId);
            _checkNonTaggedRules(balanceFrom, balanceTo, _from, _to, amount, tokenId);
        } else {
            if (adminWithdrawalActive && isFromAdmin) ruleRouter.checkAdminWithdrawalRule(adminWithdrawalRuleId, balanceFrom, amount);
        }
        // If everything checks out, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's tokenRuleRouter to perform the actual rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        if (oracleRuleActive) ruleRouter.checkOraclePasses(oracleRuleId, _to);
        _balanceFrom;
        _balanceTo;
        _from;
        _amount;
        if (tradeCounterRuleActive) {
            // get all the tags for this NFT
            bytes32[] memory tags = appManager.getAllTags(erc721Address);
            tradesInPeriod[tokenId] = ruleRouter.checkNFTTransferCounter(tradeCounterRuleId, tradesInPeriod[tokenId], tags, lastTxDate[tokenId]);
            lastTxDate[tokenId] = uint64(block.timestamp);
        }
    }

    /**
     * @dev This function uses the protocol's tokenRuleRouter to perform the actual Individual rule check.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 tokenId) internal view {
        _checkTaggedIndividualRules(_from, _to, _balanceFrom, _balanceTo, _amount);

        if (transactionLimitByRiskRuleActive) {
            /// If more rules need these values, then this can be moved above.
            uint256 currentAssetValuation = getAccTotalValuation(_to);
            uint256 thisNFTValuation = nftPricer.getNFTPrice(msg.sender, tokenId);
            _checkRiskRules(_from, _to, currentAssetValuation, _amount, thisNFTValuation);
        }
    }

    function _checkTaggedIndividualRules(address _from, address _to, uint256 _balanceFrom, uint256 _balanceTo, uint256 _amount) internal view {
        if (minMaxBalanceRuleActive || minBalByDateRuleActive) {
            // We get all tags for sender and recipient
            bytes32[] memory toTags = appManager.getAllTags(_to);
            bytes32[] memory fromTags = appManager.getAllTags(_from);
            if (minMaxBalanceRuleActive) ruleRouter.checkMinMaxAccountBalancePasses(minMaxBalanceRuleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
            if (minBalByDateRuleActive) ruleRouter.checkMinBalByDatePasses(minBalByDateRuleId, _balanceFrom, _amount, fromTags);
        }
    }

    function _checkRiskRules(address _from, address _to, uint256 currentAssetValuation, uint256 _amount, uint256 thisNFTValuation) internal view {
        currentAssetValuation;
        _amount;
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);

        if (transactionLimitByRiskRuleActive) {
            ruleRouter.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreFrom, thisNFTValuation);
            ruleRouter.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreTo, thisNFTValuation);
        }
    }

    /**
     * @dev sets the address of the nft pricing contract and loads the contract.
     * @param _address Nft Pricing Contract address.
     */
    function setNFTPricingAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        nftPricingAddress = _address;
        nftPricer = IProtocolERC721Pricing(_address);
    }

    /**
     * @dev sets the address of the erc20 pricing contract and loads the contract.
     * @param _address ERC20 Pricing Contract address.
     */
    function setERC20PricingAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        erc20PricingAddress = _address;
        erc20Pricer = IProtocolERC20Pricing(_address);
    }

    /**
     * @dev Get the account's balance in dollars. It uses the registered tokens in the app manager.
     * @notice This gets the account's balance in dollars.
     * @param _account address to get the balance for
     * @return totalValuation of the account in dollars
     */
    function getAccTotalValuation(address _account) public view returns (uint256 totalValuation) {
        address[] memory tokenList = appManager.getTokenList();
        uint256 tokenAmount;
        /// Loop through all Nfts and ERC20s and add values to balance
        for (uint256 i; i < tokenList.length; ) {
            /// First check to see if user owns the asset
            tokenAmount = (IToken(tokenList[i]).balanceOf(_account));

            if (tokenAmount > 0) {
                try IERC165(tokenList[i]).supportsInterface(0x80ac58cd) returns (bool isERC721) {
                    if (isERC721) totalValuation += _getNFTValuePerCollection(tokenList[i], _account, tokenAmount);
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

    /**
     * @dev Get the value for a specific ERC20. This is done by interacting with the pricing module
     * @notice This gets the token's value in dollars.
     * @param _tokenAddress the address of the token
     * @return price the price of 1 in dollars
     */
    function _getERC20Price(address _tokenAddress) private view returns (uint256) {
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
    function _getNFTValuePerCollection(address _tokenAddress, address _account, uint256 _tokenAmount) private view returns (uint256 totalValueInThisContract) {
        if (nftPricingAddress != address(0)) {
            for (uint i; i < _tokenAmount; ) {
                totalValueInThisContract += nftPricer.getNFTPrice(_tokenAddress, ERC721Enumerable(_tokenAddress).tokenOfOwnerByIndex(_account, i));
                unchecked {
                    ++i;
                }
            }
        } else {
            revert PricingModuleNotConfigured(erc20PricingAddress, nftPricingAddress);
        }
    }

    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleId = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_MAX_BALANCE_LIMIT, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_MAX_BALANCE_LIMIT, address(this));
        }
    }

    /**
     * Get the minMaxBalanceRuleId.
     * @return minMaxBalance rule id.
     */
    function getMinMaxBalanceRuleId() external view returns (uint32) {
        return minMaxBalanceRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinMaxBalanceActive() external view returns (bool) {
        return minMaxBalanceRuleActive;
    }

    /**
     * @dev Set the oracleRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setOracleRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        oracleRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ORACLE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ORACLE, address(this));
        }
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return oracleRuleId
     */
    function getOracleRuleId() external view returns (uint32) {
        return oracleRuleId;
    }

    /**
     * @dev Tells you if the oracle rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isOracleActive() external view returns (bool) {
        return oracleRuleActive;
    }

    /**
     * @dev Set the tradeCounterRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTradeCounterRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        tradeCounterRuleId = _ruleId;
        tradeCounterRuleActive = true;
        emit ApplicationHandlerApplied(NFT_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTradeCounterRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        tradeCounterRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(NFT_TRANSFER, address(this));
        } else {
            emit ApplicationHandlerDeactivated(NFT_TRANSFER, address(this));
        }
    }

    /**
     * @dev Retrieve the trade counter rule id
     * @return tradeCounterRuleId
     */
    function getTradeCounterRuleId() external view returns (uint32) {
        return tradeCounterRuleId;
    }

    /**
     * @dev Tells you if the tradeCounterRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTradeCounterRuleActive() external view returns (bool) {
        return tradeCounterRuleActive;
    }

    /**
     * @dev Set the parent ERC721 address
     * @param _address address of the ERC721
     */
    function setERC721Address(address _address) external appAdministratorOnly(appManagerAddress) {
        erc721Address = _address;
    }

    /**
     * @dev Retrieve the oracle rule id
     * @return transactionLimitByRiskRuleActive rule id
     */
    function getTransactionLimitByRiskRule() external view returns (uint32) {
        return transactionLimitByRiskRuleId;
    }

    /**
     * @dev Set the accountBalanceByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTransactionLimitByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        transactionLimitByRiskRuleId = _ruleId;
        transactionLimitByRiskRuleActive = true;
        emit ApplicationHandlerApplied(TX_SIZE_BY_RISK, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTransactionLimitByRiskRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        transactionLimitByRiskRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TX_SIZE_BY_RISK, address(this));
        } else {
            emit ApplicationHandlerDeactivated(TX_SIZE_BY_RISK, address(this));
        }
    }

    /**
     * @dev Tells you if the transactionLimitByRiskRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTransactionLimitByRiskActive() external view returns (bool) {
        return transactionLimitByRiskRuleActive;
    }

    /**
     * @dev Retrieve the minimum balance by date rule id
     * @return minBalByDateRuleId rule id
     */
    function getMinBalByDateRule() external view returns (uint32) {
        return minBalByDateRuleId;
    }

    /**
     * @dev Set the minBalByDateRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinBalByDateRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_BALANCE_BY_DATE, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        minBalByDateRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_BALANCE_BY_DATE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_BALANCE_BY_DATE, address(this));
        }
    }

    /**
     * @dev Tells you if the minBalByDateRuleActive is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinBalByDateActive() external view returns (bool) {
        return minBalByDateRuleActive;
    }

    /**
     * @dev Set the accountBalanceByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAdminWithdrawalRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            ruleRouter.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
        }
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        adminWithdrawalRuleId = _ruleId;
        adminWithdrawalActive = true;
        emit ApplicationHandlerApplied(ADMIN_WITHDRAWAL, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminWithdrawalRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            ruleRouter.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
        }
        adminWithdrawalActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ADMIN_WITHDRAWAL, address(this));
        } else {
            emit ApplicationHandlerDeactivated(ADMIN_WITHDRAWAL, address(this));
        }
    }

    /**
     * @dev Tells you if the admin withdrawal rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isAdminWithdrawalActive() external view returns (bool) {
        return adminWithdrawalActive;
    }

    /**
     * @dev Retrieve the admin withdrawal rule id
     * @return adminWithdrawalRuleId rule id
     */
    function getAdminWithdrawalRuleId() external view returns (uint32) {
        return adminWithdrawalRuleId;
    }
}

interface IToken {
    function balanceOf(address owner) external view returns (uint256 balance);
}

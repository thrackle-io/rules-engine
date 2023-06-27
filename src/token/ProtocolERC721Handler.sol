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
import "openzeppelin-contracts/contracts/utils/introspection/IERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../economic/IRuleProcessor.sol";
import "../application/IAppManager.sol";
import "../economic/AppAdministratorOrOwnerOnly.sol";
import "../pricing/IProtocolERC721Pricing.sol";
import "../pricing/IProtocolERC20Pricing.sol";
import "./data/Fees.sol";
import {ITokenHandlerEvents} from "../interfaces/IEvents.sol";
import "../economic/ruleStorage/RuleCodeData.sol";

contract ProtocolERC721Handler is Ownable, ITokenHandlerEvents, AppAdministratorOrOwnerOnly {
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
    uint32 private tokenTransferVolumeRuleId;
    /// on-off switches for rules
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;
    bool private tradeCounterRuleActive;
    bool private transactionLimitByRiskRuleActive;
    bool private minBalByDateRuleActive;
    bool private adminWithdrawalActive;
    bool private tokenTransferVolumeRuleActive;

    /// token level accumulators
    uint256 private transferVolume;
    uint64 private lastTransferTs;
    /// Data contracts
    Fees fees;
    bool feeActive;

    /// Trade Counter data
    // map the tokenId of this NFT to the number of trades in the period
    mapping(uint256 => uint256) tradesInPeriod;
    // map the tokenId of this NFT to the last transaction timestamp
    mapping(uint256 => uint64) lastTxDate;

    IRuleProcessor ruleProcessor;
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
     * @param _ruleProcessorProxyAddress of token rule router proxy
     * @param _appManagerAddress Address of App Manager
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, bool _upgradeMode) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        if (!_upgradeMode) {
            emit HandlerDeployed(address(this), _appManagerAddress);
        } else {
            emit HandlerDeployedForUpgrade(address(this), _appManagerAddress);
        }
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
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, uint256 amount, uint256 tokenId, RuleProcessorDiamondLib.ActionTypes _action) external returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        /// standard tagged and non-tagged rules do not apply when either to or from is an admin
        if (!isFromAdmin && !isToAdmin) {
            uint128 balanceValuation;
            uint128 transferValuation;
            if (appManager.requireValuations()) {
                balanceValuation = uint128(getAccTotalValuation(_to));
                transferValuation = uint128(nftPricer.getNFTPrice(msg.sender, tokenId));
            }
            appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
            _checkTaggedRules(balanceFrom, balanceTo, _from, _to, amount, tokenId);
            _checkNonTaggedRules(balanceFrom, balanceTo, _from, _to, amount, tokenId);
        } else {
            if (adminWithdrawalActive && isFromAdmin) ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, balanceFrom, amount);
        }
        // If everything checks out, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     * @param tokenId the token's specific ID
     */
    function _checkNonTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount, uint256 tokenId) internal {
        if (oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, _to);
        _balanceFrom;
        _balanceTo;
        _from;
        if (tradeCounterRuleActive) {
            // get all the tags for this NFT
            bytes32[] memory tags = appManager.getAllTags(erc721Address);
            tradesInPeriod[tokenId] = ruleProcessor.checkNFTTransferCounter(tradeCounterRuleId, tradesInPeriod[tokenId], tags, lastTxDate[tokenId]);
            lastTxDate[tokenId] = uint64(block.timestamp);
        }
        if (tokenTransferVolumeRuleActive) {
            transferVolume = ruleProcessor.checkTokenTransferVolumePasses(tokenTransferVolumeRuleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
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

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged non-risk rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _amount number of tokens transferred
     */
    function _checkTaggedIndividualRules(address _from, address _to, uint256 _balanceFrom, uint256 _balanceTo, uint256 _amount) internal view {
        if (minMaxBalanceRuleActive || minBalByDateRuleActive) {
            // We get all tags for sender and recipient
            bytes32[] memory toTags = appManager.getAllTags(_to);
            bytes32[] memory fromTags = appManager.getAllTags(_from);
            if (minMaxBalanceRuleActive) ruleProcessor.checkMinMaxAccountBalancePasses(minMaxBalanceRuleId, _balanceFrom, _balanceTo, _amount, toTags, fromTags);
            if (minBalByDateRuleActive) ruleProcessor.checkMinBalByDatePasses(minBalByDateRuleId, _balanceFrom, _amount, fromTags);
        }
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the risk rule checks.(Ones that require risk score values)
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _currentAssetValuation current total valuation of all assets
     * @param _amount number of tokens transferred
     * @param _thisNFTValuation valuation of NFT in question
     */
    function _checkRiskRules(address _from, address _to, uint256 _currentAssetValuation, uint256 _amount, uint256 _thisNFTValuation) internal view {
        _currentAssetValuation;
        _amount;
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);

        if (transactionLimitByRiskRuleActive) {
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreFrom, _thisNFTValuation);
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreTo, _thisNFTValuation);
        }
    }

    /* <><><><><><><><><><><> Fee functions <><><><><><><><><><><><><><> */
    /**
     * @dev This function adds a fee to the token
     * @param _tag meta data tag for fee
     * @param _minBalance minimum balance for fee application
     * @param _maxBalance maximum balance for fee application
     * @param _feePercentage fee percentage to assess
     * @param _targetAccount target for the fee proceeds
     */
    function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount) external appAdministratorOrOwnerOnly(appManagerAddress) {
        fees.addFee(_tag, _minBalance, _maxBalance, _feePercentage, _targetAccount);
        feeActive = true;
    }

    /**
     * @dev This function adds a fee to the token
     * @param _tag meta data tag for fee
     */
    function removeFee(bytes32 _tag) external appAdministratorOrOwnerOnly(appManagerAddress) {
        fees.removeFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @param _tag meta data tag for fee
     * @return fee struct containing fee data
     */
    function getFee(bytes32 _tag) external view returns (Fees.Fee memory) {
        return fees.getFee(_tag);
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeTotal total number of fees
     */
    function getFeeTotal() public view returns (uint256) {
        return fees.getFeeTotal();
    }

    /**
     * @dev Turn fees on/off
     * @param on_off value for fee status
     */
    function setFeeActivation(bool on_off) external appAdministratorOrOwnerOnly(appManagerAddress) {
        feeActive = on_off;
    }

    /**
     * @dev returns the full mapping of fees
     * @return feeActive fee activation status
     */
    function isFeeActive() external view returns (bool) {
        return feeActive;
    }

    /**
     * @dev Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
     * different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.
     * @param _from originating address
     * @param _balanceFrom Token balance of the sender address
     * @return feeCollectorAccounts list of where the fees are sent
     * @return feePercentages list of all applicable fees/discounts
     */
    function getApplicableFees(address _from, uint256 _balanceFrom) public view returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages) {
        Fees.Fee memory fee;
        bytes32[] memory _fromTags = appManager.getAllTags(_from);
        if (_fromTags.length != 0 && !appManager.isAppAdministrator(_from)) {
            uint feeCount;
            uint24 discount;
            uint discountCount;
            // size the dynamic arrays by maximum possible fees
            feeCollectorAccounts = new address[](_fromTags.length);
            feePercentages = new int24[](_fromTags.length);
            /// loop through and accumulate the fee percentages based on tags
            for (uint i; i < _fromTags.length; ) {
                fee = fees.getFee(_fromTags[i]);
                // fee must be active and the initiating account must have an acceptable balance
                if (fee.isValue && _balanceFrom < fee.maxBalance && _balanceFrom > fee.minBalance) {
                    // if it's a discount, accumulate it for distribution among all applicable fees
                    if (fee.feePercentage < 0) {
                        discount = uint24((fee.feePercentage * -1)) + discount; // convert to uint
                        discountCount += 1;
                    } else {
                        feePercentages[feeCount] = fee.feePercentage;
                        feeCollectorAccounts[feeCount] = fee.feeCollectorAccount;
                        unchecked {
                            ++feeCount;
                        }
                    }
                }
                unchecked {
                    ++i;
                }
            }
            /// if an applicable discount(s) was found, then distribute it among all the fees
            if (discount > 0 && feeCount != 0) {
                // if there are fees to discount then do so
                if (feeCount > 0) {
                    uint24 discountSlice = ((discount * 100) / (uint24(feeCount))) / 100;
                    for (uint i; i < feeCount; ) {
                        // if discount is greater than fee, then set to zero
                        if (int24(discountSlice) > feePercentages[i]) {
                            feePercentages[i] = 0;
                        } else {
                            feePercentages[i] -= int24(discountSlice);
                        }
                        unchecked {
                            ++i;
                        }
                    }
                }
            }
        }
        return (feeCollectorAccounts, feePercentages);
    }

    /**
     * @dev sets the address of the nft pricing contract and loads the contract.
     * @param _address Nft Pricing Contract address.
     */
    function setNFTPricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
        nftPricingAddress = _address;
        nftPricer = IProtocolERC721Pricing(_address);
    }

    /**
     * @dev sets the address of the erc20 pricing contract and loads the contract.
     * @param _address ERC20 Pricing Contract address.
     */
    function setERC20PricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minMaxBalanceRuleId = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
    function setOracleRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
    function setTradeCounterRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tradeCounterRuleId = _ruleId;
        tradeCounterRuleActive = true;
        emit ApplicationHandlerApplied(NFT_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTradeCounterRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
    function setERC721Address(address _address) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
     * @dev Set the TransactionLimitByRiskRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTransactionLimitByRiskRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        transactionLimitByRiskRuleId = _ruleId;
        transactionLimitByRiskRuleActive = true;
        emit ApplicationHandlerApplied(TX_SIZE_BY_RISK, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTransactionLimitByRiskRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
    function setMinBalByDateRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_BALANCE_BY_DATE, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
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
     * @dev Set the AdminWithdrawalRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAdminWithdrawalRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
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
    function activateAdminWithdrawalRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1);
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

    /**
     * @dev Retrieve the token transfer volume rule id
     * @return tokenTransferVolumeRuleId rule id
     */
    function getTokenTransferVolumeRule() external view returns (uint32) {
        return tokenTransferVolumeRuleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTokenTransferVolumeRuleId(uint32 _ruleId) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tokenTransferVolumeRuleId = _ruleId;
        tokenTransferVolumeRuleActive = true;
        emit ApplicationHandlerApplied(TRANSFER_VOLUME, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(bool _on) external appAdministratorOrOwnerOnly(appManagerAddress) {
        tokenTransferVolumeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TRANSFER_VOLUME, address(this));
        } else {
            emit ApplicationHandlerDeactivated(TRANSFER_VOLUME, address(this));
        }
    }

    /// -------------DATA CONTRACT DEPLOYMENT---------------
    /**
     * @dev Deploy all the child data contracts. Only called internally from the constructor.
     */
    function deployDataContract() private {
        fees = new Fees();
    }

    /**
     * @dev Getter for the fee rules data contract address
     * @return feesDataAddress
     */
    function getFeesDataAddress() external view returns (address) {
        return address(fees);
    }

    /**
     * @dev This function is used to migrate the data contracts to a new CoinHandler. Use with care because it changes ownership. They will no
     * longer be accessible from the original CoinHandler
     * @param _newOwner address of the new CoinHandler
     */
    function migrateDataContracts(address _newOwner) external appAdministratorOrOwnerOnly(appManagerAddress) {
        fees.transferOwnership(_newOwner);
        /// Also transfer ownership of this contract to the new asset
        transferPermissionOwnership(_newOwner, appManagerAddress);
    }

    /**
     * @dev This function is used to connect data contracts from an old CoinHandler to the current CoinHandler.
     * @param _oldHandlerAddress address of the old CoinHandler
     */
    function connectDataContracts(address _oldHandlerAddress) external appAdministratorOrOwnerOnly(appManagerAddress) {
        ProtocolERC721Handler oldHandler = ProtocolERC721Handler(_oldHandlerAddress);
        fees = Fees(oldHandler.getFeesDataAddress());
    }
}

interface IToken {
    function balanceOf(address owner) external view returns (uint256 balance);

    function totalSupply() external view returns (uint256);
}

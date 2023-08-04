// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

import "./data/Fees.sol";
import {IZeroAddressError, IAssetHandlerErrors} from "src/interfaces/IErrors.sol";
import "./ProtocolHandlerCommon.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

/**
 * @title Example ApplicationERC20Handler Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all rule checks related to the the ERC20 that implements it.
 * @notice Any rules may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.
 */
contract ProtocolERC20Handler is Ownable, ProtocolHandlerCommon, AppAdministratorOnly, IAdminWithdrawalRuleCapable, ERC165 {
    using ERC165Checker for address;
    /**
     * Functions added so far:
     * minTransfer
     * balanceLimits
     * oracle
     * Balance by AccessLevel
     * Balance Limit by Risk
     * Transaction Limit by Risk
     * AccessLevel Account balance
     * Risk Score Transaction Limit
     * Risk Score Account Balance Limit
     */
    string private riskScoreTokenId;

    /// Data contracts
    Fees fees;
    bool feeActive;

    /// RuleIds
    uint32 private minTransferRuleId;
    uint32 private oracleRuleId;
    uint32 private minMaxBalanceRuleId;
    uint32 private transactionLimitByRiskRuleId;
    uint32 private adminWithdrawalRuleId;
    uint32 private minBalByDateRuleId;
    uint32 private tokenTransferVolumeRuleId;
    uint32 private totalSupplyVolatilityRuleId;

    /// on-off switches for rules
    bool private minTransferRuleActive;
    bool private oracleRuleActive;
    bool private minMaxBalanceRuleActive;
    bool private transactionLimitByRiskRuleActive;
    bool private adminWithdrawalActive;
    bool private minBalByDateRuleActive;
    bool private tokenTransferVolumeRuleActive;
    bool private totalSupplyVolatilityRuleActive;

    /// token level accumulators
    uint256 private transferVolume;
    uint64 private lastTransferTs;
    uint64 private lastSupplyUpdateTime;
    int256 private volumeTotalForPeriod;
    uint256 private totalSupplyForPeriod;

    /**
     * @dev Constructor sets params
     * @param _ruleProcessorProxyAddress of the protocol's Rule Processor contract.
     * @param _appManagerAddress address of the application AppManager.
     * @param _assetAddress address of the controlling asset.
     * @param _upgradeMode specifies whether this is a fresh CoinHandler or an upgrade replacement.
     */
    constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode) {
        if (_appManagerAddress == address(0) || _ruleProcessorProxyAddress == address(0) || _assetAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        ruleProcessor = IRuleProcessor(_ruleProcessorProxyAddress);
        transferOwnership(_assetAddress);
        // register the supported interface, IAdminWithdrawalRuleCapable, ERC165
        // _registerInterface(type(IAdminWithdrawalRuleCapable).interfaceId);
        // _registerInterface(type(IAdminWithdrawalRuleCapable).interfaceId);
        if (!_upgradeMode) {
            deployDataContract();
            emit HandlerDeployed(address(this), _appManagerAddress);
        } else {
            emit HandlerDeployedForUpgrade(address(this), _appManagerAddress);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return interfaceId == type(IAdminWithdrawalRuleCapable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev This function is the one called from the contract that implements this handler. It's the entry point.
     * @param balanceFrom token balance of sender address
     * @param balanceTo token balance of recipient address
     * @param _from sender address
     * @param _to recipient address
     * @param amount number of tokens transferred
     * @param _action Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)
     * @return true if all checks pass
     */
    function checkAllRules(uint256 balanceFrom, uint256 balanceTo, address _from, address _to, uint256 amount, ActionTypes _action) external onlyOwner returns (bool) {
        bool isFromAdmin = appManager.isAppAdministrator(_from);
        bool isToAdmin = appManager.isAppAdministrator(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard rules do not apply when either to or from is an admin
            if (!isFromAdmin && !isToAdmin) {
                uint128 balanceValuation;
                uint128 price;
                uint128 transferValuation;
                if (appManager.requireValuations()) {
                    balanceValuation = uint128(getAccTotalValuation(_to, 0));
                    price = uint128(_getERC20Price(msg.sender));
                    transferValuation = uint128((price * amount) / (10 ** IToken(msg.sender).decimals()));
                }
                appManager.checkApplicationRules(_action, _from, _to, balanceValuation, transferValuation);
                _checkTaggedRules(balanceFrom, balanceTo, _from, _to, amount);
                _checkNonTaggedRules(balanceFrom, balanceTo, _from, _to, amount);
            } else {
                if (adminWithdrawalActive && isFromAdmin) ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, balanceFrom, amount);
            }
        }
        /// If everything checks out, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkNonTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount) internal {
        if (minTransferRuleActive) ruleProcessor.checkMinTransferPasses(minTransferRuleId, _amount);
        if (oracleRuleActive) ruleProcessor.checkOraclePasses(oracleRuleId, _to);
        if (tokenTransferVolumeRuleActive) {
            transferVolume = ruleProcessor.checkTokenTransferVolumePasses(tokenTransferVolumeRuleId, transferVolume, IToken(msg.sender).totalSupply(), _amount, lastTransferTs);
            lastTransferTs = uint64(block.timestamp);
        }
        /// rule requires ruleID and either to or from address be zero address (mint/burn)
        if (totalSupplyVolatilityRuleActive && (_from == address(0x00) || _to == address(0x00))) {
            (volumeTotalForPeriod, totalSupplyForPeriod) = ruleProcessor.checkTotalSupplyVolatilityPasses(
                totalSupplyVolatilityRuleId,
                volumeTotalForPeriod,
                totalSupplyForPeriod,
                IToken(msg.sender).totalSupply(),
                _to == address(0x00) ? int(_amount) * -1 : int(_amount),
                lastSupplyUpdateTime
            );
            lastSupplyUpdateTime = uint64(block.timestamp);
        }
        //added the following lines to remove warnings TODO remove later
        _balanceFrom;
        _balanceTo;
        _from;
    }

    /**
     * @dev This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
    function _checkTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount) internal view {
        _checkTaggedIndividualRules(_from, _to, _balanceFrom, _balanceTo, _amount);
        /// we only ask for price if we need it since this might cause the contract to require setting the pricing contracts when there is no need
        if (transactionLimitByRiskRuleActive) {
            uint256 balanceValuation = getAccTotalValuation(_to, 0);
            uint256 price = _getERC20Price(msg.sender);
            uint256 transferValuation = (price * _amount) / (10 ** IToken(msg.sender).decimals());
            _checkRiskRules(_from, _to, balanceValuation, transferValuation, _amount, price);
        }
    }

    /**
     * @dev This function consolidates all the tagged rules that utilize account tags.
     * @param _balanceFrom token balance of sender address
     * @param _balanceTo token balance of recipient address
     * @param _from address of the from account
     * @param _to address of the to account
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
     * @dev This function consolidates all the Risk rules that utilize tagged account Risk scores.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _balanceValuation address current balance in USD
     * @param _transferValuation valuation of all tokens owned by the address in USD
     * @param _amount number of tokens to be transferred
     */
    function _checkRiskRules(address _from, address _to, uint256 _balanceValuation, uint256 _transferValuation, uint256 _amount, uint256 _price) internal view {
        _balanceValuation; // this is to get rid of compiler warnings...these variables will be used in the future.
        _amount;
        _price;
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (transactionLimitByRiskRuleActive) {
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreFrom, _transferValuation);
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreTo, _transferValuation);
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
        emit FeeActivationSet(on_off);
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

    /// Rule Setters and Getters
    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinMaxAccountBalance(_ruleId);
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
     * @dev Set the minTransferRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinTransferRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinTransfer(_ruleId);
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, address(this), _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransfereRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        minTransferRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_TRANSFER, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_TRANSFER, address(this));
        }
    }

    /**
     * @dev Retrieve the minTransferRuleId
     * @return minTransferRuleId
     */
    function getMinTransferRuleId() external view returns (uint32) {
        return minTransferRuleId;
    }

    /**
     * @dev Tells you if the MinMaxBalanceRule is active or not.
     * @return boolean representing if the rule is active
     */
    function isMinTransferActive() external view returns (bool) {
        return minTransferRuleActive;
    }

    /**
     * @dev Set the oracleRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setOracleRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateOracle(_ruleId);
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
     * @dev Tells you if the Oracle Rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isOracleActive() external view returns (bool) {
        return oracleRuleActive;
    }

    /**
     * @dev Retrieve the transaction limit by risk rule id
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
    function setTransactionLimitByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTransactionLimitByRiskScore(_ruleId);
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
     * @dev Set the AdminWithdrawalRule. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setAdminWithdrawalRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAdminWithdrawal(_ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        adminWithdrawalRuleId = _ruleId;
        adminWithdrawalActive = true;
        emit ApplicationHandlerApplied(ADMIN_WITHDRAWAL, address(this), _ruleId);
    }

    /**
     * @dev This function is used by the app manager to determine if the AdminWithdrawal rule is active
     * @return Success equals true if all checks pass
     */
    function isAdminWithdrawalActiveAndApplicable() public view override returns (bool) {
        bool active;
        if (adminWithdrawalActive) {
            try ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, 1, 1) {} catch {
                active = true;
            }
        }
        return active;
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateAdminWithdrawalRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
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
        ruleProcessor.validateMinBalByDate(_ruleId);
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_ACCT_BAL_BY_DATE, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        minBalByDateRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_ACCT_BAL_BY_DATE, address(this));
        } else {
            emit ApplicationHandlerDeactivated(MIN_ACCT_BAL_BY_DATE, address(this));
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
    function setTokenTransferVolumeRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTokenTransferVolume(_ruleId);
        tokenTransferVolumeRuleId = _ruleId;
        tokenTransferVolumeRuleActive = true;
        emit ApplicationHandlerApplied(TRANSFER_VOLUME, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        tokenTransferVolumeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TRANSFER_VOLUME, address(this));
        } else {
            emit ApplicationHandlerDeactivated(TRANSFER_VOLUME, address(this));
        }
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @return boolean representing if the rule is active
     */
    function isTokenTransferVolumeActive() external view returns (bool) {
        return tokenTransferVolumeRuleActive;
    }

    /**
     * @dev Retrieve the total supply volatility rule id
     * @return totalSupplyVolatilityRuleId rule id
     */
    function getTotalSupplyVolatilityRule() external view returns (uint32) {
        return totalSupplyVolatilityRuleId;
    }

    /**
     * @dev Set the tokenTransferVolumeRuleId. Restricted to game admins only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setTotalSupplyVolatilityRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateSupplyVolatility(_ruleId);
        totalSupplyVolatilityRuleId = _ruleId;
        totalSupplyVolatilityRuleActive = true;
        emit ApplicationHandlerApplied(SUPPLY_VOLATILITY, address(this), _ruleId);
    }

    /**
     * @dev Tells you if the token total Supply Volatility rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTotalSupplyVolatilityRule(bool _on) external appAdministratorOnly(appManagerAddress) {
        totalSupplyVolatilityRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SUPPLY_VOLATILITY, address(this));
        } else {
            emit ApplicationHandlerDeactivated(SUPPLY_VOLATILITY, address(this));
        }
    }

    /**
     * @dev Tells you if the Total Supply Volatility is active or not.
     * @return boolean representing if the rule is active
     */
    function isTotalSupplyVolatilityActive() external view returns (bool) {
        return totalSupplyVolatilityRuleActive;
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
     * @dev This function is used to propose the new owner for data contracts.
     * @param _newOwner address of the new AppManager
     */
    function proposeDataContractMigration(address _newOwner) external appAdministratorOnly(appManagerAddress) {
        fees.proposeOwner(_newOwner);
    }

    /**
     * @dev This function is used to confirm this contract as the new owner for data contracts.
     */
    function confirmDataContractMigration(address _oldHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        ProtocolERC20Handler oldHandler = ProtocolERC20Handler(_oldHandlerAddress);
        fees = Fees(oldHandler.getFeesDataAddress());
        fees.confirmOwner();
    }

    // /**
    //  * @dev This function is used to connect data contracts from an old CoinHandler to the current CoinHandler.
    //  * @param _oldHandlerAddress address of the old CoinHandler
    //  */
    // function connectDataContracts(address _oldHandlerAddress) external appAdministratorOnly(appManagerAddress) {
    //     ProtocolERC20Handler oldHandler = ProtocolERC20Handler(_oldHandlerAddress);
    //     fees = Fees(oldHandler.getFeesDataAddress());
    // }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/// TODO Create a wizard that creates custom versions of this contract for each implementation.

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {IZeroAddressError, IAssetHandlerErrors} from "src/common/IErrors.sol";
import "../ProtocolHandlerCommon.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "src/client/token/data/Fees.sol";
import "src/client/token/ProtocolHandlerCommon.sol";

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
     * MinMaxbalance
     * oracle
     * Balance by AccessLevel
     * Balance Limit by Risk
     * Transaction Limit by Risk
     * AccessLevel Account balance
     * Risk Score Transaction Limit
     * Risk Score Account Balance Limit
     */
    string private riskScoreTokenId;
   
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
        if (!_upgradeMode) {
            deployDataContract();
            emit HandlerDeployed(_appManagerAddress);
        } else {
            emit HandlerDeployed(_appManagerAddress);
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
        bool isFromBypassAccount = appManager.isRuleBypassAccount(_from);
        bool isToBypassAccount = appManager.isRuleBypassAccount(_to);
        // // All transfers to treasury account are allowed
        if (!appManager.isTreasury(_to)) {
            /// standard rules do not apply when either to or from is an admin
            if (!isFromBypassAccount && !isToBypassAccount) {
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
                _checkNonTaggedRules(_from, _to, amount);
            } else {
                if (adminWithdrawalActive && isFromBypassAccount) ruleProcessor.checkAdminWithdrawalRule(adminWithdrawalRuleId, balanceFrom, amount);
                emit RulesBypassedViaRuleBypassAccount(address(msg.sender), appManagerAddress); 
            }
        }
         /// If all rule checks pass, return true
        return true;
    }

    /**
     * @dev This function uses the protocol's ruleProcessorto perform the actual  rule checks.
     * @param _from address of the from account
     * @param _to address of the to account
     * @param _amount number of tokens transferred
     */
     function _checkNonTaggedRules(address _from, address _to, uint256 _amount) internal {
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
            uint256 price = _getERC20Price(msg.sender);
            uint256 transferValuation = (price * _amount) / (10 ** IToken(msg.sender).decimals());
            _checkRiskRules(_from, _to, transferValuation);
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
     * @param _transferValuation valuation of all tokens owned by the address in USD
     */
     function _checkRiskRules(address _from, address _to, uint256 _transferValuation) internal view {
        uint8 riskScoreTo = appManager.getRiskScore(_to);
        uint8 riskScoreFrom = appManager.getRiskScore(_from);
        if (transactionLimitByRiskRuleActive) {
            ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreFrom, _transferValuation);
            if (_to != address(0)) {
                ruleProcessor.checkTransactionLimitByRiskScore(transactionLimitByRiskRuleId, riskScoreTo, _transferValuation);
            }
        }
    }

    /// Rule Setters and Getters
    /**
     * @dev Set the minMaxBalanceRuleId. Restricted to app administrators only.
     * @notice that setting a rule will automatically activate it.
     * @param _ruleId Rule Id to set
     */
    function setMinMaxBalanceRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinMaxAccountBalance(_ruleId);
        minMaxBalanceRuleId = _ruleId;
        minMaxBalanceRuleActive = true;
        emit ApplicationHandlerApplied(MIN_MAX_BALANCE_LIMIT, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minMaxBalanceRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_MAX_BALANCE_LIMIT);
        } else {
            emit ApplicationHandlerDeactivated(MIN_MAX_BALANCE_LIMIT);
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
    function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinTransfer(_ruleId);
        minTransferRuleId = _ruleId;
        minTransferRuleActive = true;
        emit ApplicationHandlerApplied(MIN_TRANSFER, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateMinTransfereRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minTransferRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_TRANSFER);
        } else {
            emit ApplicationHandlerDeactivated(MIN_TRANSFER);
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
    function setOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateOracle(_ruleId);
        oracleRuleId = _ruleId;
        oracleRuleActive = true;
        emit ApplicationHandlerApplied(ORACLE, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        oracleRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ORACLE);
        } else {
            emit ApplicationHandlerDeactivated(ORACLE);
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
    function setTransactionLimitByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTransactionLimitByRiskScore(_ruleId);
        transactionLimitByRiskRuleId = _ruleId;
        transactionLimitByRiskRuleActive = true;
        emit ApplicationHandlerApplied(TX_SIZE_BY_RISK, _ruleId);
    }

    /**
     * @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
     * @param _on boolean representing if a rule must be checked or not.
     */
    function activateTransactionLimitByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        transactionLimitByRiskRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TX_SIZE_BY_RISK);
        } else {
            emit ApplicationHandlerDeactivated(TX_SIZE_BY_RISK);
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
    function setAdminWithdrawalRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateAdminWithdrawal(_ruleId);
        /// if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
        if (adminWithdrawalActive) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        /// after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.
        adminWithdrawalRuleId = _ruleId;
        adminWithdrawalActive = true;
        emit ApplicationHandlerApplied(ADMIN_WITHDRAWAL, _ruleId);
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
    function activateAdminWithdrawalRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        /// if the rule is currently active, we check that time for current ruleId is expired
        if (!_on) {
            if (isAdminWithdrawalActiveAndApplicable()) revert AdminWithdrawalRuleisActive();
        }
        adminWithdrawalActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(ADMIN_WITHDRAWAL);
        } else {
            emit ApplicationHandlerDeactivated(ADMIN_WITHDRAWAL);
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
    function setMinBalByDateRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateMinBalByDate(_ruleId);
        minBalByDateRuleId = _ruleId;
        minBalByDateRuleActive = true;
        emit ApplicationHandlerApplied(MIN_ACCT_BAL_BY_DATE, _ruleId);
    }

    /**
     * @dev Tells you if the min bal by date rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateMinBalByDateRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        minBalByDateRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(MIN_ACCT_BAL_BY_DATE);
        } else {
            emit ApplicationHandlerDeactivated(MIN_ACCT_BAL_BY_DATE);
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
    function setTokenTransferVolumeRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateTokenTransferVolume(_ruleId);
        tokenTransferVolumeRuleId = _ruleId;
        tokenTransferVolumeRuleActive = true;
        emit ApplicationHandlerApplied(TRANSFER_VOLUME, _ruleId);
    }

    /**
     * @dev Tells you if the token transfer volume rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTokenTransferVolumeRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        tokenTransferVolumeRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(TRANSFER_VOLUME);
        } else {
            emit ApplicationHandlerDeactivated(TRANSFER_VOLUME);
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
    function setTotalSupplyVolatilityRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress) {
        ruleProcessor.validateSupplyVolatility(_ruleId);
        totalSupplyVolatilityRuleId = _ruleId;
        totalSupplyVolatilityRuleActive = true;
        emit ApplicationHandlerApplied(SUPPLY_VOLATILITY, _ruleId);
    }

    /**
     * @dev Tells you if the token total Supply Volatility rule is active or not.
     * @param _on boolean representing if the rule is active
     */
    function activateTotalSupplyVolatilityRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
        totalSupplyVolatilityRuleActive = _on;
        if (_on) {
            emit ApplicationHandlerActivated(SUPPLY_VOLATILITY);
        } else {
            emit ApplicationHandlerDeactivated(SUPPLY_VOLATILITY);
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
}

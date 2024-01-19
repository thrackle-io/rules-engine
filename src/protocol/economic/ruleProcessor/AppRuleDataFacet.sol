// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RuleProcessorDiamondImports.sol";
import "../RuleAdministratorOnly.sol";
import {AppRuleDataFacet} from "./AppRuleDataFacet.sol";


/**
 * @title App Rules Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Setters and getters for Application level Rules
 * @notice This contract sets and gets the App Rules for the protocol
 */

contract AppRuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors, IAppRuleInputErrors, IRiskInputErrors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8; 
    uint8 constant MAX_ACCESSLEVELS = 5;
    uint8 constant MAX_RISKSCORE = 99;

    //*********************** AccessLevel Rules ********************************************** */
    /**
     * @dev Function add a AccessLevel Balance rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _balanceAmounts Balance restrictions for each 5 levels from level 0 to 4 in whole USD.
     * @notice that position within the array matters. Posotion 0 represents access levellevel 0,
     * and position 4 represents level 4.
     * @return position of new rule in array
     */
    function addAccessLevelBalanceRule(address _appManagerAddr, uint48[] calldata _balanceAmounts) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        RuleS.AccessLevelRuleS storage data = Storage.accessStorage();
        uint32 index = data.accessRuleIndex;
        if (_balanceAmounts.length != MAX_ACCESSLEVELS) revert BalanceAmountsShouldHave5Levels(uint8(_balanceAmounts.length));
        for (uint i = 1; i < _balanceAmounts.length; ) {
            if (_balanceAmounts[i] < _balanceAmounts[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint8 i; i < _balanceAmounts.length; ) {
            data.accessRulesPerToken[index][i] = _balanceAmounts[i];
            unchecked {
                ++i;
            }
        }
        ++data.accessRuleIndex;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(BALANCE_BY_ACCESSLEVEL, index, empty);
        return index;
    }

    /**
     * @dev Function add a Accessc Level Withdrawal rule
     * @dev Function has ruleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _withdrawalAmounts withdrawal amaount restrictions for each 5 levels from level 0 to 4 in whole USD.
     * @notice that position within the array matters. Posotion 0 represents access levellevel 0,
     * and position 4 represents level 4.
     * @return position of new rule in array
     */
    function addAccessLevelWithdrawalRule(address _appManagerAddr, uint48[] calldata _withdrawalAmounts) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        RuleS.AccessLevelWithrawalRuleS storage data = Storage.accessLevelWithdrawalRuleStorage();
        uint32 index = data.accessLevelWithdrawalRuleIndex;
        ///validation block
        if (_withdrawalAmounts.length != MAX_ACCESSLEVELS) revert WithdrawalAmountsShouldHave5Levels(uint8(_withdrawalAmounts.length));
        for (uint i = 1; i < _withdrawalAmounts.length; ) {
            if (_withdrawalAmounts[i] < _withdrawalAmounts[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint8 i; i < _withdrawalAmounts.length; ) {
            data.accessLevelWithdrawal[index][i] = _withdrawalAmounts[i];
            unchecked {
                ++i;
            }
        }
        ++data.accessLevelWithdrawalRuleIndex;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(ACCESS_LEVEL_WITHDRAWAL, index, empty);
        return index;
    }

    //***********************  Risk Rules  ******************************* */

    //***********************  Max Tx Size Per Period By Risk Rule  ******************************* */
    /**
     * @dev Function add a Max Tx Size Per Period By Risk rule
     * @dev Function has ruleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _maxSize array of max-tx-size allowed within period (whole USD max values --no cents)
     * Each value in the array represents max USD value transacted within _period, and its positions
     * indicate what range of risk levels it applies to. A value of 1000 here means $1000.00 USD.
     * @param _riskLevel array of risk-level ceilings that define each range. Risk levels are inclusive.
     * @param _period amount of hours that each period lasts for. 0 if no period is desired.
     * @param _startTimestamp start timestamp for the rule
     * @return position of new rule in array
     * @notice _maxSize size must be equal to _riskLevel.
     * This means that the positioning of the arrays is ascendant in terms of risk levels,
     * and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function addMaxTxSizePerPeriodByRiskRule(
        address _appManagerAddr,
        uint48[] calldata _maxSize,
        uint8[] calldata _riskLevel,
        uint16 _period,
        uint64 _startTimestamp
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        /// Validation block
        if (_maxSize.length != _riskLevel.length) revert InputArraysSizesNotValid();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_maxSize.length == 0) revert InvalidRuleInput();
        if (_riskLevel[_riskLevel.length - 1] > MAX_RISKSCORE) revert RiskLevelCannotExceed99();
        for (uint256 i = 1; i < _riskLevel.length; ) {
            if (_riskLevel[i] <= _riskLevel[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 1; i < _maxSize.length; ) {
            if (_maxSize[i] > _maxSize[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        _startTimestamp.validateTimestamp();
        /// We create the rule now
        RuleS.TxSizePerPeriodToRiskRuleS storage data = Storage.txSizePerPeriodToRiskStorage();
        uint32 ruleId = data.txSizePerPeriodToRiskRuleIndex;
        ApplicationRuleStorage.TxSizePerPeriodToRiskRule memory rule = ApplicationRuleStorage.TxSizePerPeriodToRiskRule(_maxSize, _riskLevel, _period, _startTimestamp);
        data.txSizePerPeriodToRiskRule[ruleId] = rule;
        ++data.txSizePerPeriodToRiskRuleIndex;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(MAX_TX_PER_PERIOD, ruleId, empty);
        return ruleId;
    }

    /**
     * @dev Function to add new AccountBalanceByRiskScore Rules
     * @dev Function has ruleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _riskScores User Risk Level Array
     * @param _balanceLimits Account Balance Limit in whole USD for each score range. It corresponds to the _riskScores
     * array and is +1 longer than _riskScores. A value of 1000 in this arrays will be interpreted as $1000.00 USD.
     * @return position of new rule in array
     * @notice _balanceLimits size must be equal to _riskLevel.
     * The positioning of the arrays is ascendant in terms of risk levels,
     * and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     * eg.
     * risk scores      balances         resultant logic
     * -----------      --------         ---------------
     *                                   0-24  =   NO LIMIT 
     *    25              500            25-49 =   500
     *    50              250            50-74 =   250
     *    75              100            75-99 =   100
     */
    function addAccountBalanceByRiskScore(address _appManagerAddr, uint8[] calldata _riskScores, uint48[] calldata _balanceLimits) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_balanceLimits.length != _riskScores.length) revert InputArraysSizesNotValid();
        // since the arrays are compared, it is only necessary to check for one of them being empty.
        if (_balanceLimits.length == 0) revert InvalidRuleInput();
        if (_riskScores[_riskScores.length - 1] > MAX_RISKSCORE) revert RiskLevelCannotExceed99();
        for (uint i = 1; i < _riskScores.length; ) {
            if (_riskScores[i] <= _riskScores[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint i = 1; i < _balanceLimits.length; ) {
            if (_balanceLimits[i] > _balanceLimits[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        return _addAccountBalanceByRiskScore(_riskScores, _balanceLimits);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _riskScores Account Risk Level
     * @param _balanceLimits Account Balance Limit for each Score in USD (no cents). It corresponds to the _riskScores array.
     * A value of 1000 in this arrays will be interpreted as $1000.00 USD.
     * @return position of new rule in array
     */
    function _addAccountBalanceByRiskScore(uint8[] calldata _riskScores, uint48[] calldata _balanceLimits) internal returns (uint32) {
        RuleS.AccountBalanceToRiskRuleS storage data = Storage.accountBalanceToRiskStorage();
        uint32 ruleId = data.balanceToRiskRuleIndex;
        ApplicationRuleStorage.AccountBalanceToRiskRule memory rule = ApplicationRuleStorage.AccountBalanceToRiskRule(_riskScores, _balanceLimits);
        data.balanceToRiskRule[ruleId] = rule;
        ++data.balanceToRiskRuleIndex;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(BALANCE_BY_RISK, ruleId, empty);
        return ruleId;
    }

}

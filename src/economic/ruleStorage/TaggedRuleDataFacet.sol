// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {ITaggedRules as TaggedRules} from "./RuleDataInterfaces.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {IEconomicEvents} from "../../interfaces/IEvents.sol";
import {IInputErrors, IRiskInputErrors, ITagInputErrors, ITagRuleInputErrors, IZeroAddressError} from "../../interfaces/IErrors.sol";
import "./RuleCodeData.sol";
import "../RuleAdministratorOnly.sol";
import "./RuleStorageCommonLib.sol";

/**
 * @title Tagged Rule Data Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev setters and getters for Tagged token specific rules
 * @notice This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.
 */
contract TaggedRuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors, IRiskInputErrors, ITagInputErrors, ITagRuleInputErrors, IZeroAddressError {
    using RuleStorageCommonLib for uint64;
    using RuleStorageCommonLib for uint32;

    /**
     * Note that no update method is implemented. Since reutilization of
     * rules is encouraged, it is preferred to add an extra rule to the
     * set instead of modifying an existing one.
     */

    /********************** Purchase Getters/Setters ***********************/
    /**
     * @dev Function add a Token Purchase Percentage rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _purchaseAmounts Allowed total purchase limits
     * @param _purchasePeriods Hours purhchases allowed
     * @param _startTimes timestamp period to start
     * @return position of new rule in array
     */
    function addPurchaseRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _purchaseAmounts,
        uint16[] calldata _purchasePeriods,
        uint64[] calldata _startTimes
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_accountTypes.length != _purchaseAmounts.length || _accountTypes.length != _purchasePeriods.length || _accountTypes.length != _startTimes.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        return _addPurchaseRule(_accountTypes, _purchaseAmounts, _purchasePeriods, _startTimes);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _purchaseAmounts Allowed total purchase limits
     * @param _purchasePeriods Hours purhchases allowed
     * @param _startTimes timestamps for first period to start
     * @return position of new rule in array
     */
    function _addPurchaseRule(bytes32[] calldata _accountTypes, uint256[] calldata _purchaseAmounts, uint16[] calldata _purchasePeriods, uint64[] calldata _startTimes) internal returns (uint32) {
        RuleS.PurchaseRuleS storage data = Storage.purchaseStorage();
        uint32 index = data.purchaseRulesIndex;
        for (uint256 i; i < _accountTypes.length; ) {
            if (_accountTypes[i] == bytes32("")) revert BlankTag();
            if (_purchaseAmounts[i] == 0 || _purchasePeriods[i] == 0 || _startTimes[i] == 0) revert ZeroValueNotPermited();
            _startTimes[i].validateTimestamp();
            data.purchaseRulesPerUser[index][_accountTypes[i]] = TaggedRules.PurchaseRule(_purchaseAmounts[i], _purchasePeriods[i], _startTimes[i]);

            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(PURCHASE_LIMIT, index, _accountTypes);
        ++data.purchaseRulesIndex;
        return index;
    }

    /**
     * @dev Function get the purchase rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of account
     * @return PurchaseRule rule at index position
     */
    function getPurchaseRule(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.PurchaseRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalPurchaseRule());
        RuleS.PurchaseRuleS storage data = Storage.purchaseStorage();
        if (_index >= data.purchaseRulesIndex) revert IndexOutOfRange();
        return data.purchaseRulesPerUser[_index][_accountType];
    }

    /**
     * @dev Function to get total purchase rules
     * @return Total length of array
     */
    function getTotalPurchaseRule() public view returns (uint32) {
        RuleS.PurchaseRuleS storage data = Storage.purchaseStorage();
        return data.purchaseRulesIndex;
    }

    /********************** Sell Getters/Setters **********************/

    /**
     * @dev Function to add set of sell rules
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _sellAmounts Allowed total sell limits
     * @param _sellPeriod Period for sales
     * @param _startTimes rule starts
     * @return position of new rule in array
     */
    function addSellRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint192[] calldata _sellAmounts,
        uint16[] calldata _sellPeriod,
        uint64[] calldata _startTimes
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _sellAmounts.length || _accountTypes.length != _sellPeriod.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        return _addSellRule(_accountTypes, _sellAmounts, _sellPeriod, _startTimes);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _sellAmounts Allowed total sell limits
     * @param _sellPeriod Period for sales
     * @param _startTimes rule starts
     * @return position of new rule in array
     */
    function _addSellRule(bytes32[] calldata _accountTypes, uint192[] calldata _sellAmounts, uint16[] calldata _sellPeriod, uint64[] calldata _startTimes) internal returns (uint32) {
        RuleS.SellRuleS storage data = Storage.sellStorage();
        uint32 index = data.sellRulesIndex;
        for (uint256 i; i < _accountTypes.length; ) {
            if (_accountTypes[i] == bytes32("")) revert BlankTag();
            if (_sellAmounts[i] == 0 || _sellPeriod[i] == 0) revert ZeroValueNotPermited();
            _startTimes[i].validateTimestamp();
            data.sellRulesPerUser[index][_accountTypes[i]] = TaggedRules.SellRule(_sellAmounts[i], _sellPeriod[i], _startTimes[i]);
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(SELL_LIMIT, index, _accountTypes);
        ++data.sellRulesIndex;
        return index;
    }

    /**
     * @dev Function to get Sell rule at index
     * @param _index Position of rule in array
     * @param _accountType Types of Accounts
     * @return SellRule at position in array
     */
    function getSellRuleByIndex(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.SellRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalSellRule());
        RuleS.SellRuleS storage data = Storage.sellStorage();
        if (_index >= data.sellRulesIndex) revert IndexOutOfRange();
        return data.sellRulesPerUser[_index][_accountType];
    }

    /**
     * @dev Function to get total Sell rules
     * @return Total length of array
     */
    function getTotalSellRule() public view returns (uint32) {
        RuleS.SellRuleS storage data = Storage.sellStorage();
        return data.sellRulesIndex;
    }

    /********************** Balance Limit Getters/Setters ***********************/

    /**
     * @dev Function adds Balance Limit Rule
     * @param _appManagerAddr App Manager Address
     * @param _accountTypes Types of Accounts
     * @param _minimum Minimum Balance allowed for tagged accounts
     * @param _maximum Maximum Balance allowed for tagged accounts
     * @return _addBalanceLimitRules which returns location of rule in array
     */
    function addBalanceLimitRules(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _minimum,
        uint256[] calldata _maximum
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _minimum.length || _accountTypes.length != _maximum.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        return _addBalanceLimitRules(_accountTypes, _minimum, _maximum);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _minimum Minimum Balance allowed for tagged accounts
     * @param _maximum Maximum Balance allowed for tagged accounts
     * @return position of new rule in array
     */
    function _addBalanceLimitRules(bytes32[] calldata _accountTypes, uint256[] calldata _minimum, uint256[] calldata _maximum) internal returns (uint32) {
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        uint32 index = data.balanceLimitRuleIndex;
        for (uint256 i; i < _accountTypes.length; ) {
            if (_accountTypes[i] == bytes32("")) revert BlankTag();
            if (_minimum[i] == 0 || _maximum[i] == 0) revert ZeroValueNotPermited();
            if (_minimum[i] > _maximum[i]) revert InvertedLimits();
            TaggedRules.BalanceLimitRule memory rule = TaggedRules.BalanceLimitRule(_minimum[i], _maximum[i]);
            data.balanceLimitsPerAccountType[index][_accountTypes[i]] = rule;
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(MIN_MAX_BALANCE_LIMIT, index, _accountTypes);
        ++data.balanceLimitRuleIndex;
        return index;
    }

    /**
     * @dev Function get the purchase rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountType Type of Accounts
     * @return BalanceLimitRule at index location in array
     */
    function getBalanceLimitRule(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.BalanceLimitRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalBalanceLimitRules());
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        if (_index >= data.balanceLimitRuleIndex) revert IndexOutOfRange();
        return data.balanceLimitsPerAccountType[_index][_accountType];
    }

    /**
     * @dev Function gets total Balance Limit rules
     * @return Total length of array
     */
    function getTotalBalanceLimitRules() public view returns (uint32) {
        RuleS.BalanceLimitRuleS storage data = Storage.balanceLimitStorage();
        return data.balanceLimitRuleIndex;
    }

    /************ Account Withdrawal Getters/Setters ***********/
    /**
     * @dev Function adds Withdrawal Rule
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _amount Transaction total
     * @param _releaseDate Date of release
     * @return _addWithdrawalRule which returns position of new rule in array
     */
    function addWithdrawalRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _amount,
        uint256[] calldata _releaseDate
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _amount.length || _accountTypes.length != _releaseDate.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        return _addWithdrawalRule(_accountTypes, _amount, _releaseDate);
    }

    /**
     * @dev Internal function to avoid stack-too-deep error
     * @param _accountTypes Types of Accounts
     * @param _amount Transaction total
     * @param _releaseDate Date of release
     * @return position of new rule in array
     */
    function _addWithdrawalRule(bytes32[] calldata _accountTypes, uint256[] calldata _amount, uint256[] calldata _releaseDate) internal returns (uint32) {
        RuleS.WithdrawalRuleS storage data = Storage.withdrawalStorage();
        uint32 index = data.withdrawalRulesIndex;
        for (uint256 i; i < _accountTypes.length; ) {
            if (_accountTypes[i] == bytes32("")) revert BlankTag();
            if (_amount[i] == 0) revert ZeroValueNotPermited();
            if (_releaseDate[i] <= block.timestamp) revert DateInThePast(_releaseDate[i]);
            TaggedRules.WithdrawalRule memory rule = TaggedRules.WithdrawalRule(_amount[i], _releaseDate[i]);
            data.withdrawalRulesPerToken[index][_accountTypes[i]] = rule;
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(WITHDRAWAL, index, _accountTypes);
        ++data.withdrawalRulesIndex;
        return index;
    }

    /**
     * @dev Function gets withdrawal rule at index
     * @param _index position of rule in array
     * @param _accountType Type of Account
     * @return WithdrawalRule rule at indexed postion
     */
    function getWithdrawalRule(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.WithdrawalRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalWithdrawalRule());
        RuleS.WithdrawalRuleS storage data = Storage.withdrawalStorage();
        if (_index >= data.withdrawalRulesIndex) revert IndexOutOfRange();
        return data.withdrawalRulesPerToken[_index][_accountType];
    }

    /**
     * @dev Function to get total withdrawal rules
     * @return withdrawalRulesIndex total length of array
     */
    function getTotalWithdrawalRule() public view returns (uint32) {
        RuleS.WithdrawalRuleS storage data = Storage.withdrawalStorage();
        return data.withdrawalRulesIndex;
    }

    /************ Admin Account Withdrawal Getters/Setters ***********/

    /**
     * @dev Function adds Withdrawal Rule for admins
     * @param _appManagerAddr Address of App Manager
     * @param _amount Transaction total
     * @param _releaseDate Date of release
     * @return adminWithdrawalRulesPerToken position of new rule in array
     */
    function addAdminWithdrawalRule(address _appManagerAddr, uint256 _amount, uint256 _releaseDate) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        if (_amount == 0) revert ZeroValueNotPermited();
        if (_releaseDate <= block.timestamp) revert DateInThePast(_releaseDate);
        uint32 index = data.adminWithdrawalRulesIndex;
        TaggedRules.AdminWithdrawalRule memory rule = TaggedRules.AdminWithdrawalRule(_amount, _releaseDate);
        data.adminWithdrawalRulesPerToken[index] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(ADMIN_WITHDRAWAL, index, empty);
        ++data.adminWithdrawalRulesIndex;
        return index;
    }

    /**
     * @dev Function gets Admin withdrawal rule at index
     * @param _index position of rule in array
     * @return adminWithdrawalRulesPerToken rule at indexed postion
     */
    function getAdminWithdrawalRule(uint32 _index) external view returns (TaggedRules.AdminWithdrawalRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalAdminWithdrawalRules());
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        if (_index >= data.adminWithdrawalRulesIndex) revert IndexOutOfRange();
        return data.adminWithdrawalRulesPerToken[_index];
    }

    /**
     * @dev Function to get total Admin withdrawal rules
     * @return adminWithdrawalRulesPerToken total length of array
     */
    function getTotalAdminWithdrawalRules() public view returns (uint32) {
        RuleS.AdminWithdrawalRuleS storage data = Storage.adminWithdrawalStorage();
        return data.adminWithdrawalRulesIndex;
    }

    //***********************  Risk Rules  ******************************* */
    /**
     * @dev Function to add new TransactionLimitByRiskScore Rules
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _riskScores User Risk Level Array which defines the limits between ranges. The levels are inclusive as ceilings.
     * @param _txnLimits Transaction Limit in whole USD for each score range. It corresponds to the _riskScores array and is +1 longer than _riskScores.
     * A value of 1000 in this arrays will be interpreted as $1000.00 USD.
     * @return position of new rule in array
     * @notice _maxSize size must be equal to _riskLevel + 1 since the _maxSize must
     * specify the maximum tx size for anything between the highest risk score and 100
     * which should be specified in the last position of the _riskLevel. This also
     * means that the positioning of the arrays is ascendant in terms of risk levels, and
     * descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
     * will apply to all risk scores of 100.)
     */
    function addTransactionLimitByRiskScore(address _appManagerAddr, uint8[] calldata _riskScores, uint48[] calldata _txnLimits) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_riskScores.length == 0 || _txnLimits.length == 0) revert InvalidRuleInput();
        if (_txnLimits.length != _riskScores.length + 1) revert InputArraysSizesNotValid();
        if (_riskScores[_riskScores.length - 1] > 99) revert RiskLevelCannotExceed99();
        for (uint i = 1; i < _riskScores.length; ) {
            if (_riskScores[i] <= _riskScores[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        for (uint i = 1; i < _txnLimits.length; ) {
            if (_txnLimits[i] > _txnLimits[i - 1]) revert WrongArrayOrder();
            unchecked {
                ++i;
            }
        }
        return _addTransactionLimitByRiskScore(_riskScores, _txnLimits);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _riskScores Account Risk Level
     * @param _txnLimits Transaction Limit for each Score. It corresponds to the _riskScores array
     * @return position of new rule in array
     */
    function _addTransactionLimitByRiskScore(uint8[] calldata _riskScores, uint48[] calldata _txnLimits) internal returns (uint32) {
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        uint32 index = data.txSizeToRiskRuleIndex;
        TaggedRules.TransactionSizeToRiskRule memory rule = TaggedRules.TransactionSizeToRiskRule(_riskScores, _txnLimits);
        data.txSizeToRiskRule[index] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TX_SIZE_BY_RISK, index, empty);
        ++data.txSizeToRiskRuleIndex;
        return index;
    }

    /**
     * @dev Function to get the TransactionLimit in the rule set that belongs to an risk score
     * @param _index position of rule in array
     * @return balanceAmount balance allowed for access levellevel
     */
    function getTransactionLimitByRiskRule(uint32 _index) external view returns (TaggedRules.TransactionSizeToRiskRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTransactionLimitByRiskRules());
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        if (_index >= data.txSizeToRiskRuleIndex) revert IndexOutOfRange();
        return data.txSizeToRiskRule[_index];
    }

    /**
     * @dev Function to get total Transaction Limit by Risk Score rules
     * @return Total length of array
     */
    function getTotalTransactionLimitByRiskRules() public view returns (uint32) {
        RuleS.TxSizeToRiskRuleS storage data = Storage.txSizeToRiskStorage();
        return data.txSizeToRiskRuleIndex;
    }

    /********************** Minimum Account Balance By Date Getters/Setters ***********************/
    /**
     * @dev Function add a Minimum Account Balance By Date rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _accountTags Types of Accounts
     * @param _holdAmounts Allowed total purchase limits
     * @param _holdPeriods Hours purchases allowed
     * @param _startTimestamps Timestamp that the check should start
     * @return ruleId of new rule in array
     */
    function addMinBalByDateRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTags,
        uint256[] calldata _holdAmounts,
        uint16[] calldata _holdPeriods,
        uint64[] calldata _startTimestamps
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTags.length != _holdAmounts.length || _accountTags.length != _holdPeriods.length || _accountTags.length != _startTimestamps.length) revert InputArraysMustHaveSameLength();
        // since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTags.length == 0) revert InvalidRuleInput();
        return _addMinBalByDateRule(_accountTags, _holdAmounts, _holdPeriods, _startTimestamps);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _accountTags Types of Accounts
     * @param _holdAmounts Allowed total purchase limits
     * @param _holdPeriods Hours purhchases allowed
     * @param _startTimestamps Timestamp that the check should start
     * @return ruleId of new rule in array
     */
    function _addMinBalByDateRule(bytes32[] calldata _accountTags, uint256[] calldata _holdAmounts, uint16[] calldata _holdPeriods, uint64[] memory _startTimestamps) internal returns (uint32) {
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        uint32 index = data.minBalByDateRulesIndex;
        /// if defaults sent for timestamp, start them with current block time
        for (uint256 i; i < _startTimestamps.length; ) {
            if (_startTimestamps[i] == 0) _startTimestamps[i] = uint64(block.timestamp);
            unchecked {
                ++i;
            }
        }
        for (uint256 i; i < _accountTags.length; ) {
            if (_accountTags[i] == bytes32("")) revert BlankTag();
            if (_holdAmounts[i] == 0 || _holdPeriods[i] == 0) revert ZeroValueNotPermited();
            data.minBalByDateRulesPerUser[index][_accountTags[i]] = TaggedRules.MinBalByDateRule(_holdAmounts[i], _holdPeriods[i], _startTimestamps[i]);
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(MIN_ACCT_BAL_BY_DATE, index, _accountTags);
        ++data.minBalByDateRulesIndex;
        return index;
    }

    /**
     * @dev Function get the minimum balance by date rule in the rule set that belongs to an account type
     * @param _index position of rule in array
     * @param _accountTag Tag of account
     * @return PurchaseRule rule at index position
     */
    function getMinBalByDateRule(uint32 _index, bytes32 _accountTag) external view returns (TaggedRules.MinBalByDateRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalMinBalByDateRule());
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        if (_index >= data.minBalByDateRulesIndex) revert IndexOutOfRange();
        return data.minBalByDateRulesPerUser[_index][_accountTag];
    }

    /**
     * @dev Function to get total minimum balance by date rules
     * @return Total length of array
     */
    function getTotalMinBalByDateRule() public view returns (uint32) {
        RuleS.MinBalByDateRuleS storage data = Storage.minBalByDateRuleStorage();
        return data.minBalByDateRulesIndex;
    }
}

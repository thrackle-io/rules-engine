// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "src/protocol/economic/ruleProcessor/RuleProcessorDiamondImports.sol";
import "src/protocol/economic/RuleAdministratorOnly.sol";

/**
 * @title Tagged Rule Data Facet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev setters and getters for Tagged token specific rules
 * @notice This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.
 */
contract TaggedRuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors, ITagInputErrors, ITagRuleInputErrors, IZeroAddressError {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    using RuleProcessorCommonLib for uint8;
    using RuleProcessorCommonLib for bytes32[];

    /********************** Account Max Trade Size ***********************/
    /**
     * @dev Function add an Account Max Trade Size rule
     * @dev Function has RuleAdministratorOnly Modifier and takes AppManager Address Param
     * @param _appManagerAddr Address of App Manager
     * @param _accountTypes Types of Accounts
     * @param _maxSizes Allowed total purchase limits
     * @param _periods Hours purhchases allowed
     * @param _startTime timestamp period to start
     * @return position of new rule in array
     */
    function addAccountMaxTradeSize(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint240[] calldata _maxSizes,
        uint16[] calldata _periods,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_accountTypes.length != _maxSizes.length || _accountTypes.length != _periods.length) revert InputArraysMustHaveSameLength();
        /// since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        _accountTypes.validateTags();
        return _addAccountMaxTradeSize(_accountTypes, _maxSizes, _periods, _startTime);
    }

    /**
     * @dev Internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _maxSizes Allowed total buy sizes
     * @param _periods Amount of hours that define the periods
     * @param _startTime timestamp for first period to start
     * @return position of new rule in array
     */
    function _addAccountMaxTradeSize(bytes32[] calldata _accountTypes, uint240[] calldata _maxSizes, uint16[] calldata _periods, uint64 _startTime) internal returns (uint32) {
        RuleS.AccountMaxTradeSizeS storage data = Storage.accountMaxTradeSizeStorage();
        uint32 index = data.accountMaxTradeSizeIndex;
        _startTime.validateTimestamp();
        for (uint256 i; i < _accountTypes.length; ++i) {
            if (_periods[i] == 0 || _maxSizes[0] == 0) revert ZeroValueNotPermited();
            data.accountMaxTradeSizeRules[index][_accountTypes[i]] = TaggedRules.AccountMaxTradeSize(_maxSizes[i], _periods[i]);
        }
        data.startTimes[index] = _startTime;
        emit AD1467_ProtocolRuleCreated(ACCOUNT_MAX_TRADE_SIZE, index, _accountTypes);
        ++data.accountMaxTradeSizeIndex;
        return index;
    }

    /********************** Account Min Max Token Balance ***********************/

    /**
     * @dev Function adds Account Min Max Token Balance Rule
     * @param _appManagerAddr App Manager Address
     * @param _accountTypes Types of Accounts
     * @param _min Minimum Balance allowed for tagged accounts
     * @param _max Maximum Balance allowed for tagged accounts
     * @param _periods Amount of hours that define the periods
     * @param _startTime Timestamp that the check should start
     * @return _addAccountMinMaxTokenBalance which returns location of rule in array
     */
    function addAccountMinMaxTokenBalance(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _min,
        uint256[] calldata _max,
        uint16[] calldata _periods,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_accountTypes.length != _min.length || _accountTypes.length != _max.length || (_periods.length > 0 && _accountTypes.length != _periods.length)) revert InputArraysMustHaveSameLength();
        /// since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.
        if (_accountTypes.length == 0) revert InvalidRuleInput();
        _accountTypes.validateTags();
        return _addAccountMinMaxTokenBalance(_accountTypes, _min, _max, _periods, _startTime);
    }

    /**
     * @dev Internal Function to avoid stack too deep error
     * @param _accountTypes Types of Accounts
     * @param _min Minimum Balance allowed for tagged accounts
     * @param _max Maximum Balance allowed for tagged accounts
     * @param _periods Amount of hours that define the periods
     * @param _startTime Timestamp that the check should start
     * @return position of new rule in array
     */
    function _addAccountMinMaxTokenBalance(
        bytes32[] calldata _accountTypes,
        uint256[] calldata _min,
        uint256[] calldata _max,
        uint16[] calldata _periods,
        uint64 _startTime
    ) internal returns (uint32) {
        RuleS.AccountMinMaxTokenBalanceS storage data = Storage.accountMinMaxTokenBalanceStorage();
        uint32 index = data.accountMinMaxTokenBalanceIndex;
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if (_startTime == 0) _startTime = uint64(block.timestamp);
        for (uint256 i; i < _accountTypes.length; ++i) {
            if (_min[i] > _max[i]) revert InvertedLimits();
            if (_periods.length > 0 && _periods[i] == 0) revert CantMixPeriodicAndNonPeriodic();
            data.accountMinMaxTokenBalanceRules[index][_accountTypes[i]] = TaggedRules.AccountMinMaxTokenBalance(_min[i], _max[i], _periods.length == 0 ? 0 : _periods[i]);
        }
        data.startTimes[index] = _startTime;
        emit AD1467_ProtocolRuleCreated(ACCOUNT_MIN_MAX_TOKEN_BALANCE, index, _accountTypes);
        ++data.accountMinMaxTokenBalanceIndex;
        return index;
    }

    /************ Token Max Daily Trades ***********/
    /**
     * @dev Function adds Token Max Daily Trades Rule
     * @param _appManagerAddr App Manager Address
     * @param _nftTags Tags of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @param _startTime starting timestamp for the rule
     * @return _nftTransferCounterRules which returns location of rule in array
     */
    function addTokenMaxDailyTrades(
        address _appManagerAddr,
        bytes32[] calldata _nftTags,
        uint8[] calldata _tradesAllowed,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_nftTags.length == 0 || _startTime == 0) revert ZeroValueNotPermited();
        if (_nftTags.length != _tradesAllowed.length) revert InputArraysMustHaveSameLength();
        _startTime.validateTimestamp();
        _nftTags.validateTags();
        return _addTokenMaxDailyTrades(_nftTags, _tradesAllowed, _startTime);
    }

    /**
     * @dev Internal Function to avoid stack too deep error
     * @param _nftTags Tags of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @param _startTime starting timestamp for the rule
     * @return position of new rule in array
     */
    function _addTokenMaxDailyTrades(bytes32[] calldata _nftTags, uint8[] calldata _tradesAllowed, uint64 _startTime) internal returns (uint32) {
        RuleS.TokenMaxDailyTradesS storage data = Storage.TokenMaxDailyTradesStorage();
        uint32 index = data.tokenMaxDailyTradesIndex;
        for (uint256 i; i < _nftTags.length; ++i) {
            TaggedRules.TokenMaxDailyTrades memory rule = TaggedRules.TokenMaxDailyTrades(_tradesAllowed[i], _startTime);
            data.tokenMaxDailyTradesRules[index][_nftTags[i]] = rule;
        }
        emit AD1467_ProtocolRuleCreated(TOKEN_MAX_DAILY_TRADES, index, _nftTags);
        ++data.tokenMaxDailyTradesIndex;
        return index;
    }
}

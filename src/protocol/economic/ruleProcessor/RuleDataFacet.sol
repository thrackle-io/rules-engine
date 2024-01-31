// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "../RuleAdministratorOnly.sol";
import "../AppAdministratorOnly.sol";
import "./RuleProcessorDiamondImports.sol";

/**
 * @title RuleDataFacet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev setters and getters for non tagged token specific rules
 * @notice This contract sets and gets the Rules for the protocol
 */
contract RuleDataFacet is Context, RuleAdministratorOnly, IEconomicEvents, IInputErrors, ITagInputErrors, IZeroAddressError, IAppRuleInputErrors {
    using RuleProcessorCommonLib for uint64;
    using RuleProcessorCommonLib for uint32;
    uint16 constant MAX_TOKEN_PERCENTAGE = 9999;
    uint16 constant MAX_PERCENTAGE = 10000;
    uint24 constant MAX_VOLUME_PERCENTAGE = 100000;

    /**
     * Note that no update method is implemented for rules. Since reutilization of
     * rules is encouraged, it is preferred to add an extra rule to the
     * set instead of modifying an existing one.
     */


    /**
     * @dev Function to add a Token Max Buy Volume rule
     * @param _appManagerAddr Address of App Manager
     * @param _supplyPercentage Percentage of Tokens allowed to purchase
     * @param _period Time period that transactions are accumulated (in hours)
     * @param _totalSupply total supply of tokens (0 if using total supply from the token contract)
     * @param _startTime start timestamp for the rule
     * @return ruleId position of new rule in array
     */
    function addTokenMaxBuyVolume(
        address _appManagerAddr,
        uint16 _supplyPercentage,
        uint16 _period,
        uint256 _totalSupply,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_supplyPercentage > MAX_TOKEN_PERCENTAGE) revert ValueOutOfRange(_supplyPercentage);
        if (_period == 0 || _supplyPercentage == 0) revert ZeroValueNotPermited();
        _startTime.validateTimestamp();
        RuleS.TokenMaxBuyVolumeS storage data = Storage.accountMaxBuyVolumeStorage();
        NonTaggedRules.TokenMaxBuyVolume memory rule = NonTaggedRules.TokenMaxBuyVolume(_supplyPercentage, _period, _totalSupply, _startTime);
        uint32 ruleId = data.tokenMaxBuyVolumeIndex;
        data.tokenMaxBuyVolumeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_MAX_BUY_VOLUME, ruleId, empty);
        ++data.tokenMaxBuyVolumeIndex;
        return ruleId;
    }

    /**
     * @dev Function to add a Token Max Sell Volume rule
     * @param _appManagerAddr Address of App Manager
     * @param _supplyPercentage Percent of Tokens allowed to sell
     * @param _period Time period that transactions are frozen
     * @param _totalSupply total supply of tokens (0 if using total supply from the token contract)
     * @param _startTime start time for the period
     * @return ruleId position of new rule in array
     */
    function addTokenMaxSellVolume(
        address _appManagerAddr,
        uint16 _supplyPercentage,
        uint16 _period,
        uint256 _totalSupply,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_supplyPercentage > MAX_TOKEN_PERCENTAGE) revert ValueOutOfRange(_supplyPercentage);
        if (_period == 0 || _supplyPercentage == 0) revert ZeroValueNotPermited();
        _startTime.validateTimestamp();
        RuleS.TokenMaxSellVolumeS storage data = Storage.accountMaxSellVolumeStorage();
        uint32 ruleId = data.tokenMaxSellVolumeIndex;
        NonTaggedRules.TokenMaxSellVolume memory rule = NonTaggedRules.TokenMaxSellVolume(_supplyPercentage, _period, _totalSupply, _startTime);
        data.tokenMaxSellVolumeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_MAX_SELL_VOLUME, ruleId, empty);
        ++data.tokenMaxSellVolumeIndex;
        return ruleId;
    }

    /**
     * @dev Function to add a Token Purchase Fee By Volume rule
     * @param _appManagerAddr Address of App Manager
     * @param _volume Maximum allowed volume
     * @param _rateIncreased Amount rate increased
     * @return ruleId position of new rule in array
     */
    function addPurchaseFeeByVolumeRule(address _appManagerAddr, uint256 _volume, uint16 _rateIncreased) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_volume == 0 || _rateIncreased == 0) revert ZeroValueNotPermited();
        if (_rateIncreased > MAX_PERCENTAGE) revert ValueOutOfRange(_rateIncreased);
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = NonTaggedRules.TokenPurchaseFeeByVolume(_volume, _rateIncreased);
        uint32 ruleId = data.purchaseFeeByVolumeRuleIndex;
        data.purchaseFeeByVolumeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(BUY_FEE_BY_VOLUME, ruleId, empty);
        ++data.purchaseFeeByVolumeRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token PurchaseFeeByVolume Rule by index
     * @param _index position of rule in array
     * @return TokenPurchaseFeeByVolume rule at index position
     */
    function getPurchaseFeeByVolumeRule(uint32 _index) external view returns (NonTaggedRules.TokenPurchaseFeeByVolume memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTokenPurchaseFeeByVolumeRules());
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        return data.purchaseFeeByVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Purchase Percentage
     * @return Total length of array
     */
    function getTotalTokenPurchaseFeeByVolumeRules() public view returns (uint32) {
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        return data.purchaseFeeByVolumeRuleIndex;
    }

    /**
     * @dev Function to add a Token Max Price Volatility rule
     * @param _appManagerAddr Address of App Manager
     * @param _max Maximum allowed volume
     * @param _period period in hours for the rule
     * @param _hoursFrozen freeze period hours
     * @return ruleId position of new rule in array
     */
    function addTokenMaxPriceVolatility(
        address _appManagerAddr,
        uint16 _max,
        uint16 _period,
        uint16 _hoursFrozen,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_max == 0 || _period == 0 || _hoursFrozen == 0) revert ZeroValueNotPermited();
        RuleS.TokenMaxPriceVolatilityS storage data = Storage.tokenMaxPriceVolatilityStorage();
        NonTaggedRules.TokenMaxPriceVolatility memory rule = NonTaggedRules.TokenMaxPriceVolatility(_max, _period, _hoursFrozen, _totalSupply);
        uint32 ruleId = data.tokenMaxPriceVolatilityIndex;
        data.tokenMaxPriceVolatilityRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_VOLATILITY, ruleId, empty);
        ++data.tokenMaxPriceVolatilityIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token Volatility Rule by index
     * @param _index position of rule in array
     * @return tokenMaxPriceVolatilityRules rule at index position
     */
    function getTokenMaxPriceVolatility(uint32 _index) external view returns (NonTaggedRules.TokenMaxPriceVolatility memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalTokenMaxPriceVolatility());
        RuleS.TokenMaxPriceVolatilityS storage data = Storage.tokenMaxPriceVolatilityStorage();
        return data.tokenMaxPriceVolatilityRules[_index];
    }

    /**
     * @dev Function to get total Volatility rules
     * @return Total length of array
     */
    function getTotalTokenMaxPriceVolatility() public view returns (uint32) {
        RuleS.TokenMaxPriceVolatilityS storage data = Storage.tokenMaxPriceVolatilityStorage();
        return data.tokenMaxPriceVolatilityIndex;
    }

    /**
     * @dev Function to add a Token max trading Volume rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxPercentage Maximum allowed volume percentage (this is 4 digits to allow 2 decimal places)
     * @param _hoursPerPeriod hours that define a period
     * @param _startTime Timestamp to start the rule
     * @param _totalSupply Circulating supply value to use in calculations. If not specified, defaults to ERC20 totalSupply
     * @return ruleId position of new rule in array
     */
    function addTokenMaxTradingVolume(
        address _appManagerAddr,
        uint24 _maxPercentage,
        uint16 _hoursPerPeriod,
        uint64 _startTime,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_maxPercentage > MAX_VOLUME_PERCENTAGE) revert ValueOutOfRange(_maxPercentage);
        if (_maxPercentage == 0 || _hoursPerPeriod == 0) revert ZeroValueNotPermited();
        _startTime.validateTimestamp();
        RuleS.TokenMaxTradingVolumeS storage data = Storage.tokenMaxTradingVolumeStorage();
        NonTaggedRules.TokenMaxTradingVolume memory rule = NonTaggedRules.TokenMaxTradingVolume(_maxPercentage, _hoursPerPeriod, _startTime, _totalSupply);
        uint32 ruleId = data.tokenMaxTradingVolumeIndex;
        data.tokenMaxTradingVolumeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_MAX_TRADING_VOLUME, ruleId, empty);
        ++data.tokenMaxTradingVolumeIndex;
        return ruleId;
    }

    /**
     * @dev Function to add Token Min Tx Size rules
     * @param _appManagerAddr Address of App Manager
     * @param _minSize Mimimum amount of tokens required for transfer
     * @return ruleId position of new rule in array
     */
    function addTokenMinTxSize(address _appManagerAddr, uint256 _minSize) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_minSize == 0) revert ZeroValueNotPermited();
        RuleS.TokenMinTxSizeS storage data = Storage.tokenMinTxSizePosition();
        NonTaggedRules.TokenMinTxSize memory rule = NonTaggedRules.TokenMinTxSize(_minSize);
        uint32 ruleId = data.tokenMinTxSizeIndex;
        data.tokenMinTxSizeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_MIN_TX_SIZE, ruleId, empty);
        ++data.tokenMinTxSizeIndex;
        return ruleId;
    }


    /**
     * @dev Function Token Max Supply Volatility rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxPercentage Maximum amount of change allowed. This is not capped and will allow for values greater than 100%.
     * Since there is no cap for _maxPercentage this could allow burning of full totalSupply() if over 100% (10000).
     * @param _period Allowed hours per period
     * @param _startTime Unix timestamp for the _period to start counting.
     * @param _totalSupply this is an optional parameter. If 0, the toalSupply will be calculated dyamically. If not zero, this is  
     * going to be the locked value to calculate the rule 
     * @return ruleId position of new rule in array
     */
    function addTokenMaxSupplyVolatility(
        address _appManagerAddr,
        uint16 _maxPercentage,
        uint16 _period,
        uint64 _startTime,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxPercentage == 0 || _period == 0) revert ZeroValueNotPermited();
        _startTime.validateTimestamp();
        RuleS.TokenMaxSupplyVolatilityS storage data = Storage.tokenMaxSupplyVolatilityStorage();
        NonTaggedRules.TokenMaxSupplyVolatility memory rule = NonTaggedRules.TokenMaxSupplyVolatility(_maxPercentage, _period, _startTime, _totalSupply);
        uint32 ruleId = data.tokenMaxSupplyVolatilityIndex;
        data.tokenMaxSupplyVolatilityRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_MAX_SUPPLY_VOLATILITY, ruleId, empty);
        ++data.tokenMaxSupplyVolatilityIndex;
        return ruleId;
    }

    /**
     * @dev Function add an Account Approve/Deny Oracle rule
     * @param _appManagerAddr Address of App Manager
     * @param _type type of Oracle Rule --> 0 = restricted; 1 = allowed
     * @param _oracleAddress Address of Oracle
     * @return ruleId position of rule in storage
     */
    function addAccountApproveDenyOracle(address _appManagerAddr, uint8 _type, address _oracleAddress) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_oracleAddress == address(0)) revert ZeroAddress();
        if (_type > 1) revert InvalidOracleType(_type);
        RuleS.AccountApproveDenyOracleS storage data = Storage.accountApproveDenyOracleStorage();
        NonTaggedRules.AccountApproveDenyOracle memory rule = NonTaggedRules.AccountApproveDenyOracle(_type, _oracleAddress);
        uint32 ruleId = data.accountApproveDenyOracleIndex;
        data.accountApproveDenyOracleRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(ACCOUNT_APPROVE_DENY_ORACLE, ruleId, empty);
        ++data.accountApproveDenyOracleIndex;
        return ruleId;
    }

}
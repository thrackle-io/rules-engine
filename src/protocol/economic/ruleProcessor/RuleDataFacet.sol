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

    /************ Token Purchase Percentage Getters/Setters ***********/

    /**
     * @dev Function to add a Token Purchase Percentage rule
     * @param _appManagerAddr Address of App Manager
     * @param _tokenPercentage Percentage of Tokens allowed to purchase
     * @param _purchasePeriod Time period that transactions are accumulated
     * @param _totalSupply total supply of tokens (0 if using total supply from the token contract)
     * @param _startTimestamp start timestamp for the rule
     * @return ruleId position of new rule in array
     */
    function addPercentagePurchaseRule(
        address _appManagerAddr,
        uint16 _tokenPercentage,
        uint16 _purchasePeriod,
        uint256 _totalSupply,
        uint64 _startTimestamp
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_tokenPercentage > MAX_TOKEN_PERCENTAGE) revert ValueOutOfRange(_tokenPercentage);
        if (_purchasePeriod == 0 || _tokenPercentage == 0) revert ZeroValueNotPermited();
        _startTimestamp.validateTimestamp();
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        NonTaggedRules.TokenPercentagePurchaseRule memory rule = NonTaggedRules.TokenPercentagePurchaseRule(_tokenPercentage, _purchasePeriod, _totalSupply, _startTimestamp);
        uint32 ruleId = data.percentagePurchaseRuleIndex;
        data.percentagePurchaseRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(PURCHASE_PERCENTAGE, ruleId, empty);
        ++data.percentagePurchaseRuleIndex;
        return ruleId;
    }

    /************ Token Sell Percentage Getters/Setters ***********/

    /**
     * @dev Function to add a Token Sell Percentage rule
     * @param _appManagerAddr Address of App Manager
     * @param _tokenPercentage Percent of Tokens allowed to sell
     * @param _sellPeriod Time period that transactions are frozen
     * @param _totalSupply total supply of tokens (0 if using total supply from the token contract)
     * @param _startTimestamp start time for the period
     * @return ruleId position of new rule in array
     */
    function addPercentageSellRule(
        address _appManagerAddr,
        uint16 _tokenPercentage,
        uint16 _sellPeriod,
        uint256 _totalSupply,
        uint64 _startTimestamp
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_tokenPercentage > MAX_TOKEN_PERCENTAGE) revert ValueOutOfRange(_tokenPercentage);
        if (_sellPeriod == 0 || _tokenPercentage == 0) revert ZeroValueNotPermited();
        _startTimestamp.validateTimestamp();
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        uint32 ruleId = data.percentageSellRuleIndex;
        NonTaggedRules.TokenPercentageSellRule memory rule = NonTaggedRules.TokenPercentageSellRule(_tokenPercentage, _sellPeriod, _totalSupply, _startTimestamp);
        data.percentageSellRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(SELL_PERCENTAGE, ruleId, empty);
        ++data.percentageSellRuleIndex;
        return ruleId;
    }

    /************ Token Purchase Fee By Volume Getters/Setters ***********/

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
        emit ProtocolRuleCreated(PURCHASE_FEE_BY_VOLUME, ruleId, empty);
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

    /************ Token Volatility Getters/Setters ***********/

    /**
     * @dev Function to add a Token Volatility rule
     * @param _appManagerAddr Address of App Manager
     * @param _maxVolatility Maximum allowed volume
     * @param _period period in hours for the rule
     * @param _hoursFrozen freeze period hours
     * @return ruleId position of new rule in array
     */
    function addVolatilityRule(
        address _appManagerAddr,
        uint16 _maxVolatility,
        uint16 _period,
        uint16 _hoursFrozen,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_maxVolatility == 0 || _period == 0 || _hoursFrozen == 0) revert ZeroValueNotPermited();
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        NonTaggedRules.TokenVolatilityRule memory rule = NonTaggedRules.TokenVolatilityRule(_maxVolatility, _period, _hoursFrozen, _totalSupply);
        uint32 ruleId = data.volatilityRuleIndex;
        data.volatilityRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TOKEN_VOLATILITY, ruleId, empty);
        ++data.volatilityRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token Volatility Rule by index
     * @param _index position of rule in array
     * @return volatilityRules rule at index position
     */
    function getVolatilityRule(uint32 _index) external view returns (NonTaggedRules.TokenVolatilityRule memory) {
        // check one of the required non zero values to check for existence, if not, revert
        _index.checkRuleExistence(getTotalVolatilityRules());
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        return data.volatilityRules[_index];
    }

    /**
     * @dev Function to get total Volatility rules
     * @return Total length of array
     */
    function getTotalVolatilityRules() public view returns (uint32) {
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        return data.volatilityRuleIndex;
    }

    /************ Token Transfer Volume Getters/Setters ***********/

    /**
     * @dev Function to add a Token transfer Volume rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxVolumePercentage Maximum allowed volume percentage (this is 4 digits to allow 2 decimal places)
     * @param _hoursPerPeriod Allowed hours per period
     * @param _startTimestamp Timestamp to start the rule
     * @param _totalSupply Circulating supply value to use in calculations. If not specified, defaults to ERC20 totalSupply
     * @return ruleId position of new rule in array
     */
    function addTransferVolumeRule(
        address _appManagerAddr,
        uint24 _maxVolumePercentage,
        uint16 _hoursPerPeriod,
        uint64 _startTimestamp,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_maxVolumePercentage > MAX_VOLUME_PERCENTAGE) revert ValueOutOfRange(_maxVolumePercentage);
        if (_maxVolumePercentage == 0 || _hoursPerPeriod == 0) revert ZeroValueNotPermited();
        _startTimestamp.validateTimestamp();
        RuleS.TransferVolRuleS storage data = Storage.volumeStorage();
        NonTaggedRules.TokenTransferVolumeRule memory rule = NonTaggedRules.TokenTransferVolumeRule(_maxVolumePercentage, _hoursPerPeriod, _startTimestamp, _totalSupply);
        uint32 ruleId = data.transferVolRuleIndex;
        data.transferVolumeRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(TRANSFER_VOLUME, ruleId, empty);
        ++data.transferVolRuleIndex;
        return ruleId;
    }

    /************ Minimum Transfer Rule Getters/Setters ***********/

    /**
     * @dev Function to add Min Transfer rules
     * @param _appManagerAddr Address of App Manager
     * @param _minimumTransfer Mimimum amount of tokens required for transfer
     * @return ruleId position of new rule in array
     */
    function addMinimumTransferRule(address _appManagerAddr, uint256 _minimumTransfer) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_minimumTransfer == 0) revert ZeroValueNotPermited();
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        NonTaggedRules.TokenMinimumTransferRule memory rule = NonTaggedRules.TokenMinimumTransferRule(_minimumTransfer);
        uint32 ruleId = data.minimumTransferRuleIndex;
        data.minimumTransferRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(MIN_TRANSFER, ruleId, empty);
        ++data.minimumTransferRuleIndex;
        return ruleId;
    }

    /************ Supply Volatility Getters/Setters ***********/

    /**
     * @dev Function Token Supply Volatility rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxVolumePercentage Maximum amount of change allowed. This is not capped and will allow for values greater than 100%.
     * Since there is no cap for _maxVolumePercentage this could allow burning of full totalSupply() if over 100% (10000).
     * @param _period Allowed hours per period
     * @param _startTimestamp Unix timestamp for the _period to start counting.
     * @param _totalSupply this is an optional parameter. If 0, the toalSupply will be calculated dyamically. If not zero, this is  
     * going to be the locked value to calculate the rule 
     * @return ruleId position of new rule in array
     */
    function addSupplyVolatilityRule(
        address _appManagerAddr,
        uint16 _maxVolumePercentage,
        uint16 _period,
        uint64 _startTimestamp,
        uint256 _totalSupply
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxVolumePercentage == 0 || _period == 0) revert ZeroValueNotPermited();
        _startTimestamp.validateTimestamp();
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        NonTaggedRules.SupplyVolatilityRule memory rule = NonTaggedRules.SupplyVolatilityRule(_maxVolumePercentage, _period, _startTimestamp, _totalSupply);
        uint32 ruleId = data.supplyVolatilityRuleIndex;
        data.supplyVolatilityRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(SUPPLY_VOLATILITY, ruleId, empty);
        ++data.supplyVolatilityRuleIndex;
        return ruleId;
    }

    /************ Oracle Getters/Setters ***********/

    /**
     * @dev Function add an Oracle rule
     * @param _appManagerAddr Address of App Manager
     * @param _type type of Oracle Rule --> 0 = restricted; 1 = allowed
     * @param _oracleAddress Address of Oracle
     * @return ruleId position of rule in storage
     */
    function addOracleRule(address _appManagerAddr, uint8 _type, address _oracleAddress) external ruleAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_appManagerAddr == address(0)) revert ZeroAddress();
        if (_oracleAddress == address(0)) revert ZeroAddress();
        if (_type > 1) revert InvalidOracleType(_type);
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        NonTaggedRules.OracleRule memory rule = NonTaggedRules.OracleRule(_type, _oracleAddress);
        uint32 ruleId = data.oracleRuleIndex;
        data.oracleRules[ruleId] = rule;
        bytes32[] memory empty;
        emit ProtocolRuleCreated(ORACLE, ruleId, empty);
        ++data.oracleRuleIndex;
        return ruleId;
    }

}
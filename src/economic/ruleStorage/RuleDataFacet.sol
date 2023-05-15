// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/utils/Context.sol";
import "../AppAdministratorOnly.sol";
import {RuleStoragePositionLib as Storage} from "./RuleStoragePositionLib.sol";
import {INonTaggedRules as NonTaggedRules} from "./RuleDataInterfaces.sol";
import {IRuleStorage as RuleS} from "./IRuleStorage.sol";
import {IEconomicEvents} from "../../interfaces/IEvents.sol";
import "./RuleCodeData.sol";

/**
 * @title RuleDataFacet
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev setters and getters for rules
 * @notice This contract sets and gets the Rules for the protocol
 */
contract RuleDataFacet is Context, AppAdministratorOnly, IEconomicEvents {
    error InputArraysMustHaveSameLength();
    error IndexOutOfRange();
    error PageOutOfRange();
    error PercentageValueGreaterThan9999();
    error ZeroValueNotPermited();
    error ZeroAddress();
    error BlankTag();

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
     * @param _hoursFrozen Time period that transactions are frozen
     * @return ruleId position of new rule in array
     */
    function addPercentagePurchaseRule(address _appManagerAddr, uint16 _tokenPercentage, uint32 _hoursFrozen) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_tokenPercentage > 9999) revert PercentageValueGreaterThan9999();
        if (_hoursFrozen == 0 || _tokenPercentage == 0) revert ZeroValueNotPermited();
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        NonTaggedRules.TokenPercentagePurchaseRule memory rule = NonTaggedRules.TokenPercentagePurchaseRule(_tokenPercentage, _hoursFrozen);
        uint32 ruleId = data.percentagePurchaseRuleIndex;
        data.percentagePurchaseRules[ruleId] = rule;
        emit ProtocolRuleCreated(PURCHASE_PERCENTAGE, ruleId);
        ++data.percentagePurchaseRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token Purchase Percentage by index
     * @param _index position of rule in array
     * @return percentagePurchaseRules rule at index position
     */
    function getPctPurchaseRule(uint32 _index) external view returns (NonTaggedRules.TokenPercentagePurchaseRule memory) {
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        return data.percentagePurchaseRules[_index];
    }

    /**
     * @dev Function to get total Token Purchase Percentage
     * @return Total length of array
     */
    function getTotalPctPurchaseRule() external view returns (uint32) {
        RuleS.PctPurchaseRuleS storage data = Storage.pctPurchaseStorage();
        return data.percentagePurchaseRuleIndex;
    }

    /************ Token Sell Percentage Getters/Setters ***********/

    /**
     * @dev Function to add a Token Sell Percentage rule
     * @param _appManagerAddr Address of App Manager
     * @param _tokenPercentage Percent of Tokens allowed to sell
     * @param _hoursFrozen Time period that transactions are frozen
     * @return ruleId position of new rule in array
     */
    function addPercentageSellRule(address _appManagerAddr, uint16 _tokenPercentage, uint32 _hoursFrozen) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_tokenPercentage > 9999) revert PercentageValueGreaterThan9999();
        if (_hoursFrozen == 0 || _tokenPercentage == 0) revert ZeroValueNotPermited();
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        uint32 ruleId = data.percentageSellRuleIndex;
        NonTaggedRules.TokenPercentageSellRule memory rule = NonTaggedRules.TokenPercentageSellRule(_tokenPercentage, _hoursFrozen);
        data.percentageSellRules[ruleId] = rule;
        emit ProtocolRuleCreated(SELL_PERCENTAGE, ruleId);
        ++data.percentageSellRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token sell Percentage by index
     * @param _index position of rule in array
     * @return percentageSellRules rule at index position
     */
    function getPctSellRule(uint32 _index) external view returns (NonTaggedRules.TokenPercentageSellRule memory) {
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        return data.percentageSellRules[_index];
    }

    /**
     * @dev Function to get total Token Percentage Sell
     * @return Total length of array
     */
    function getTotalPctSellRule() external view returns (uint32) {
        RuleS.PctSellRuleS storage data = Storage.pctSellStorage();
        return data.percentageSellRuleIndex;
    }

    /************ Token Purchase Fee By Volume Getters/Setters ***********/

    /**
     * @dev Function to add a Token Purchase Fee By Volume rule
     * @param _appManagerAddr Address of App Manager
     * @param _volume Maximum allowed volume
     * @param _rateIncreased Amount rate increased
     * @return ruleId position of new rule in array
     */
    function addPurchaseFeeByVolumeRule(address _appManagerAddr, uint256 _volume, uint16 _rateIncreased) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_volume == 0 || _rateIncreased == 0) revert ZeroValueNotPermited();
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = NonTaggedRules.TokenPurchaseFeeByVolume(_volume, _rateIncreased);
        uint32 ruleId = data.purchaseFeeByVolumeRuleIndex;
        data.purchaseFeeByVolumeRules[ruleId] = rule;
        emit ProtocolRuleCreated(PURCHASE_FEE_BY_VOLUME, ruleId);
        ++data.purchaseFeeByVolumeRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token PurchaseFeeByVolume Rule by index
     * @param _index position of rule in array
     * @return TokenPurchaseFeeByVolume rule at index position
     */
    function getPurchaseFeeByVolumeRule(uint32 _index) external view returns (NonTaggedRules.TokenPurchaseFeeByVolume memory) {
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        return data.purchaseFeeByVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Purchase Percentage
     * @return Total length of array
     */
    function getTotalTokenPurchaseFeeByVolumeRules() external view returns (uint32) {
        RuleS.PurchaseFeeByVolRuleS storage data = Storage.purchaseFeeByVolumeStorage();
        return data.purchaseFeeByVolumeRuleIndex;
    }

    /************ Token Volatility Getters/Setters ***********/

    /**
     * @dev Function to add a Token Volatility rule
     * @param _appManagerAddr Address of App Manager
     * @param _maxVolatility Maximum allowed volume
     * @param _blocksPerPeriod Allowed blocks per period
     * @param _hoursFrozen Time period that transactions are frozen
     * @return ruleId position of new rule in array
     */
    function addVolatilityRule(address _appManagerAddr, uint16 _maxVolatility, uint8 _blocksPerPeriod, uint8 _hoursFrozen) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxVolatility == 0 || _blocksPerPeriod == 0 || _hoursFrozen == 0) revert ZeroValueNotPermited();
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        NonTaggedRules.TokenVolatilityRule memory rule = NonTaggedRules.TokenVolatilityRule(_maxVolatility, _blocksPerPeriod, _hoursFrozen);
        uint32 ruleId = data.volatilityRuleIndex;
        data.volatilityRules[ruleId] = rule;
        emit ProtocolRuleCreated(TOKEN_VOLATILITY, ruleId);
        ++data.volatilityRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token Volatility Rule by index
     * @param _index position of rule in array
     * @return volatilityRules rule at index position
     */
    function getVolatilityRule(uint32 _index) external view returns (NonTaggedRules.TokenVolatilityRule memory) {
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        return data.volatilityRules[_index];
    }

    /**
     * @dev Function to get total Volatility rules
     * @return Total length of array
     */
    function getTotalVolatilityRules() external view returns (uint32) {
        RuleS.VolatilityRuleS storage data = Storage.priceVolatilityStorage();
        return data.volatilityRuleIndex;
    }

    /************ Token Trading Volume Getters/Setters ***********/

    /**
     * @dev Function to add a Token Trading Volume rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxVolume Maximum allowed volume
     * @param _hoursPerPeriod Allowed hours per period
     * @param _hoursFrozen Time period that transactions are frozen
     * @return ruleId position of new rule in array
     */
    function addTradingVolumeRule(address _appManagerAddr, uint256 _maxVolume, uint8 _hoursPerPeriod, uint8 _hoursFrozen) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxVolume == 0 || _hoursPerPeriod == 0 || _hoursFrozen == 0) revert ZeroValueNotPermited();
        RuleS.TradingVolRuleS storage data = Storage.volumeStorage();
        NonTaggedRules.TokenTradingVolumeRule memory rule = NonTaggedRules.TokenTradingVolumeRule(_maxVolume, _hoursPerPeriod, _hoursFrozen);
        uint32 ruleId = data.tradingVolumeRuleIndex;
        data.tradingVolumeRules[ruleId] = rule;
        emit ProtocolRuleCreated(TRADING_VOLUME, ruleId);
        ++data.tradingVolumeRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Token Trading Volume Rule by index
     * @param _index position of rule in array
     * @return TokenTradingVolumeRule rule at index position
     */
    function getTradingVolumeRule(uint32 _index) external view returns (NonTaggedRules.TokenTradingVolumeRule memory) {
        RuleS.TradingVolRuleS storage data = Storage.volumeStorage();
        return data.tradingVolumeRules[_index];
    }

    /**
     * @dev Function to get total Token Trading Volume rules
     * @return Total length of array
     */
    function getTotalTradingVolumeRules() external view returns (uint32) {
        RuleS.TradingVolRuleS storage data = Storage.volumeStorage();
        return data.tradingVolumeRuleIndex;
    }

    /************ Minimum Transfer Rule Getters/Setters ***********/

    /**
     * @dev Function to add Min Transfer rules
     * @param _appManagerAddr Address of App Manager
     * @param _minimumTransfer Mimimum amount of tokens required for transfer
     * @return ruleId position of new rule in array
     */
    function addMinimumTransferRule(address _appManagerAddr, uint256 _minimumTransfer) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_minimumTransfer == 0) revert ZeroValueNotPermited();
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        data.minimumTransferRules.push(_minimumTransfer);
        uint32 ruleId = uint32(data.minimumTransferRules.length) - 1;
        emit ProtocolRuleCreated(MIN_TRANSFER, ruleId);
        return ruleId;
    }

    /**
     * @dev Function to get Minimum Transfer rules by index
     * @param _index position of rule in array
     * @return Rule at index
     */
    function getMinimumTransferRule(uint32 _index) external view returns (uint256) {
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return data.minimumTransferRules[_index];
    }

    /**
     * @dev Function to get total Minimum Transfer rules
     * @return Total length of array
     */
    function getTotalMinimumTransferRules() external view returns (uint32) {
        RuleS.MinTransferRuleS storage data = Storage.minTransferStorage();
        return uint32(data.minimumTransferRules.length);
    }

    /************ Supply Volatility Getters/Setters ***********/

    /**
     * @dev Function Token Supply Volatility rules
     * @param _appManagerAddr Address of App Manager
     * @param _maxChange Maximum amount of change allowed
     * @param _hoursPerPeriod Allowed hours per period
     * @param _hoursFrozen Hours that transactions are frozen
     * @return ruleId position of new rule in array
     */
    function addSupplyVolatilityRule(address _appManagerAddr, uint16 _maxChange, uint8 _hoursPerPeriod, uint8 _hoursFrozen) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_maxChange == 0 || _hoursPerPeriod == 0 || _hoursFrozen == 0) revert ZeroValueNotPermited();
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        NonTaggedRules.SupplyVolatilityRule memory rule = NonTaggedRules.SupplyVolatilityRule(_maxChange, _hoursPerPeriod, _hoursFrozen);
        uint32 ruleId = data.supplyVolatilityRuleIndex;
        data.supplyVolatilityRules[ruleId] = rule;
        emit ProtocolRuleCreated(SUPPLY_VOLATILITY, ruleId);
        ++data.supplyVolatilityRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function gets Supply Volitility rule at index
     * @param _index position of rule in array
     * @return SupplyVolatilityRule rule at indexed postion
     */
    function getSupplyVolatilityRule(uint32 _index) external view returns (NonTaggedRules.SupplyVolatilityRule memory) {
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        return data.supplyVolatilityRules[_index];
    }

    /**
     * @dev Function to get total Supply Volitility rules
     * @return supplyVolatilityRules total length of array
     */
    function getTotalSupplyVolatilityRules() external view returns (uint32) {
        RuleS.SupplyVolatilityRuleS storage data = Storage.supplyVolatilityStorage();
        return data.supplyVolatilityRuleIndex;
    }

    /************ Oracle Getters/Setters ***********/

    /**
     * @dev Function add an Oracle rule
     * @param _appManagerAddr Address of App Manager
     * @param _type type of Oracle Rule
     * @param _oracleAddress Address of Oracle
     * @return ruleId position of rule in storage
     */
    function addOracleRule(address _appManagerAddr, uint8 _type, address _oracleAddress) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_oracleAddress == address(0)) revert ZeroAddress();
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        NonTaggedRules.OracleRule memory rule = NonTaggedRules.OracleRule(_type, _oracleAddress);
        uint32 ruleId = data.oracleRuleIndex;
        data.oracleRules[ruleId] = rule;
        emit ProtocolRuleCreated(ORACLE, ruleId);
        ++data.oracleRuleIndex;
        return ruleId;
    }

    /**
     * @dev Function get Oracle Rule by index
     * @param _index Position of rule in storage
     * @return OracleRule at index
     */
    function getOracleRule(uint32 _index) external view returns (NonTaggedRules.OracleRule memory) {
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        return data.oracleRules[_index];
    }

    /**
     * @dev Function get total Oracle rules
     * @return total oracleRules array length
     */
    function getTotalOracleRules() external view returns (uint32) {
        RuleS.OracleRuleS storage data = Storage.oracleStorage();
        return data.oracleRuleIndex;
    }

    /************ NFT Getters/Setters ***********/
    /**
     * @dev Function adds Balance Limit Rule
     * @param _appManagerAddr App Manager Address
     * @param _nftTypes Types of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @return _nftTransferCounterRules which returns location of rule in array
     */
    function addNFTTransferCounterRule(address _appManagerAddr, bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed) external appAdministratorOnly(_appManagerAddr) returns (uint32) {
        if (_nftTypes.length != _tradesAllowed.length) revert InputArraysMustHaveSameLength();

        return _addNFTTransferCounterRule(_nftTypes, _tradesAllowed);
    }

    /**
     * @dev internal Function to avoid stack too deep error
     * @param _nftTypes Types of NFTs
     * @param _tradesAllowed Maximum trades allowed within 24 hours
     * @return position of new rule in array
     */
    function _addNFTTransferCounterRule(bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed) internal returns (uint32) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        uint32 index = data.NFTTransferCounterRuleIndex;
        for (uint256 i; i < _nftTypes.length; ) {
            if (_nftTypes[i] == bytes32("")) revert BlankTag();
            NonTaggedRules.NFTTradeCounterRule memory rule = NonTaggedRules.NFTTradeCounterRule(_tradesAllowed[i], true);
            data.NFTTransferCounterRule[index][_nftTypes[i]] = rule;
            unchecked {
                ++i;
            }
        }
        emit ProtocolRuleCreated(NFT_TRANSFER, index);
        ++data.NFTTransferCounterRuleIndex;
        return index;
    }

    /**
     * @dev Function get the NFT Transfer Counter rule in the rule set that belongs to an NFT type
     * @param _index position of rule in array
     * @param _nftType Type of NFT
     * @return NftTradeCounterRule at index location in array
     */
    function getNFTTransferCounterRule(uint32 _index, bytes32 _nftType) external view returns (NonTaggedRules.NFTTradeCounterRule memory) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        if (_index >= data.NFTTransferCounterRuleIndex) revert IndexOutOfRange();
        return data.NFTTransferCounterRule[_index][_nftType];
    }

    /**
     * @dev Function gets total NFT Trade Counter rules
     * @return Total length of array
     */
    function getTotalNFTTransferCounterRules() external view returns (uint32) {
        RuleS.NFTTransferCounterRuleS storage data = Storage.nftTransferStorage();
        return data.NFTTransferCounterRuleIndex;
    }
}

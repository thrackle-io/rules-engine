# RuleDataFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/economic/ruleStorage/RuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/interfaces/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/interfaces/IErrors.sol/interface.IInputErrors.md), [ITagInputErrors](/src/interfaces/IErrors.sol/interface.ITagInputErrors.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md), [IAppRuleInputErrors](/src/interfaces/IErrors.sol/interface.IAppRuleInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Rules for the protocol

*setters and getters for non tagged token specific rules*


## Functions
### addPercentagePurchaseRule

Note that no update method is implemented for rules. Since reutilization of
rules is encouraged, it is preferred to add an extra rule to the
set instead of modifying an existing one.
Token Purchase Percentage Getters/Setters **********

*Function to add a Token Purchase Percentage rule*


```solidity
function addPercentagePurchaseRule(
    address _appManagerAddr,
    uint16 _tokenPercentage,
    uint16 _purchasePeriod,
    uint256 _totalSupply,
    uint64 _startTimestamp
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_tokenPercentage`|`uint16`|Percentage of Tokens allowed to purchase|
|`_purchasePeriod`|`uint16`|Time period that transactions are accumulated|
|`_totalSupply`|`uint256`|total supply of tokens (0 if using total supply from the token contract)|
|`_startTimestamp`|`uint64`|start timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getPctPurchaseRule

*Function get Token Purchase Percentage by index*


```solidity
function getPctPurchaseRule(uint32 _index) external view returns (NonTaggedRules.TokenPercentagePurchaseRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenPercentagePurchaseRule`|percentagePurchaseRules rule at index position|


### getTotalPctPurchaseRule

*Function to get total Token Purchase Percentage*


```solidity
function getTotalPctPurchaseRule() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addPercentageSellRule

Token Sell Percentage Getters/Setters **********

*Function to add a Token Sell Percentage rule*


```solidity
function addPercentageSellRule(
    address _appManagerAddr,
    uint16 _tokenPercentage,
    uint16 _sellPeriod,
    uint256 _totalSupply,
    uint64 _startTimestamp
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_tokenPercentage`|`uint16`|Percent of Tokens allowed to sell|
|`_sellPeriod`|`uint16`|Time period that transactions are frozen|
|`_totalSupply`|`uint256`|total supply of tokens (0 if using total supply from the token contract)|
|`_startTimestamp`|`uint64`|start time for the period|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getPctSellRule

*Function get Token sell Percentage by index*


```solidity
function getPctSellRule(uint32 _index) external view returns (NonTaggedRules.TokenPercentageSellRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenPercentageSellRule`|percentageSellRules rule at index position|


### getTotalPctSellRule

*Function to get total Token Percentage Sell*


```solidity
function getTotalPctSellRule() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addPurchaseFeeByVolumeRule

Token Purchase Fee By Volume Getters/Setters **********

*Function to add a Token Purchase Fee By Volume rule*


```solidity
function addPurchaseFeeByVolumeRule(address _appManagerAddr, uint256 _volume, uint16 _rateIncreased)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_volume`|`uint256`|Maximum allowed volume|
|`_rateIncreased`|`uint16`|Amount rate increased|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getPurchaseFeeByVolumeRule

*Function get Token PurchaseFeeByVolume Rule by index*


```solidity
function getPurchaseFeeByVolumeRule(uint32 _index)
    external
    view
    returns (NonTaggedRules.TokenPurchaseFeeByVolume memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenPurchaseFeeByVolume`|TokenPurchaseFeeByVolume rule at index position|


### getTotalTokenPurchaseFeeByVolumeRules

*Function to get total Token Purchase Percentage*


```solidity
function getTotalTokenPurchaseFeeByVolumeRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addVolatilityRule

Token Volatility Getters/Setters **********

*Function to add a Token Volatility rule*


```solidity
function addVolatilityRule(
    address _appManagerAddr,
    uint16 _maxVolatility,
    uint16 _period,
    uint16 _hoursFrozen,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxVolatility`|`uint16`|Maximum allowed volume|
|`_period`|`uint16`|period in hours for the rule|
|`_hoursFrozen`|`uint16`|freeze period hours|
|`_totalSupply`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getVolatilityRule

*Function get Token Volatility Rule by index*


```solidity
function getVolatilityRule(uint32 _index) external view returns (NonTaggedRules.TokenVolatilityRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenVolatilityRule`|volatilityRules rule at index position|


### getTotalVolatilityRules

*Function to get total Volatility rules*


```solidity
function getTotalVolatilityRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addTransferVolumeRule

Token Transfer Volume Getters/Setters **********

*Function to add a Token transfer Volume rules*


```solidity
function addTransferVolumeRule(
    address _appManagerAddr,
    uint24 _maxVolumePercentage,
    uint16 _hoursPerPeriod,
    uint64 _startTimestamp,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxVolumePercentage`|`uint24`|Maximum allowed volume percentage (this is 4 digits to allow 2 decimal places)|
|`_hoursPerPeriod`|`uint16`|Allowed hours per period|
|`_startTimestamp`|`uint64`|Timestamp to start the rule|
|`_totalSupply`|`uint256`|Circulating supply value to use in calculations. If not specified, defaults to ERC20 totalSupply|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getTransferVolumeRule

*Function get Token Transfer Volume Rule by index*


```solidity
function getTransferVolumeRule(uint32 _index) external view returns (NonTaggedRules.TokenTransferVolumeRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenTransferVolumeRule`|TokenTransferVolumeRule rule at index position|


### getTotalTransferVolumeRules

*Function to get total Token Transfer Volume rules*


```solidity
function getTotalTransferVolumeRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addMinimumTransferRule

Minimum Transfer Rule Getters/Setters **********

*Function to add Min Transfer rules*


```solidity
function addMinimumTransferRule(address _appManagerAddr, uint256 _minimumTransfer)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_minimumTransfer`|`uint256`|Mimimum amount of tokens required for transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getMinimumTransferRule

*Function to get Minimum Transfer rules by index*


```solidity
function getMinimumTransferRule(uint32 _index) external view returns (NonTaggedRules.TokenMinimumTransferRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMinimumTransferRule`|Rule at index|


### getTotalMinimumTransferRules

*Function to get total Minimum Transfer rules*


```solidity
function getTotalMinimumTransferRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addSupplyVolatilityRule

Supply Volatility Getters/Setters **********

*Function Token Supply Volatility rules*


```solidity
function addSupplyVolatilityRule(
    address _appManagerAddr,
    uint16 _maxVolumePercentage,
    uint16 _period,
    uint64 _startTimestamp,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_maxVolumePercentage`|`uint16`|Maximum amount of change allowed. This is not capped and will allow for values greater than 100%. Since there is no cap for _maxVolumePercentage this could allow burning of full totalSupply() if over 100% (10000).|
|`_period`|`uint16`|Allowed hours per period|
|`_startTimestamp`|`uint64`|Hours that transactions are frozen|
|`_totalSupply`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of new rule in array|


### getSupplyVolatilityRule

*Function gets Supply Volitility rule at index*


```solidity
function getSupplyVolatilityRule(uint32 _index) external view returns (NonTaggedRules.SupplyVolatilityRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.SupplyVolatilityRule`|SupplyVolatilityRule rule at indexed postion|


### getTotalSupplyVolatilityRules

*Function to get total Supply Volitility rules*


```solidity
function getTotalSupplyVolatilityRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|supplyVolatilityRules total length of array|


### addOracleRule

Oracle Getters/Setters **********

*Function add an Oracle rule*


```solidity
function addOracleRule(address _appManagerAddr, uint8 _type, address _oracleAddress)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_type`|`uint8`|type of Oracle Rule --> 0 = restricted; 1 = allowed|
|`_oracleAddress`|`address`|Address of Oracle|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of rule in storage|


### getOracleRule

*Function get Oracle Rule by index*


```solidity
function getOracleRule(uint32 _index) external view returns (NonTaggedRules.OracleRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in storage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.OracleRule`|OracleRule at index|


### getTotalOracleRules

*Function get total Oracle rules*


```solidity
function getTotalOracleRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total oracleRules array length|


### addNFTTransferCounterRule

NFT Getters/Setters **********

*Function adds Balance Limit Rule*


```solidity
function addNFTTransferCounterRule(
    address _appManagerAddr,
    bytes32[] calldata _nftTypes,
    uint8[] calldata _tradesAllowed,
    uint64 _startTs
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|App Manager Address|
|`_nftTypes`|`bytes32[]`|Types of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTs`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_nftTransferCounterRules which returns location of rule in array|


### _addNFTTransferCounterRule

*internal Function to avoid stack too deep error*


```solidity
function _addNFTTransferCounterRule(bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed, uint64 _startTs)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nftTypes`|`bytes32[]`|Types of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTs`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getNFTTransferCounterRule

*Function get the NFT Transfer Counter rule in the rule set that belongs to an NFT type*


```solidity
function getNFTTransferCounterRule(uint32 _index, bytes32 _nftType)
    external
    view
    returns (NonTaggedRules.NFTTradeCounterRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_nftType`|`bytes32`|Type of NFT|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.NFTTradeCounterRule`|NftTradeCounterRule at index location in array|


### getTotalNFTTransferCounterRules

*Function gets total NFT Trade Counter rules*


```solidity
function getTotalNFTTransferCounterRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



# RuleApplicationValidationFacet
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Check that a rule in fact exists.

*Facet in charge of the logic to check rule existence*


## Functions
### validateAccountMinMaxTokenBalanceERC721

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalanceERC721(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMinMaxTokenBalance

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalance(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMinMaxTokenBalance

*Function gets total AccountMinMaxTokenBalance rules*


```solidity
function getTotalAccountMinMaxTokenBalance() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxDailyTrades

*Validate the existence of the rule*


```solidity
function validateTokenMaxDailyTrades(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxDailyTradesRules

*Function gets total tokenMaxDailyTrades rules*


```solidity
function getTotalTokenMaxDailyTradesRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxBuySize

*Validate the existence of the rule*


```solidity
function validateAccountMaxBuySize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxBuySize

*Function to get total account max buy size rules*


```solidity
function getTotalAccountMaxBuySize() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxSellSize

*Validate the existence of the rule*


```solidity
function validateAccountMaxSellSize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxSellSize

*Function to get total Account Max Sell Size rules*


```solidity
function getTotalAccountMaxSellSize() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAdminMinTokenBalance

*Validate the existence of the rule*


```solidity
function validateAdminMinTokenBalance(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAdminMinTokenBalance

*Function to get total Admin Min Token Balance rules*


```solidity
function getTotalAdminMinTokenBalance() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminMinTokenBalanceRules total length of array|


### validateTokenMinTxSize

*Validate the existence of the rule*


```solidity
function validateTokenMinTxSize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMinTxSize

*Function to get total Token Min Tx Size rules*


```solidity
function getTotalTokenMinTxSize() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountApproveDenyOracle

*Validate the existence of the rule*


```solidity
function validateAccountApproveDenyOracle(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountApproveDenyOracle

*Function get total Account Approve Deny Oracle rules*


```solidity
function getTotalAccountApproveDenyOracle() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total accountApproveDenyOracleRules array length|


### validateTokenMaxBuyVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxBuyVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxBuyVolume

*Function to get total Token Max Buy Volume*


```solidity
function getTotalTokenMaxBuyVolume() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxSellVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxSellVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxSellVolume

*Function to get total Token Max Sell Volume*


```solidity
function getTotalTokenMaxSellVolume() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxTradingVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxTradingVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxTradingVolume

*Function to get total Token Max Trading Volume*


```solidity
function getTotalTokenMaxTradingVolume() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxSupplyVolatility

*Validate the existence of the rule*


```solidity
function validateTokenMaxSupplyVolatility(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxSupplyVolatility

*Function to get total Token Max Supply Volitility rules*


```solidity
function getTotalTokenMaxSupplyVolatility() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenMaxSupplyVolatilityRules total length of array|


### validateAccountMaxValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxValueByRiskScore

*Function to get total Account Max Value by Risk Score rules*


```solidity
function getTotalAccountMaxValueByRiskScore() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxTxValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxTxValueByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxTxValueByRiskScore

*Function to get total Account Max Transaction Value by Risk rules*


```solidity
function getTotalAccountMaxTxValueByRiskScore() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validatePause

*Validate the existence of the rule*


```solidity
function validatePause(uint32 _ruleId, address _dataServer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_dataServer`|`address`|address of the appManager contract|


### validateAccountMaxValueByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxValueByAccessLevel

*Function to get total Account Max Value By Access Level rules*


```solidity
function getTotalAccountMaxValueByAccessLevel() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxValueOutByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueOutByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxValueOutByAccessLevel

*Function to get total Account Max Value Out By Access Level rules*


```solidity
function getTotalAccountMaxValueOutByAccessLevel() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total number of access level withdrawal rules|



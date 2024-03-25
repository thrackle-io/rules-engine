# RuleApplicationValidationFacet
[Git Source](https://github.com/thrackle-io/tron/blob/f0e9b435619e8bdc38f4e9105781dfc663d9f089/src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Check that a rule in fact exists.

*Facet in charge of the logic to check rule existence*


## Functions
### validateAccountMinMaxTokenBalanceERC721

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalanceERC721(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMinMaxTokenBalance

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalance(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateTokenMaxDailyTrades(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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


### getTotalAccountMaxTradeSize

*Function to get total account max Trade size rules*


```solidity
<<<<<<< HEAD
function getTotalAccountMaxTradeSize() internal view returns (uint32);
=======
function validateAccountMaxBuySize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxBuySize

*Function to get total account max buy size rules*


```solidity
function getTotalAccountMaxBuySize() internal view returns (uint32);
>>>>>>> b8f804fac (Initial commit)
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxTradeSize

*Validate the existence of the rule*


```solidity
<<<<<<< HEAD
function validateAccountMaxTradeSize(uint32 _ruleId) external view;
=======
function validateAccountMaxSellSize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
>>>>>>> b8f804fac (Initial commit)
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAdminMinTokenBalance

*Validate the existence of the rule*


```solidity
function validateAdminMinTokenBalance(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateTokenMinTxSize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateAccountApproveDenyOracle(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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


### validateTokenMaxBuySellVolume

*Validate the existence of the rule*


```solidity
<<<<<<< HEAD
function validateTokenMaxBuySellVolume(uint32 _ruleId) external view;
=======
function validateTokenMaxBuyVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
>>>>>>> b8f804fac (Initial commit)
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxBuySellVolume

*Function to get total Token Max Buy Sell Volume*


```solidity
<<<<<<< HEAD
function getTotalTokenMaxBuySellVolume() internal view returns (uint32);
=======
function getTotalTokenMaxBuyVolume() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxSellVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxSellVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxSellVolume

*Function to get total Token Max Sell Volume*


```solidity
function getTotalTokenMaxSellVolume() internal view returns (uint32);
>>>>>>> b8f804fac (Initial commit)
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMaxTradingVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxTradingVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateTokenMaxSupplyVolatility(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateAccountMaxValueByRiskScore(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateAccountMaxTxValueByRiskScore(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validatePause(ActionTypes[] memory _actions, uint32 _ruleId, address _dataServer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_dataServer`|`address`|address of the appManager contract|


### validateAccountMaxValueByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByAccessLevel(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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
function validateAccountMaxValueOutByAccessLevel(ActionTypes[] memory _actions, uint32 _ruleId) external view;
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



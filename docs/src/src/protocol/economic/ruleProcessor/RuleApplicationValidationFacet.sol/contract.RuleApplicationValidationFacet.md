# RuleApplicationValidationFacet
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol)

**Inherits:**
ERC173

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
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMinMaxTokenBalance

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalance(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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


### validateAccountMaxTradeSize

*Validate the existence of the rule*


```solidity
function validateAccountMaxTradeSize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxTradeSize

*Function to get total account max trade size rules*


```solidity
function getTotalAccountMaxTradeSize() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAdminMinTokenBalance

*Validate the existence of the rule*


```solidity
function validateAdminMinTokenBalance(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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
function validateTokenMaxBuySellVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMaxBuySellVolume

*Function to get total Token Max Buy Sell Volume*


```solidity
function getTotalTokenMaxBuySellVolume() internal view returns (uint32);
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
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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


### validateAccountMaxValueByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByAccessLevel(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
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
|`_actions`|`ActionTypes[]`||
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


### areActionsEnabledInRule

*Function to check if the action type is enabled for the rule*


```solidity
function areActionsEnabledInRule(bytes32 _rule, ActionTypes[] memory _actions) public view returns (bool allEnabled);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rule`|`bytes32`|the bytes32 rule code pointer in storage|
|`_actions`|`ActionTypes[]`|ActionTypes array to be checked if type is enabled|


### enabledActionsInRule

*Function to enable the action type for the rule*


```solidity
function enabledActionsInRule(bytes32 _rule, ActionTypes[] memory _actions) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rule`|`bytes32`|the bytes32 rule code pointer in storage|
|`_actions`|`ActionTypes[]`|ActionTypes array to be enabled|


### disableActionsInRule

*Function to disable the action type for the rule*


```solidity
function disableActionsInRule(bytes32 _rule, ActionTypes[] memory _actions) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rule`|`bytes32`|the bytes32 rule code pointer in storage|
|`_actions`|`ActionTypes[]`|ActionTypes array to be disable|



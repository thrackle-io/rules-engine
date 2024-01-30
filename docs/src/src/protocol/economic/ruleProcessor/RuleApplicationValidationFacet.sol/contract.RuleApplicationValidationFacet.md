# RuleApplicationValidationFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Check that a rule in fact exists.

*Facet in charge of the logic to check rule existence*


## Functions
### validateAMMFee

*Validate the existence of the rule*


```solidity
function validateAMMFee(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllAMMFeeRules

*Function get all AMM Fee rules for validation*


```solidity
function getAllAMMFeeRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total ammFeeRules array length|


### validateTransactionLimitByRiskScore

*Validate the existence of the rule*


```solidity
function validateTransactionLimitByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllTransactionLimitByRiskRules

*Function to get all Transaction Limit by Risk Score rules for validation*


```solidity
function getAllTransactionLimitByRiskRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateMinMaxAccountBalanceERC721

*Validate the existence of the rule*


```solidity
function validateMinMaxAccountBalanceERC721(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateMinMaxAccountBalance

*Validate the existence of the rule*


```solidity
function validateMinMaxAccountBalance(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllMinMaxBalanceRules

*Function gets total Balance Limit rules*


```solidity
function getAllMinMaxBalanceRules() internal view returns (uint32);
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

*Function gets total NFT Trade Counter rules*


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


### validateSellLimit

*Validate the existence of the rule*


```solidity
function validateSellLimit(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllSellRule

*Function to get total Sell rules*


```solidity
function getAllSellRule() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAdminWithdrawal

*Validate the existence of the rule*


```solidity
function validateAdminWithdrawal(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllAdminMinTokenBalances

*Function to get total Admin withdrawal rules*


```solidity
function getAllAdminMinTokenBalances() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminMinTokenBalanceRules total length of array|


### validateWithdrawal

*Validate the existence of the rule*


```solidity
function validateWithdrawal(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllWithdrawalRule

*Function to get total withdrawal rules*


```solidity
function getAllWithdrawalRule() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|withdrawalRulesIndex total length of array|


### validateMinBalByDate

*Validate the existence of the rule*


```solidity
function validateMinBalByDate(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllMinBalByDateRule

*Function to get total minimum balance by date rules*


```solidity
function getAllMinBalByDateRule() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenMinTransactionSize

*Validate the existence of the rule*


```solidity
function validateTokenMinTransactionSize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalTokenMinTransactionSize

*Function to get total Minimum Transfer rules*


```solidity
function getTotalTokenMinTransactionSize() internal view returns (uint32);
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

*Function get total Oracle rules*


```solidity
function getTotalAccountApproveDenyOracle() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total oracleRules array length|


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

*Function to get total Token Purchase Percentage*


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

*Function to get total Token Percentage Sell*


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

*Function to get total Token Transfer Volume rules*


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


### getAllSupplyVolatilityRules

*Function to get total Supply Volitility rules*


```solidity
function getAllSupplyVolatilityRules() internal view returns (uint32);
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

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getTotalAccountMaxValueByRiskScore() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateAccountMaxTransactionValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxTransactionValueByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getTotalAccountMaxTransactionValueByRiskScore

*Function to get total Max Tx Size Per Period By Risk rules*


```solidity
function getTotalAccountMaxTransactionValueByRiskScore() internal view returns (uint32);
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

*Function to get total AccessLevel Balance rules*


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

*Function to get total AccessLevel withdrawal rules*


```solidity
function getTotalAccountMaxValueOutByAccessLevel() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total number of access level withdrawal rules|



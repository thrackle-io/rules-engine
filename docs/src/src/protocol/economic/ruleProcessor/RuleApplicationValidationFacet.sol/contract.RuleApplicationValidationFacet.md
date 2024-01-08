# RuleApplicationValidationFacet
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol)

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


### validateNFTTransferCounter

*Validate the existence of the rule*


```solidity
function validateNFTTransferCounter(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllNFTTransferCounterRules

*Function gets total NFT Trade Counter rules*


```solidity
function getAllNFTTransferCounterRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validatePurchaseLimit

*Validate the existence of the rule*


```solidity
function validatePurchaseLimit(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllPurchaseRule

*Function to get total purchase rules*


```solidity
function getAllPurchaseRule() internal view returns (uint32);
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


### getAllAdminWithdrawalRules

*Function to get total Admin withdrawal rules*


```solidity
function getAllAdminWithdrawalRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminWithdrawalRulesPerToken total length of array|


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


### validateMinTransfer

*Validate the existence of the rule*


```solidity
function validateMinTransfer(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllMinimumTransferRules

*Function to get total Minimum Transfer rules*


```solidity
function getAllMinimumTransferRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateOracle

*Validate the existence of the rule*


```solidity
function validateOracle(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllOracleRules

*Function get total Oracle rules*


```solidity
function getAllOracleRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total oracleRules array length|


### validatePurchasePercentage

*Validate the existence of the rule*


```solidity
function validatePurchasePercentage(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllPctPurchaseRule

*Function to get total Token Purchase Percentage*


```solidity
function getAllPctPurchaseRule() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateSellPercentage

*Validate the existence of the rule*


```solidity
function validateSellPercentage(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllPctSellRule

*Function to get total Token Percentage Sell*


```solidity
function getAllPctSellRule() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateTokenTransferVolume

*Validate the existence of the rule*


```solidity
function validateTokenTransferVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllTransferVolumeRules

*Function to get total Token Transfer Volume rules*


```solidity
function getAllTransferVolumeRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateSupplyVolatility

*Validate the existence of the rule*


```solidity
function validateSupplyVolatility(uint32 _ruleId) external view;
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
|`<none>`|`uint32`|supplyVolatilityRules total length of array|


### validateAccBalanceByRisk

*Validate the existence of the rule*


```solidity
function validateAccBalanceByRisk(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllAccountBalanceByRiskScoreRules

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getAllAccountBalanceByRiskScoreRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateMaxTxSizePerPeriodByRisk

*Validate the existence of the rule*


```solidity
function validateMaxTxSizePerPeriodByRisk(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllMaxTxSizePerPeriodRules

*Function to get total Max Tx Size Per Period By Risk rules*


```solidity
function getAllMaxTxSizePerPeriodRules() internal view returns (uint32);
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


### validateAccBalanceByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccBalanceByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllAccessLevelBalanceRules

*Function to get total AccessLevel Balance rules*


```solidity
function getAllAccessLevelBalanceRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### validateWithdrawalLimitsByAccessLevel

*Validate the existence of the rule*


```solidity
function validateWithdrawalLimitsByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### getAllAccessLevelWithdrawalRules

*Function to get total AccessLevel withdrawal rules*


```solidity
function getAllAccessLevelWithdrawalRules() internal view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total number of access level withdrawal rules|



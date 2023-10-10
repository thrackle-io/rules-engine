# FeeRuleDataFacet
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/economic/ruleStorage/FeeRuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/interfaces/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/interfaces/IErrors.sol/interface.IInputErrors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Fee Rules for the protocol

*Contains the setters and getters for fee rules*


## State Variables
### MAX_PERCENTAGE

```solidity
uint16 constant MAX_PERCENTAGE = 10000;
```


## Functions
### addAMMFeeRule

AMM Fee Getters/Setters **********

*Function add an AMM Fee rule*


```solidity
function addAMMFeeRule(address _appManagerAddr, uint256 _feePercentage)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_feePercentage`|`uint256`|percentage of collateralized token to be assessed for fees|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId position of rule in storage|


### getAMMFeeRule

s

*Function get AMM Fee Rule by index*


```solidity
function getAMMFeeRule(uint32 _index) external view returns (Fee.AMMFeeRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in storage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Fee.AMMFeeRule`|AMMFeeRule at index|


### getTotalAMMFeeRules

*Function get total AMM Fee rules*


```solidity
function getTotalAMMFeeRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total ammFeeRules array length|



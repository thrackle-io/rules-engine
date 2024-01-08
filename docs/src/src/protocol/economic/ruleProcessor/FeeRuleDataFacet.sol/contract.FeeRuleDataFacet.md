# FeeRuleDataFacet
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/protocol/economic/ruleProcessor/FeeRuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/common/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

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



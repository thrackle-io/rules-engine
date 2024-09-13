# FeesFacet
[Git Source](https://github.com/thrackle-io/rules-engine/blob/af2c902a06ffbdb4f9de3bdbb6a20c476a93b949/src/client/token/handler/diamond/FeesFacet.sol)

**Inherits:**
[RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [Fees](/src/client/token/handler/ruleContracts/Fees.sol/contract.Fees.md)


## Functions
### setFeeActivation

*Turn fees on/off*


```solidity
function setFeeActivation(bool on_off) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`on_off`|`bool`|value for fee status|


### isFeeActive

*returns the full mapping of fees*


```solidity
function isFeeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|feeActive fee activation status|



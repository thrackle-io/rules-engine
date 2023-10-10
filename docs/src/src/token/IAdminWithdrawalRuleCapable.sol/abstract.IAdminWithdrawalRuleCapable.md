# IAdminWithdrawalRuleCapable
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/token/IAdminWithdrawalRuleCapable.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*This interface provides the ABI for any asset handler capable of implementing the admin withdrawal rule*


## Functions
### isAdminWithdrawalActiveAndApplicable

*This function is used by the app manager to determine if the AdminWithdrawal rule is active*


```solidity
function isAdminWithdrawalActiveAndApplicable() external virtual returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


## Errors
### AdminWithdrawalRuleisActive

```solidity
error AdminWithdrawalRuleisActive();
```


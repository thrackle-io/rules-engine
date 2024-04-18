# IAdminMinTokenBalanceCapable
[Git Source](https://github.com/thrackle-io/tron/blob/4370cba4c6c86564c45ea5da17298f68b13753b5/src/client/token/IAdminMinTokenBalanceCapable.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*This interface provides the ABI for any asset handler capable of implementing the Admin Min Token Balance rule*


## Functions
### isAdminMinTokenBalanceActiveAndApplicable

*This function is used by the app manager to determine if the Admin Min Token Balance rule is active for any of the actions*


```solidity
function isAdminMinTokenBalanceActiveAndApplicable() external virtual returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|



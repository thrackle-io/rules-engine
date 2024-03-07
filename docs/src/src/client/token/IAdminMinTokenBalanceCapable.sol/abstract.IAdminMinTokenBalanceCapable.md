# IAdminMinTokenBalanceCapable
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/client/token/IAdminMinTokenBalanceCapable.sol)

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



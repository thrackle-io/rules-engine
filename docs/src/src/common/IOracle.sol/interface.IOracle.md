# IOracle
[Git Source](https://github.com/thrackle-io/tron/blob/4370cba4c6c86564c45ea5da17298f68b13753b5/src/common/IOracle.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This stores the function signature for external oracles

*Both "approve list" and "deny list" oracles will use this interface*


## Functions
### isDenied

*This function checks to see if the address is on the oracle's denied list. This is the DENIED_LIST type.*


```solidity
function isDenied(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Account address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|denied returns true if denied, false if not|


### isApproved

*This function checks to see if the address is on the oracle's approved list. This is the APPROVED_LIST type.*


```solidity
function isApproved(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Account address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|denied returns true if approved, false if not|



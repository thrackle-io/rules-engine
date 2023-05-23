# IOracle
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/ruleProcessor/nontagged/IOracle.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This stores the function signature for external oracles

*Both "white list" and "black list" oracles will use this interface*


## Functions
### isRestricted

*This function checks to see if the address is on the oracle's sanction list. This is the RESTRICTED_LIST type.*


```solidity
function isRestricted(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Account address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|sanctioned returns true if sanctioned, false if not|


### isAllowed

*This function checks to see if the address is on the oracle's allowed list. This is the ALLOWED_LIST type.*


```solidity
function isAllowed(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Account address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|sanctioned returns true if allowed, false if not|



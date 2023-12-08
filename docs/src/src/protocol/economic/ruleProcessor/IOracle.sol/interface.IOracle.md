# IOracle
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/IOracle.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This stores the function signature for external oracles

*Both "allow list" and "restrict list" oracles will use this interface*


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



# GeneralTags
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/data/GeneralTags.sol)

**Inherits:**
[DataModule](/src/data/DataModule.sol/contract.DataModule.md), [IGeneralTags](/src/data/IGeneralTags.sol/interface.IGeneralTags.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Stores tag data for accounts

*Tags are stored as an internal mapping*


## State Variables
### tagRecords

```solidity
mapping(address => bytes32[]) public tagRecords;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor();
```

### addTag

*Add the tag. Restricted to owner.*


```solidity
function addTag(address _address, bytes32 _tag) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be added|


### _removeTag

*Helper function to remove tags*


```solidity
function _removeTag(address _address, uint256 i) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|of the account to remove tag|
|`i`|`uint256`|index of the tag to remove|


### removeTag

*Remove the tag. Restricted to owner.*


```solidity
function removeTag(address _address, bytes32 _tag) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be removed|


### hasTag

*Check is a user has a certain tag*


```solidity
function hasTag(address _address, bytes32 _tag) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|hasTag true if it has the tag, false if it doesn't|


### getAllTags


```solidity
function getAllTags(address _address) public view returns (bytes32[] memory);
```


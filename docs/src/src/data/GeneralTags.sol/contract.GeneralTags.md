# GeneralTags
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/data/GeneralTags.sol)

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

there is a hard limit of 10 tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert.

*Add the tag. Restricted to owner.*


```solidity
function addTag(address _address, bytes32 _tag) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be added|


### addGeneralTagToMultipleAccounts

there is a hard limit of 10 tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert.

*Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.*


```solidity
function addGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tag`|`bytes32`|Tag for the account. Can be any allowed string variant|


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


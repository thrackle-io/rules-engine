# Tags
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/f3f89426d30f93406f5ff447f7284dbf958844b4/src/client/application/data/Tags.sol)

**Inherits:**
[DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md), [ITags](/src/client/application/data/ITags.sol/interface.ITags.md), [INoAddressToRemove](/src/common/IErrors.sol/interface.INoAddressToRemove.md), [IAppLevelEvents](/src/common/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Stores tag data for accounts

*Tags are stored as an internal mapping*


## State Variables
### tagRecords

```solidity
mapping(address => bytes32[]) public tagRecords;
```


### tagToIndex

```solidity
mapping(address => mapping(bytes32 => uint256)) tagToIndex;
```


### isTagRegistered

```solidity
mapping(address => mapping(bytes32 => bool)) isTagRegistered;
```


### MAX_TAGS

```solidity
uint8 constant MAX_TAGS = 10;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### addTag

There is a hard limit of MAX_TAGS tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert.

*Add the tag. Restricted to owner.*


```solidity
function addTag(address _address, bytes32 _tag) public virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be added|


### addTagToMultipleAccounts

There is a hard limit of MAX_TAGS tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert.

*Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.*


```solidity
function addTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tag`|`bytes32`|Tag for the account. Can be any allowed string variant|


### removeTag

*Remove the tag. Restricted to owner.*


```solidity
function removeTag(address _address, bytes32 _tag) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be removed|


### addMultipleTagToMultipleAccounts

we only remove the tag if this exists in the account's tag list
we store the last tag on a local variable to avoid unnecessary costly memory reads
we check if we are trying to remove the last tag since this would mean we can skip some steps
if it is not the last tag, then we store the index of the address to remove
we remove the tag by replacing it in the array with the last tag (now duplicated)
we update the last tag index to its new position (the removed-tag index)
we remove the last element of the tag array since it is now duplicated
we set to false the membership mapping for this tag in this account
we set the index to zero for this tag in this account
only one event should be emitted and only if a tag was actually removed

there is a hard limit of 10 tags per address.

*Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.*


```solidity
function addMultipleTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tags) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tags`|`bytes32[]`|Tag array for the account at index. Can be any allowed string variant|


### hasTag

*Check is a user has a certain tag*


```solidity
function hasTag(address _address, bytes32 _tag) public view virtual returns (bool);
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
function getAllTags(address _address) public view virtual returns (bytes32[] memory);
```


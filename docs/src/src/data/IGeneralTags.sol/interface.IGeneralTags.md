# IGeneralTags
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/data/IGeneralTags.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md), [ITagInputErrors](/src/interfaces/IErrors.sol/interface.ITagInputErrors.md), [IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IMaxTagLimitError](/src/interfaces/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Stores tag data for accounts

*Tags storage retrieval functions are defined here*


## Functions
### addTag

*Add the tag. Restricted to owner.*


```solidity
function addTag(address _address, bytes32 _tag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be added|


### removeTag

*Remove the tag. Restricted to owner.*


```solidity
function removeTag(address _address, bytes32 _tag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|
|`_tag`|`bytes32`|metadata tag to be removed|


### hasTag

*Check is a user has a certain tag*


```solidity
function hasTag(address _address, bytes32 _tag) external view returns (bool);
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

*Get all the tags for the address*


```solidity
function getAllTags(address _address) external view returns (bytes32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|user address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32[]`|tags array of tags|


### addGeneralTagToMultipleAccounts

there is a hard limit of 10 tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert

*Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.*


```solidity
function addGeneralTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tag`|`bytes32`|Tag for the account. Can be any allowed string variant|



# ITags
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/client/application/data/ITags.sol)

**Inherits:**
[IDataModule](/src/client/application/data/IDataModule.sol/interface.IDataModule.md), [ITagInputErrors](/src/common/IErrors.sol/interface.ITagInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md)

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


### addTagToMultipleAccounts

there is a hard limit of 10 tags per address. This limit is also enforced by the
protocol, so keeping this limit here prevents transfers to unexpectedly revert

*Add a general tag to an account. Restricted to Application Administrators. Loops through existing tags on accounts and will emit an event if tag is * already applied.*


```solidity
function addTagToMultipleAccounts(address[] memory _accounts, bytes32 _tag) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tag`|`bytes32`|Tag for the account. Can be any allowed string variant|


### addMultipleTagToMultipleAccounts

there is a hard limit of 10 tags per address.

*Add a general tag to an account at index in array. Restricted to Application Administrators. Loops through existing tags on accounts and will emit  an event if tag is already applied.*


```solidity
function addMultipleTagToMultipleAccounts(address[] memory _accounts, bytes32[] memory _tags) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|Address array to be tagged|
|`_tags`|`bytes32[]`|Tag array for the account at index. Can be any allowed string variant|



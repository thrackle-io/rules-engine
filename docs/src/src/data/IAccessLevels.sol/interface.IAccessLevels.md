# IAccessLevels
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/data/IAccessLevels.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md), [IAccessLevelErrors](/src/interfaces/IErrors.sol/interface.IAccessLevelErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

interface to define the functionality of the AccessLevel Levels data contract

*AccessLevel score storage and retrieval functions are defined here*


## Functions
### addLevel

*Add the Access Level to the account. Restricted to the owner*


```solidity
function addLevel(address _address, uint8 _level) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_level`|`uint8`|access levellevel(0-4)|


### removelevel

*Remove the Access Level for the account. Restricted to the owner*


```solidity
function removelevel(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### getAccessLevel

*Get the Access Level for the account. Restricted to the owner*


```solidity
function getAccessLevel(address _account) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|level Access Level(0-4)|


### addAccessLevelToMultipleAccounts

*Add the Access Level(0-4) to multiple accounts. Restricted to Access Tiers.*


```solidity
function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address upon which to apply the Access Level|
|`_level`|`uint8`|Access Level to add|



# OracleRestricted
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/example/OracleRestricted.sol)

**Inherits:**
Ownable, [IOracleEvents](/src/interfaces/IEvents.sol/interface.IOracleEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example on-chain oracle that maintains a restricted list.

*This is intended to be a model only. It stores the allow list internally and returns bool true if address is in list.*


## State Variables
### sanctionedAddresses

```solidity
mapping(address => bool) private sanctionedAddresses;
```


## Functions
### constructor

*Constructor that only serves the purpose of notifying the indexer of its creation via event*


```solidity
constructor();
```

### name

*Return the contract name*


```solidity
function name() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|name the name of the contract|


### addToSanctionsList

*Add addresses to the sanction list. Restricted to owner.*


```solidity
function addToSanctionsList(address[] memory newSanctions) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSanctions`|`address[]`|the addresses to add|


### addAddressToSanctionsList

*Add single address to the allow list. Restricted to owner.*


```solidity
function addAddressToSanctionsList(address newSanction) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newSanction`|`address`|the addresses to add|


### removeFromSanctionsList

*Remove addresses from the restricted list. Restricted to owner.*


```solidity
function removeFromSanctionsList(address[] memory removeSanctions) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`removeSanctions`|`address[]`|the addresses to remove|


### isRestricted

*Check to see if address is in restricted list*


```solidity
function isRestricted(address addr) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|restricted returns true if in the restricted list, false if not.|


### isRestrictedVerbose

*Check to see if address is in restricted list. Also emits events based on the results*


```solidity
function isRestrictedVerbose(address addr) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|restricted returns true if in the restricted list, false if not.|



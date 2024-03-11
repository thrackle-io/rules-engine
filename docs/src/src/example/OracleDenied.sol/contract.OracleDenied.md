# OracleDenied
[Git Source](https://github.com/thrackle-io/tron/blob/13105ed31bc78c8d50cdf97173deb83a68e88dee/src/example/OracleDenied.sol)

**Inherits:**
Ownable, [IOracleEvents](/src/common/IEvents.sol/interface.IOracleEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example on-chain oracle that maintains a denied list.

*This is intended to be a model only. It stores the Denied list internally and returns bool true if address is in list.*


## State Variables
### deniedAddresses

```solidity
mapping(address => bool) private deniedAddresses;
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


### addToDeniedList

*Add addresses to the denied list. Restricted to owner.*


```solidity
function addToDeniedList(address[] memory newDeniedAddrs) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newDeniedAddrs`|`address[]`|the addresses to add|


### addAddressToDeniedList

*Add single address to the denied list. Restricted to owner.*


```solidity
function addAddressToDeniedList(address newDeniedAddr) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newDeniedAddr`|`address`|the addresses to add|


### removeFromDeniedList

*Remove addresses from the Denied list. Restricted to owner.*


```solidity
function removeFromDeniedList(address[] memory removeDeniedAddrs) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`removeDeniedAddrs`|`address[]`|the addresses to remove|


### isDenied

*Check to see if address is in denied list*


```solidity
function isDenied(address addr) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|denied returns true if in the denied list, false if not.|


### isDeniedVerbose

*Check to see if address is in denied list. Also emits events based on the results*


```solidity
function isDeniedVerbose(address addr) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|denied returns true if in the denied list, false if not.|



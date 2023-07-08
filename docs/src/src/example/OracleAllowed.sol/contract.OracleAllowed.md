# OracleAllowed
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/example/OracleAllowed.sol)

**Inherits:**
Ownable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example on-chain oracle that maintains an allow list.

*This is intended to be a model only. It stores the allow list internally and returns bool true if address is in list.*


## State Variables
### allowedAddresses

```solidity
mapping(address => bool) private allowedAddresses;
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


### addToAllowList

*Add addresses to the allow list. Restricted to owner.*


```solidity
function addToAllowList(address[] memory newAllows) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newAllows`|`address[]`|the addresses to add|


### addAddressToAllowList

*Add single address to the allow list. Restricted to owner.*


```solidity
function addAddressToAllowList(address newAllow) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newAllow`|`address`|the addresses to add|


### removeFromAllowedList

*Remove addresses from the allow list. Restricted to owner.*


```solidity
function removeFromAllowedList(address[] memory removeAllows) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`removeAllows`|`address[]`|the addresses to remove|


### isAllowed

*Check to see if address is in allowed list*


```solidity
function isAllowed(address addr) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|allowed returns true if in the allowed list, false if not.|


### isAllowedVerbose

*Check to see if address is in allowed list. Also emits events based on the results*


```solidity
function isAllowedVerbose(address addr) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|allowed returns true if in the allowed list, false if not.|


## Events
### AllowedAddress

```solidity
event AllowedAddress(address indexed addr);
```

### AllowedAddressesAdded

```solidity
event AllowedAddressesAdded(address[] addrs);
```

### AllowedAddressAdded

```solidity
event AllowedAddressAdded(address addrs);
```

### AllowedAddressesRemoved

```solidity
event AllowedAddressesRemoved(address[] addrs);
```

### NotAllowedAddress

```solidity
event NotAllowedAddress(address indexed addr);
```

### AllowListOracleDeployed

```solidity
event AllowListOracleDeployed();
```


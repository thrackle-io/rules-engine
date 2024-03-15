# OracleApproved
[Git Source](https://github.com/thrackle-io/tron/blob/d4dc3a1319e6df3195618c1297a6c755d61cf319/src/example/OracleApproved.sol)

**Inherits:**
Ownable, [IOracleEvents](/src/common/IEvents.sol/interface.IOracleEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example on-chain oracle that maintains an approve list.

*This is intended to be a model only. It stores the approve list internally and returns bool true if address is in list.*


## State Variables
### approvedAddresses

```solidity
mapping(address => bool) private approvedAddresses;
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


### addToApprovedList

*Add addresses to the approve list. Restricted to owner.*


```solidity
function addToApprovedList(address[] memory newApproves) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newApproves`|`address[]`|the addresses to add|


### addAddressToApprovedList

*Add single address to the approve list. Restricted to owner.*


```solidity
function addAddressToApprovedList(address newApprove) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newApprove`|`address`|the addresses to add|


### removeFromAprovededList

*Remove addresses from the approve list. Restricted to owner.*


```solidity
function removeFromAprovededList(address[] memory removeApproves) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`removeApproves`|`address[]`|the addresses to remove|


### isApproved

*Check to see if address is in approved list*


```solidity
function isApproved(address addr) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|approved returns true if in the approved list, false if not.|


### isApprovedVerbose

*Check to see if address is in approved list. Also emits events based on the results*


```solidity
function isApprovedVerbose(address addr) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`addr`|`address`|the address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|approved returns true if in the approved list, false if not.|



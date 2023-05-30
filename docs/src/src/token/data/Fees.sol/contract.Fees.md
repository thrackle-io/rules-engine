# Fees
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/941799bce65220406b4d9686c5c5f1ae7c99f4ee/src/token/data/Fees.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a storage for fees

*Uses DataAppManager, which has basic ownable functionality. It will get created, and therefore owned, by the creating contract*


## State Variables
### defaultFee

```solidity
int256 defaultFee;
```


### feesByTag

```solidity
mapping(bytes32 => Fee) feesByTag;
```


### feeTotal

```solidity
uint256 feeTotal;
```


## Functions
### addFee

*This function adds a fee to the token*


```solidity
function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|
|`_minBalance`|`uint256`|minimum balance for fee application|
|`_maxBalance`|`uint256`|maximum balance for fee application|
|`_feePercentage`|`int24`|fee percentage to assess|
|`_targetAccount`|`address`|fee percentage to assess|


### removeFee

*This function adds a fee to the token*


```solidity
function removeFee(bytes32 _tag) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|


### getFee

*returns the full mapping of fees*


```solidity
function getFee(bytes32 _tag) public view onlyOwner returns (Fee memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Fee`|fee struct containing fee data|


### getFeeTotal

*returns the full mapping of fees*


```solidity
function getFeeTotal() external view onlyOwner returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|feeTotal total number of fees|


### getMaxUint

*this is a quick and dirty way of getting the max uint without using exponents or hardcoding the 78 digit number.*


```solidity
function getMaxUint() internal pure returns (uint256);
```

## Errors
### InvertedLimits

```solidity
error InvertedLimits();
```

### ValueOutOfRange

```solidity
error ValueOutOfRange(uint24 percentage);
```

### ZeroValueNotPermited

```solidity
error ZeroValueNotPermited();
```

### BlankTag

```solidity
error BlankTag();
```

## Structs
### Fee

```solidity
struct Fee {
    uint256 minBalance;
    uint256 maxBalance;
    int24 feePercentage;
    address feeCollectorAccount;
    bool isValue;
}
```


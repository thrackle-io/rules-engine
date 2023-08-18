# Fees
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/32fc908f43bfbb804e52e049074d30ce661a637a/src/token/data/Fees.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/interfaces/IEvents.sol/interface.IApplicationEvents.md), [IInputErrors](/src/interfaces/IErrors.sol/interface.IInputErrors.md), [ITagInputErrors](/src/interfaces/IErrors.sol/interface.ITagInputErrors.md), [IOwnershipErrors](/src/interfaces/IErrors.sol/interface.IOwnershipErrors.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md), [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a storage for asset transfer fees

*This contract should not be accessed directly. All processing should go through its controlling asset(ProtocolERC20, ProtocolERC721, etc.)*


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


### newOwner

```solidity
address newOwner;
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


### proposeOwner

*this function proposes a new owner that is put in storage to be confirmed in a separate process*


```solidity
function proposeOwner(address _newOwner) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|the new address being proposed|


### confirmOwner

*this function confirms a new asset handler address that was put in storage. It can only be confirmed by the proposed address*


```solidity
function confirmOwner() external;
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


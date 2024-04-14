# Fees
[Git Source](https://github.com/thrackle-io/tron/blob/c8d7d0c68b3a2cdcb9e6e4cb41159f2dda90a8b6/src/client/token/handler/ruleContracts/Fees.sol)

**Inherits:**
[IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [ITokenHandlerEvents](/src/common/IEvents.sol/interface.ITokenHandlerEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [ITagInputErrors](/src/common/IErrors.sol/interface.ITagInputErrors.md), [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IFeesErrors](/src/common/IErrors.sol/interface.IFeesErrors.md), [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract serves as a storage for asset transfer fees

*This contract should not be accessed directly. All processing should go through its controlling asset(ProtocolERC20, ProtocolERC721, etc.)*


## State Variables
### BLANK_TAG

```solidity
bytes32 constant BLANK_TAG = bytes32("");
```


## Functions
### addFee

*This function adds a fee to the token. Blank tags are allowed*


```solidity
function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount)
    external
    ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
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

*This function removes a fee to the token*


```solidity
function removeFee(bytes32 _tag) external ruleAdministratorOnly(lib.handlerBaseStorage().appManager);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|


### getFee

*returns the full mapping of fees*


```solidity
function getFee(bytes32 _tag) public view returns (Fee memory);
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
function getFeeTotal() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|feeTotal total number of fees|


### getApplicableFees

*Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.*


```solidity
function getApplicableFees(address _from, uint256 _balanceFrom)
    public
    view
    returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|originating address|
|`_balanceFrom`|`uint256`|Token balance of the sender address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`feeCollectorAccounts`|`address[]`|list of where the fees are sent|
|`feePercentages`|`int24[]`|list of all applicable fees/discounts|



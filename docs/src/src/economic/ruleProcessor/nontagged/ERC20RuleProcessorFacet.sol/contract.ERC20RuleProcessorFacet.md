# ERC20RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/economic/ruleProcessor/nontagged/ERC20RuleProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Fee Rules on Accounts.

*Facet in charge of the logic to check token rules compliance*


## Functions
### checkMinTransferPasses

*Check if transaction passes minTransfer rule.*


```solidity
function checkMinTransferPasses(uint32 _ruleId, uint256 amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred|


### checkOraclePasses

*This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkOraclePasses(uint32 _ruleId, address _address) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id|
|`_address`|`address`|user address to be checked|


## Errors
### BelowMinTransfer

```solidity
error BelowMinTransfer();
```

### AddressIsRestricted

```solidity
error AddressIsRestricted();
```

### AddressNotOnAllowedList

```solidity
error AddressNotOnAllowedList();
```

### OracleTypeInvalid

```solidity
error OracleTypeInvalid();
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```


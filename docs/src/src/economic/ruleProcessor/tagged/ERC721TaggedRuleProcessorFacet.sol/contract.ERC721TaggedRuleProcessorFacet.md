# ERC721TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/ruleProcessor/tagged/ERC721TaggedRuleProcessorFacet.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Non-Fungible Token Checks on Tagged Accounts.

*This contract implements rules to be checked by Handler.*


## Functions
### minAccountBalanceERC721

*Check if tagged account passes minAccountBalanceERC721 rule*


```solidity
function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata fromTags, uint32 ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Number of tokens held by sender address|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### maxAccountBalanceERC721

This Function checks the min account balance for accounts depending on GeneralTags.
Function will revert if a transaction breaks a single tag-dependent rule
if a min is 0 then no need to check.

*Check if tagged account passes maxAccountBalanceERC721 rule*


```solidity
function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] calldata toTags, uint32 ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceTo`|`uint256`|Number of tokens held by recipient address|
|`toTags`|`bytes32[]`|Account tags applied to recipient via App Manager|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


## Errors
### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### BalanceBelowMin

```solidity
error BalanceBelowMin();
```

### MaxBalanceExceeded

```solidity
error MaxBalanceExceeded();
```


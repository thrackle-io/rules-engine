# ERC721TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [ITagRuleErrors](/src/interfaces/IErrors.sol/interface.ITagRuleErrors.md), [IMaxTagLimitError](/src/interfaces/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Non-Fungible Token Checks on Tagged Accounts.

*This contract implements rules to be checked by Handler.*


## Functions
### checkMinMaxAccountBalanceERC721

*Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.*


```solidity
function checkMinMaxAccountBalanceERC721(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    bytes32[] calldata toTags,
    bytes32[] calldata fromTags
) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### minAccountBalanceERC721

*Check if tagged account passes minAccountBalanceERC721 rule*


```solidity
function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] calldata fromTags, uint32 ruleId) internal view;
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
function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] calldata toTags, uint32 ruleId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceTo`|`uint256`|Number of tokens held by recipient address|
|`toTags`|`bytes32[]`|Account tags applied to recipient via App Manager|
|`ruleId`|`uint32`|Rule identifier for rule arguments|



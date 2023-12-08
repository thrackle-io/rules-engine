# ERC20TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [ITagRuleErrors](/src/common/IErrors.sol/interface.ITagRuleErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Rules on Tagged Accounts.

*Contract implements rules to be checked by Handler.*


## Functions
### checkMinMaxAccountBalancePasses

*Check the minimum/maximum rule. This rule ensures that both the to and from accounts do not
exceed the max balance or go below the min balance.*


```solidity
function checkMinMaxAccountBalancePasses(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    uint256 amount,
    bytes32[] calldata toTags,
    bytes32[] calldata fromTags
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkMinMaxAccountBalancePassesAMM

*Check the minimum/maximum rule through the AMM Swap*


```solidity
function checkMinMaxAccountBalancePassesAMM(
    uint32 ruleIdToken0,
    uint32 ruleIdToken1,
    uint256 tokenBalance0,
    uint256 tokenBalance1,
    uint256 amountIn,
    uint256 amountOut,
    bytes32[] calldata fromTags
) public view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleIdToken0`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`ruleIdToken1`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`tokenBalance0`|`uint256`|Token balance of the token being swapped|
|`tokenBalance1`|`uint256`|Token balance of the received token|
|`amountIn`|`uint256`|total number of tokens to be swapped|
|`amountOut`|`uint256`|total number of tokens to be received|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### maxAccountBalanceCheck

*Check if tagged account passes maxAccountBalance rule*


```solidity
function maxAccountBalanceCheck(uint256 balanceTo, bytes32[] calldata toTags, uint256 amount, uint32 ruleId)
    public
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceTo`|`uint256`|Number of tokens held by recipient address|
|`toTags`|`bytes32[]`|Account tags applied to recipient via App Manager|
|`amount`|`uint256`|Number of tokens to be transferred|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### minAccountBalanceCheck

This Function checks the max account balance for accounts depending on GeneralTags.
Function will revert if a transaction breaks a single tag-dependent rule
if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0

*Check if tagged account passes minAccountBalance rule*


```solidity
function minAccountBalanceCheck(uint256 balanceFrom, bytes32[] calldata fromTags, uint256 amount, uint32 ruleId)
    public
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Number of tokens held by sender address|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`amount`|`uint256`|Number of tokens to be transferred|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### getMinMaxBalanceRule

This Function checks the min account balance for accounts depending on GeneralTags.
Function will revert if a transaction breaks a single tag-dependent rule
if a min is 0 then no need to check.

*Function get the minMaxBalanceRule in the rule set that belongs to an account type*


```solidity
function getMinMaxBalanceRule(uint32 _index, bytes32 _accountType)
    public
    view
    returns (TaggedRules.MinMaxBalanceRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of Accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.MinMaxBalanceRule`|minMaxBalanceRule at index location in array|


### getTotalMinMaxBalanceRules

*Function gets total Balance Limit rules*


```solidity
function getTotalMinMaxBalanceRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkAdminWithdrawalRule

that the function will revert if the check finds a violation of the rule, but won't give anything
back if everything checks out.

*checks that an admin won't hold less tokens than promised until a certain date*


```solidity
function checkAdminWithdrawalRule(uint32 ruleId, uint256 currentBalance, uint256 amount) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`currentBalance`|`uint256`|of tokens held by the admin|
|`amount`|`uint256`|Number of tokens to be transferred|


### getAdminWithdrawalRule

*Function gets Admin withdrawal rule at index*


```solidity
function getAdminWithdrawalRule(uint32 _index) public view returns (TaggedRules.AdminWithdrawalRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AdminWithdrawalRule`|adminWithdrawalRulesPerToken rule at indexed postion|


### getTotalAdminWithdrawalRules

*Function to get total Admin withdrawal rules*


```solidity
function getTotalAdminWithdrawalRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminWithdrawalRulesPerToken total length of array|


### checkMinBalByDatePasses

*Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified*


```solidity
function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`balance`|`uint256`|account's current balance|
|`amount`|`uint256`|Number of tokens to be transferred from this account|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|


### getMinBalByDateRule

first check to see if still in the hold period
If the transaction will violate the rule, then revert

*Function get the minimum balance by date rule in the rule set that belongs to an account type*


```solidity
function getMinBalByDateRule(uint32 _index, bytes32 _accountTag)
    public
    view
    returns (TaggedRules.MinBalByDateRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountTag`|`bytes32`|Tag of account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.MinBalByDateRule`|Min BalanceByDate rule at index position|


### getTotalMinBalByDateRules

*Function to get total minimum balance by date rules*


```solidity
function getTotalMinBalByDateRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



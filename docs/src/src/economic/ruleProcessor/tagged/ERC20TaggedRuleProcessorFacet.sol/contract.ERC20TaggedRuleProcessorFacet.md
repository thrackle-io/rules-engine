# ERC20TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/ruleProcessor/tagged/ERC20TaggedRuleProcessorFacet.sol)

**Inherits:**
Context, [ERC173](/src/diamond/implementations/ERC173/ERC173.sol/abstract.ERC173.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Rules on Tagged Accounts.

*Contract implements rules to be checked by Handler.*


## State Variables
### VERSION

```solidity
uint8 public constant VERSION = 1;
```


## Functions
### maxAccountBalanceCheck

*Check if tagged account passes maxAccountBalance rule*


```solidity
function maxAccountBalanceCheck(uint256 balanceTo, bytes32[] calldata toTags, uint256 amount, uint32 ruleId)
    external
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
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Number of tokens held by sender address|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`amount`|`uint256`|Number of tokens to be transferred|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### purchaseLimit

This Function checks the min account balance for accounts depending on GeneralTags.
Function will revert if a transaction breaks a single tag-dependent rule
if a min is 0 then no need to check.

*Rule checks if recipient balance + amount exceeded purchaseAmount during purchase period, prevent purchases for freeze period*


```solidity
function purchaseLimit(
    uint32 ruleId,
    uint256 purchasedWithinPeriod,
    uint256 amount,
    bytes32[] calldata toTags,
    uint64 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`purchasedWithinPeriod`|`uint256`|Number of tokens purchased within purchase Period|
|`amount`|`uint256`|Number of tokens to be transferred|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint64`|block.timestamp of most recent transaction from sender.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|cumulativePurchaseTotal Total tokens sold within sell period.|


### sellLimit

*Sell rule functions similar to purchase rule but "resets" at 12 utc after sellAmount is exceeded*


```solidity
function sellLimit(
    uint32 ruleId,
    uint256 salesWithinPeriod,
    uint256 amount,
    bytes32[] calldata fromTags,
    uint256 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`salesWithinPeriod`|`uint256`||
|`amount`|`uint256`|Number of tokens to be transferred|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint256`|block.timestamp of most recent transaction from sender.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|cumulativeSalesTotal Total tokens sold within sell period.|


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


## Errors
### MaxBalanceExceeded

```solidity
error MaxBalanceExceeded();
```

### BalanceBelowMin

```solidity
error BalanceBelowMin();
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### TxnInFreezeWindow

```solidity
error TxnInFreezeWindow();
```

### TemporarySellRestriction

```solidity
error TemporarySellRestriction();
```


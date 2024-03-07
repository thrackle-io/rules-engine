# ERC20TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [ITagRuleErrors](/src/common/IErrors.sol/interface.ITagRuleErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Rules on Tagged Accounts.

*Contract implements rules to be checked by Handler.*


## State Variables
### BLANK_TAG

```solidity
bytes32 constant BLANK_TAG = bytes32("");
```


## Functions
### checkAccountMinMaxTokenBalance

*Check the min/max token balance rule. This rule ensures that both the to and from accounts do not
exceed the max balance or go below the min balance.*


```solidity
function checkAccountMinMaxTokenBalance(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    uint256 amount,
    bytes32[] memory toTags,
    bytes32[] memory fromTags
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


### checkAccountMinMaxTokenBalanceAMM

*Check the min/max token balance rule through the AMM Swap*


```solidity
function checkAccountMinMaxTokenBalanceAMM(
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


### checkAccountMaxTokenBalance

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*Check if tagged account passes AccountMaxTokenBalance rule*


```solidity
function checkAccountMaxTokenBalance(uint256 balanceTo, bytes32[] memory toTags, uint256 amount, uint32 ruleId)
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


### checkAccountMinTokenBalance

check if period is 0, 0 means a period hasn't been applied to this rule
if a max is 0 it means it is an empty-rule/no-rule. a max should be greater than 0

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*Check if tagged account passes AccountMinTokenBalance rule*


```solidity
function checkAccountMinTokenBalance(uint256 balanceFrom, bytes32[] memory fromTags, uint256 amount, uint32 ruleId)
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


### getAccountMinMaxTokenBalanceStart

check if period is 0, 0 means a period hasn't been applied to this rule
Check to see if still in the hold period
If the transaction will violate the rule, then revert
if a min is 0 it means it is an empty-rule/no-rule. a min should be greater than 0

*Function get the min/max rule start timestamp*


```solidity
function getAccountMinMaxTokenBalanceStart(uint32 _index) public view returns (uint64 startTime);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint64`|rule start time|


### getAccountMinMaxTokenBalance

*Function get the accountMinMaxTokenBalance Rule in the rule set that belongs to an account type*


```solidity
function getAccountMinMaxTokenBalance(uint32 _index, bytes32 _accountType)
    public
    view
    returns (TaggedRules.AccountMinMaxTokenBalance memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of Accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AccountMinMaxTokenBalance`|accountMinMaxTokenBalance Rule at index location in array|


### getTotalAccountMinMaxTokenBalances

*Function gets total AccountMinMaxTokenBalances rules*


```solidity
function getTotalAccountMinMaxTokenBalances() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkAdminMinTokenBalance

that the function will revert if the check finds a violation of the rule, but won't give anything
back if everything checks out.

*Checks that an admin won't hold less tokens than promised until a certain date*


```solidity
function checkAdminMinTokenBalance(uint32 ruleId, uint256 currentBalance, uint256 amount) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`currentBalance`|`uint256`|of tokens held by the admin|
|`amount`|`uint256`|Number of tokens to be transferred|


### getAdminMinTokenBalance

*Function gets AdminMinTokenBalance rule at index*


```solidity
function getAdminMinTokenBalance(uint32 _index) public view returns (TaggedRules.AdminMinTokenBalance memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AdminMinTokenBalance`|adminMinTokenBalanceRules rule at indexed postion|


### getTotalAdminMinTokenBalance

*Function to get total AdminMinTokenBalance rules*


```solidity
function getTotalAdminMinTokenBalance() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminMinTokenBalanceRules total length of array|


### checkAccountMaxBuySize

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*Rule checks if recipient balance + amount exceeded purchaseAmount during purchase period, prevent purchases for freeze period*


```solidity
function checkAccountMaxBuySize(
    uint32 ruleId,
    uint256 boughtInPeriod,
    uint256 amount,
    bytes32[] memory toTags,
    uint64 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`boughtInPeriod`|`uint256`|Number of tokens bought during Period|
|`amount`|`uint256`|Number of tokens to be transferred|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint64`|block.timestamp of most recent transaction from sender.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|cumulativeTotal total amount of tokens bought within buy period.|


### getAccountMaxBuySize

*Function get the account max buy size rule in the rule set that belongs to an account type*


```solidity
function getAccountMaxBuySize(uint32 _index, bytes32 _accountType)
    public
    view
    returns (TaggedRules.AccountMaxBuySize memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AccountMaxBuySize`|AccountMaxBuySize rule at index position|


### getAccountMaxBuySizeStart

*Function get the account max buy size rule start timestamp*


```solidity
function getAccountMaxBuySizeStart(uint32 _index) public view returns (uint64 startTime);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint64`|startTimestamp of rule at index position|


### getTotalAccountMaxBuySize

*Function to get total account max buy size rules*


```solidity
function getTotalAccountMaxBuySize() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkAccountMaxSellSize

*Sell rule functions similar to account max buy size rule but "resets" at 12 utc after maxSize is exceeded*


```solidity
function checkAccountMaxSellSize(
    uint32 ruleId,
    uint256 salesInPeriod,
    uint256 amount,
    bytes32[] memory fromTags,
    uint64 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`salesInPeriod`|`uint256`||
|`amount`|`uint256`|Number of tokens to be transferred|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint64`|block.timestamp of most recent transaction from sender.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|cumulativeSales Total tokens sold within sell period.|


### getAccountMaxSellSizeByIndex

*Function to get Sell rule at index*


```solidity
function getAccountMaxSellSizeByIndex(uint32 _index, bytes32 _accountType)
    public
    view
    returns (TaggedRules.AccountMaxSellSize memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in array|
|`_accountType`|`bytes32`|Types of Accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AccountMaxSellSize`|AccountMaxSellSize at position in array|


### getAccountMaxSellSizeStartByIndex

*Function get the account max buy size rule start timestamp*


```solidity
function getAccountMaxSellSizeStartByIndex(uint32 _index) public view returns (uint64 startTime);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`startTime`|`uint64`|rule start timestamp.|


### getTotalAccountMaxSellSize

*Function to get total Sell rules*


```solidity
function getTotalAccountMaxSellSize() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



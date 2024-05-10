# ERC721TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/9006c7893599df6faee125cfb638dc80c156ce12/src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IERC721Errors](/src/common/IErrors.sol/interface.IERC721Errors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [ITagRuleErrors](/src/common/IErrors.sol/interface.ITagRuleErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Non-Fungible Token Checks on Tagged Accounts.

*This contract implements rules to be checked by a Token Handler.*


## State Variables
### BLANK_TAG

```solidity
bytes32 constant BLANK_TAG = bytes32("");
```


## Functions
### checkMinMaxAccountBalanceERC721

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*Check the minMaxAccoutBalance rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.*


```solidity
function checkMinMaxAccountBalanceERC721(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    bytes32[] memory toTags,
    bytes32[] memory fromTags
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

most restrictive tag will be enforced.

*Check if tagged account passes minAccountBalanceERC721 rule*


```solidity
function minAccountBalanceERC721(uint256 balanceFrom, bytes32[] memory fromTags, uint32 ruleId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Number of tokens held by sender address|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### maxAccountBalanceERC721

*Check if tagged account passes maxAccountBalanceERC721 rule*


```solidity
function maxAccountBalanceERC721(uint256 balanceTo, bytes32[] memory toTags, uint32 ruleId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceTo`|`uint256`|Number of tokens held by recipient address|
|`toTags`|`bytes32[]`|Account tags applied to recipient via App Manager|
|`ruleId`|`uint32`|Rule identifier for rule arguments|


### getAccountMinMaxTokenBalanceERC721

*Function get the Account Min Max Token Balance ERC721 rule in the rule set that belongs to a specific tag.*


```solidity
function getAccountMinMaxTokenBalanceERC721(uint32 _index, bytes32 _nftTag)
    public
    view
    returns (TaggedRules.AccountMinMaxTokenBalance memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_nftTag`|`bytes32`|nft tag for rule application|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AccountMinMaxTokenBalance`|AccountMinMaxTokenBalance at index location in array|


### getTotalAccountMinMaxTokenBalancesERC721

*Function gets total Account Min Max Token Balance ERC721 rules*


```solidity
function getTotalAccountMinMaxTokenBalancesERC721() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkTokenMaxDailyTrades

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*This function receives a rule id, which it uses to get the Token Max Daily Trades rule to check if the transfer is valid.*


```solidity
function checkTokenMaxDailyTrades(
    uint32 ruleId,
    uint256 transfersWithinPeriod,
    bytes32[] memory nftTags,
    uint64 lastTransferTime
) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`transfersWithinPeriod`|`uint256`|Number of transfers within the time period|
|`nftTags`|`bytes32[]`|NFT tags|
|`lastTransferTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### getTokenMaxDailyTrades

*Function get the Token Max Daily Trades rule in the rule set that belongs to an NFT type*


```solidity
function getTokenMaxDailyTrades(uint32 _index, bytes32 _nftType)
    public
    view
    returns (TaggedRules.TokenMaxDailyTrades memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_nftType`|`bytes32`|Type of NFT|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.TokenMaxDailyTrades`|TokenMaxDailyTrades at index location in array|


### getTotalTokenMaxDailyTrades

*Function gets total Token Max Daily Trades rules*


```solidity
function getTotalTokenMaxDailyTrades() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



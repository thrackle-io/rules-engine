# ERC721TaggedRuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IERC721Errors](/src/common/IErrors.sol/interface.IERC721Errors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [ITagRuleErrors](/src/common/IErrors.sol/interface.ITagRuleErrors.md), [IMaxTagLimitError](/src/common/IErrors.sol/interface.IMaxTagLimitError.md)

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
we decrease the balance to check the rule
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


### getMinMaxBalanceRuleERC721

we increase the balance to check the rule.

*Function get the account max buy size rule in the rule set that belongs to an account type*


```solidity
function getMinMaxBalanceRuleERC721(uint32 _index, bytes32 _accountType)
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
|`<none>`|`TaggedRules.MinMaxBalanceRule`|MinMaxBalanceRule at index location in array|


### getTotalMinMaxBalanceRulesERC721

*Function gets total Balance Limit rules*


```solidity
function getTotalMinMaxBalanceRulesERC721() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkTokenMaxDailyTrades

*This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.*


```solidity
function checkTokenMaxDailyTrades(
    uint32 ruleId,
    uint256 transfersWithinPeriod,
    bytes32[] calldata nftTags,
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

*Function get the NFT Transfer Counter rule in the rule set that belongs to an NFT type*


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
|`<none>`|`TaggedRules.TokenMaxDailyTrades`|NftTradeCounterRule at index location in array|


### getTotalTokenMaxDailyTrades

*Function gets total NFT Trade Counter rules*


```solidity
function getTotalTokenMaxDailyTrades() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



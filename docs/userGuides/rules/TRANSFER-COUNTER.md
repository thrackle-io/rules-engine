# Transfer Counter Rule

## Purpose

The purpose of the transfer-counter rule is to set and maintain a daily "trades" limit for all tokenId's within a collection. This allows for the reduction in volitility of tokens within the collection and the prevention of malfeasance for holders who transfer a token between addresses repeatedly. Trades are considered a transfer from one address to another for this rule. When this rule is active and the tradesAllowedPerDay is 0 this rule will act as a psuedo "soulBound" token, preventing all transfers of tokens in the collection. 

## Tokens Supported

- ERC721 

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

This is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. The tag is applied to the NFT collection address instead of individual users. The tranfer counter rule is composed of two components:

- tradesAllowedPerDay(uint8): The number of trades allowed per tokenId of the collection while the rule is active 
- startTs(uint64): The unnix timestamp for the time that the rule starts. 

```c
/// ******** NFT ********
    struct NFTTradeCounterRule {
        uint8 tradesAllowedPerDay;
        uint64 startTs; // starting timestamp for the rule
    }
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

Additionally, each one of these data structures will be under a tagged NFT Collection (bytes32):

tag -> token collection (sub-rule).

```javascript
    mapping(bytes32 => INonTaggedRules.NFTTradeCounterRule)
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

The tagged token collections then compose a transfer-counter rule.

 ```c
    struct NFTTransferCounterRuleS {
        /// ruleIndex => taggedNFT => tradesAllowed
        mapping(uint32 => mapping(bytes32 => INonTaggedRules.NFTTradeCounterRule)) NFTTransferCounterRule;
        uint32 NFTTransferCounterRuleIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

There is no limit to the amount of sub-rules that a rule can have other than at least one sub-rule.

### Role Applicability

- **Evaluation Exceptions**: 
    - This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction.

- **Configuration and Enabling/disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the asset handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
    - This rule can only be updated in the asset handler by a **rule administrator**.

## Rule Evaluation

The rule will be evaluated in the following way:

1. The collection being evaluated will pass to the protocol all the tags it has registered to its address in the application manager.
2. The processor will receive these tags along with the ID of the transfer-counter rule set in the token handler.
3. The processor will then try to retrieve the sub-rule associated with each tag.
4. The processor will evaluate whether the last transaction time for the tokenId is within the rule period from the starting timestamp. If yes, the rule will continue to the trades per day check. If no, the rule will return the new trades per day value for the token Id. 
5. The processor will evaluate if the total number of trades within the period plus the current trade would be more than the amount of trades allowed per day by the rule in the case of the transaction succeeding. If yes (trades will exceed allowable trades per day), then the transaction will revert.

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC721RuleProcessorFacet.sol) -> checkNFTTransferCounter*

### Create Function

Adding a transfer-counter rule is done through the function:

```c
function addNFTTransferCounterRule(
        address _appManagerAddr,
        bytes32[] calldata _nftTypes,
        uint8[] calldata _tradesAllowed,
        uint64 _startTs
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32)
```
bytes32 _nftTypes are the same as [tags](../GLOSSARY.md) and are applied to the ERC721 contract address in the App Manager. 

The registering function in the protocol needs to receive the appManager address of the application in order to verify that the caller has Rule administrator privileges. 

The function will return the protocol id of the rule.

###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)*

### Return Data

This rule returns a new tradesInPeriod(uint256) to the token handler on success.

```
mapping(uint256 => uint256) tradesInPeriod;
```
### Data Recorded

This rule requires that the handler record the timestamp for each tokenId's last trade. This is recorded only after the rule is activated and after each successfull transfer. 
```
mapping(uint256 => uint64) lastTxDate;
```
### Events

- **ProcotolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)** emitted when a Transfer counter rule has been added. For this rule:
    - ruleType is NFT_TRANSFER
    - index is the rule index set by the Protocol
    - extraTags is an empty array.

### Dependencies

- **Tags**: This rules relies on NFT Collections having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they must match the tag in the rule for it to have any effect.
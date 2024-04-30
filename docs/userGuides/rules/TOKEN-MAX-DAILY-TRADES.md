# Token Max Daily Trades

## Purpose

The token-max-daily-trades rule enforces a daily limit on the number of trades for each token within a collection. In the context of this rule, a "trade" is a transfer of a token from one address to another. Example uses of this rule: to mitigate price manipulation of tokens in the collection via the limitation of wash trading or the prevention of malfeasance for holders who transfer a token between addresses repeatedly. When this rule is active and the tradesAllowedPerDay is 0 this rule will act as a pseudo "soulBound" token, preventing all transfers of tokens in the collection.  

## Applies To:

- [ ] ERC20
- [x] ERC721
- [ ] AMM

## Applies To Actions:

- [x] MINT
- [ ] BURN
- [x] BUY
- [x] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at a token level. It must be activated and configured for each desired token collection in the corresponding token handler.

## Data Structure

This is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. In this case, the tag is applied to the NFT collection address. The transfer counter rule is composed of two components:

- **Trades allowed per day** (uint8): The number of trades allowed per tokenId of the collection while the rule is active 
- **Start timestamp** (uint64): The unix timestamp for the time that the rule starts. 

```c
/// ******** Token Max Daily Trades ********
    struct TokenMaxDailyTrades {
        uint8 tradesAllowedPerDay;
        uint64 startTime; // starting timestamp for the rule
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

If a single blank `tag` is specified, the rule is applicable to all users.

Additionally, each one of these data structures will be under a tagged NFT Collection (bytes32):

tag -> token collection (sub-rule).

```c
    //       tag         =>   sub-rule
    mapping(bytes32 => INonTaggedRules.TokenMaxDailyTrades)
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

The tagged token collections then compose a token-max-daily-trades rule.

 ```c
    struct TokenMaxDailyTradesS {
        /// ruleIndex => taggedNFT => tradesAllowed
        mapping(uint32 => mapping(bytes32 => INonTaggedRules.TokenMaxDailyTrades)) tokenMaxDailyTradesRules;
        uint32 tokenMaxDailyTradesIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

A token-max-daily-trades rule must have at least one sub-rule. There is no maximum number of sub-rules.

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.

## Rule Evaluation

The rule will be evaluated in the following way:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The collection being evaluated will pass to the protocol all the tags it has registered to its address in the application manager.
3. The processor will receive these tags along with the ID of the token-max-daily-trades rule set in the token handler.
4. The processor will then try to retrieve the sub-rule associated with each tag.
5. The processor will evaluate whether the trade is within a new period. If no, the rule will continue to the trades per day check (step 5). If yes, the rule will return `tradesInPeriod` of 1 (current trade) for the token Id. 
6. The processor will evaluate if the total number of trades within the period plus the current trade would be more than the amount of trades allowed per day by the rule in the case of the transaction succeeding. If yes (trades will exceed allowable trades per day), then the transaction will revert.

###### *see [ERC721RuleProcessor](../../../src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol) -> checkTokenMaxDailyTrades*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxDailyTrades();
```

The selector for this error is `0x09a92f2d`.
## Create Function

Adding a token-max-daily-trades rule is done through the function:

```c
function addTokenMaxDailyTrades(
        address _appManagerAddr,
        bytes32[] calldata _nftTags,
        uint8[] calldata _tradesAllowed,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32)
```
bytes32 _nftTags are the same as [tags](../GLOSSARY.md) and are applied to the ERC721 contract address in the App Manager.  

The function will return the protocol id of the rule.

###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)*

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_nftTags** (bytes32[]): array of types (tags) that the NFT contract has registered in the application manager.
- **_tradesAllowed** (uint8[]): the amount of trades allowed in a day.
- **_startTime** (uint64): starting timestamp of the rule. This timestamp will determine the time that a day starts and ends for the rule processing. For example, *the amount of trades will reset to 0 very day at 2:30 pm.*

### Parameter Optionality:

The parameters where developers have the options are:
- **_startTimes**: developers can pass Unix timestamps or simply 0s. If a `startTimestamp` is 0, then the protocol will interpret this as the timestamp of rule creation.  

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- All the parameter arrays have at least one element.
- All the parameter arrays have the exact same length.
- `tag` can either be a single blank tag or a list of non blank `tag`s.


###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getTokenMaxDailyTrades(
                    uint32 _index, 
                    bytes32 _nftTags
                ) 
                external 
                view 
                returns 
                (TaggedRules.TokenMaxDailyTrades memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTokenMaxDailyTrades() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTokenMaxDailyTrades(
                    uint32 ruleId, 
                    uint256 transfersWithinPeriod, 
                    bytes32[] calldata nftTags
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setTokenMaxDailyTradesId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateTokenMaxDailyTrades(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isTokenMaxDailyTradesActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getTokenMaxDailyTradesId(ActionTypes _action) external view returns (uint32);
        ```

### Return Data

This rule returns a new tradesInPeriod(uint256) to the token handler on success.

```c
mapping(uint256 => uint256) tradesInPeriod;
```
###### *see [ERC721Handler](../Architecture/Client/AssetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)*
### Data Recorded

This rule requires that the handler record the timestamp for each tokenId's last trade. This is recorded only after the rule is activated and after each successful transfer. 
```c
mapping(uint256 => uint64) lastTxDate;
```
###### *see [ERC721Handler](../Architecture/Client/AssetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)*
### Events

- **event AD1467_ProcotolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)** 
    - Emitted when: A Transfer counter rule has been added. For this rule:
    - Parameters:
        - ruleType: TOKEN_MAX_DAILY_TRADES.
        - index: the rule index set by the Protocol.
        - extraTags: an empty array.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: A Transfer counter rule has been added. For this rule:
    - Parameters: 
        - ruleType: TOKEN_MAX_DAILY_TRADES.
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: A Transfer counter rule has been activated in an asset handler:
    Parameters:
        - ruleType: TOKEN_MAX_DAILY_TRADES.
        - action: the protocol action for which the rule is being activated.

### Dependencies

- **Tags**: This rule relies on accounts having a matching [tag](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md) or the rule being configured with a blank [tag](../GLOSSARY.md).
# Transfer Counter Rule

## Purpose

The purpose of this rule is .

## Tokens Supported

- ERC721 

## Scope 

This rule works at a token level which means that it has to be activated and configured in each token handler it is desired to enforce this rule.

## Data Structure

S

- h
- h
- s

```c
/// ******** NFT ********
    struct NFTTradeCounterRule {
        uint8 tradesAllowedPerDay;
        uint64 startTs; // starting timestamp for the rule
    }
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

Additionally, each one of these data structures will be under a tag (bytes32):

 tag -> sub-rule.

 ```javascript
    mapping(bytes32 => ITaggedRules.MinBalByDateRule)
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

The collection of these tagged sub-rules composes a minumum-account-balance-by-date rule.

 ```c
    struct NFTTransferCounterRuleS {
        /// ruleIndex => taggedNFT => tradesAllowed
        mapping(uint32 => mapping(bytes32 => INonTaggedRules.NFTTradeCounterRule)) NFTTransferCounterRule;
        uint32 NFTTransferCounterRuleIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

There is no limit in the amount of sub-rules that a rule can have other than at least one sub-rule.

### Rule Registering

Registering a minimum-balance-by-date rule is done through the function:

```c
function addMinBalByDateRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTags,
        uint256[] calldata _holdAmounts,
        uint16[] calldata _holdPeriods,
        uint64[] calldata _startTimestamps
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```

The registering function in the protocol needs to receive the appManager address of the application in order to verify that the caller has Rule administrator privileges. 

The function will return the protocol id of the rule.

###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

### Role Applicability

- **Evaluation Exceptions**: 
    - This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
    - This rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

- **Configuration and Enabling/disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the asset handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
    - This rule can only be updated in the asset handler by a **rule administrator**.

## Rule Processing

The rule will be evaluated in the following way:

1. T

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinBalByDatePasses*

### Return Data

This rule doesn't return any data.

### Data Recorded

This rule doesn't require of any data to be recorded.

### Events

No events are emitted in this rule.

### Dependencies

This rule doesn't have any dependency.
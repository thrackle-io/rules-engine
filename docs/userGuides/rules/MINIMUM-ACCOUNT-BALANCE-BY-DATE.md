# Minimum Account Balance By Date Rule

## Purpose

The purpose of the minimum-balance-by-date rule is to prevent ERC20 token holders from rapidly flooding the market with newly acquired tokens since a dramatic increase in supply over a short time frame can cause a token price crash. This rule attempts to mitigates this scenario by making holders wait some period of time before they can sell their tokens. The length of time depends on the account's tags. Different accounts may need to wait different periods of time depending on their tags, or even no time at all.

## Tokens Supported

- ERC20

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. A minumum-balance-by-date "sub-rule" is specified by 3 variables:

- **Hold amount** (uint256): The minimum amount of tokens to be held by the account for the *hold-period* time.
- **Hold period** (uint16): The amount of hours to hold the tokens.
- **Starting timestamp** (uint64): The timestamp of the date when the *hold period* starts counting.

```c
/// ******** Minimum Balance By Date Rules ********
    struct MinBalByDateRule {
        uint256 holdAmount; /// token units
        uint16 holdPeriod; /// hours
        uint256 startTimeStamp; /// start
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
    /// ******** Minimum Balance By Date ********
    struct MinBalByDateRuleS {
        /// ruleIndex => userTag => rules
        mapping(uint32 => mapping(bytes32 => ITaggedRules.MinBalByDateRule)) minBalByDateRulesPerUser;
        uint32 minBalByDateRulesIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

A minimum-balance-by-date rule must have at least one sub-rule. There is no maximum number of sub-rules.

## Role Applicability

- **Evaluation Exceptions**: 
    - This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
    - This rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

- **Configuration and Enabling/Disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the asset handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
    - This rule can only be updated in the asset handler by a **rule administrator**.

## Create Function

Registering a minimum-balance-by-date rule is done through the function:

```javascript
function addMinBalByDateRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTags,
        uint256[] calldata _holdAmounts,
        uint16[] calldata _holdPeriods,
        uint64[] calldata _startTimestamps
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```

The registering function in the protocol needs to receive the appManager address of the application in order to verify that the caller has Rule administrator privileges. 

The registering function will return the protocol ID of the rule.

###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

## Rule Processing

The rule will be evaluated in the following way:

1. The account being evaluated will pass to the protocol all the tags it has registered to its address in the application manager.
2. The processor will receive these tags along with the ID of the minimum-balance-by-date rule set in the token handler. 
3. The processor then will try to retrieve the sub-rule associated with each tag of the account.
4. The processor will evaluate whether each sub-rule's hold period is still active (if the current time is within `hold period` from the `starting timestamp`). If it is, the processor will then evaluate if the final balance of the account would be less than the `hold amount` in the case of the transaction succeeding. If yes, then the transaction will revert.
5. Step 4 is repeated for each of the account's tags. 

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinBalByDatePasses*



### Return Data

This rule doesn't return any data.

### Data Recorded

This rule doesn't require of any data to be recorded.

### Events

No events are emitted in this rule.

### Dependencies

- **Tags**: This rules relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.


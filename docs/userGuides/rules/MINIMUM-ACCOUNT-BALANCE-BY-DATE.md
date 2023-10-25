# Minimum Account Balance By Date Rule

## Purpose

The purpose of this rule is to avoid ERC20 token holders to flood the market with their new tokens since this could effectively drive the supply up dramatically and, with it, cause a token price crash. In other words, this rule attempts to cool down traders by making them wait for some periods of time depending on their tags before they can sell their tokens. Due to the tagged nature of this rule, accounts have to wait for different periods of time depending on their tags, or even no time at all.

## Tokens Supported

- ERC20

## Scope 

This rule works at a token level which means that it has to be activated and configured in each token handler it is desired to enforce this rule.

## Data Structure

Due to the tagged nature of this rule, you can think of it as a collection of rules, where each "sub-rule" is totally independent from each other, and where each "sub-rule" is indexed by its tag. Therefore, a minumum-account-balance-by-date "sub-rule" is composed of 3 variables:

- Hold amount (uint256).
- hold period (uint16).
- starting timestamp (uint64).

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

## Rule Processing

The rule will be evaluated in the following way:

1. The account being evaluated will pass to the protocol all the tags it has registered to its address in the application manager.
2. The processor will receive these tags alongside the id of the minimum-balance-by-date rule set in the token handler. 
3. The processor then will try to retrieve the sub-rule associated with each tag of the account.
4. The processor will evaluate if such sub-rule's period is still active. If it is, the processor will then evaluate if the final balance of the account will be less than the minimum balance set in the sub-rule after the transaction is completed. If it will be in fact less than the minimum, then the transaction will revert.
5. The step 4 is repeated for each tag of the account. 

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinBalByDatePasses*

### Return Data

This rule doesn't return any data.

### Data Recorded

This rule doesn't require of any data to be recorded.

### Events

No events are emitted in this rule.

### Dependencies

This rule doesn't have any dependency.

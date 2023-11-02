# Minimum Account Balance By Date Rule

## Purpose

The purpose of the minimum-balance-by-date rule is to prevent token holders from rapidly flooding the market with newly acquired tokens since a dramatic increase in supply over a short time frame can cause a token price crash. This rule attempts to mitigate this scenario by making holders wait some period of time before they can transfer their tokens. The length of time depends on the account's tags. Different accounts may need to wait different periods of time depending on their tags, or even no time at all.

## Tokens Supported

- ERC20
- ERC721

## Scope 

This rule works at the application level which means that all tokens in the app will comply with this rule when the rule is active.

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

 ```c
    //      tag     =>   sub-rule
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
    - In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

- **Configuration and Enabling/Disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the asset handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
    - This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The account being evaluated will pass to the protocol all the tags it has registered to its address in the application manager.
2. The processor will receive these tags along with the ID of the minimum-balance-by-date rule set in the token handler. 
3. The processor will then try to retrieve the sub-rule associated with each tag.
4. The processor will evaluate whether each sub-rule's hold period is still active (if the current time is within `hold period` from the `starting timestamp`). If it is, the processor will then evaluate if the final balance of the account would be less than the `hold amount` in the case of the transaction succeeding. If yes, then the transaction will revert.
5. Step 4 is repeated for each of the account's tags. 

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinBalByDatePasses*

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error TxnInFreezeWindow();
```

The selector for this error is `0xa7fb7b4b`.

## Create Function

Adding a minimum-balance-by-date rule is done through the function:

```c
function addMinBalByDateRule(
            address _appManagerAddr,
            bytes32[] calldata _accountTags,
            uint256[] calldata _holdAmounts,
            uint16[] calldata _holdPeriods,
            uint64[] calldata _startTimestamps
        ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTags** (bytes32[]): array of tags that will contain each sub-rule.
- **_holdAmounts** (uint256[]): array of *hold amounts* for each sub-rule.
- **_holdPeriods** (uint16[]): array of *hold periods* for each sub-rule.
- **_startTimestamps** (uint64[]): array of *timestamps* for each sub-rule.

It is important to note that array positioning matters in this function. For instance, tag in position zero of the `_accountTags` array will contain the sub-rule created by the values in the position zero of `_holdAmounts`, `_holdPeriods` and `_startTimestamps`. Same with tag in posotion *n*.

### Parameter Optionality:

The parameters where developers have the options are:
- **_startTimestamps**: developers can pass Unix timestamps or simply 0s. If a `startTimestamp` is 0, then the protocol will interpret this as the timestamp of rule creation. The `_startTimestamps` array can have mixed options.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- All the parameter arrays have at least one element.
- All the parameter arrays have the exact same length.
- Not one `tag` can be a blank tag.
- Not one `holdAmount` nor `holdPeriod` can have a value of 0.


###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond]((../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)):
    -  Function to get a rule by its ID:
        ```c
        function getMinBalByDateRule(
                    uint32 _index, 
                    bytes32 _accountTag
                ) 
                external 
                view 
                returns 
                (TaggedRules.MinBalByDateRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalMinBalByDateRule() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkMinBalByDatePasses(
                    uint32 ruleId, 
                    uint256 balance, 
                    uint256 amount, 
                    bytes32[] calldata toTags
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setMinBalByDateRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateMinBalByDateRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isMinBalByDateActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getMinBalByDateRule() external view returns (uint32);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "MIN_ACCT_BAL_BY_DATE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: the tags for each sub-rule.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "MIN_ACCT_BAL_BY_DATE".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

- **Tags**: This rules relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.


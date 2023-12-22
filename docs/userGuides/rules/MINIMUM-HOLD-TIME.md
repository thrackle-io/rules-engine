# Minimum Account Balance By Date Rule

## Purpose

The purpose of the minimum-hold-time rule is to prevent 

## Applies To:

- [ ] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure



```c

```
###### *see [RuleDataInterfaces](../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*


## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The 
2. The 
3. 
4. 
5. 

###### *see [ERC20TaggedRuleProcessorFacet](../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinBalByDatePasses*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

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
            uint64 _startTime
        ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTags** (bytes32[]): array of tags that will contain each sub-rule.
- **_holdAmounts** (uint256[]): array of *hold amounts* for each sub-rule.
- **_holdPeriods** (uint16[]): array of *hold periods* for each sub-rule.
- **_startTimetamp** (uint64): *timestamp* that applies to each sub-rule.

It is important to note that array positioning matters in this function. For instance, tag in position zero of the `_accountTags` array will contain the sub-rule created by the values in the position zero of `_holdAmounts` and `_holdPeriods`. Same with tag in position *n*. The `_startTimestamp` applies to all subrules

### Parameter Optionality:

The parameters where developers have the options are:
- **_startTimestamp**: developers can pass a Unix timestamps or simply 0. If a `startTimestamp` is 0, then the protocol will interpret this as the timestamp of rule creation. 

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- All the parameter arrays have at least one element.
- All the parameter arrays have the exact same length.
- Not one `tag` can be a blank tag.
- Not one `holdAmount` nor `holdPeriod` can have a value of 0.


###### *see [TaggedRuleDataFacet](../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getMinBalByDateRule(
                    uint32 _index, 
                    bytes32 _accountTag
                ) 
                external 
                view 
                returns 
                (TaggedRules.MinBalByDateRule memory, uint64 startTime);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalMinBalByDateRule() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
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
    - Parameters: 
        - ruleType: "MIN_ACCT_BAL_BY_DATE".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

- **Tags**: This rule relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.


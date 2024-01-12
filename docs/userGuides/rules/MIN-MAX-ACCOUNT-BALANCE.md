# Minimum Maximum Account Balance Rule

## Purpose

The minimum-maximum-account-balance rule enforces token balance thresholds for user accounts with specific tags. This allows developers to set lower and upper limits on the amount of each token the user account can hold. This rule attempts to mitigate the risk of token holders selling more than the minimum allowed amount and accumulating more than the maximum allowed amount of tokens for each specific tag. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at both the token level and AMM level. It must be activated and configured for each desired token in the corresponding token handler or each desired AMM supported token within the AMM Handler.

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. A minumum-maximum-account-balance "sub-rule" is specified by 2 variables:

- **Minimum** (uint256): The minimum amount of tokens to be held by the account.
- **Maximum** (uint256): The maximum amount of tokens to be held by the account.


```c
/// ******** Minimum/Maximum Account Balances ********
    struct MinMaxBalanceRule {
        uint256 minimum;
        uint256 maximum;
    }
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

Additionally, each one of these data structures will be under a tag (bytes32):

 tag -> sub-rule.

 ```c
    //      tag     =>   sub-rule
    mapping(bytes32 => ITaggedRules.MinMaxBalanceRule)
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

The collection of these tagged sub-rules composes a minumum-maximum-account-balance rule.

 ```c
/// ******** Minimum/Maximum Account Balances ********
    /// ******** Minimum/Maximum Account Balances ********
struct MinMaxBalanceRuleS {
    /// ruleIndex => taggedAccount => minimumTransfer
    mapping(uint32 => mapping(bytes32 => ITaggedRules.MinMaxBalanceRule)) minMaxBalanceRulesPerUser;
    uint32 minMaxBalanceRuleIndex; /// increments every time someone adds a rule
}
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

A minumum-maximum-account-balance rule must have at least one sub-rule. There is no maximum number of sub-rules.

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The receiver account and the sender account being evaluated pass all the tags they have registered to their addresses in the application manager to the protocol.
2. The processor receives these tags along with the ID of the minumum-maximum-account-balance rule set in the token handler. 
3. The processor tries to retrieve the sub-rule associated with each tag.
4. The processor evaluates if the final balance of the sender account would be less than the`minimum` in the case of the transaction succeeding. If yes, the transaction reverts.
5. The processor evaluates if the final balance of the receiver account would be greater than the `maximum` in the case of the transaction succeeding. If yes, the transaction reverts.
6. Step 4 and 5 are repeated for each of the account's tags. 

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkMinMaxAccountBalancePasses*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.e.
- In the case of ERC20s and AMMs, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with one of the following errors if the rule check fails: 

```
error MaxBalanceExceeded();
```
```
error BalanceBelowMin();
```

The selectors for these errors are `0x24691f6b` and `0xf1737570` .

## Create Function

Adding a minumum-maximum-account-balance rule is done through the function:

```c
function addMinMaxBalanceRule(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _minimum,
        uint256[] calldata _maximum
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTags** (bytes32[]): array of tags that will contain each sub-rule.
- **_minimum** (uint256[]): array of *minimum amounts* for each sub-rule.
- **_maximum** (uint256[]): array of *maximum amounts* for each sub-rule.

It is important to note that array positioning matters in this function. For instance, tag in position zero of the `_accountTags` array will contain the sub-rule created by the values in the position zero of `_minimum` and `_maximum`. Same with tag in position *n*.

### Parameter Optionality:

There is no parameter optionality for this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- All the parameter arrays have at least one element.
- All the parameter arrays have the exact same length.
- Not one `tag` can be a blank tag.
- Not one `minimum` or `maximum` can have a value of 0.
- `minimum`is not greater than `maximum`


###### *see [TaggedRuleDataFacet](../../../src/economic/ruleStorage/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getMinMaxBalanceRule(
                    uint32 _index, 
                    bytes32 _accountTag
                ) 
                external 
                view 
                returns 
                (TaggedRules.MinMaxBalanceRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalMinMaxBalanceRules() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule for tokens:
        ```c
        function checkMinMaxAccountBalancePasses(
                uint32 ruleId, 
                uint256 balanceFrom, 
                uint256 balanceTo, 
                uint256 amount, 
                bytes32[] calldata toTags, 
                bytes32[] calldata fromTags
            ) 
            external 
            view;
        ```
    - Function that evaluates the rule for AMMs:
        ```c
        function checkMinMaxAccountBalancePassesAMM(
                uint32 ruleIdToken0,
                uint32 ruleIdToken1,
                uint256 tokenBalance0,
                uint256 tokenBalance1,
                uint256 amountIn,
                uint256 amountOut,
                bytes32[] calldata fromTags
            ) 
            public 
            view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setMinMaxBalanceRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isMinMaxBalanceActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getMinMaxBalanceRuleId() external view returns (uint32);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "MIN_MAX_BALANCE_LIMIT".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: the tags for each sub-rule.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "MIN_MAX_BALANCE_LIMIT".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the ruleId set for this rule in the handler.

- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)**:
    - Emitted when: rule has been activated in the asset handler.
    - Parameters:
        - ruleType: "MIN_MAX_BALANCE_LIMIT".
        - handlerAddress: the address of the asset handler where the rule has been activated.


## Dependencies

- **Tags**: This rule relies on accounts having [tags](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md), and they should match at least one of the tags in the rule for it to have any effect.


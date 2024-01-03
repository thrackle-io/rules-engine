# Minimum Transaction Rule

## Purpose

The purpose of the minimum-transaction rule is to prevent micro-trades or dust trades within an ecosystem. A developer can set the minimum number of tokens required per transfer to prevent these types of trades. 

## Applies To:

- [x] ERC20
- [ ] ERC721
- [ ] AMM

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

A minimum-transaction rule is composed of 1 component:

- **Min Transfer Amount**  (uint256): minimum number of tokens that must be transferred for each transaction. 

```c
    /// ******** Token Minimum Transfer Rules ********
    struct TokenMinimumTransferRule {
        uint256 minTransferAmount;
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

The minimum-transaction rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Minimum Transaction ********
    struct MinTransferRuleS {
        mapping(uint32 => INonTaggedRules.TokenMinimumTransferRule) minimumTransferRules;
        uint32 minimumTransferRuleIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The processor receives the ID of the minimum-transaction rule set in the token handler. 
2. The processor receives the `amount` of tokens from the handler.
3. The processor evaluates the `amount` against the rule `minTransferAmount` and reverts if the `amount` less than the rule minimum. 


###### *see [ERC20RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkMinTransferPasses*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error BelowMinTransfer();
```

The selector for this error is `0x70311aa2`.

## Create Function

Adding a minimum-transaction rule is done through the function:

```c
function addMinimumTransferRule(
    address _appManagerAddr,
    uint256 _minimumTransfer
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_minimumTransfer** (uint256): Minimum number of tokens for the transaction.


### Parameter Optionality:

There is no parameter optionality for this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_minimumTransfer` is greater than 0.


###### *see [RuleDataFacet](../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getMinimumTransferRule(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.TokenMinimumTransferRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalMinimumTransferRules() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkMinTransferPasses(
                    uint32 _ruleId, 
                    uint256 _amountToTransfer
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateMinTransfereRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isMinTransferActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getMinTransferRuleId() external view returns (uint32);
        ```
## Return Data

This rule does not return any data.

## Data Recorded

This rule does not require any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "MIN_TRANSFER".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "MIN_TRANSFER".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

- **ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)** emitted when a Transfer counter rule has been activated in an asset handler:
    - ruleType: "MIN_TRANSFER".
    - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- This rule has no dependencies.
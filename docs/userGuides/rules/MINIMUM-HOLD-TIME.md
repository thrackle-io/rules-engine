# Minimum Account Balance By Date Rule

## Purpose

The purpose of the minimum-hold-time rule is to reduce trade volitility by preventing transfers of tokens for a number of hours after ownership is acquired, either via minting or transfers. This rule allows developers to specifiy a number of hours, up to 43830 (5 years), that each tokenId must be held for.  

## Applies To:

- [ ] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

The rule is a uint32 variable for number of hours each individual token must be held by the owner of that tokenId, up to a maximum of 43830 hours or 5 years. 

```c
/// simple rule(with single parameter) variables
    uint32 private minimumHoldTimeHours;
```

Additionally, each starting unix timestamp for the ownership of the tokenId is stored in a mapping inside the hanlder. 

```c
/// Minimum Hold time data
    mapping(uint256 => uint256) ownershipStart;
```
###### *see [ERC721Handler](../../../src/client/token/ERC721/ProtocolERC721Handler.sol)*


## Configuration and Enabling/Disabling
- This rule can only be configured in the handler by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler evaluates the account's `ownershipStart` to check that it is greater than zero.
2. The handler passes the account's `ownershipStart` and `minimumHoldTimeHours` to the processor. 
3. The Processor evaluates if the current time minus `ownershipStart` is less than `minimumHoldTimeHours`. If it is the transaction reverts.

###### *see [ERC721RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol) -> checkNFTHoldTime*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.


### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error MinimumHoldTimePeriodNotReached();
```

The selector for this error is `0x6d12e45a`.

## Create Function

Adding a minimum-hold-time rule is done through the function:

```c
function setMinimumHoldTimeHours(
            uint32 _minimumHoldTimeHours
        ) external ruleAdministratorOnly(_appManagerAddr);
```
###### *see [ERC721Handler](../../../src/client/token/ERC721/ProtocolERC721Handler.sol)*


### Parameters:

- **_minimumHoldTimeHours** (uint32): Number of hours each tokenId must be held for.


### Parameter Optionality:

There is no parameter optionality for this rule.  

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_minimumHoldTimeHours` is greater than zero.
- `_minimumHoldTimeHours` is less than `MAX_HOLD_TIME_HOURS`.


###### *see [ERC721Handler](../../../src/client/token/ERC721/ProtocolERC721Handler.sol)*

## Other Functions:

- in Asset Handler:
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateMinimumHoldTimeRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isMinimumHoldTimeActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getMinimumHoldTimeHours() external view returns (uint256);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule requires the unix timestamp for each tokenId each time the ownership of the token is transferred.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "MINIMUM_HOLD_TIME".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: the tags for each sub-rule.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "MINIMUM_HOLD_TIME".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the ruleId set for this rule in the handler.

## Dependencies

- This rule has no dependencies.


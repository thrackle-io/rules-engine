# Token Min Hold Time

## Purpose

The purpose of the token-min-hold-time rule is to reduce trade volitility by preventing transfers of tokens for a number of hours after ownership is acquired, either via minting or transfers. This rule allows developers to specifiy a number of hours, up to 43830 (5 years), that each tokenId must be held for.  

## Applies To:

- [ ] ERC20
- [x] ERC721
- [ ] AMM

## Applies To Actions:

- [ ] MINT
- [x] BURN
- [ ] BUY
- [x] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

The rule is a uint32 variable for number of hours each individual token must be held by the owner of that tokenId, up to a maximum of 43830 hours or 5 years. 

```c
/// simple rule(with single parameter) variables
    uint32 private period;
```

Additionally, each starting unix timestamp for the ownership of the tokenId is stored in a mapping inside the handler. 

```c
/// Minimum Hold time data
    mapping(uint256 => uint256) ownershipStart;
```
###### *see [ERC721Handler](../architecture/client/assetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)*


## Configuration and Enabling/Disabling
- This rule can only be configured in the handler by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The handler evaluates the account's `ownershipStart` to check that it is greater than zero.
3. The handler passes the account's `ownershipStart` and `period` to the processor. 
4. The Processor evaluates if the current time minus `ownershipStart` is less than `period`. If it is the transaction reverts.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC721RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC721RuleProcessorFacet.sol) -> checkTokenMinHoldTime*

## Evaluation Exceptions 
- This rule doesn't apply when a **treasuryAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an treasury account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.


### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error UnderHoldPeriod();
```

The selector for this error is `0x5f98112f`.

## Create Function

Adding a token-min-hold-time rule for the supplied actions is done through the function:

```c
function setTokenMinHoldTime(
            ActionTypes[] calldata _actions,
            uint32 _minHoldTimeHours
        ) external ruleAdministratorOnly(_appManagerAddr);
```
###### *see [ERC721Handler](../architecture/client/assetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)*


### Parameters:

- **_minHoldTimeHours** (uint32): Number of hours each tokenId must be held for.


### Parameter Optionality:

There is no parameter optionality for this rule.  

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_minHoldTimeHours` is greater than zero.
- `_minHoldTimeHours` is less than `MAX_HOLD_TIME_HOURS`.


###### *see [ERC721Handler](../architecture/client/assetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)*

## Other Functions:

- in Asset Handler:
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateTokenMinHoldTime(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isTokenMinHoldTimeActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getTokenMinHoldTimePeriod(ActionTypes _action) external view returns (uint256);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule requires the unix timestamp for each tokenId each time the ownership of the token is transferred.

NOTE: When this rule is updated and/or deactivated, the recorded data is cleared. When the rule is reactivated or set to a new ruleId, the recorded data will start in its default state.

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TOKEN_MIN_HOLD_TIME".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: the tags for each sub-rule.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "TOKEN_MIN_HOLD_TIME".
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.

- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: A Minimum Hold TIme rule has been activated in an asset handler:
    - Parameters:
        - ruleType: "TOKEN_MIN_HOLD_TIME".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- This rule has no dependencies.


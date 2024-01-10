# Pause Rule

## Purpose

The purpose of the pause rule is to allow developers to pause the entirety of an application for maintenance, security or any other reason. Pausing the application means that no transfer of tokens is allowed at any level (with the few exceptions listed in the Role Applicability section). 

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A pause rule is composed of 3 components:

- **Date Created** (uint256): The timestamp of the creation of the rule.
- **Pause Start** (uint256): The timestamp where the pause rule starts.
- **Pause Stop** (uint256): The timestamp where the pause rule ends.

```c
struct PauseRule {
    uint256 dateCreated;
    uint256 pauseStart;
    uint256 pauseStop;
}
```
###### *see [PauseRule](../../../src/client/application/data/PauseRule.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The protocol's rule processor retrieves all the pause rules stored in the data contract of the appManager. 
2. The processor loops through all these pause rules, and evaluates if current timestamp is greater or equal to `pauseStart` and less than `pauseStop`. If the condition is true for at least one rule, then the transaction reverts.

###### *see [ApplicationPauseProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol) -> checkPauseRules*

## Evaluation Exceptions 
- This rule doesn't apply when an **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error ApplicationPaused(uint256 started, uint256 ends);
```

The selector for this error is `0x33385551`.


## Create Function

Adding a pause rule is done through the function:

```c
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyRole(RULE_ADMIN_ROLE);
```
###### *see [AppManager](../../../src/client/application/AppManager.sol)*

### Parameters:

- **_pauseStart** (uint256): the Unix timestamp for the start of the paused period.
- **_pauseStop** (uint256): the Unix timestamp for the end of the paused period.

The create function will return the protocol ID of the rule.

This create function will also delete automatically any pause rule where the `pauseStop` timestamp is less than current timestamp  since this means that the rule has *expired*. 

There is a default limit of 15 pause rules per application to avoid too much gas consumption during transactions.

```
uint8 constant MAX_RULES = 15;
```

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The amount of rules won't be greater than `MAX_RULES`.
- `pauseStop` timestamp is greater than `pauseStart`.
- `pauseStart` timestamp is greater than current timestamp.


###### *see [PauseRules](../../../src/data/PauseRules.sol)*

It is worth noting that this rule is special in the sense that it is not stored in the protocol but in the AppManager data contracts. Therefore, this rule doesn't have an ID like the other rules. This fact also makes this rule unreachable by other applications.

###### *see [ProtocolApplicationHandler](../../../src/client/application/ProtocolApplicationHandler.sol)*

## Other Functions:

- In [AppManager](../../../src/client/application/AppManager.sol):
    -  Function to remove a rule:
        ```c
        function removePauseRule(
                        uint256 _pauseStart, 
                        uint256 _pauseStop
                    ) 
                    external 
                    onlyRole(RULE_ADMIN_ROLE);
        ```
    - Function to activate/deactivate the rule:
        ```c
        function activatePauseRuleCheck(bool _on) external onlyRole(RULE_ADMIN_ROLE);
        ```
    - Function to get all rules:
        ```c
        function getPauseRules() external view returns (PauseRule[] memory);
        ```
    - Function to clean expired rules:
        ```c
        function cleanOutdatedRules() external;
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **PauseRuleEvent(uint256 indexed pauseStart, uint256 indexed pauseStop, bool indexed add)**: emitted when:
    - A pause rule has been added. In this case, the `add` field of the event will be *true*.
    - A pause rule has been removed. In this case, the `add` field of the event will be *false*.

## Dependencies

This rule has no dependencies.


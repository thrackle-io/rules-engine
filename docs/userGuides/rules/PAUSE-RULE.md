# Pause Rule

## Purpose

The purpose of the pause rule is to allow developers to pause the entirety of an application for maintenance, security or any other reason. Pausing the application means that no transfer of tokens is allowed at any level (with the few exceptions listed in the Role Applicability section). 

## Tokens Supported

- ERC20
- ERC721

## Scope 

This rule works at the application level which means that all tokens in the app will have no choise but to comply with this rule when active.

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
###### *see [PauseRule](../../../src/data/PauseRule.sol)*

## Role Applicability

- **Evaluation Exceptions**: 
    - This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
    - In the case of the ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

- **Configuration and Enabling/Disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the application handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the application handler by a **rule administrator**.
    - This rule can only be updated in the application handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The protocol's rule processor will retrieve all the pause rules stored in the data contract of the appManager. 
2. Then, it will loop through all these pause rules, and will evaluate if current timestamp is greater or equal to `pauseStart` and less than `pauseStop`. If the condition is true for at least one rule, then the transaction will revert.

## Create Function

Adding a pause rule is done through the function:

```javascript
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyRole(RULE_ADMIN_ROLE);
```
###### *see [AppManager](../../../src/application/AppManager.sol)*

The create function in the AppManager needs to receive the start timestamp (_pauseStart) and the ending timestamp (_pauseStop).

This create function will also delete automatically any pause rule where the `pauseStop` timestamp is less than current timestamp  since this means that the rule has *expired*. 

There is a default limit of 15 pause rules per application to avoid too much gas consumption during transactions.

```
uint8 constant MAX_RULES = 15;
```

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The amount of rules won't be greater than `MAX_RULES`.
- `pauseStop` timestamp is greater than `pauseStart`.
- `pauseStart` timestamp is greater than current timestamp.


###### *see [PauseRules](../../../src/data/PauseRules.sol)*

It is worth noting that this rule is special in the sense that it is not stored in the protocol but in the AppManager data contracts. Therefore, this rule doesn't have an ID like the other rules. This fact also makes this rule unreachable by other applications.

###### *see [ProtocolApplicationHandler](../../../src/application/ProtocolApplicationHandler.sol)*

## Other Functions:

- In [AppManager](../../../src/application/AppManager.sol):
    -  Function to remove a rule:
        ```javascript
        function removePauseRule(
                        uint256 _pauseStart, 
                        uint256 _pauseStop
                    ) 
                    external 
                    onlyRole(RULE_ADMIN_ROLE);
        ```
    - Function to activate/deactivate the rule:
        ```javascript
        function activatePauseRuleCheck(bool _on) external onlyRole(RULE_ADMIN_ROLE);
        ```
    - Function to get all rules:
        ```javascript
        function getPauseRules() external view returns (PauseRule[] memory);
        ```
    - Function to clean expired rules:
        ```javascript
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


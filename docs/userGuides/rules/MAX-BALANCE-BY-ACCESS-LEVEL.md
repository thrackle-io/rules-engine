# Maximum Account Balance By Access Level Rule

## Purpose

The purpose of this rule is to provide control over the balance limits for accounts at the application level. The limits will depend on the *access level* of the accounts. This control is mostly thought as a way of compliancy with possible government regulatory laws around crypto and KYC. For example, KYC could be used as the access level indicator where KYC 0 means no KYC at all, which means the account is only allowed to manage -for instance- 10 dollars worth of application assets, or even no assets at all, whereas KYC 4 means a very thorough KYC process carried out and therefore a trusted party which is allowed to manage millions of dollars within the application economy assets. 

## Tokens Supported

- ERC20
- ERC721

## Scope 

This rule works at the application level which means that all tokens in the app will have no choise but to comply with this rule when active.

## Data Structure

A max-balance-by-access-level rule is composed of a single variable:

- **maxBalance** (mapping(uint8 =>uint48)): the maximum amount of dollars that accounts can have per acces level.

```c
 mapping(uint8 => uint48);
```

###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

***NOTE: access levels are restricted from 0 to 4.***

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
 /// Balance Limit by Access Level
    struct AccessLevelRuleS {
        /// ruleIndex => level => max
        mapping(uint32 => mapping(uint8 => uint48)) accessRulesPerToken;
        uint32 accessRuleIndex; /// increments every time someone adds a rule
    }
```

###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

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

1. The application manager will send to the protocol's rule processor the sum of the balances of every application asset of the account, the access level of the account, the ruleId, and the dollar amount to be transferred in the transaction.
2. Then, the rule processor will retrieve the maximum balance allowed for the rule with the ruleId passed, and for the access level of the account. If the balance will exceed the maximum allowed by the rule in the case of a successful  transactions, then the transaction reverts.

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccBalanceByAccessLevel*

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error BalanceExceedsAccessLevelAllowedLimit();
```

The selector for this error is `0xdd76c810`.


## Create Function

Adding a max-balance-by-access-level rule is done through the function:

```c
function addAccessLevelBalanceRule(
            address _appManagerAddr, 
            uint48[] calldata _balanceAmounts
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [AppRuleDataFacet](../../../src/economic/ruleStorage/AppRuleDataFacet.sol)*

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_balanceAmounts** (uint48[]): array of balance limits for each 5 levels (levels 0 to 4) in whole USD amounts (1 -> 1 USD; 1000 -> 1000 USD). Note that the position within the array matters. Posotion 0 represents access level 0, and position 4 represents level 4.

The create function will return the protocol ID of the rule.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_balanceAmounts` array has length 5.
- The elements of the `_balanceAmounts` array are in ascendant order.

###### *see [AppRuleDataFacet](../../../src/economic/ruleStorage/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond](../../../src/economic/ruleStorage/AppRuleDataFacet.sol):
    - Function to get a rule by its Id:
        ```c
        function getAccessLevelBalanceRule(uint32 _index, uint8 _accessLevel) external view returns (uint48);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccessLevelBalanceRules() external view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAccBalanceByAccessLevel(
                    uint32 _ruleId, 
                    uint8 _accessLevel, 
                    uint128 _balance, 
                    uint128 _amountToTransfer
                ) 
                external 
                view;
        ```
- In the [App Manager Handler](../../../src/application/ProtocolApplicationHandler.sol):
    - Function to set and activate at the same time the rule in the application handler:
        ```c
        function setAccountBalanceByAccessLevelRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in the application handler:
        ```c
        function activateAccountBalanceByAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule in an asset handler:
        ```c
        function isAccountBalanceByAccessLevelActive() external view returns (bool);
        ```
    - Function to get the rule Id from the application handler:
        ```c
        function getAccountBalanceByAccessLevelRule() external view returns (uint32);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "BALANCE_BY_ACCESSLEVEL".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application manager handler.
    - parameters: 
        - ruleType: "BALANCE_BY_ACCESSLEVEL".
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

This rule depends on:

- **Pricing contracts**: pricing contracts for ERC20s and ERC721s need to be setup in the token handlers in order for this rule to work.


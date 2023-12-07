# Maximum Account Balance By Access Level Rule

## Purpose

The purpose of this rule is to provide balance limits for accounts at the application level based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provided gated accumulation of assets to ensure accounts cannot accumulate more assets without performing other actions defined by the application. For example, the application may decide users may not accumulate any assets without performing specific onboarding activities. The application developer may set a maximum balance of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value.

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A max-balance-by-access-level rule is composed of a single variable:

- **maxBalance** (mapping(uint8 =>uint48)): the maximum USD worth of application assets that accounts can have per access level.

```c
 mapping(uint8 => uint48);
```

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/IRuleStorage.sol)*

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

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The application manager will send to the protocol's rule processor the dollar value sum of all application assets the account holds, the access level of the account, the ruleId, and the dollar amount to be transferred in the transaction.
2. Then, the rule processor will retrieve the maximum balance allowed for the rule with the ruleId passed, and for the access level of the account. If the balance will exceed the maximum allowed by the rule in the case of a successful transactions, then the transaction reverts.

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccBalanceByAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

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
###### *see [AppRuleDataFacet](../../../src/economic/ruleProcessor/AppRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_balanceAmounts** (uint48[]): array of balance limits for each 5 levels (levels 0 to 4) in whole USD amounts (1 -> 1 USD; 1000 -> 1000 USD). Note that the position within the array matters. Posotion 0 represents access level 0, and position 4 represents level 4.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_balanceAmounts` array has length 5.
- The elements of the `_balanceAmounts` array are in ascendant order.

###### *see [AppRuleDataFacet](../../../src/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
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
- In the [Application Handler](../../../src/application/ProtocolApplicationHandler.sol):
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
    - Parameters: 
        - ruleType: "BALANCE_BY_ACCESSLEVEL".
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

This rule depends on:

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be setup in the token handlers in order for this rule to work.


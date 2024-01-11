# Withdrawal Limit By Access Level Rule

## Purpose

The purpose of this rule is to provide withdrawal limits for accounts at the application level based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provide gated withdrawal limits of assets to ensure accounts cannot withdraw more US Dollars or chain native tokens without first performing other actions defined by the application. For example, the application may decide users may not withdraw without performing specific onboarding activities. The application developer may set a maximum withdraw limit of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not withdraw from the ecosystem until the application changes their access level to a higher value. This rule does not prevent the accumulation of protocol supported assets. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A withdrawal-by-access-level rule is composed of a single variable:

- **maxBalance** (mapping(uint8 =>uint48)): the maximum USD worth of application assets that accounts can withdraw per access level.

```c
 mapping(uint8 => uint48);
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

***NOTE: access levels are restricted from 0 to 4.***

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
/// Withdrawal Limit by Access Level
    struct AccessLevelWithrawalRuleS {
        /// ruleIndex => access level => max
        mapping(uint32 => mapping(uint8 => uint48)) accessLevelWithdrawal;
        uint32 accessLevelWithdrawalRuleIndex;
    }
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the application handler by a **rule administrator**.
- This rule can only be activated/deactivated in the application handler by a **rule administrator**.
- This rule can only be updated in the application handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The application manager sends to the protocol's rule processor the dollar value sum of all application assets the account has already withdrawn, the access level of the account, the ruleId, and the dollar amount to be transferred in the transaction.
2. The processor retrieves the maximum withdrawal limit allowed for the rule with the ruleId passed, and for the access level of the account. If the withdrawal amount plus already withdrawn amount exceeds the maximum allowed by the rule in the case of a successful transactions, then the transaction reverts.

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccBalanceByAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when an **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error WithdrawalExceedsAccessLevelAllowedLimit();
```

The selector for this error is `0x2bbc9aea`.


## Create Function

Adding a withdrawal-by-access-level rule is done through the function:

```c
function addAccessLevelWithdrawalRule(
            address _appManagerAddr, 
            uint48[] calldata _withdrawalAmounts
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_withdrawalAmounts** (uint48[]): array of withdrawal limits for each 5 levels (levels 0 to 4) in whole USD amounts (1 -> 1 USD; 1000 -> 1000 USD). Note that the position within the array matters. Position 0 represents access level 0, and position 4 represents level 4.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_withdrawalAmounts` array has length 5.
- The elements of the `_balanceAmounts` array are in ascendant order.

###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function to get a rule by its Id:
        ```c
        function getAccessLevelWithdrawalRules(uint32 _index, uint8 _accessLevel) external view returns (uint48);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccessLevelWithdrawalRule() external view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkwithdrawalLimitsByAccessLevel(
                    uint32 _ruleId, 
                    uint8 _accessLevel, 
                    uint128 _usdWithdrawalTotal, 
                    uint128 _usdAmountTransferring
                ) 
                external 
                view;
        ```
- In the [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol):
    - Function to set and activate at the same time the rule in the application handler:
        ```c
        function setWithdrawalLimitByAccessLevelRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in the application handler:
        ```c
        function activateWithdrawalLimitByAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule in an asset handler:
        ```c
        function isWithdrawalLimitByAccessLevelActive() external view returns (bool);
        ```
    - Function to get the rule Id from the application handler:
        ```c
        function getWithdrawalLimitByAccessLevelRule() external view returns (uint32);
        ```

## Return Data

This rule returns 1 value:

1. **Accumulated US Dollar Amount Withdrawn** (uint128): the updated value for the total US Dollar amount of withdrawn per account. 

```c
mapping(address => uint128) usdValueTotalWithrawals;
```

*see [ProtocolApplicationHandler](../../../src/client/application/ProtocolApplicationHandler.sol)


## Data Recorded

This rule requires recording of the following information in the application handler:

```c
    /// AccessLevelWithdrawalRule data
    mapping(address => uint128) usdValueTotalWithrawals;
```

*see [ProtocolApplicationHandler](../../../src/client/application/ProtocolApplicationHandler.sol)


## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ACCESS_LEVEL_WITHDRAWAL".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "ACCESS_LEVEL_WITHDRAWAL".
        - ruleId: the ruleId set for this rule in the handler.
- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)**:
    - Emitted when: a rule has been activated in an application handler:
    - Parameters: 
        - ruleType: "ACCESS_LEVEL_WITHDRAWAL".
        - handlerAddress: the address of the application handler where the rule has been activated.


## Dependencies

This rule depends on:

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be set up in the token handlers in order for this rule to work.


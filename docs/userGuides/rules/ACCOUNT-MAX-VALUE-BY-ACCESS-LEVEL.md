# Account Max Value By Access Level Rule

## Purpose

The purpose of this rule is to provide balance limits for accounts at the application level based on an application defined segment of users. The segments are defined as the access levels of the accounts. This rule may be used to provided gated accumulation of assets to ensure accounts cannot accumulate more assets without performing other actions defined by the application. For example, the application may decide users may not accumulate any assets without performing specific onboarding activities. The application developer may set a maximum balance of $0 for the default access level and $1000 for the next access level. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value.

## Applies To:

- [x] ERC20
- [x] ERC721

## Applies To Actions:

- [x] MINT
- [ ] BURN
- [x] BUY
- [ ] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A account-max-value-by-access-level  rule is composed of a single variable:

- **maxValue** (mapping(uint8 =>uint48)): the maximum USD worth of application assets that accounts can have per access level.

```c
 mapping(uint8 => uint48);
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

***NOTE: access levels are restricted from 0 to 4.***

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
 /// Max Value by Access Level
    struct AccountMaxValueByAccessLevelS {
        /// ruleIndex => level => max
        mapping(uint32 => mapping(uint8 => uint48)) accountMaxValueByAccessLevelRules;
        uint32 accountMaxValueByAccessLevelIndex; /// increments every time someone adds a rule
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

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The application manager sends to the protocol's rule processor the dollar value sum of all application assets the account holds, the access level of the account, the ruleId, and the dollar amount to be transferred in the transaction.
3. The processor retrieves the maximum balance allowed for the rule with the ruleId passed, and for the access level of the account. If the balance exceeds the maximum allowed by the rule in the case of a successful transactions, then the transaction reverts.
4. If it's a non-custodial style [Sell](./ACTION-TYPES.md#sell) 
    1. When the [Buy](./ACTION-TYPES.md#buy) action is also active, checks steps 1-3 for to address.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccountMaxValueByAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when a **treasuryAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an treasury account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxValueByAccessLevel();
```

The selector for this error is `0xaee8b993`.


## Create Function

Adding a account-max-value-by-access-level  rule is done through the function:

```c
function addAccountMaxValueByAccessLevel(
            address _appManagerAddr, 
            uint48[] calldata _maxValues
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_maxValues** (uint48[]): array of max value limits for each 5 levels (levels 0 to 4) in whole USD amounts (1 -> 1 USD; 1000 -> 1000 USD). Note that the position within the array matters. Position 0 represents access level 0, and position 4 represents level 4.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_maxValues` array has length 5.
- The elements of the `_maxValues` array are in ascending order.

###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function to get a rule by its Id:
        ```c
        function getAccountMaxValueByAccessLevel(uint32 _index, uint8 _accessLevel) external view returns (uint48);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccountMaxValueByAccessLevel() external view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAccountMaxValueByAccessLevel(
                    uint32 _ruleId, 
                    uint8 _accessLevel, 
                    uint128 _balance, 
                    uint128 _amountToTransfer
                ) 
                external 
                view;
        ```
- In the [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol):
    - Function to set and activate at the same time the rule for the supplied actions in the application handler:
        ```c
        function setAccountMaxValueByAccessLevelId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to atomically set and activate at the same time the rule for the supplied actions in the application handler:
        ```c
        function setAccountMaxValueByAccessLevelIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in the application handler:
        ```c
        function activateAccountMaxValueByAccessLevel(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule for the supplied action in an application handler:
        ```c
        function isAccountMaxValueByAccessLevelActive(ActionTypes _action, ) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from the application handler:
        ```c
        function getAccountMaxValueByAccessLevelId(ActionTypes _action) external view returns (uint32);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ACC_MAX_VALUE_BY_ACCESS_LEVEL".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event AD1467_ApplicationRuleApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application handler.
    - Parameters: 
        - ruleType: "ACC_MAX_VALUE_BY_ACCESS_LEVEL".
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.

- **event AD1467_ApplicationRuleAppliedFull(bytes32 indexed ruleType, ActionTypes[] actions, uint32[] ruleIds);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "ACC_MAX_VALUE_BY_ACCESS_LEVEL".
        - actions: the protocol actions the rule is being applied to.
        - ruleIds: the ruleIds set for each action on this rule in the handler.

## Dependencies

This rule depends on:

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be setup in the application handler in order for this rule to work.


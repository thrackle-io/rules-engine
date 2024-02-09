# Account Deny For No Access Level Rule

## Purpose

The purpose of this rule is to provide a way to prevent the transfer of assets without application verification. For example, the application may decide users may not accumulate or transfer any assets without first performing specific onboarding activities. The application developer may set the account deny for no access level rule to active. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Applies To Actions:

- [x] MINT
- [ ] BURN
- [x] BUY
- [x] SELL
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

This rule is a simple boolean stored in the Application Handler contract:

```c
bool private AccountDenyForNoAccessLevelRuleActive;
```

###### *see [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol)*

## Configuration and Enabling/Disabling
- This rule can only be activated/deactivated in the application handler by a **rule administrator**.

## Rule Evaluation

The rule will be evaluated with the following logic:

1. The application manager sends to the protocol's rule processor the the access level of the `to` account in the transaction.
2. The processor checks that the access level is greater than 0. If the access level is equal to zero, then the transaction reverts.
3. The application manager sends to the procotol's rule processor the access level of the `from` account in the transaction.
4. The processor checks that the access level is greater than 0. If the access level is equal to zero, then the transaction reverts.

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccountMaxValueByAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- This rule doesn't apply when a **registeredAMM** address is in either the *from* or the *to* side of the transaction.
- This rule doesn't apply when the *to* address is the zero address to allow for burning while rule is active. 
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error NotAllowedForAccessLevel();
```

The selector for this error is `0x3fac082d`.


## Create Function

Adding a account-deny-for-no-access-level rule is done through the function:

```c
function addAccountMaxValueByAccessLevel(
            address _appManagerAddr, 
            uint48[] calldata _maxValues
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol)*



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
    - Function to set and activate at the same time the rule in the application handler:
        ```c
        function setAccountMaxValueByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in the application handler:
        ```c
        function activateAccountMaxValueByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule in an application handler:
        ```c
        function isAccountMaxValueByAccessLevelActive() external view returns (bool);
        ```
    - Function to get the rule Id from the application handler:
        ```c
        function getAccountMaxValueByAccessLevelId() external view returns (uint32);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ACC_MAX_VALUE_BY_ACCESS_LEVEL".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "ACC_MAX_VALUE_BY_ACCESS_LEVEL".
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

This rule has no dependancies. 
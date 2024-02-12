# Account Deny For No Access Level Rule

## Purpose

The purpose of this rule is to provide a way to prevent the transfer of assets for accounts that do not have an access level or whose access level has been set to 0. For example, the application may decide users may not accumulate or transfer any assets without first performing specific onboarding activities. The application developer may set the account deny for no access level rule to active. As accounts are introduced to the ecosystem, they may not receive any assets until the application changes their access level to a higher value. 

***NOTE: access levels are restricted from 0 to 4.***

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

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccountDenyForNoAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- This rule doesn't apply when a **registeredAMM** address is in either the *from* or the *to* side of the transaction.
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
/**
* @dev enable/disable rule. Disabling a rule will save gas on transfer transactions.
* @param _on boolean representing if a rule must be checked or not.
*/
function activateAccountDenyForNoAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress) {
    AccountDenyForNoAccessLevelRuleActive = _on;
    if (_on) {
        emit ApplicationHandlerActivated(ACCESS_LEVEL_0);
    } else {
        emit ApplicationHandlerDeactivated(ACCESS_LEVEL_0);
    }
}
```

This rule does not require an add function with the Rule Processor diamond. This rule is set in the application handler contract. 

###### *see [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol)*


## Other Functions:

- In the [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol):
     - Function to know the activation state of the rule in an application handler:
        ```c
        function isAccountDenyForNoAccessLevelActive() external view returns (bool);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application handler.
    - Parameters: 
        - ruleType: "ACCOUNT_DENY_FOR_NO_ACCESS_LEVEL".
        - ruleId: the ruleId set for this rule in the handler.


## Dependencies

This rule has no dependancies. 
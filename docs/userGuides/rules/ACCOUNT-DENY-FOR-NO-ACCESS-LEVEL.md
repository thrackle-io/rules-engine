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
bool private accountDenyForNoAccessLevelRuleActive;
```

###### *see [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol)*

## Configuration and Enabling/Disabling
- This rule can only be activated/deactivated in the application handler by a **rule administrator**.

## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. Rule processing differs for each [ACTION_TYPE](./ACTION-TYPES.md)
   1. [Mint](./ACTION-TYPES.md#mint)
      1. Check that the mint recipient address's access level is greater than 0.
   2. [Burn](./ACTION-TYPES.md#burn) 
      1. Check that the burning address's access level is greater than 0.
   3. [Peer To Peer Transfer](./ACTION-TYPES.md#p2p_transfer)
      1. Check that the sender address's access level is greater than 0.
      2. Check the recipient address's access level is greater than 0.
   4. [Buy](./ACTION-TYPES.md#buy) 
      1. For non-custodial style buys:
         1. Check the buyer address's access level is greater than 0.
         2. When the [Sell](./ACTION-TYPES.md#sell) action is also active, check that the seller address's access level is greater than 0.
      2. For custodial style buys:
         1. Check the buyer address's access level is greater than 0. 
   5. [Sell](./ACTION-TYPES.md#sell) 
      1.  For non-custodial style sells:
         1. Check the seller address's access level is greater than 0.
         2. When the [Buy](./ACTION-TYPES.md#buy) action is also active, check that the buyer address's access level is greater than 0.
      2. For custodial style sells:
         1. Check the seller address's access level is greater than 0.    
3. If the pertinent check fails, then the transaction reverts.

###### *see [ApplicationAccessLevelProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol) -> checkAccountDenyForNoAccessLevel*

## Evaluation Exceptions 
- This rule doesn't apply when a **treasuryAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an treasury account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.


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
* @param _actions list of action types
* @param _on boolean representing if a rule must be checked or not.
*/
function activateAccountDenyForNoAccessLevelRule(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress)
```

This rule does not require an add function with the Rule Processor diamond. This rule is set in the application handler contract. 

###### *see [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol)*


## Other Functions:

- In the [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol):
     - Function to know the activation state of the rule for the supplied action in an application handler:
        ```c
        function isAccountDenyForNoAccessLevelActive(ActionTypes _action) external view returns (bool);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event AD1467_ApplicationRuleApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application handler.
    - Parameters: 
        - ruleType: "ACCOUNT_DENY_FOR_NO_ACCESS_LEVEL".
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.
- **event AD1467_ApplicationRuleAppliedFull(bytes32 indexed ruleType, ActionTypes[] actions, uint32[] ruleIds);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "ACCOUNT_DENY_FOR_NO_ACCESS_LEVEL".
        - actions: the protocol actions the rule is being applied to.
        - ruleIds: the ruleIds set for each action on this rule in the handler.


## Dependencies

This rule has no dependencies. 
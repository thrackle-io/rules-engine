# Admin Min Token Balance

## Purpose

The purpose of the admin-min-token-balance rule is to allow developers to prove to their community that they will hold a certain amount of tokens for a certain period of time. Adding this rule prevents developers from flooding the market with their supply and effectively "rug pulling" their community. 

## Applies To:

- [x] ERC20
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

An admin-min-token-balance rule is composed of 2 variables:

- **Amount** (uint256): The minimum amount of tokens to be held by the admin until the *endTime* (in wei).
- **endTime** (uint256): The Unix timestamp of the date after which the administrator is free to transfer the tokens.

```c
/// ******** Admin Withdrawal Rules ********
    struct AdminMinTokenBalance {
        uint256 amount;
        uint256 endTime; /// timestamp
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Admin Withdrawal Rules ********
    struct AdminMinTokenBalanceS {
        mapping(uint32 => ITaggedRules.AdminMinTokenBalance) adminMinTokenBalanceRules;
        uint32 adminMinTokenBalanceIndex;
    }
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling

- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.

Since this rule is intended to apply specifically to rule bypass accounts, there are some special restrictions:

- This rule can only be deactivated if current rule is outside its active period (post `endTime`).
- This rule prevents app administrators from renouncing their roles when the rule is in its active period (pre `endTime`).

## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The asset handler checks if the transfer of tokens is from an app administrator account. If it is not, the rule evaluation is skipped.
3. The handler sends the amount of tokens being transferred, the current balance of the app administrator account, and the ruleId to the protocol's rule processor.
4. The rule processor calculates what the final balance of the administrator account would be if the transaction succeeds. If the final balance calculated is less than the minimum balance specified in the rule, the transaction reverts.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkAdminMinTokenBalance*

### Evaluation Exceptions

- This rule doesn't apply when an **ruleBypassAccount** address is **not** in the *from* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error UnderMinBalance();
```

The selector for this error is `0x3e237976`.

## Create Function

Adding an admin-min-token-balance rule is done through the function:

```c
function addAdminMinTokenBalance(
            address _appManagerAddr, 
            uint256 _amount, 
            uint256 _endTime
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_amount** (uint256): the minimum amount of tokens to be held by the app administrator until `_endTime` (in wei).
- **_endTime** (uint256[]): the Unix timestamp of the date after which the app aministrator is free to transfer the tokens.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_amount` is not zero.
- `_endTime` is not in the past.

###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getAdminMinTokenBalance(
                    uint32 _index
                ) 
                external 
                view 
                returns (TaggedRules.AdminMinTokenBalance memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAdminMinTokenBalance() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAdminMinTokenBalance(uint32 ruleId, uint256 currentBalance, uint256 amount) external view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setAdminMinTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateAdminMinTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c 
        function isAdminMinTokenBalanceActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to know the activation state of the rule in an asset handler and if it is in the active period:
        ```c
        function isAdminMinTokenBalanceActiveAndApplicable() public view override returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getAdminMinTokenBalanceId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ADMIN_MIN_TOKEN_BALANCE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "ADMIN_MIN_TOKEN_BALANCE".
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.

- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: rule has been activated in the asset handler.
    - Parameters:
        - ruleType: "ADMIN_MIN_TOKEN_BALANCE".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- This rule has no dependencies.


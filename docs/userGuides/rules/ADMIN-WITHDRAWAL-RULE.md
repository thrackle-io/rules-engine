# Admin Withdrawal Rule

## Purpose

The purpose of the admin-withdrawal rule is to allow developers to prove to their community that they will hold a certain amount of tokens for a certain period of time. Adding this rule prevents developers from flooding the market with their supply and effectively "rug pulling" their community. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

An admin-withdrawal rule is composed of 2 variables:

- **Amount** (uint256): The minimum amount of tokens to be held by the admin until the *releaseDate* (in wei).
- **Release Date** (uint256): The Unix timestamp of the date after which the administrator is free to transfer the tokens.

```c
/// ******** Admin Withdrawal Rules ********
    struct AdminWithdrawalRule {
        uint256 amount;
        uint256 releaseDate; /// timestamp
    }
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleProcessor/RuleDataInterfaces.sol)*

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Admin Withdrawal Rules ********
    struct AdminWithdrawalRuleS {
        mapping(uint32 => ITaggedRules.AdminWithdrawalRule) adminWithdrawalRulesPerToken;
        uint32 adminWithdrawalRulesIndex;
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling

- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.

Since this rule is intended to apply specifically to app administrators, there are some special restrictions:

- This rule can only be deactivated if current rule is outside its active period (post `releaseDate`).
- This rule prevents app administrators from renouncing their roles when the rule is in its active period (pre `releaseDate`).

## Rule Evaluation

The rule will be evaluated with the following logic:

1. The asset handler checks if the transfer of tokens is from an app administrator account. If it is not, the rule evaluation is skipped.
2. The handler sends the amount of tokens being transferred, the current balance of the app administrator account, and the ruleId to the protocol's rule processor.
3. The rule processor calculates what the final balance of the administrator account would be if the transaction succeeds. If the final balance calculated is less than the minimum balance specified in the rule, the transaction reverts.

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkAdminWithdrawalRule*

### Evaluation Exceptions

- This rule doesn't apply when an **app administrator** address is **not** in the *from* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error BalanceBelowMin();
```

The selector for this error is `0xf1737570`.

## Create Function

Adding an admin-withdrawal rule is done through the function:

```c
function addAdminWithdrawalRule(
            address _appManagerAddr, 
            uint256 _amount, 
            uint256 _releaseDate
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr) 
        returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_amount** (uint256): the minimum amount of tokens to be held by the app administrator until `_releaseDate` (in wei).
- **_releaseDate** (uint256[]): the Unix timestamp of the date after which the app aministrator is free to transfer the tokens.

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_amount` is not zero.
- `_releaseDate` is not in the past.

###### *see [TaggedRuleDataFacet](../../../src/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getAdminWithdrawalRule(
                    uint32 _index
                ) 
                external 
                view 
                returns (TaggedRules.AdminWithdrawalRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAdminWithdrawalRules() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAdminWithdrawalRule(uint32 ruleId, uint256 currentBalance, uint256 amount) external view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setAdminWithdrawalRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateAdminWithdrawalRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c 
        function isAdminWithdrawalActive() external view returns (bool);
        ```
    - Function to know the activation state of the rule in an asset handler and if it is in the active period:
        ```c
        function isAdminWithdrawalActiveAndApplicable() public view override returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getAdminWithdrawalRuleId() external view returns (uint32);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ADMIN_WITHDRAWAL".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "ADMIN_WITHDRAWAL".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the ruleId set for this rule in the handler.
- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)**:
    - Emitted when: rule has been activated in the asset handler.
    - Parameters:
        - ruleType: "ADMIN_WITHDRAWAL".
        - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- This rule has no dependencies.


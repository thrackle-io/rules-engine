# Account Min Max Token Balance

## Purpose

The account-min-max-token-balance rule enforces token balance thresholds for user accounts with specific tags. This allows developers to set lower and upper limits on the amount of each token the user account can hold. This rule attempts to mitigate the risk of token holders selling more than the minimum allowed amount and accumulating more than the maximum allowed amount of tokens for each specific tag. It can also be used to prevent token holders from rapidly flooding the market with newly acquired tokens since a dramatic increase in supply over a short time frame can cause a token price crash. This is done by associating an opional period with the rule.

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Applies To Actions:

- [x] MINT
- [x] BURN
- [x] BUY
- [x] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at both the token level and AMM level. It must be activated and configured for each desired token in the corresponding token handler or each desired AMM supported token within the AMM Handler.

## Data Structure

As this is a [tag](../GLOSSARY.md)-based rule, you can think of it as a collection of rules, where all "sub-rules" are independent from each other, and where each "sub-rule" is indexed by its tag. A account-min-max-token-balance "sub-rule" is specified by 3 variables:

- **Min** (uint256): The minimum amount of tokens to be held by the account.
- **Max** (uint256): The maximum amount of tokens to be held by the account.
- **Period** (uint16): The amount of hours the minimum/maximum limit will be in effect.


```c
/// ******** Account Minimum/Maximum Balance ********
    struct AccountMinMaxTokenBalance {
        uint256 min;
        uint256 max;
        uint16 period; /// hours
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

If a single blank `tag` is specified, the rule is applicable to all users.

Additionally, each one of these data structures will be under a tag (bytes32):

 tag -> sub-rule.

 ```c
    //      tag     =>   sub-rule
    mapping(bytes32 => ITaggedRules.AccountMinMaxTokenBalance)
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

The collection of these tagged sub-rules composes a account-min-max-token-balance rule.

 ```c
/// ******** Account Minimum/Maximum Balances ********
struct AccountMinMaxTokenBalanceS {
    /// ruleIndex => taggedAccount => minimumTransfer
    mapping(uint32 => mapping(bytes32 => ITaggedRules.AccountMinMaxTokenBalance)) accountMinMaxTokenBalanceRules;
    uint256 startTime; /// start
    uint32 accountMinMaxTokenBalanceIndex; /// increments every time someone adds a rule
}
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

A account-min-max-token-balance rule must have at least one sub-rule. There is no maximum number of sub-rules.

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The receiver account and the sender account being evaluated pass all the tags they have registered to their addresses in the application manager to the protocol.
3. The processor receives these tags along with the ID of the account-min-max-token-balance rule set in the token handler. 
4. The processor tries to retrieve the sub-rule associated with each tag.
5. The processor evaluates whether each sub-rule's period is still active (if the current time is within `period` from the `starting timestamp`). If not, processing of the rule for the selected tag does not proceed.
6. Rule processing differs for each [ACTION_TYPE](./ACTION-TYPES.md)
   1. [Mint](./ACTION-TYPES.md#mint)
      1. The processor evaluates if the final balance of the receiver account would be greater than the `max` in the case of the transaction succeeding. If yes, the transaction reverts.
      2. NOTE: This means that minting actions will never violate the minimum balance as it is a transfer in and not out.
   2. [Burn](./ACTION-TYPES.md#burn) 
      1. The processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
      2. NOTE: This means that burning actions will never violate the maximum balance as it is a transfer out and not in.
   3. [Peer To Peer Transfer](./ACTION-TYPES.md#p2p_transfer)
      1. The processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
      2. The processor evaluates if the final balance of the receiver account would be greater than the `max` in the case of the transaction succeeding. If yes, the transaction reverts.
   4. [Buy](./ACTION-TYPES.md#buy) 
      1. For non-custodial style buys:
         1. The processor evaluates if the final balance of the receiver account would be greater than the `max` in the case of the transaction succeeding. If yes, the transaction reverts.
         2. When the [Sell](./ACTION-TYPES.md#sell) action is also active, the processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
      2. For custodial style buys:
         1. The processor evaluates if the final balance of the receiver account would be greater than the `max` in the case of the transaction succeeding. If yes, the transaction reverts.
         2. NOTE: This means that custodial style buying actions will never violate the minimum balance as it is a transfer in and not out.
   5. [Sell](./ACTION-TYPES.md#sell) 
      1.  For non-custodial style sells:
         1. The processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
         2. When the [Buy](./ACTION-TYPES.md#buy) action is also active, the processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
      2. For custodial style sells:
         1. The processor evaluates if the final balance of the sender account would be less than the`min` in the case of the transaction succeeding. If yes, the transaction reverts.
         2. NOTE: This means that custodial style selling actions will never violate the maximum balance as it is a transfer out and not in.  
7. Step 4-5 are repeated for each of the account's tags. 

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20TaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol) -> checkAccountMinMaxTokenBalance*

## Evaluation Exceptions 
- This rule doesn't apply when a **treasuryAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an treasury account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.

### Revert Message

The rule processor will revert with one of the following errors if the rule check fails: 

```
error OverMaxBalance();
```
```
error UnderMinBalance();
```
```
error TxnInFreezeWindow();
```

The selectors for these errors are `0x1da56a44`, `0xa7fb7b4b` and `0x3e237976` .

## Create Function

Adding a account-min-max-token-balance rule is done through the function:

```c
function addAccountMinMaxTokenBalance(
        address _appManagerAddr,
        bytes32[] calldata _accountTypes,
        uint256[] calldata _min,
        uint256[] calldata _max,
        uint16[] calldata _periods,
        uint64 _startTime
    ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has Rule administrator privileges.
- **_accountTags** (bytes32[]): array of tags that will contain each sub-rule.
- **_min** (uint256[]): array of *minimum amounts* for each sub-rule.
- **_max** (uint256[]): array of *maximum amounts* for each sub-rule.
- **_periods** (uint16[]): array of *periods* for each sub-rule.
- **_startTimetamp** (uint64): *timestamp* that applies to each sub-rule.

It is important to note that array positioning matters in this function. For instance, tag in position zero of the `_accountTags` array will contain the sub-rule created by the values in the position zero of `_min`,  `_max` and `_periods`. Same with tag in position *n*.

#### Note:
HoldPeriods are not required, but within a rule creation all sub-rules must either be periodic or not. If non-periodic is desired pass in an empty array for the periods parameter.

Minimum and Maximum values are required, but you can use specific values to only apply one of the two:
- To only apply a maximum set the corresponding minimum to 0.
- To only apply a minimum set the corresponding maximum to the max value for uint256.

### Parameter Optionality:

There is no parameter optionality for this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- All the parameter arrays have at least one element.
- All the parameter arrays, except periods, have the exact same length.
- periods is either empty or the same length as the other arrays.
- `tag` can either be a single blank tag or a list of non blank `tag`s.
- `min`is not greater than `max`


###### *see [TaggedRuleDataFacet](../../../src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getAccountMinMaxTokenBalance(
                    uint32 _index, 
                    bytes32 _accountTag
                ) 
                external 
                view 
                returns 
                (TaggedRules.AccountMinMaxTokenBalance memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccountMinMaxTokenBalances() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol):
    - Function that evaluates the rule for tokens:
        ```c
        function checkAccountMinMaxTokenBalance(
                uint32 ruleId, 
                uint256 balanceFrom, 
                uint256 balanceTo, 
                uint256 amount, 
                bytes32[] calldata toTags, 
                bytes32[] calldata fromTags
            ) 
            external 
            view;
        ```
    - Function that evaluates the rule for AMMs:
        ```c
        function checkAccountMinMaxTokenBalanceAMM(
                uint32 ruleIdToken0,
                uint32 ruleIdToken1,
                uint256 tokenBalance0,
                uint256 tokenBalance1,
                uint256 amountIn,
                uint256 amountOut,
                bytes32[] calldata fromTags
            ) 
            public 
            view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setAccountMinMaxTokenBalanceId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateAccountMinMaxTokenBalance(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isAccountMinMaxTokenBalanceActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getAccountMinMaxTokenBalanceId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "ACCOUNT_MIN_MAX_TOKEN_BALANCE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: the tags for each sub-rule.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - Parameters: 
        - ruleType: "ACCOUNT_MIN_MAX_TOKEN_BALANCE".
        - action: the protocol action the rule is being applied to.
        - ruleId: the ruleId set for this rule in the handler.

- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes actions, uint256 indexed ruleId)** 
    - Emitted when: rule has been activated in the asset handler.
    - Parameters:
        - ruleType: "ACCOUNT_MIN_MAX_TOKEN_BALANCE".
        - actions: the protocol actions for which the rule is being activated.
        - ruleId: a placeholder of 0 will be passed for ruleId
- **event AD1467_ApplicationHandlerActionDeactivated(bytes32 indexed ruleType, ActionTypes actions, uint256 indexed ruleId)** 
    - Emitted when: rule has been deactivated in the asset handler.
    - Parameters:
        - ruleType: "ACCOUNT_MIN_MAX_TOKEN_BALANCE".
        - actions: the protocol actions for which the rule is being deactivated.
        - ruleId: a placeholder of 0 will be passed for ruleId

## Dependencies

- **Tags**: This rule relies on accounts having a matching [tag](../GLOSSARY.md) registered in their [AppManager](../GLOSSARY.md) or the rule being configured with a blank [tag](../GLOSSARY.md).
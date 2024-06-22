# Token Min Tx Size

## Purpose

The purpose of the token-min-tx-size rule is to prevent micro-trades or dust trades within an ecosystem. A developer can set the minimum number of tokens required per transfer to prevent these types of trades. 

## Applies To:

- [x] ERC20
- [ ] ERC721
- [ ] AMM

## Applies To Actions:

- [x] MINT
- [x] BURN
- [x] BUY
- [x] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

A token-min-tx-size rule is composed of 1 component:

- **minSize**  (uint256): minimum number of tokens that must be transferred for each transaction. 

```c
    /// ******** Token Minimum Transfer Rules ********
    struct TokenMinTxSize {
        uint256 minSize;
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

The token-min-tx-size rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Minimum Transaction ********
    struct TokenMinTxSizeS {
        mapping(uint32 => INonTaggedRules.TokenMinTxSize) tokenMinTxSizeRules;
        uint32 tokenMinTxSizeIndex; /// increments every time someone adds a rule
    }
```
###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The handler determines if the rule is active from the supplied action. If not, processing does not continue past this step.
2. The processor receives the ID of the token-min-tx-size rule set in the token handler. 
3. The processor receives the `amount` of tokens from the handler.
4. The processor evaluates the `amount` against the rule `minSize` and reverts if the `amount` less than the rule minimum.
5. If it's a non-custodial style [Buy](./ACTION-TYPES.md#buy) 
    1. When the [Sell](./ACTION-TYPES.md#sell) action is also active, checks steps 1-4 for from address.
6. If it's a non-custodial style [Sell](./ACTION-TYPES.md#sell) 
    1. When the [Buy](./ACTION-TYPES.md#buy) action is also active, checks steps 1-4 for to address. 

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenMinTxSize*

## Evaluation Exceptions 
- This rule doesn't apply when a **treasuryAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an treasury account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error UnderMinTxSize();
```

The selector for this error is `0x7a78c901`.

## Create Function

Adding a token-min-tx-size rule is done through the function:

```c
function addTokenMinTxSize(
    address _appManagerAddr,
    uint256 _minSize
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_minSize** (uint256): Minimum number of tokens for the transaction.


### Parameter Optionality:

There is no parameter optionality for this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_minSize` is greater than 0.


###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getTokenMinTxSize(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.TokenMinTxSize memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTokenMinTxSize() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTokenMinTxSize(
                    uint32 _ruleId, 
                    uint256 _amountToTransfer
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setTokenMinTxSizeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions actions in an asset handler:
        ```c
        function activateTokenMinTxSize(ActionTypes[] calldata _action, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isTokenMinTxSizeActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getTokenMinTxSizeId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule does not return any data.

## Data Recorded

This rule does not require any data to be recorded.

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TOKEN_MIN_TX_SIZE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "TOKEN_MIN_TX_SIZE".
        - action: the protocol action the rule is being applied to.
        - ruleId: the index of the rule created in the protocol by rule type.


- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: A Token Min Transaction Size rule has been activated in an asset handler:
    - Parameters:
        - ruleType: "TOKEN_MIN_TX_SIZE".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- This rule has no dependencies.
# Token Max Buy Volume Rule

## Purpose

The token-max-buy-volume rule enforces a limit on the purchase of tokens during a certain time period. This rule sets the limit as a percentage of the token's total supply. The rule will apply to the token designated when a purchase action is detected.  

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at the token level. It must be activated and configured for each token in the corresponding token handler.

## Data Structure

A token-max-buy-volume rule is composed of 4 components:

- **Token Percentage** (uint16): The maximum percent in basis units of total supply able to be purchased during the *period* (i.e. 5050 = 50.50% of total supply). 
- **Purchase  Period** (uint16): The length of time for which the rule will apply, in hours.
- **Starting Timestamp** (uint64): The unix timestamp of the date when the *period* starts counting.
- **Total Supply** (uint256): if not zero, this value will always be used as the token's total supply for rule evaluation. This can be used when the amount of circulating supply is much smaller than the amount of the token totalSupply due to some tokens being locked in a dev account or a vesting contract, etc. Only use this value in such cases.

```c
/// ******** Token Max Buy Volume Rules ********
struct TokenMaxBuyVolume {
    uint16 tokenPercentage; /// from 0000 to 10000 => 0.00% to 100.00%.
    uint16 period;
    uint256 totalSupply; /// set 0 to use erc20 totalSupply
    uint64 startTime; ///start of time period for the rule
}
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

The token-max-buy-volume rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
/// ******** Token Max Buy Volume ********
struct TokenMaxBuyVolumeS {
    mapping(uint32 => INonTaggedRules.TokenMaxBuyVolume) tokenMaxBuyVolumeRules;
    uint32 tokenMaxBuyVolumeIndex;
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
2. The token handler decides if the transfer is a Purchase (user perspective). Only if it is, it continues with the next steps.
3. The processor receives the ID of the token-max-buy-volume rule set in the asset handler. 
4. The processor receives the current total purchased within period, token A amount (total amount of token A being transferred in the current transaction), previous purchase time, and token's total supply from the handler.
5. The processor evaluates whether the rule has a set total supply or uses the token's total supply provided by the handler set at the beginning of every new `period`.  
6. The processor evaluates whether the current time is within a new `period`.
    - **If it is a new period**, the processor sets the percent of total supply to the token A amount.
    - **If it is not a new period**, the processor sets percent of total supply to the sum of the total purchased within period and token A amount. 
7. The processor calculates the final purchase percentage, in basis units, using the percent of total supply calculated in step 4 and the total supply set in step 3.  
8. The processor evaluates if the final purchase percentage of total supply would be greater than the `token percentage`. 
    - If yes, the transaction reverts. 
    - If no, the processor returns the `token percentage` value for the current `period` to the handler.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenMaxBuyVolume*

## Evaluation Exceptions 
This rule doesn't apply when:
- An approved Trading-Rule Whitelisted address is in the *to* side of the transaction.
- rulebypasser account is in the *from* or *to* side of the transaction.

Additionally, in the case of the ERC20, this rule doesn't apply also when registered treasury address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxBuyVolume();
```

The selector for this error is `0x6a46d1f4`.

## Create Function

Adding a token-max-buy-volume rule is done through the function:

```c
function addTokenMaxBuyVolume(
    address _appManagerAddr,
    uint16 _supplyPercentage,
    uint16 _period,
    uint256 _totalSupply,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_supplyPercentage** (uint16): Maximum allowable percentage (in basis unit) of trading volume per period.
- **_period** (uint16): The amount of hours per period.
- **_startTime** (uint64): Unix timestamp for the *_period* to start counting.
- **_totalSupply** (uint256): (optional) if not 0, then this is the value used for totalSupply instead of the live token's totalSupply value at rule processing time.


### Parameter Optionality:

The parameters where developers have the options are:
- **_totalSupply**: For purchase volume over supply calculations, when this is zero, the token's totalSupply is used. Otherwise, this value is used as the total supply.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_supplyPercentage_` is not greater than 9999 (99.99%). 
- `_supplyPercentage` and `_period` are greater than a value of 0.
- `_startTime` is not zero and is not more than 52 weeks in the future.


###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getTokenMaxBuyVolume(
            uint32 _index
            ) 
            external 
            view 
            returns 
            (NonTaggedRules.TokenMaxBuyVolume memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTokenMaxBuyVolume() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTokenMaxBuyVolume(
                uint32 ruleId, 
                uint256 currentTotalSupply, 
                uint256 amountToTransfer, 
                uint64 lastPurchaseTime, 
                uint256 boughtInPeriod
            ) 
            external 
            view 
            returns (uint256);
        ```
- in [ERC20Handler](../../../src/client/token/ERC20/ProtocolERC20Handler.sol), [ERC721Handler](../../../src/client/token/ERC721/ProtocolERC721Handler.sol):
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setTokenMaxBuyVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateTokenMaxBuyVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isTokenMaxBuyVolumeActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getTokenMaxBuyVolumeId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Total Purchased Within Period** (uint256): the updated value for the total traded volume during the period. 

```c
uint256 private totalBoughtInPeriod;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Total Purchased Within Period** (uint256): the updated value for the total purchased during the period. 
- **Previous Purchase Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
uint64 private previousPurchaseTime;
uint256 private totalBoughtInPeriod;
```

*see [Token Handler](../../../src/client/token/ProtocolHandlerCommon.sol)*

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TOKEN_MAX_BUY_VOLUME".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "TOKEN_MAX_BUY_VOLUME".
        - action: the protocol action the rule is being applied to.
        - ruleId: the index of the rule created in the protocol by rule type.

- **event ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: a Transfer counter rule has been activated in an asset handler:
    - Parameters:
        - ruleType: "TOKEN_MAX_BUY_VOLUME".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- This rule has no dependencies.
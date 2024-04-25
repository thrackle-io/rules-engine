# Token Max Trading Volume

## Purpose

The purpose of the token-max-trading-volume rule is to reduce high trading volatility periods by allowing developers to set a maximum volume (as a percentage of the token's total supply) that can be traded within a period of time. When the trading volume maximum is reached, transfers are suspended until the next period begins. Trading volume is the accumulated total number of tokens transferred during each period, and reset with each new period by the first transaction of that period. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Applies To Actions:

- [x] MINT
- [ ] BURN
- [x] BUY
- [x] SELL
- [x] TRANSFER(Peer to Peer)
  
## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

A token-max-trading-volume rule is composed of 4 components:

- **Max Volume** (uint24): The maximum percent in basis units of total supply to be traded during the *period*.
- **Period** (uint16): The amount of hours that defines a period.
- **Starting Timestamp** (uint64): The timestamp of the date when the *period* starts counting.
- **Total Supply** (uint256): if not zero, this value will always be used as the token's total supply for rule evaluation. This can be used when the amount of circulating supply is much smaller than the amount of the token totalSupply due to some tokens being locked in a dev account or a vesting contract, etc. Only use this value in such cases.

```c
/// ******** Token Max Trading Volume ********
    struct TokenMaxTradingVolume {
        uint24 max; // this is a percentage with 2 decimals of precision (2500 = 25%)
        uint16 period; // hours
        uint64 startTime; // UNIX date MUST be at a time with 0 minutes, 0 seconds. i.e: 20:00 on Jan 01 2024
        uint256 totalSupply; // If specified, this is the circulating supply value to use. If not specified, it defaults to token's totalSupply.
    }
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

The token-max-trading-volume rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
/// ******** Token Transfer Volume ********
    struct TokenMaxTradingVolumeS {
        mapping(uint32 => INonTaggedRules.TokenMaxTradingVolume) tokenMaxTradingVolumeRules;
        uint32 tokenMaxTradingVolumeIndex;
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
2. The processor receives the ID of the token-max-trading-volume rule set in the token handler. 
3. The processor receives the current `transfer volume`, `last transfer time`, `amount` and token's total supply from the handler.
4. The processor evaluates whether the rule has a set total supply or use the token's total supply provided by the handler set at the beginning of every new `period`. 
5. The processor evaluates whether the rule is active based on the `starting timestamp`. If it is not active, the rule evaluation skips the next steps, and simply returns the `transfer volume` value.
6. The processor evaluates whether the current time is within a new `period`.
    - **If it is a new period**, the processor will set the `amount` value from the current transaction as the `_volume` value for the volume percent of total supply calculation.
    - **If it is not a new period**, the processor accumulates the `transfer volume` (tokens transferred) and the `amount` of tokens to be transferred as the `_volume` value for the volume percent of total supply calculation. 
7. The processor calculates the final volume percentage, in basis units, from `_volume` and the total supply set in step 3. 
8. The processor evaluates if the final volume percentage of total supply would be greater than the `max volume`. 
    - If yes, then the transaction reverts. 
    - If no, the processor returns the `_volume` value for the current `period` to the handler.

**The list of available actions rules can be applied to can be found at [ACTION_TYPES.md](./ACTION-TYPES.md)**

###### *see [ERC20RuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenMaxTradingVolume*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxTradingVolume();
```

The selector for this error is `0x009da0ce`.

## Create Function

Adding a token-max-trading-volume rule is done through the function:

```c
function addTokenMaxTradingVolume(
    address _appManagerAddr,
    uint24 _maxPercentage,
    uint16 _hoursPerPeriod,
    uint64 _startTime,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_maxPercentage** (uint24): maximum allowable basis unit percentage of trading volume per period.
- **_hoursPerPeriod** (uint16): the amount of hours per period.
- **_startTime** (uint64): starting timestamp of the rule. This timestamp will determine the time that a day starts and ends for the rule processing. For example, *the amount of trades will reset to 0 every day at 2:30 pm.*
- **_totalSupply** (uint256): (optional) if not 0, then this is the value used for totalSupply instead of the live token's totalSupply value at rule processing time.


### Parameter Optionality:

The parameters where developers have the options are:
- **_totalSupply**: For volatility calculations, when this is zero, the token's totalSupply is used. Otherwise, this value is used as the total supply.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_maxPercentage_` is not greater than 1000000 (1000%). 
- `maxPercentage` and `_hoursPerPeriod` are greater than a value of 0.
- `_startTime` is not zero and is not more than 52 weeks in the future.


###### *see [RuleDataFacet](../../../src/protocol/economic/ruleProcessor/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    -  Function to get a rule by its ID:
        ```c
        function getTokenMaxTradingVolume(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.TokenMaxTradingVolume memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTokenMaxTradingVolume() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTokenMaxTradingVolume(
                    uint32 _ruleId, 
                    uint256 _volume,
                    uint256 _supply, 
                    uint256 _amount, 
                    uint64 _lastTransferTime
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule for the supplied actions in an asset handler:
        ```c
        function setTokenMaxTradingVolumeId(ActionTypes[] calldata _actions, uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule for the supplied actions in an asset handler:
        ```c
        function activateTokenMaxTradingVolume(ActionTypes[] calldata _actions, bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule for the supplied action in an asset handler:
        ```c
        function isTokenMaxTradingVolumeActive(ActionTypes _action) external view returns (bool);
        ```
    - Function to get the rule Id for the supplied action from an asset handler:
        ```c
        function getTokenMaxTradingVolumeId(ActionTypes _action) external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Transfer Volume** (uint256): the updated value for the total traded volume during the period. 

```c
uint256 private transferVolume;
```

*see [ERC721Handler](../Architecture/Client/AssetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)/[ERC20Handler](../Architecture/Client/AssetHandler/PROTOCOL-FUNGIBLE-TOKEN-HANDLER.md)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Transfer Volume** (uint256): the updated value for the total traded volume during the period. 
- **Last Transfer Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
uint64 private lastTransferTime;
uint256 private transferVolume;
```

*see [ERC721Handler](../Architecture/Client/AssetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md)/[ERC20Handler](../Architecture/Client/AssetHandler/PROTOCOL-FUNGIBLE-TOKEN-HANDLER.md)*

## Events

- **event AD1467_ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TOKEN_MAX_TRADING_VOLUME".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event AD1467_ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes action, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "TOKEN_MAX_TRADING_VOLUME".
        - action: the protocol action the rule is being applied to.
        - ruleId: the index of the rule created in the protocol by rule type.

- **event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action)** 
    - Emitted when: A Transfer counter rule has been activated in an asset handler:
    - Parameters: 
        - ruleType: "TOKEN_MAX_TRADING_VOLUME".
        - action: the protocol action for which the rule is being activated.

## Dependencies

- **ERC721Enumerable**: This rule utilizes the totalSupply function, requiring [ERC721Enumerable](https://eips.ethereum.org/EIPS/eip-721)
# Token Transfer Volume Rule

## Purpose

The purpose of the token-transfer-volume rule is to reduce high trading volatility periods by allowing developers to set a maximum volume (as a percentage of the token's total supply) that can be traded within a period of time. When the trading volume maximum is reached, transfers are suspended until the next period begins. Trading volume is the accumulated total number of tokens transferred during each period, and reset with each new period by the first transaction of that period. 

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at a token level. It must be activated and configured for each desired token in the corresponding token handler.

## Data Structure

A token-transfer-volume rule is composed of 4 components:

- **Max Volume** (uint24): The maximum percent in basis units of total supply to be traded during the *period*.
- **Period** (uint16): The amount of hours that defines a period.
- **Starting Timestamp** (uint64): The timestamp of the date when the *period* starts counting.
- **Total Supply** (uint256): if not zero, this value will always be used as the token's total supply for rule evaluation. This can be used when the amount of circulating supply is much smaller than the amount of the token totalSupply due to some tokens being locked in a dev account or a vesting contract, etc. Only use this value in such cases.

```c
/// ******** Token Transfer Volume ********
    struct TokenTransferVolumeRule {
        uint24 maxVolume; // this is a percentage with 2 decimals of precision (2500 = 25%)
        uint16 period; // hours
        uint64 startTime; // UNIX date MUST be at a time with 0 minutes, 0 seconds. i.e: 20:00 on Jan 01 2024
        uint256 totalSupply; // If specified, this is the circulating supply value to use. If not specified, it defaults to token's totalSupply.
    }
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

The token-transfer-volume rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
/// ******** Token Transfer Volume ********
    struct TransferVolRuleS {
        mapping(uint32 => INonTaggedRules.TokenTransferVolumeRule) transferVolumeRules;
        uint32 transferVolRuleIndex;
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The processor receives the ID of the token-transfer-volume rule set in the token handler. 
2. The processor receives the current `transfer volume`, `last transfer time`, `amount` and token's total supply from the handler.
3. The processor evaluates whether the rule has a set total supply or use the token's total supply provided by the handler set at the beginning of every new `period`. 
4. The processor evaluates whether the rule is active based on the `starting timestamp`. If it is not active, the rule evaluation will skip the next steps, and will simply return the `transfer volume` value.
5. The processor evaluates whether the current time is within a new `period`.
    - **If it is a new period**, the processor will set the `amount` value from the current transaction as the `_volume` value for the volume percent of total supply calculation.
    - **If it is not a new period**, the processor accumulates the `transfer volume` (tokens transferred) and the `amount` of tokens to be transferred as the `_volume` value for the volume percent of total supply calculation. 
6. The processor calculates the final volume percentage, in basis units, from `_volume` and the total supply set in step 3. 
7. The processor evaluates if the final volume percentage of total supply would be greater than the `max volume` in the case of the transaction succeeding. 
    - If yes, then the transaction will revert. 
    - If no, the processor will return the `_volume` value for the current `period` to the handler.

###### *see [ERC20RuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenTransferVolumePasses*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error TransferExceedsMaxVolumeAllowed();
```

The selector for this error is `0x3627495d`.

## Create Function

Adding a token-transfer-volume rule is done through the function:

```c
function addTransferVolumeRule(
    address _appManagerAddr,
    uint24 _maxVolumePercentage,
    uint16 _hoursPerPeriod,
    uint64 _startTimestamp,
    uint256 _totalSupply
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_maxVolumePercentage** (uint24): maximum allowable basis unit percentage of trading volume per period.
- **_hoursPerPeriod** (uint16): the amount of hours per period.
- **_startTimestamp** (uint64): starting timestamp of the rule. This timestamp will determine the time that a day starts and ends for the rule processing. For example, *the amount of trades will reset to 0 every day at 2:30 pm.*
- **_totalSupply** (uint256): (optional) if not 0, then this is the value used for totalSupply instead of the live token's totalSupply value at rule processing time.


### Parameter Optionality:

The parameters where developers have the options are:
- **_totalSupply**: For volatility calculations, when this is zero, the token's totalSupply is used. Otherwise, this value is used as the total supply.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_maxVolumePercentage_` is not greater than 1000000 (1000%). 
- `maxVolumePercentage` and `_hoursPerPeriod` are greater than a value of 0.
- `_startTimestamp` is not zero and is not more than 52 weeks in the future.


###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond]((../../../src/economic/ruleStorage/RuleDataFacet.sol)):
    -  Function to get a rule by its ID:
        ```c
        function getTransferVolumeRule(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.TokenTransferVolumeRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTransferVolumeRules() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTokenTransferVolumePasses(
                    uint32 _ruleId, 
                    uint256 _volume,
                    uint256 _supply, 
                    uint256 _amount, 
                    uint64 _lastTransferTs
                ) 
                external 
                view;
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setTokenTransferVolumeRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateTokenTransferVolumeRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isTokenTransferVolumeActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getTokenTransferVolumeRule() external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Transfer Volume** (uint256): the updated value for the total traded volume during the period. 

```c
uint256 private transferVolume;
```

*see [ERC721Handler](../../../src/token/ERC721/ProtocolERC721Handler.sol)/[ERC20Handler](../../../src/token/ERC20/ProtocolERC20Handler.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Transfer Volume** (uint256): the updated value for the total traded volume during the period. 
- **Last Transfer Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
uint64 private lastTransferTs;
uint256 private transferVolume;
```

*see [ERC721Handler](../../../src/token/ERC721/ProtocolERC721Handler.sol)/[ERC20Handler](../../../src/token/ERC20/ProtocolERC20Handler.sol)*

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TRANSFER_VOLUME".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "TRANSFER_VOLUME".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

- **ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)** emitted when a Transfer counter rule has been activated in an asset handler:
    - ruleType: "TRANSFER_VOLUME".
    - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- This rule has no dependencies.
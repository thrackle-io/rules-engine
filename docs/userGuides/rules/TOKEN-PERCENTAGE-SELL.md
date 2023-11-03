# Token Transfer Volume Rule

## Purpose

The token-percentage-sell rule enforces a limit of the sale of tokens during a period. This rule sets a percentage of the token's total supply that is able to be sold per period. For this rule, a sell is considered a swap of an application token for an non application or chain native token. This can also be interpreted as an account leaving the application's ecosystem via AMM an swap. 

## Tokens Supported

- ERC20

## Scope 

This rule works at an asset level. It must be activated and configured for each desired AMM in the corresponding asset handler.

## Data Structure

A token-percentage-sell rule is composed of 4 components:

- **Token Percentage** (uint16): The maximum percent in basis units of total supply to be sold during the *period*.
- **Sell  Period** (uint16): The amount of hours that defines a period.
- **Starting Timestamp** (uint64): The timestamp of the date when the *period* starts counting.
- **Total Supply** (uint256): if not zero, this value will always be used as the token's total supply for rule evaluation. This can be used when the amount of circulating supply is much smaller than the amount of the token totalSupply due to some tokens being locked in a dev account or a vesting contract, etc. Only use this value in such cases.

```c
/// ******** Token Percentage Sell Rules ********
struct TokenPercentageSellRule {
    uint16 tokenPercentage; /// from 0000 to 10000 => 0.00% to 100.00%.
    uint16 sellPeriod;
    uint256 totalSupply; /// set 0 to use erc20 totalSupply
    uint64 startTime; ///start of time period for the rule
}
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

The token-percentage-sell rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
/// ******** Token Percentage Sell Rules ********
struct PctSellRuleS {
    mapping(uint32 => INonTaggedRules.TokenPercentageSellRule) percentageSellRules;
    uint32 percentageSellRuleIndex;
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

1. The processor receives the ID of the token-percentage-sell rule set in the asset handler. 
2. The processor receives the current `totalSoldWithinPeriod`, `_token_amount_0`, `previous sell time`, and token's total supply from the handler.
3. The processor evaluates whether the rule has a set total supply or uses the token's total supply provided by the handler set at the beginning of every new `period`.  
4. The processor will evaluate whether the current time is within a new `period`.
    - **If it is a new period**, the processor will use the `_token_amount_0` value from the current transaction as the `percentOfTotalSupply` value for the sell percent of total supply calculation.
    - **If it is not a new period**, the processor will then accumulate the `totalSoldWithinPeriod` (tokens transferred) and the `_token_amount_0` of tokens to be transferred as the `percentOfTotalSupply` value for the sell percent of total supply calculation. 
5. The processor calculates the final sell percentage, in basis units, from `percentOfTotalSupply` and the total supply set in step 3. 
6. The processor evaluates if the final sell percentage of total supply would be greater than the `tokenPercentage` in the case of the transaction succeeding. 
    - If yes, then the transaction will revert. 
    - If no, the processor will return the `tokenPercentage` value for the current `period` to the handler.

###### *see [ERC20RuleProcessorFacet](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkSellPercentagePasses*

## Evaluation Exceptions 
- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error SellPercentageReached();
```

The selector for this error is `0xb17ff693`.

## Create Function

Adding a token-percentage-sell rule is done through the function:

```c
function addPercentageSellRule(
    address _appManagerAddr,
    uint16 _tokenPercentage,
    uint16 _sellPeriod,
    uint256 _totalSupply,
    uint64 _startTimestamp
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)* 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_tokenPercentage** (uint16): maximum allowable basis unit percentage of trading volume per period.
- **_sellPeriod** (uint16): the amount of hours per period.
- **_startTimestamp** (uint64): starting timestamp of the rule. This timestamp will determine the time that a day starts and ends for the rule processing. For example, *the amount of trades will reset to 0 every day at 2:30 pm.*
- **_totalSupply** (uint256): (optional) if not 0, then this is the value used for totalSupply instead of the live token's totalSupply value at rule processing time.


### Parameter Optionality:

The parameters where developers have the options are:
- **_totalSupply**: For volatility calculations, when this is zero, the token's totalSupply is used. Otherwise, this value is used as the total supply.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_tokenPercentage_` is not greater than 9999 (99.99%). 
- `_tokenPercentage` and `_sellPeriod` are greater than a value of 0.
- `_startTimestamp` is not zero and is not more than 52 weeks in the future.


###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond]((../../../src/economic/ruleStorage/RuleDataFacet.sol)):
    -  Function to get a rule by its ID:
        ```c
        function getPctSellRule(
            uint32 _index
            ) 
            external 
            view 
            returns 
            (NonTaggedRules.TokenPercentageSellRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalPctSellRule() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkSellPercentagePasses(
                uint32 ruleId, 
                uint256 currentTotalSupply, 
                uint256 amountToTransfer, 
                uint64 lastSellTime, 
                uint256 soldWithinPeriod
            ) 
            external 
            view 
            returns (uint256);
        ```
- in Asset Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setSellPercentageRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateSellPercentageRuleIdRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isSellPercentageRuleActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getSellPercentageRuleId() external view returns (uint32);
        ```
## Return Data

This rule returns the value:
1. **Total Sold Within Period** (uint256): the updated value for the total traded volume during the period. 

```c
uint256 private totalSoldWithinPeriod;
```

*see [AMMHandler](../../../src/liquidity/ProtocolAMMHandler.sol)*

## Data Recorded

This rule requires recording of the following information in the asset handler:

- **Total Sold Within Period** (uint256): the updated value for the total sold during the period. 
- **Previous Sell Time** (uint64): the Unix timestamp of the last update in the Last-Transfer-Time variable

```c
uint64 private previousSellTime;
uint256 private totalSoldWithinPeriod;
```

*see [AMMHandler](../../../src/liquidity/ProtocolAMMHandler.sol)*

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "SELL_PERCENTAGE".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "SELL_PERCENTAGE".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

- **ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)** emitted when a Transfer counter rule has been activated in an asset handler:
    - ruleType: "SELL_PERCENTAGE".
    - handlerAddress: the address of the asset handler where the rule has been activated.

## Dependencies

- This rule has no dependencies.
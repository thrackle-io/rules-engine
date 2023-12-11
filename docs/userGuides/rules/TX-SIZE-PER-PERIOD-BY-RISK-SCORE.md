# Transaction Size Per Period By Risk Score Rule

## Purpose

The purpose of this rule is to prevent accounts identified as "risky" from moving large amounts of US Dollars in tokens within a specified period of time. This attempts to mitigate the existential, ethical or legal risks to an economy posed by such accounts.

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A transaction-size-per-period-by-risk-score rule is composed of 4 variables:

- **riskLevel** (uint8[]): array of risk score delimiting the different risk segments.
- **maxSize** (uint48[]): array of maximum USD worth of application assets that a transaction can move per risk segment in a period of time.
- **period** (uint16): the amount of hours that defines a period.
- **startingTime** (uint64): the Unix timestamp of the date when the rule starts the first *period*.

The relation between `riskLevel` and `maxSize` can be explained better in the following example:

Imagine the following data structure
```
riskLevel = [25, 50, 75];
maxSize = [500, 250, 50];
```

 | risk score | balance | resultant logic |
| - | - | - |
| Implied* | Implied* | 0-24 ->  NO LIMIT |
| 25 | $500 | 25-49 ->   $500 max |
| 50 | $250 | 50-74 ->   $250 max |
| 75 | $50 | 75-100 ->   $50 max |

\* *Note that the first risk segment is implied and has no limit. This first segment is from risk score 0 to the lowest risk score defined in the rule (`riskLevel`). A no-implied-segment rule could be achieved by starting the `riskLevel` from 0.*

***risk scores can be between 0 and 100.***

```c
/// ******** Transaction Size Per Period Rules ********
struct TxSizePerPeriodToRiskRule {
        uint48[] maxSize; /// whole USD (no cents) -> 1 = 1 USD (Max allowed: 281 trillion USD)
        uint8[] riskLevel;
        uint16 period; // hours
        uint64 startingTime; 
    }
```
###### *see [RuleDataInterfaces](../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
 /// ******** Transaction Size Per Period Rules ********
    struct TxSizePerPeriodToRiskRuleS {
        mapping(uint32 => IApplicationRules.TxSizePerPeriodToRiskRule) txSizePerPeriodToRiskRule;
        uint32 txSizePerPeriodToRiskRuleIndex;
    }
```

###### *see [IRuleStorage](../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the asset handler by a **rule administrator**.
- This rule can only be activated/deactivated in the asset handler by a **rule administrator**.
- This rule can only be updated in the asset handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The asset handler calculates the US Dollar amount of tokens being transferred, and gets the risk score from the AppManager for the account in the *from* side of the transaction.
2. The asset handler then sends these values along with the rule Id of the transaction-size-per-period-by-risk-score rule set in the handler, the date of the last transfer of tokens by the account, and the accumulated US Dollar amount transferred during the period to the protocol.
3. The protocol then proceeds to check if the current transaction is part of an ongoing period, or if it is the first one in a new period.
    - **If it is a new period**, the protocol resets the accumulated US Dollar amount transferred during current period to just the amount being currently transferred. 
    - **If it is not a new period**, then the protocol accumulates the amount being currently transferred to the accumulated US Dollar amount transferred during the period. 
4. The protocol then evaluates the accumulated US Dollar amount transferred during current period against the rule's maximum allowed for the risk segment in which the account is in. The protocol reverts the transaction if the accumulated amount exceeds this rule risk-segment's maximum.

###### *see [ApplicationRiskProcessorFacet](../../src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol) -> checkMaxTxSizePerPeriodByRisk*

## Evaluation Exceptions 

- This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error MaxTxSizePerPeriodReached(uint8 riskScore, uint256 maxTxSize, uint16 hoursOfPeriod);
```

- riskScore: account's risk score.
- maxTxSize: the rule's risk-segment's maximum allowed.
- hoursOfPeriod: the rule's risk-segment's period.

The selector for this error is `0x3dcf1b35`.


## Create Function

Adding a transaction-size-per-period-by-risk-score rule is done through the function:

```c
function addMaxTxSizePerPeriodByRiskRule(
            address _appManagerAddr,
            uint48[] calldata _maxSize,
            uint8[] calldata _riskLevel,
            uint16 _period,
            uint64 _startTimestamp
        ) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```

###### *see [AppRuleDataFacet](../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*
The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_riskScores** (uint8[]): array of risk scores delimiting each risk segment.
- **_txnLimits** (uint48[]): array of maximum US-Dollar amounts allowed to be transferred in a transaction for each risk segment (in whole US Dollars).
- **_period** (uint16): the amount of hours that defines a period.
- **_startTimestamp** (uint64): the timestamp of the date when the rule starts the first *period*.

### Parameter Optionality:
There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_appManagerAddr` is not the zero address.
- `_riskScores` and `_txnLimits` are the same size.
- `_riskScores` elements are in ascending order and no greater than 99.
- `_txnLimits` elements are in descending order.
- `period` is not zero.
- `_startTimestamp` is not zero and is not more than 52 weeks in the future.

###### *see [AppRuleDataFacet](../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:
- In Protocol [Rule Processor](../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function to get a rule by its Id:
        ```c
        function getMaxTxSizePerPeriodRule(uint32 _index) external view returns (AppRules.TxSizePerPeriodToRiskRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalMaxTxSizePerPeriodRules() external view returns (uint32);
        ```
- In Protocol [Rule Processor](../../src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkMaxTxSizePerPeriodByRisk(
                    uint32 ruleId, 
                    uint128 _usdValueTransactedInPeriod, 
                    uint128 amount, 
                    uint64 lastTxDate, 
                    uint8 _riskScore
                ) 
                external 
                view 
                returns (uint128);
        ```
- In the [Application Handler](../../src/client/application/ProtocolApplicationHandler.sol):
    - Function to set and activate at the same time the rule in the asset handler:
        ```c
        function setMaxTxSizePerPeriodByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in the asset handler:
        ```c
        function activateMaxTxSizePerPeriodByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule in an asset handler:
        ```c
        function isMaxTxSizePerPeriodByRiskActive() external view returns (bool);
        ```
    - Function to get the rule Id from the asset handler:
        ```c
        function getMaxTxSizePerPeriodByRiskRuleId() external view returns (uint32);
        ```

## Return Data

This rule returns 1 value:

1. **Accumulated US Dollar Amount Transferred During Period** (uint128): the updated value for the total US Dollar amount of tokens during current period. 

```c
mapping(address => uint128) usdValueTransactedInRiskPeriod;
```

*see [ProtocolApplicationHandler](../../src/client/application/ProtocolApplicationHandler.sol)


## Data Recorded

This rule requires recording of the following information in the application handler:

```c
/// MaxTxSizePerPeriodByRisk data
mapping(address => uint128) usdValueTransactedInRiskPeriod;
mapping(address => uint64) lastTxDateRiskRule;
```

*see [ProtocolApplicationHandler](../../src/client/application/ProtocolApplicationHandler.sol)


## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "MAX_TX_PER_PERIOD".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.
- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "MAX_TX_PER_PERIOD".
        - ruleId: the ruleId set for this rule in the handler.

## Dependencies

This rule depends on:

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be setup in the token handlers in order for this rule to work.

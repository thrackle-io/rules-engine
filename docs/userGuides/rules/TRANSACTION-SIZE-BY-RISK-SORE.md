# Transaction Size By Risk Score Rule

## Purpose

The purpose of this rule is to prevent accounts identified as "risky" from moving large amounts of US Dollars in tokens in a single transaction. This attempts to mitigate the existential, ethical, or legal risks to an economy posed by such accounts.

## Applies To:

- [x] ERC20
- [x] ERC721
- [x] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will have no choice but to comply with this rule when active.

## Data Structure

A transaction-size-by-risk-score rule is composed of 2 variables:

- **riskLevel** uint8[]: array of risk scores delimiting the different risk segments.
- **maxSize** uint48[]: array of maximum USD worth of application assets that a transaction can move per risk segment.

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
/// ******** Transaction Size Rules ********
    struct TransactionSizeToRiskRule {
        uint8[] riskLevel;
        uint48[] maxSize; /// whole USD (no cents) -> 1 = 1 USD (Max allowed: 281 trillion USD)
    }
```

###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*


These rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

```c
 /// ******** Transaction Size Rules ********
    struct TxSizeToRiskRuleS {
        mapping(uint32 => ITaggedRules.TransactionSizeToRiskRule) txSizeToRiskRule;
        uint32 txSizeToRiskRuleIndex;
    }
```

###### *see [IRuleStorage](../../../src/protocol/economic/ruleProcessor/IRuleStorage.sol)*

## Configuration and Enabling/Disabling
- This rule can only be configured in the protocol by a **rule administrator**.
- This rule can only be set in the application handler by a **rule administrator**.
- This rule can only be activated/deactivated in the application handler by a **rule administrator**.
- This rule can only be updated in the application handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The application handler calculates the US Dollar amount of tokens being transferred, and gets the risk score from the AppManager for the account in the *from* side of the transaction.
2. The application handler then sends these values along with the rule Id of the transaction-size-by-risk-score rule set in the handler to the protocol.
3. The protocol evaluates the amount being transferred against the rule's maximum allowed for the risk segment in which the account is in. The protocol reverts the transaction if the amount being transferred exceeds this rule risk-segment's maximum.

###### *see [RiskTaggedRuleProcessorFacet](../../../src/protocol/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol) -> checkTransactionLimitByRiskScore*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error TransactionExceedsRiskScoreLimit();
```

The selector for this error is `0x9fe6aeac`.


## Create Function

Adding a transaction-size-by-risk-score rule is done through the function:

```c
function addTransactionLimitByRiskScore(
            address _appManagerAddr, 
            uint8[] calldata _riskScores, 
            uint48[] calldata _txnLimits
        ) 
        external 
        ruleAdministratorOnly(_appManagerAddr)
        returns (uint32);
```
###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): the address of the application manager to verify that the caller has rule administrator privileges.
- **_riskScores** (uint8[]): array of risk scores delimiting each risk segment.
- **_txnLimits** (uint48[]): array of maximum US-Dollar amounts allowed to be transferred in a transaction for each risk segment (in whole US Dollars).

### Parameter Optionality:

There are no options for the parameters of this rule.

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- The `_appManagerAddr` is not the zero address.
- `_riskScores` and `_txnLimits` are the same size.
- `_riskScores` elements are in ascending order and no greater than 99.
- `_txnLimits` elements are in descending order.

###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function to get a rule by its Id:
        ```c
        function getTransactionLimitByRiskRule(uint32 _index) external view returns (AppRules.TransactionSizeToRiskRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalTransactionLimitByRiskRules() external view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view;
        ```
- - In the [Application Handler](../../../src/client/application/ProtocolApplicationHandler.sol):
    - Function to set and activate at the same time the rule in the application handler:
        ```c
        function setTransactionLimitByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in the application handler:
        ```c
        function activateTransactionLimitByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
     - Function to know the activation state of the rule in an application handler:
        ```c
        function isTransactionLimitByRiskActive() external view returns (bool);
        ```
    - Function to get the rule Id from the application handler:
        ```c
        function getTransactionLimitByRiskRule() external view returns (uint32);
        ```

## Return Data

This rule doesn't return any data.

## Data Recorded

This rule doesn't require of any data to be recorded.

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "TX_SIZE_BY_RISK".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: empty array.

- **event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);**:
    - Emitted when: rule has been applied in an application manager handler.
    - Parameters: 
        - ruleType: "TX_SIZE_BY_RISK".
        - ruleId: the ruleId set for this rule in the handler.

- **event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress)**:
    - Emitted when: a rule has been activated in an application handler:
    - Parameters: 
        - ruleType: "TX_SIZE_BY_RISK".
        - handlerAddress: the address of the application handler where the rule has been activated.


## Dependencies

This rule depends on:

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be setup in the application handler in order for this rule to work.


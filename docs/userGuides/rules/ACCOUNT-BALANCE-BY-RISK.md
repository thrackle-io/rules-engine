# Account Balance By Risk Rule

## Purpose

The account-balance-by-risk rule enforces accumulated balance limits in $USD for user accounts based on a protocol assigned risk score to that account via the application manager. Risk scores are ranged between 0-99. Balance limits are set by range based on the risk scores given at rule creation. For example, if risk scores given in the array are: 25,50,75 and balance limits are: 500,250,100. The balance limit ranges are as follows: 0-24 = NO LIMIT, 25-49 = 500, 50-74 = 250, 75-99 = 100. 
```c
risk scores      balances         resultant logic
-----------      --------         ---------------
                                   0-24  =   NO LIMIT 
    25              500            25-49 =   500
    50              250            50-74 =   250
    75              100            75-99 =   100
```

## Tokens Supported

- ERC20
- ERC721

## Scope 

This rule works at the application level. It must be activated and configured in the application handler. Each token in the application ecosystem will be valued and contribute to the rule balance calculation. This rule, when active, will apply to each token within the application.

## Data Structure

An account-balance-by-risk rule is composed of 2 components:

- **Risk Level** (uint8[]): The array of risk scores.
- **Max Balance** (uint48[]): The array of maximum whole dollar limits for risk score range.

```c
/// ******** Account Balance Rules By Risk Score ********
struct AccountBalanceToRiskRule {
    uint8[] riskLevel; 
    uint48[] maxBalance; /// whole USD (no cents) -> 1 = 1 USD (Max allowed: 281 trillion USD)
}
```
###### *see [RuleDataInterfaces](../../../src/economic/ruleStorage/RuleDataInterfaces.sol)*

The account-balance-by-risk-score rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Account Balance Rules ********
    struct AccountBalanceToRiskRuleS {
        mapping(uint32 => IApplicationRules.AccountBalanceToRiskRule) balanceToRiskRule;
        uint32 balanceToRiskRuleIndex;
    }
```
###### *see [IRuleStorage](../../../src/economic/ruleStorage/IRuleStorage.sol)*

## Role Applicability

- **Evaluation Exceptions**: 
    - This rule doesn't apply when an **app administrator** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an app administrator is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
    - In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

- **Configuration and Enabling/Disabling**:
    - This rule can only be configured in the protocol by a **rule administrator**.
    - This rule can only be set in the application handler by a **rule administrator**.
    - This rule can only be activated/deactivated in the application handler by a **rule administrator**.
    - This rule can only be updated in the application handler by a **rule administrator**.


## Rule Evaluation

The rule will be evaluated with the following logic:

1. The processor will receive the ID of the account-balance-by-risk rule set in the application handler. 
2. The processor will receive the risk score of the user set in the app manager.
3. The processor will receive the $USD value of all protocol supported tokens owned by the to address and the $USD value of the transaction. 
4. The processor will loop through the risk scores within the rule ID provided to find the range that the user is within. The processor loops until a risk score within the rule is greater than the risk score of the to address and uses the previous range.
    - If the risk score of the to address is greater than or equal to the last risk score in the `risk scores` array, the processor will use the last `max balance` limit of the array. 
5. The processor will then check if the transaction value + current balance total is less than the risk score `max balance`. If total is greater than `max balance`, the rule will revert. 

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenTransferVolumePasses*

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error BalanceExceedsRiskScoreLimit();
```

The selector for this error is `0x58b13098`.

## Create Function

Adding a token-transfer-volume rule is done through the function:

```c
function addAccountBalanceByRiskScore(
    address _appManagerAddr, 
    uint8[] calldata _riskScores, 
    uint48[] calldata _balanceLimits
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [RuleDataFacet](../../../src/economic/ruleStorage/RuleDataFacet.sol)*


The create function in the protocol needs to receive the appManager address of the application in order to verify that the caller has Rule administrator privileges. 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_riskScores** (uint8): The array of risk score ranges (0-99).
- **_balanceLimits** (uint48): the maximum whole $USD limit for each risk score range.


### Parameter Optionality:

There is no parameter optionality for this rule. 

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_riskScores` and `_balanceLimits` arrays are equal in length. 
- `_riskScores` array last value is not greater than 99.
- `_riskScores` array is in ascending order (the next value is always larger than the previous value in the array).
- `_balanceLimits` array is in descending order (the next value is always smaller than the previous value in the array). 


###### *see [AppRuleDataFacet](../../../src/economic/ruleStorage/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Storage Diamond]((../../../src/economic/ruleStorage/RuleDataFacet.sol)):
    -  Function to get a rule by its ID:
        ```c
        function getAccountBalanceByRiskScore(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (NonTaggedRules.TokenTransferVolumeRule memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccountBalanceByRiskScoreRules() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAccBalanceByRisk(
                    uint32 _ruleId, 
                    address _toAddress, 
                    uint8 _riskScore, 
                    uint128 _totalValuationTo, 
                    uint128 _amountToTransfer
                ) 
                external 
                view;
        ```
- in Application Handler:
    - Function to set and activate at the same time the rule in an asset handler:
        ```c
        function setAccountBalanceByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an asset handler:
        ```c
        function activateAccountBalanceByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an asset handler:
        ```c
        function isAccountBalanceByRiskActive() external view returns (bool);
        ```
    - Function to get the rule Id from an asset handler:
        ```c
        function getAccountBalanceByRiskRule() external view returns (uint32);
        ```
## Return Data

This rule does not return any data.

## Data Recorded

This rule does not require any data to be recorded. 

## Events

- **event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags)**: 
    - Emitted when: the rule has been created in the protocol.
    - Parameters:
        - ruleType: "BALANCE_BY_RISK".
        - ruleId: the index of the rule created in the protocol by rule type.
        - extraTags: an empty array.

- **event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId)**:
    - Emitted when: rule has been applied in an asset handler.
    - parameters: 
        - ruleType: "BALANCE_BY_RISK".
        - handlerAddress: the address of the asset handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

## Dependencies

- This rule has no dependencies.
# Account Max Value By Risk Score

## Purpose

The account-max-value-by-risk-score rule enforces accumulated balance limits in U.S. dollars for user accounts based on a protocol assigned risk score to that account via the application manager. Risk scores are ranged between 0-99. Balance limits are set by range based on the risk scores given at rule creation. For example, if risk scores given in the array are: 25,50,75 and balance limits are: 500,250,100. The balance limit ranges are as follows: 0-24 = NO LIMIT, 25-49 = 500, 50-74 = 250, 75-99 = 100. 
```c
risk scores      balances         resultant logic
-----------      --------         ---------------
                                   0-24  =   NO LIMIT 
    25              500            25-49 =   500
    50              250            50-74 =   250
    75              100            75-99 =   100
```

## Applies To:

- [x] ERC20
- [x] ERC721
- [ ] AMM

## Scope 

This rule works at the application level which means that all tokens in the app will comply with this rule when the rule is active. Each token in the application ecosystem will be valued and contribute to the rule balance calculation.

## Data Structure

An account-max-value-by-risk-score rule is composed of 2 components:

- **Risk Score** (uint8[]): The array of risk scores.
- **Max Value** (uint48[]): The array of maximum whole dollar limits for risk score range.

```c
/// ******** Account Max Value By Risk Scoree ********
struct AccountMaxValueByRiskScore {
    uint8[] riskScore; 
    uint48[] maxValue; /// whole US dollar (no cents) -> 1 = 1 US dollar (Max allowed: 281 trillion USD)
}
```
###### *see [RuleDataInterfaces](../../../src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol)*

The account-max-value-by-risk-score-score rules are stored in a mapping indexed by ruleId(uint32) in order of creation:

 ```c
    /// ******** Account Max Value Rules ********
    struct AccountMaxValueByRiskScoreS {
        mapping(uint32 => IApplicationRules.AccountMaxValueByRiskScore) accountMaxValueByRiskScoreRules;
        uint32 accountMaxValueByRiskScoreIndex;
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

1. The processor receives the ID of the account-max-value-by-risk-score rule set in the application handler. 
2. The processor receives the risk score of the user set in the app manager.
3. The processor receives the U.S. dollar value of all protocol supported tokens owned by the to address and the U.S. dollar value of the transaction. 
4. The processor finds the `max value` value for the risk score.  
5. The processor checks if the transaction value + current balance total is less than the risk score `max value`. If total is greater than `max value`, the rule reverts. 

###### *see [ApplicationRiskProcessorFacet](../../../src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol) -> checkAccountMaxValueByRiskScore*

## Evaluation Exceptions 
- This rule doesn't apply when a **ruleBypassAccount** address is in either the *from* or the *to* side of the transaction. This doesn't necessarily mean that if an rule bypass account is the one executing the transaction it will bypass the rule, unless the aforementioned condition is true.
- In the case of ERC20s, this rule doesn't apply when a **registered treasury** address is in the *to* side of the transaction.

### Revert Message

The rule processor will revert with the following error if the rule check fails: 

```
error OverMaxAccValueByRiskScore();
```

The selector for this error is `0x8312246e`.

## Create Function

Adding an account-max-value-by-risk-score rule is done through the function:

```c
function addAccountMaxValueByRiskScore(
    address _appManagerAddr, 
    uint8[] calldata _riskScores, 
    uint48[] calldata _maxValue
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_riskScores** (uint8): The array of risk score ranges (0-99).
- **_maxValue** (uint48): the maximum whole U.S. dollar limit for each risk score range.


### Parameter Optionality:

There is no parameter optionality for this rule. 

### Parameter Validation:

The following validation will be carried out by the create function in order to ensure that these parameters are valid and make sense:

- `_appManagerAddr` is not the zero address.
- `_riskScores` and `_maxValue` arrays are equal in length. 
- `_riskScores` array last value is not greater than 99.
- `_riskScores` array is in ascending order (the next value is always larger than the previous value in the array).
- `_maxValue` array is in descending order (the next value is always smaller than the previous value in the array). 


###### *see [AppRuleDataFacet](../../../src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol)*

## Other Functions:

- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol)):
    -  Function to get a rule by its ID:
        ```c
        function getAccountMaxValueByRiskScore(
                    uint32 _index
                ) 
                external 
                view 
                returns 
                (appRules.AccountMaxValueByRiskScore memory);
        ```
    - Function to get current amount of rules in the protocol:
        ```c
        function getTotalAccountMaxValueByRiskScore() public view returns (uint32);
        ```
- In Protocol [Rule Processor](../../../src/protocol/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol):
    - Function that evaluates the rule:
        ```c
        function checkAccountMaxValueByRiskScore(
                    uint32 _ruleId, 
                    address _toAddress, 
                    uint8 _riskScore, 
                    uint128 _totalValueTo, 
                    uint128 _amountToTransfer
                ) 
                external 
                view;
        ```
- in Application Handler:
    - Function to set and activate at the same time the rule in an application handler:
        ```c
        function setAccountMaxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to activate/deactivate the rule in an application handler:
        ```c
        function activateAccountMaxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress);
        ```
    - Function to know the activation state of the rule in an application handler:
        ```c
        function isAccountMaxValueByRiskScoreActive() external view returns (bool);
        ```
    - Function to get the rule Id from an application handler:
        ```c
        function getAccountMaxValueByRiskScoreId() external view returns (uint32);
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
    - Emitted when: rule has been applied in an application handler.
    - Parameters: 
        - ruleType: "BALANCE_BY_RISK".
        - handlerAddress: the address of the application handler where the rule has been applied.
        - ruleId: the index of the rule created in the protocol by rule type.

## Dependencies

- **Pricing contracts**: [pricing contracts](../pricing/README.md) for ERC20s and ERC721s need to be setup in the application handler in order for this rule to work.

- **ERC721Enumerable**: This rule utilizes the balance valuation calculated using the tokenOfOwnerByIndex function, requiring [ERC721Enumerable](https://eips.ethereum.org/EIPS/eip-721)
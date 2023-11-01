# Account Balance By Risk Rule

## Purpose

The account-balance-by-risk rule enforces accumulated balance limits in $USD for user accounts based on a risk score assigned to that account. Risk scores are ranged between 0-99. Balance limits are set by range based on the risk scores given at rule creation. For example, if risk scores given in the array are: 25,50,75 and balance limits are: 1000,500,250. The balance limits ranges are as follows: 0-24 = NO LIMIT, 25-49 = 500, 50-74 = 250, 75-99 = 100. 
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

This rule works at the application level. It must be activated and configured in the application handler. Each token in the application ecosystem will be valued and contribute to the rule balance calculation. 

## Data Structure

A token-transfer-volume rule is composed of 4 components:

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
3. The 

###### *see [IRuleStorage](../../../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol) -> checkTokenTransferVolumePasses*

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


The create function in the protocol needs to receive the appManager address of the application in order to verify that the caller has Rule administrator privileges. 

The create function will return the protocol ID of the rule.

### Parameters:

- **_appManagerAddr** (address): The address of the application manager to verify that the caller has Rule administrator privileges.
- **_maxVolumePercentage** (uint24): .
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
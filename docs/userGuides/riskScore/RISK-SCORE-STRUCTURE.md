# Protocol Risk Score Structure 

## Purpose

Application developers may wish to assign risk scores to accounts and addresses that they determine have a higher potential for behavior that is detrimental to their economy. These scores can range from 0-99. [Risk administrators](../permissions/ADMIN-ROLES.md) are the only admins that can assign risk scores to accounts and addresses. 

Rule administrators can add and activate [RISK-RULES](./RISK-SCORE-RULES.md) via the application handler contract. These rules are applied at the application level, meaning all assets within the application will be subjected to these rules. 


## Scope 

Risk scores can be applied to individual accounts or addresses of contracts. Risk scores are used to facilitate risk rule checks throughout the protocol. When an account (user) is given a risk score, they will be subject to any risk rules that are active. When a risk rule is added and activated every user with a risk score will be subjected to this risk rule. This means if the [TX-SIZE-PER-PERIOD](../rules/TX-SIZE-PER-PERIOD-BY-RISK-SCORE.md) is active and a has the following rule values: 
```
riskLevel = [25, 50, 75];
maxSize = [500, 250, 50];
```
The max values per period will be as follows: 

| risk score | balance | resultant logic |
| - | - | - |
| Implied* | Implied* | 0-24 ->  NO LIMIT |
| 25 | $500 | 25-49 ->   $500 max |
| 50 | $250 | 50-74 ->   $250 max |
| 75 | $50 | 75-100 ->   $50 max |

###### *see [RISK-RULES](./RISK-SCORE-RULES.md)* 


## Data Structure
Risk scores are a uint8 value stored in a mapping inside the RiskScores data contract. 
 
```c
///     address   => riskScore 
mapping(address => uint8) public scores;
```

###### *see [RiskScores](../../../src/client/application/data/RiskScores.sol)*

## Enabling/Disabling
- Risk scores can only be added in the app manager by an **risk administrator**.
- Risk scores can only be removed in the app manager by an **risk administrator**.


### Revert Messages

The transaction will revert with the following error if the risk score assigned is out of range when assigning risck scores: 

```
error riskScoreOutOfRange();
```
The selector for this error is `0xb3cbc6f3`.


## Add Functions

Adding a risk score is done through the function:

```c
function addRiskScore(address _account, uint8 _score) external onlyRole(RISK_ADMIN_ROLE); 
```

Adding multiple risk scores to a single account or address is done through the function:

```c
function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external onlyRole(RISK_ADMIN_ROLE); 
```

Adding multiple risk scores to multiple accounts or addresses is done through the function:

```c
function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyRole(RISK_ADMIN_ROLE); 
```

## Remove Function

Removing a risk score from account or address is done through the function:

```c
function removeRiskScore(address _account) external onlyRole(RISK_ADMIN_ROLE); 
```

###### *see [App Manager](../../../client/application/AppManager.sol)*

### Parameters:

- **_score** (uint8): risk score for an account.
- **_scores** (uint8): array of risk scores for an account.
- **_account** (address): address of the account for the risk score
- **_accounts** (address[]): array of addresses to for the risk scores


### Parameter Optionality:

There are no options for the parameters for the add functions.

### Parameter Validation:

The following validation will be carried out by the addRiskScore function in order to ensure that these parameters are valid and make sense:

- `_score` is within the 0-99 score range.
- `_account` is not the zero address.   

###### *see [RiskScores](../../../src/client/application/data/RiskScores.sol)*

## Other Functions:

- In [App Manager](../../../src/client/application/AppManager.sol):
    -  Function to check the score of an account or address:
        ```c
        function getRiskScore(address _account) external view virtual returns (uint8);
        ```
    -  Function to deploy new data contracts:
        ```c
        function deployDataContracts() private;
        ```
    - Function to retrieve risk scores data contract address:
        ```c
        function getRiskDataAddress() external view returns (address);
        ```
    - Function to propose data contract migration to new handler:
        ```c
        function proposeDataContractMigration(address _newOwner) external  onlyRole(APP_ADMIN_ROLE);
        ```
    - Function to confirm migration of data contracts to new handler:
        ```c
        function confirmDataContractMigration(address _oldHandlerAddress) external  onlyRole(APP_ADMIN_ROLE);
        ``` 

## Events

- **RiskScoreAdded(address indexed _address, uint8 _score)**: emitted when:
    - A risk score has been added.
- **RiskScoreRemoved(address indexed _address)**: emitted when: 
    - A risk score is removed. 
- **RiskProviderSet(address indexed _address)**: emitted when:
    - A risk score data contract has been migrated to the app manager address
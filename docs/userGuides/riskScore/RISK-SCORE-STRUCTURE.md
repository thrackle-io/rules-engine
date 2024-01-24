# Protocol Risk Score Structure 

## Purpose

Application developers may wish to assign risk scores to accounts and addresses that they determine have a higher potential for behavior that is detrimental to their economy. These scores can range from 0-99. [Risk administrators](../permissions/ADMIN-ROLES.md) are the only admins that can assign risk scores to accounts and addresses. 

Rule administrators can add and activate [RISK-RULES](./RISK-SCORE-RULES.md) via the application handler contract. These rules are applied at the application level, meaning all assets within the application will be subjected to these rules. 


## Scope 

Risk scores can be applied to individual accounts or addresses of contracts. Risk scores are used to facilitate risk rule checks throughout the procotol. When an account (user) is given a risk score, they will be subject to any rules that are active that utilize that tag. When a risk rule is added and activated every user with a risk score will be subjected to this risk rule. This means if the [TX-SIZE-PER-PERIOD](../rules/TX-SIZE-PER-PERIOD-BY-RISK-SCORE.md) is active and a has the following rule values: 
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

Adding a tag is done through the function:

```c
function addRiskScore(address _account, uint8 _score) external onlyRole(APP_ADMIN_ROLE); 
```

Adding multiple tags to a single account or address is done through the function:

```c
function addTagToMultipleAccounts(address[] _accounts, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE); 
```

Adding multiple tags to multiple accounts or addresses is done through the function:

```c
function addMultipleTagToMultipleAccounts(address[] _accounts, bytes32 _tags) external onlyRole(APP_ADMIN_ROLE); 
```

###### *see [Tags](../../../client/application/data/Tags.sol)*

## Remove Function

Removing a tag is done through the function:

```c
function removeTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE); 
```
###### *see [Tags](../../../client/application/data/Tags.sol)*

### Parameters:

- **_tag** (bytes32): tag for an account.
- **_tags** (bytes32[]): array of tags for an account.
- **_account** (address): address of the account to tag
- **_accounts** (address[]): array of addresses to tag


### Parameter Optionality:

There are no options for the parameters of the add or remove functions.

Application administrators can submit rules with "blank" tags. This allows for a default or always applicable rule values for [TAGGED-RULES](./TAGGED-RULES.md). 

### Parameter Validation:

The following validation will be carried out by the addTag function in order to ensure that these parameters are valid and make sense:

- `_tag` is not blank.
- `_account` has the tag. When adding tags this is used to avoid duplication. When removing tags this is used to ensure account has the tag to be removed.   

###### *see [Tags](../../../client/application/data/Tags.sol)*

## Other Functions:

- In [App Manager](../../../client/application/AppManager.sol):
    -  Function to check if an account or address has a tag:
        ```c
        function hasTag(address _address, bytes32 _tag) public view returns (bool);
        ```
    -  Function to get all the tags for an address:
        ```c
        function getAllTags(address _address) external view returns (bytes32[] memory);
        ```
    -  Function to deploy new data contracts:
        ```c
        function deployDataContracts() private;
        ```
    - Function to retrieve tags data contract address:
        ```c
        function getTagsDataAddress() external view returns (address);
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

- **Tag(address indexed _address, bytes32 indexed _tag, bool indexed add)**: emitted when:
    - A tag has been added. In this case, the `add` field of the event will be *true*.
    - A tag has been removed. In this case, the `add` field of the event will be *false*.
- **TagAlreadyApplied(address indexed _address)**: emitted when: 
    - A tag has already been added to an account. 
- **TagProviderSet(address indexed _address)**: emitted when:
    - A tag data contract has been migrated to the app manager address
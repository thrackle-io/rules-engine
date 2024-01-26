# Protocol Access Tier Structure 

## Purpose

Access Tier levels can be assigned to accounts and addresses by Access Tier Administrators through the [AppManager](../../src/client/application/AppManager.sol). They are predefined as 0,1,2,3,4 and are stored as uint8 in the AcessLevels data contract. This data contract is deployed when the app manager is deployed. The AccessLevels data contract can be migrated to a new application manager during an upgrade to maintain access level and address data. [Access Tier administrators](../permissions/ADMIN-ROLES.md) can migrate data contracts to a new app manager through a two step migration process.

The protocol uses access levels to perform access tier related rule checks. The levels may be used as needed to suit the needs of the application and the rules. 

The default access level for each account is 0. 

## Scope 

Access Levels can be applied to individual accounts or addresses of contracts. When an access tier related rule is activated, users will be subject to any limitations set by the rule related to their individual access level. 

###### *see [ACCESS-TIER-RULES](./ACCESS-TIER-RULES.md)* 


## Data Structure
Access Levels are a uint8 number stored in a mapping inside the AccessLevels data contract. 
 
```c
///     address   => levels 
mapping(address => uint8) public levels;
```

###### *see [AccessLevels](../../../client/application/data/AccessLevels.sol)*

## Enabling/Disabling
- Access Levels can only be set in the app manager by an **access tier administrator**.

### Revert Messages

The transaction will revert with the following error when attempting to set access level greater than 4: 

```
error AccessLevelIsNotValid();
```
The selector for this error is `0xfd12da91`.


The transaction will revert with the following error when attempting to set access level for 0x0000000000000000000000000000000000000000 address: 

```
error ZeroAddress();
```
The selector for this error is `0xd92e233d`.


## Add Functions

Adding an access level is done through the function:

```c
function addAccessLevel(address _account, uint8 _level) public onlyRole(ACCESS_TIER_ADMIN_ROLE);
```

Adding a single access level to multiple accounts or addresses is done through the function:

```c
function addAccessLevelToMultipleAccounts(address[] memory _accounts, uint8 _level) external onlyRole(ACCESS_TIER_ADMIN_ROLE);
```

Adding multiple access levels to multiple accounts or addresses is done through the function:

```c
function addMultipleAccessLevels(address[] memory _accounts, uint8[] memory _level) external onlyRole(ACCESS_TIER_ADMIN_ROLE);
```

###### *see [AccessLevels](../../../client/application/data/AccessLevels.sol)*

## Remove Function

N/A

### Parameters:

- **_level** (uint8): access level for an account.
- **_levels** (uint8[]): array of access levels for an account.
- **_account** (address): address of the account to tag
- **_accounts** (address[]): array of addresses to tag


### Parameter Optionality:

There are no options for the parameters of the add or remove functions.

### Parameter Validation:

The following validation will be carried out by the addAccessLevel function in order to ensure that these parameters are valid and make sense:

- `_level` is not greater than 4.
- `_account` is an address and not the zero address.

###### *see [AccessLevels](../../../client/application/data/AccessLevels.sol)*

## Other Functions:

- In [App Manager](../../../client/application/AppManager.sol):
    -  Function to get the access level of an address:
        ```c
        function getAccessLevel(address _account) external view returns (uint8);
        ```
    -  Function to deploy new data contracts:
        ```c
        function deployDataContracts() private;
        ```
    - Function to propose a new Access Level Provider
        ```c
        function proposeAccessLevelsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE);
        ```
    - Function to get the Access Level Provider address
        ```c
        function getAccessLevelProvider() external view returns (address);
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
- **AccessLevelAdded(address indexed _address, uint8 indexed _level)**: emitted when: 
    - An access level has been added. 
- **AccessLevelRemoved(address indexed _address)**: emitted when:
    - An access level has been removed. 
- **AccessLevelProviderSet(address indexed _address)**: emitted when:
    - An access level data contract has been migrated to the app manager address
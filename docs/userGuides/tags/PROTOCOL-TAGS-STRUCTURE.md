# Protocol Tags Structure 

## Purpose

Tags are assigned to addresses by application administrators through the application manager contract. A maximum of 10 Tags per address are stored as bytes32 in the Tags data contract. This data contract is deployed when the app manager is deployed. The Tags data contract can be migrated to a new application manager during an upgrade to maintain tagged address data. [App administrators](../permissions/ADMIN-ROLES.md) can migrate data contracts to a new app manager through a two step migration process.

The protocol uses tags to assess fees and perform rule checks for tag-based rules. Based on a user's tags different rule values will be assessed. Users with "TagA" may have a max balance limit of 1000 protocol supported tokens where users with "TagB" may have a 10,000 token limit. For a list of rules that utilize tags see [TAGGED-RULES](./TAGGED-RULES.md). 

Rules may utilize a "blank tag" where no specific tag is provided to the protocol when the rule is created. These rules will apply to all users of the protocol supported token that do not have a tag assigned to them. If a Min/Max Balance [TAGGED-RULES](./TAGGED-RULES.md) is active with a blank tag, every user that is not assigned a tag by the application administrators will be subject to the minimum and maximum limits of that rule. 

Tags are also used for the assessment of fees within the protocol. When activated, fees are additive and will be assessed for each tag an address has stored. 


## Scope 

Tags can be applied to individual accounts or addresses of contracts. Tags are used to assess fees or facilitate tagged rule checks throughout the procotol. When an account (user) is tagged, they will be subject to any rules that are active that utilize that tag. 

###### *see [TAGGED-RULES](./TAGGED-RULES.md)* 


## Data Structure
Tags are a bytes32 array stored in a mapping inside the Tags data contract. 
 
```c
///     address   => tags 
mapping(address => bytes32[]) public tagRecords;
```

###### *see [Tags](../../../src/client/application/data/Tags.sol)*

## Enabling/Disabling
- Tags can only be added in the app manager by an **app administrator**.
- Tags can only be removed in the app manager by an **app administrator**.


### Revert Messages

The transaction will revert with the following error if the tag limit is reached when adding tags: 

```
error MaxTagLimitReached();
```
The selector for this error is `0xa3afb2e2`.


The transaction will revert with the following error if there is no tag assigned when removing tags: 

```
error NoAddressToRemove();
```
The selector for this error is `0x7de8c17d`.


## Add Functions

Adding a tag is done through the function:

```c
function addTag(address _account, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE); 
```

Adding multiple tags to a single account or address is done through the function:

```c
function addTagToMultipleAccounts(address[] _accounts, bytes32 _tag) external onlyRole(APP_ADMIN_ROLE); 
```

Adding multiple tags to multiple addresses is done through the function:

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

- **event AD1467_Tag(address indexed _address, bytes32 indexed _tag, bool indexed add)**: emitted when:
    - A tag has been added. In this case, the `add` field of the event will be *true*.
    - A tag has been removed. In this case, the `add` field of the event will be *false*.
- **event AD1467_TagAlreadyApplied(address indexed _address)**: emitted when: 
    - A tag has already been added to an account. 
- **event AD1467_TagProviderSet(address indexed _address)**: emitted when:
    - A tag data contract has been migrated to the app manager address
# Application Manager

## Purpose

The Application Manager acts as a central hub for managing the application it is associated with. 

It provides the ability to manage metadata for accounts associated with the application including:
- Roles
- Tags
- Risk Scores
- Access Levels

The Application Manager also provides the ability to check application level rules via its associated Application Handler.

### Metadata

#### Roles

The Application Manager can be utilized for both updating and checking an account's role in relation to the application. These capabilites are provided for the following roles:

- Super Admin
- App Admin
- Risk Admin
- Access Level Admin
- Rule Admin
- Rule-Bypass Account

The following functions are provided for each admin type (we'll use the App Admin variant as an example here):

```c
function isAppAdministrator(address account) public view returns (bool)
```
Checks whether or not the provided address is an App Admin for the application. 

```c
function addAppAdministrator(address account) public onlyRole(SUPER_ADMIN_ROLE)
```
Adds the provided address as a new App Admin for the application. This function can only be called by the existing Super Admin.

```c
 function addMultipleAppAdministrator(address[] memory _accounts) external onlyRole(SUPER_ADMIN_ROLE) 
```
A utility method to add multiple App Admins at the same time. Like the singular version this can only be called by the existing Super Admin.

```c
function renounceAppAdministrator() external
```
Removes the senders role as an App Admin.


##### Super Admin Special Case

The functions are slightly different for a Super Admin. Because there can only be one super admin at a time we use a two-step process to set a new one. The following functions are used in place of the add function the other admin types employ:

```c
function proposeNewSuperAdmin(address account) external onlyRole(SUPER_ADMIN_ROLE)
├── when the caller is not a super administrator
│ └── it should revert
└── when the caller is a super administrator
    └── if the account proposed for new super admin is not zero address 
        ├── if number of proposed super admins is greater than 0 
        │ └── it should set the account as the proposed super admin role   
        │    └── it should grant only the account as the proposed super admin 
        └── if number of proposed super admins is 0 
          └── it should grant only the account as the proposed super admin
```
The first part of the two-step process, to propose the new Super Admin address. This can only be called by the existing Super admin.

```c
function confirmSuperAdmin() external
├── it will set the newSuperAdmin local variable as the proposed super admin 
├── if the caller is not the proposed super admin 
│ └── it should revert
└── it sets the super admin as the oldSuperAdmin local variable 
    ├── it grants the super admin role to the newSuperAdmin   
    ├── it revokes the super admin role from the oldSuperAdmin  
    └── it renounces the proposed super admin role for the caller  
        ├── it emits an {AD1467_SuperAdministrator} event for the new super admin
        └── it emits an {AD1467_SuperAdministrator} event for the former super admin 

```
The second part of the two-step process, confirming renounces the role for the existing Super Admin and promotes the Proposed Super Admin to the role. This can only be called by the Proposed Super Admin.

#### Access Levels, Risk Scores and Tags

The AppManager contains the functionality used to manage the Access Levels, Risk Scores and Tags associated with accounts, with respect to the application it manages. 

In order to manage these, the following functions have been provided for each (we'll use the Risk Scores variant as an example here):

```c
function addRiskScore(address _account, uint8 _score) public onlyRole(RISK_ADMIN_ROLE)
```
Applies the provided risk score to the provided address (of note that the Application Manager deploys the storage contracts for the Risk Scores, Access Levels and Tags associated with the application on its creation, these can be updated to point to external providers which we'll cover in the next section). This can only be called by a Risk Admin.

```c
function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external onlyRole(RISK_ADMIN_ROLE)
```
Utility function to add a single Risk Score to multiple accounts. Like the singular function this can only be called by a Risk Admin.

```c
function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyRole(RISK_ADMIN_ROLE)
```
Another Utility function that allows you to provide an array of scores to apply to an array of accounts (The arrays must be the same size). This function also can only be called by a Risk Admin.

```c
function getRiskScore(address _account) external view returns (uint8)
```
Retrieves the Risk Score associated with the provided address.

```c
function removeRiskScore(address _account) external onlyRole(RISK_ADMIN_ROLE)
```
Removes the Risk Score from the provided address. This function can only be called by a Risk Admin.

#### Changing Data Providers

In addition to using the functions outlined above to manually manage the qualifiers, each can be switched to an external provider.
Of note the external provider must conform to the relevant interface definition: IRiskScores, IAccessLevels or ITags.

Changing data providers is a 2 step process. Since the same function API is used for each of the providers we'll be using the Access Level Provider as an example:

```c
function proposeAccessLevelsProvider(address _newProvider) external onlyRole(APP_ADMIN_ROLE)
```
The first step in the process is to propose the new provider. The provided address must conform to the IAccessLevel interface. Only App Admins can call the propose new provider functions.

After the new address is proposed it is confirmed by invoking a confirmation function in the new provider that in turn invokes the following function in the AppManager contract:

```c
function confirmNewDataProvider(IDataModule.ProviderType _providerType) external 
```
This function only succeeds if the msg sender is the proposed provider address. If it is, the provider is updated to be the proposed address and the process concludes.

### Application Level Rules

The Application Manager provides a function that can be called from registered Token Handlers to check the Application Level Rules for a transaction.

```c
function checkApplicationRules(address _tokenAddress, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external onlyHandler
├── when the caller is not a registered handler 
│ └── it should revert
└── when the caller is a registered handler
    └── it should call the application handler requireApplicationRulesChecked()
        └── when application level rules are active 
          └── it should validate application level rules through the application handler 
            └── when the application handler returns true 
                └── it should succeed

```
The function actually calls to the registered Application Handler to check the rules. This can only be called by registered Token Handlers. 

### Associated Contracts

The Application Manager also contains the functionality to register, deregister and check various related contracts, including:
- The Application Handler
- Protocol Compliant Tokens
- Treasury

We'll use the treasury functions to demonstrate the API:

```c
function registerTreasury(address _treasuryAddress) external onlyRole(APP_ADMIN_ROLE)
```
Registers the treasury address with the Application Manager. It can only be called by the Application Admin.

```c
function deRegisterTreasury(address _treasuryAddress) external onlyRole(APP_ADMIN_ROLE)
```
Deregisters the treasury address with the Application Manager. It can only be called by the App Admin.

```c
function isTreasury(address _treasuryAddress) public view returns (bool)
```
Checks if the provided address is the registered treasury.

### Upgrading The Contract

When upgrading to a new Application Manager contract a two step process is provided to migrate the data contracts.

First the following function must be called on the original Application Manager:
```c
function proposeDataContractMigration(address _newOwner) external onlyRole(APP_ADMIN_ROLE) 
├── when the caller is not an application administrator
│ └── it should revert
└── when the caller is an application administrator
    └── it should call the proposeOwner() in each data contract 
        ├── when proposeOwner() is called for accounts data contract 
        │ └── it should set the newDataProviderOwner for the accounts data contract 
        │    └── it should continue to next data contract 
        ├── when proposeOwner() is called for accessLevels data contract 
        │ └── it should set the newDataProviderOwner for the accessLevels data contract 
        │    └── it should continue to next data contract 
        ├── when proposeOwner() is called for riskScores data contract 
        │ └── it should set the newDataProviderOwner for the riskScores data contract 
        │    └── it should continue to next data contract
        ├── when proposeOwner() is called for tags data contract 
        │ └── it should set the newDataProviderOwner for the tags data contract 
        │    └── it should continue to next data contract
        ├── when proposeOwner() is called for pauseRules data contract 
        │ └── it should set the newDataProviderOwner for the pauseRules data contract 
        └── when all proposeOwner() functions succeed 
          └── it should emit {AD1467_AppManagerDataUpgradeProposed} event
```
The provided address should be the address of the new Application Manager contract. This function can only be called by the Application Admin.

In order to finalize the process the following function must be called in the new Application Manager:
```c
function confirmDataContractMigration(address _oldAppManagerAddress) external onlyRole(APP_ADMIN_ROLE)
├── when the caller is not an application administrator
│ └── it should revert
└── when the caller is an application administrator
    ├── it should set the oldAppManager variable to _oldAppManagerAddress
    └── it should call the getAccountDataAddress() in each data contract 
        ├── when getAccountDataAddress() is called for accounts data contract 
        │ └── it should set the newDataProviderOwner for the accounts data contract 
        │    └── it should continue to next data contract 
        ├── when getAccessLevelDataAddress() is called for accessLevels data contract 
        │ └── it should set the newDataProviderOwner for the accessLevels data contract 
        │    └── it should continue to next data contract 
        ├── when getRiskDataAddress() is called for riskScores data contract 
        │ └── it should set the newDataProviderOwner for the riskScores data contract 
        │    └── it should continue to next data contract
        ├── when getTagsDataAddress() is called for tags data contract 
        │ └── it should set the newDataProviderOwner for the tags data contract 
        │    └── it should continue to next data contract
        ├── when getPauseRulesDataAddress() is called for pauseRules data contract 
        │ └── it should set the newDataProviderOwner for the pauseRules data contract 
        │    └── it should continue to confirmOwner functions
        ├── it should call confirmOwner() on accounts data contract 
        ├── it should call confirmOwner() on accessLevel data contract
        ├── it should call confirmOwner() on riskScores data contract
        ├── it should call confirmOwner() on tags data contract
        ├── it should call confirmOwner() on pauseRules data contract  
        └── when all getDataAddress functions and all confirm owner functions succeed 
          └── it should emit {AD1467_DataContractsMigrated} event
```
This function can only be called by the App Admin.
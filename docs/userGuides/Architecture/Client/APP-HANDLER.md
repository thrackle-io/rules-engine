# App Handler

## Purpose

The App Handler



### Application Level Rules

The App Handler

### Associated Contracts

The App Handler

### Upgrading The Contract

When upgrading to a new App Manager contract a two step process is provided to migrate the data contracts.

First the following function must be called on the original App Manager:
```c
function proposeDataContractMigration(address _newOwner) external onlyRole(APP_ADMIN_ROLE) 
```
The provided address should be the address of the new App Manager contract. This function can only be called by the App Admin.

In order to finalize the process the following function must be called in the new App Manager:
```c
function confirmDataContractMigration(address _oldAppManagerAddress) external onlyRole(APP_ADMIN_ROLE)
```
This function can only be called by the App Admin.
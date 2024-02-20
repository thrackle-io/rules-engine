# App Handler

## Purpose

The App Handler supports the App Manager by storing the application level rules data and functions. Procotol supported asset handler contracts call check application level rules via the App Manager. The App Manager then checks the associated App Handler where application level rule data is stored. The App Handler contract also serves as the App Manager's connection to the protocol rule processor diamond for the application level rules.


### Application Level Rules

The App Handler facilitates the rule checks for each application level rule. The first function called by the App Manager is: 

```c
function requireApplicationRulesChecked() public view returns (bool)
```
This function allows the App Manager to know if any application level rules are active and if the call should continue to the handler to check the active rules. 

The App Manager then calls the function: 
```c
 function checkApplicationRules(address _tokenAddress, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external onlyOwner returns (bool)
```

The check application rules function will check all application level rules set to active within the handler with the following internal functions:

```c
function _checkRiskRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal 
```

```c
function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal
```

### Rule Functions 

The App Handler is responsible for setting each [application level rule](./APPLICATION-RULES-LIST.md) to active or inactive accordingly. Only [Rule Administrators](../../../permissions/ADMIN-ROLES.md) may set the status of a rule.  

### Upgrading The Contract

When upgrading to a new App Handler contract the following function must be called on the App Manager:

```c
function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyRole(APP_ADMIN_ROLE)
```
This function can only be called by an [App Administrators](../../../permissions/ADMIN-ROLES.md).
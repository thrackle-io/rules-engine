# Application Handler

## Purpose

The Application Handler supports the ApplicationManager by storing the application level rules data and functions. Procotol supported asset handler contracts call the `check-application-level-rules function` via the ApplicationManager. The ApplicationManager then checks the associated Application Handler where application level rule data is stored. The Application Handler contract also serves as the ApplicationManager's connection to the protocol rule processor diamond for the application level rules.


### Application Level Rules

[Application level rules](./APPLICATION-RULES-LIST.md) apply to all assets associated to the Application Manager and handler when set to active. The Application Handler facilitates the rule checks for each application level rule. The first function called by the ApplicationManager is: 

```c
function requireApplicationRulesChecked() public view returns (bool)
```
This function allows the ApplicationManager to know if any application level rules are active and if the call should continue to the handler to check the active rules. 

The Application Manager then calls the function: 
```c
 function checkApplicationRules(address _tokenAddress, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external onlyOwner returns (bool)
```
Within the check application rules function are validation checks for pause rules and valuations. Pause rules are assessed if set to active in the handler. 

Token valuation functions are assessed depending on the Handler Type. 

The check application rules function will check all application level rules set to active within the handler with the following internal functions:

```c
function _checkRiskRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal 
```

```c
function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal
```

### Rule Functions 

The Application Handler is responsible for setting each [application level rule](./APPLICATION-RULES-LIST.md) to active or inactive accordingly. Only [Rule Administrators](../../../permissions/ADMIN-ROLES.md) may set the status of a rule.  

### Upgrading The Contract

When upgrading to a new Application Handler contract the following function must be called on the Application Manager:

```c
function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyRole(APP_ADMIN_ROLE)
```
This function can only be called by an [App Administrators](../../../permissions/ADMIN-ROLES.md).
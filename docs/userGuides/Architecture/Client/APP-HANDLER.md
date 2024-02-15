# App Handler

## Purpose

The App Handler supports the App Manager by storing the application level rules data and functions. Procotol supported asset handler contracts call check application level rules via the App Manager. The App Manager then checks the associated App Handler where application level rule data is stored. The App Handler contract also serves as the App Manager's connection to the protocol rule processor diamond for the application level rules.


### Application Level Rules

The App Handler facilitates the rule checks for each application level rule. The first function called by the App Manager is: 

```c
requireApplicationRulesChecked
```

```c
checkAppRules

```

```c
RiskRules 
```

```c
AccessLevelRules
```

```c
PauseRules
```

### Rule Functions 

The App Handler is responsible for setting each application level rule to active or inactive accordingly. 

### Upgrading The Contract

When upgrading to a new App Handler contract the following function must be called on the App Manager:

```c
function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyRole(APP_ADMIN_ROLE)
```
This function can only be called by the App Admin.
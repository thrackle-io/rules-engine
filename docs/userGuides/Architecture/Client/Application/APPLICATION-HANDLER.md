# Application Handler

## Purpose

The Application Handler supports the Application Manager by storing the application level rules data and functions. Procotol supported asset handler contracts call the `check-application-level-rules function` via the Application Manager. The Application Manager then checks the associated Application Handler where application level rule data is stored. The Application Handler contract also serves as the Application Manager's connection to the protocol rule processor diamond for the application level rules.


### Application Level Rules

[Application level rules](./APPLICATION-RULES-LIST.md) apply to all assets associated to the Application Manager and handler when set to active. The Application Handler facilitates the rule checks for each application level rule. The first function called by the Application Manager is: 

```c
function requireApplicationRulesChecked() public view returns (bool)
├── when pauseRuleActive is true 
├── or when accountMaxValueByRiskScoreActive is true
├── or when accountMaxTransactionValueByRiskScoreActive is true
├── or when accountMaxValueByAccessLevelActive is true
├── or when accountMaxValueOutByAccessLevelActive is true
└── or when accountDenyForNoAccessLevelRuleActive is true
    └── it should return true
    
```
This function allows the Application Manager to know if any application level rules are active and if the call should continue to the handler to check the active rules. 

The Application Manager then calls the function: 
```c
 function checkApplicationRules(address _tokenAddress, address _from, address _to, uint256 _amount, uint16 _nftValuationLimit, uint256 _tokenId, ActionTypes _action, HandlerTypes _handlerType) external onlyOwner returns (bool)
├── when the caller is not the owner
│ └── it should revert
└── when the caller is the owner
    └── it should call the rule processor diamond and validate the transaction when application level rules are active 
        ├── when pauseRuleActive rules are active 
        │ └── it should validate pause rules through the rule processor diamond 
        │    ├── when the rule processor diamond returns true 
        │    └── it should continue to next active rule check 
        ├── when accountMaxValueByRiskScoreActive is true 
        │ └── it should validate account Max Value By RiskScore rules through the rule processor diamond 
        │    ├── when the rule processor diamond returns true 
        │    └── it should continue to next active rule check
        ├── when accountMaxTransactionValueByRiskScoreActive is true 
        │ └── it should validate account Max Transaction Value By Risk Score rules through the rule processor diamond 
        │    ├── when the rule processor diamond returns true 
        │    └── it should continue to next active rule check
        ├── when accountMaxValueByAccessLevelActive is true 
        │ └── it should validate account Max Value By Access Level rules through the rule processor diamond 
        │    ├── when the rule processor diamond returns true 
        │    └── it should continue to next active rule check
        ├── when accountMaxValueOutByAccessLevelActive is true 
        │ └── it should validate account Max Value Out By Access Level rules through the rule processor diamond 
        │    ├── when the rule processor diamond returns true 
        │    └── it should continue to next active rule check
        ├── when accountDenyForNoAccessLevelRuleActive is true 
        │ └── it should validate Account Deny For No Access Level Rule rules through the rule processor diamond 
        │    └── when the rule processor diamond returns true 
        └── when all active application rule checks return true
          └── it should succeed


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
├── when the caller is not an app administrator
│ └── it should revert
└── when the caller is an app administrator
    ├── when the _newApplicationHandler is the same as the current handler address │
    │   ├── it should re-set the applicationHandlerAddress state variable
    │   └── it should re-set the applicationHandler state variable
    └── when the _newApplicationHandler is not the same as the current handler address │
        ├── when _newApplicationHandler is the zero address
        │ └── it should revert
        └── when the _newApplicationHandler is not the zero address │
            ├── it should set the applicationHandlerAddress state variable
            └── it should set the applicationHandler state variable
```
This function can only be called by an [App Administrators](../../../permissions/ADMIN-ROLES.md).
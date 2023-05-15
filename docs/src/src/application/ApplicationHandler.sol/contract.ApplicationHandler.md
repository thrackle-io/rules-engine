# ApplicationHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/application/ApplicationHandler.sol)

**Inherits:**
Ownable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IAppLevelEvents](/src/interfaces/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the connector between the AppManagerRulesDiamond and the Application App Managers. It is maintained by the client application.
Deployment happens automatically when the AppManager is deployed.

*This contract is injected into the appManagerss.*


## State Variables
### applicationRuleProcessorDiamondAddress

```solidity
address applicationRuleProcessorDiamondAddress;
```


### appManager

```solidity
AppManager appManager;
```


### appManagerAddress

```solidity
address appManagerAddress;
```


### accountBalanceByRiskRuleId
Application Risk and AccessLevel rule Ids
Risk Rule Ids


```solidity
uint32 private accountBalanceByRiskRuleId;
```


### maxTxSizePerPeriodByRiskRuleId

```solidity
uint32 private maxTxSizePerPeriodByRiskRuleId;
```


### accountBalanceByRiskRuleActive
Risk Rule on-off switches


```solidity
bool private accountBalanceByRiskRuleActive;
```


### maxTxSizePerPeriodByRiskActive

```solidity
bool private maxTxSizePerPeriodByRiskActive;
```


### accountBalanceByAccessLevelRuleId
AccessLevel Rule Id


```solidity
uint32 private accountBalanceByAccessLevelRuleId;
```


### accountBalanceByAccessLevelRuleActive
AccessLevel Rule on-off switch


```solidity
bool private accountBalanceByAccessLevelRuleActive;
```


### AccessLevel0RuleActive

```solidity
bool private AccessLevel0RuleActive;
```


### usdValueTransactedInRiskPeriod
MaxTxSizePerPeriodByRisk data


```solidity
mapping(address => uint128) usdValueTransactedInRiskPeriod;
```


### lastTxDateRiskRule

```solidity
mapping(address => uint64) lastTxDateRiskRule;
```


## Functions
### constructor

*Initializes the contract setting the owner as the one provided.*


```solidity
constructor(address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Address for the appManager|


### riskOrAccessLevelRulesActive

*checks if any of the AccessLevel or Risk rules are active*


```solidity
function riskOrAccessLevelRulesActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if one or more rules are active|


### checkApplicationRules

*Check Application Rules for valid transaction.*


```solidity
function checkApplicationRules(
    ApplicationRuleProcessorDiamondLib.ActionTypes _action,
    address _from,
    address _to,
    uint128 _usdBalanceTo,
    uint128 _usdAmountTransferring
) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action to be checked|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_usdBalanceTo`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success Returns true if allowed, false if not allowed|


### _checkRiskRules

*This function consolidates all the Risk rules that utilize tagged account Risk scores.*


```solidity
function _checkRiskRules(address _from, address _to, uint128 _usdBalanceTo, uint128 _usdAmountTransferring) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_usdBalanceTo`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### _checkAccessLevelRules

we check for sender
we check for recipient

*This function consolidates all the AccessLevel rules that utilize tagged account AccessLevel scores.*


```solidity
function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _amount) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`||
|`_to`|`address`|address of the to account|
|`_balanceValuation`|`uint128`|address current balance in USD|
|`_amount`|`uint128`|number of tokens transferred|


### setAccountBalanceByRiskRuleId

that setting a rule will automatically activate it.

*Set the accountBalanceByRiskRule. Restricted to app administrators only.*


```solidity
function setAccountBalanceByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountBalanceByRiskRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountBalanceByRiskRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountBalanceByRiskActive

*Tells you if the accountBalanceByRiskRule is active or not.*


```solidity
function isAccountBalanceByRiskActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountBalanceByRiskRule

*Retrieve the accountBalanceByRisk rule id*


```solidity
function getAccountBalanceByRiskRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountBalanceByRiskRuleId rule id|


### setAccountBalanceByAccessLevelRuleId

that setting a rule will automatically activate it.

*Set the accountBalanceByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountBalanceByAccessLevelRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountBalanceByAccessLevelRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountBalanceByAccessLevelRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountBalanceByAccessLevelActive

*Tells you if the accountBalanceByAccessLevelRule is active or not.*


```solidity
function isAccountBalanceByAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountBalanceByAccessLevelkRule

*Retrieve the accountBalanceByAccessLevel rule id*


```solidity
function getAccountBalanceByAccessLevelkRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountBalanceByAccessLevelRuleId rule id|


### activateAccessLevel0Rule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccessLevel0Rule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccessLevel0Active

*Tells you if the AccessLevel0 Rule is active or not.*


```solidity
function isAccessLevel0Active() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getMaxTxSizePerPeriodByRiskRuleId

*Retrieve the oracle rule id*


```solidity
function getMaxTxSizePerPeriodByRiskRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|MaxTxSizePerPeriodByRisk rule id for specified token|


### setMaxTxSizePerPeriodByRiskRuleId

that setting a rule will automatically activate it.

*Set the MaxTxSizePerPeriodByRisk. Restricted to app administrators only.*


```solidity
function setMaxTxSizePerPeriodByRiskRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMaxTxSizePerPeriodByRiskRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMaxTxSizePerPeriodByRiskRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isMaxTxSizePerPeriodByRiskActive

*Tells you if the MaxTxSizePerPeriodByRisk is active or not.*


```solidity
function isMaxTxSizePerPeriodByRiskActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active for specified token|


### setApplicationRuleProcessorDiamondAddress

*This function gets the Application Rule Processor Diamond Contract Address.*


```solidity
function setApplicationRuleProcessorDiamondAddress(address _address) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the access action diamond contract|


### getApplicationRuleProcessorDiamondAddress

*This function gets the Application Rule Processor Diamond Contract Address.*


```solidity
function getApplicationRuleProcessorDiamondAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|applicationRuleProcessorDiamondAddress address of the access action diamond contract|


### checkPauseRules

*This function checks if the requested action is valid according to pause rules.*


```solidity
function checkPauseRules(address _dataServer) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataServer`|`address`|address of the Application Rule Processor Diamond contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if passes, false if not passes|


### checkAccBalanceByRisk

*This function checks if the requested action is valid according to the AccountBalanceByRiskScore rule*


```solidity
function checkAccBalanceByRisk(uint32 _ruleId, uint8 _riskScoreTo, uint128 _totalValuationTo, uint128 _amountToTransfer)
    internal
    view
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_riskScoreTo`|`uint8`|the Risk Score of the recepient account|
|`_totalValuationTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkAccBalanceByAccessLevel


```solidity
function checkAccBalanceByAccessLevel(
    uint32 _ruleId,
    uint8 _riskScoreTo,
    uint128 _totalValuationTo,
    uint128 _amountToTransfer
) internal view returns (bool);
```

### checkAccessLevel0Passes


```solidity
function checkAccessLevel0Passes(uint8 _accessLevel) internal view returns (bool);
```

### checkMaxTxSizePerPeriodByRisk

that these ranges are set by ranges.

*rule that checks if the tx exceeds the limit size in USD for a specific risk profile
within a specified period of time.*

*this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
the limit for the address risk profile.*


```solidity
function checkMaxTxSizePerPeriodByRisk(
    uint32 ruleId,
    uint128 _usdValueTransactedInPeriod,
    uint128 amount,
    uint64 lastTxDate,
    uint8 riskScore
) internal view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_usdValueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`amount`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```


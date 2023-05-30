# ProtocolApplicationHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/application/ProtocolApplicationHandler.sol)

**Inherits:**
Ownable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IAppLevelEvents](/src/interfaces/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the rules handler for all application level rules. It is implemented via the AppManager

*This contract is injected into the appManagerss.*


## State Variables
### appManager

```solidity
AppManager appManager;
```


### appManagerAddress

```solidity
address appManagerAddress;
```


### ruleProcessor

```solidity
IRuleProcessor immutable ruleProcessor;
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
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|


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
    RuleProcessorDiamondLib.ActionTypes _action,
    address _from,
    address _to,
    uint128 _usdBalanceTo,
    uint128 _usdAmountTransferring
) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`RuleProcessorDiamondLib.ActionTypes`|Action to be checked|
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


## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```


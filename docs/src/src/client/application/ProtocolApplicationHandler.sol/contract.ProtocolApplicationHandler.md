# ProtocolApplicationHandler
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/client/application/ProtocolApplicationHandler.sol)

**Inherits:**
Ownable, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IApplicationHandlerEvents](/src/common/IEvents.sol/interface.IApplicationHandlerEvents.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the rules handler for all application level rules. It is implemented via the AppManager

*This contract is injected into the appManagers.*


## State Variables
### VERSION

```solidity
string private constant VERSION = "1.1.0";
```


### appManager

```solidity
AppManager appManager;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### ruleProcessor

```solidity
IRuleProcessor immutable ruleProcessor;
```


### accountBalanceByRiskRuleId
Application level Rule Ids


```solidity
uint32 private accountBalanceByRiskRuleId;
```


### accountMaxTransactionValueByRiskScoreId

```solidity
uint32 private accountMaxTransactionValueByRiskScoreId;
```


### accountMaxValueByRiskScoreActive
Application level Rule on-off switches


```solidity
bool private accountMaxValueByRiskScoreActive;
```


### accountMaxTransactionValueByRiskScoreActive

```solidity
bool private accountMaxTransactionValueByRiskScoreActive;
```


### accountBalanceByAccessLevelRuleId
AccessLevel Rule Ids


```solidity
uint32 private accountBalanceByAccessLevelRuleId;
```


### accountMaxValueOutByAccessLevelId

```solidity
uint32 private accountMaxValueOutByAccessLevelId;
```


### accountMaxValueByAccessLevelActive
AccessLevel Rule on-off switches


```solidity
bool private accountMaxValueByAccessLevelActive;
```


### AccessLevel0RuleActive

```solidity
bool private AccessLevel0RuleActive;
```


### accountMaxValueOutByAccessLevelActive

```solidity
bool private accountMaxValueOutByAccessLevelActive;
```


### pauseRuleActive
Pause Rule on-off switch


```solidity
bool private pauseRuleActive;
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


### usdValueTotalWithrawals
AccessLevelWithdrawalRule data


```solidity
mapping(address => uint128) usdValueTotalWithrawals;
```


## Functions
### constructor

*Initializes the contract setting the AppManager address as the one provided and setting the ruleProcessor for protocol access*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|


### requireValuations

*checks if any of the balance prerequisite rules are active*


```solidity
function requireValuations() public view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if one or more rules are active|


### checkApplicationRules

*Check Application Rules for valid transaction.*


```solidity
function checkApplicationRules(
    ActionTypes _action,
    address _from,
    address _to,
    uint128 _usdBalanceTo,
    uint128 _usdAmountTransferring
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|Action to be checked. This param is intentially added for future enhancements.|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_usdBalanceTo`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success Returns true if allowed, false if not allowed|


### _checkRiskRules

*This function consolidates all the Risk rules that utilize application level Risk rules.*


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

if rule is active check if the recipient is address(0) for burning tokens
check if sender violates the rule
check if recipient violates the rule

*This function consolidates all the application level AccessLevel rules.*


```solidity
function _checkAccessLevelRules(
    address _from,
    address _to,
    uint128 _usdBalanceValuation,
    uint128 _usdAmountTransferring
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`||
|`_to`|`address`|address of the to account|
|`_usdBalanceValuation`|`uint128`|address current balance in USD|
|`_usdAmountTransferring`|`uint128`|number of tokens transferred|


### setAccountMaxValueByRiskScoreId

Check if sender is not AMM and then check sender access level
Check if receiver is not an AMM or address(0) and then check the recipient access level. Exempting address(0) allows for burning.
Check that the recipient is not address(0). If it is we do not check this rule as it is a burn.

that setting a rule will automatically activate it.

*Set the accountBalanceByRiskRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByRiskScoreActive

*Tells you if the accountBalanceByRiskRule is active or not.*


```solidity
function isAccountMaxValueByRiskScoreActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByRiskScoreId

*Retrieve the accountBalanceByRisk rule id*


```solidity
function getAccountMaxValueByRiskScoreId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountBalanceByRiskRuleId rule id|


### setAccountMaxValueByAccessLevelId

that setting a rule will automatically activate it.

*Set the accountBalanceByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByAccessLevelActive

*Tells you if the accountBalanceByAccessLevelRule is active or not.*


```solidity
function isAccountMaxValueByAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByAccessLevelId

*Retrieve the accountBalanceByAccessLevel rule id*


```solidity
function getAccountMaxValueByAccessLevelId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountBalanceByAccessLevelRuleId rule id|


### activateAccessLevel0Rule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccessLevel0Rule(bool _on) external ruleAdministratorOnly(appManagerAddress);
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


### setAccountMaxValueOutByAccessLevelId

that setting a rule will automatically activate it.

*Set the withdrawalLimitByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueOutByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueOutByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueOutByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueOutByAccessLevelActive

*Tells you if the withdrawalLimitByAccessLevelRule is active or not.*


```solidity
function isAccountMaxValueOutByAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueOutByAccessLevelId

*Retrieve the withdrawalLimitByAccessLevel rule id*


```solidity
function getAccountMaxValueOutByAccessLevelId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueOutByAccessLevelId rule id|


### getAccountMaxTransactionValueByRiskScoreId

*Retrieve the MaxTxSizePerPeriodByRisk rule id*


```solidity
function getAccountMaxTransactionValueByRiskScoreId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|MaxTxSizePerPeriodByRisk rule id for specified token|


### setAccountMaxTransactionValueByRiskScoreId

that setting a rule will automatically activate it.

*Set the MaxTxSizePerPeriodByRisk. Restricted to app administrators only.*


```solidity
function setAccountMaxTransactionValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxTransactionValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxTransactionValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxTransactionValueByRiskScoreActive

*Tells you if the MaxTxSizePerPeriodByRisk is active or not.*


```solidity
function isAccountMaxTransactionValueByRiskScoreActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active for specified token|


### activatePauseRule

This function uses the onlyOwner modifier since the appManager contract is calling this function when adding a pause rule or removing the final pause rule of the array.

*enable/disable rule. Disabling a rule will save gas on transfer transactions.
This function does not use ruleAdministratorOnly modifier, the onlyOwner modifier checks that the caller is the appManager contract.*


```solidity
function activatePauseRule(bool _on) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isPauseRuleActive

*Tells you if the pause rule check is active or not.*


```solidity
function isPauseRuleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active for specified token|


### version

*gets the version of the contract*


```solidity
function version() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|VERSION|



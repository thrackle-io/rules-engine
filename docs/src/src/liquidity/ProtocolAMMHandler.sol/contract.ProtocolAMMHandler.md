# ProtocolAMMHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/liquidity/ProtocolAMMHandler.sol)

**Inherits:**
Ownable, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [ITokenHandlerEvents](/src/interfaces/IEvents.sol/interface.ITokenHandlerEvents.md), [IProtocolAMMHandler](/src/liquidity/IProtocolAMMHandler.sol/interface.IProtocolAMMHandler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

TODO Create a wizard that creates custom versions of this contract for each implementation.

Any rules may be updated by modifying this contract and redeploying.

*This contract performs rule checks related to the the AMM that implements it.*


## State Variables
### lastPurchaseTime
Mapping lastUpdateTime for most recent previous tranaction through Protocol


```solidity
mapping(address => uint64) lastPurchaseTime;
```


### purchasedWithinPeriod

```solidity
mapping(address => uint256) purchasedWithinPeriod;
```


### salesWithinPeriod

```solidity
mapping(address => uint256) salesWithinPeriod;
```


### lastSellTime

```solidity
mapping(address => uint256) lastSellTime;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### ruleRouterAddress

```solidity
address public ruleRouterAddress;
```


### ruleRouter

```solidity
ITokenRuleRouter immutable ruleRouter;
```


### appManager

```solidity
IAppManager appManager;
```


### purchaseLimitRuleId
Rule ID's


```solidity
uint32 private purchaseLimitRuleId;
```


### sellLimitRuleId

```solidity
uint32 private sellLimitRuleId;
```


### minTransferRuleId

```solidity
uint32 private minTransferRuleId;
```


### minMaxBalanceRuleIdToken0

```solidity
uint32 private minMaxBalanceRuleIdToken0;
```


### minMaxBalanceRuleIdToken1

```solidity
uint32 private minMaxBalanceRuleIdToken1;
```


### oracleRuleId

```solidity
uint32 private oracleRuleId;
```


### ammFeeRuleId
Fee ID's


```solidity
uint32 private ammFeeRuleId;
```


### purchaseLimitRuleActive
Rule Activation Bools


```solidity
bool private purchaseLimitRuleActive;
```


### sellLimitRuleActive

```solidity
bool private sellLimitRuleActive;
```


### minTransferRuleActive

```solidity
bool private minTransferRuleActive;
```


### oracleRuleActive

```solidity
bool private oracleRuleActive;
```


### minMaxBalanceRuleActive

```solidity
bool private minMaxBalanceRuleActive;
```


### ammFeeRuleActive
Fee Activation Bools


```solidity
bool private ammFeeRuleActive;
```


## Functions
### constructor

*Constructor sets the App Manager andToken Rule Router Address*


```solidity
constructor(address _appManagerAddress, address _tokenRuleRouterProxyAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|Application App Manager Address|
|`_tokenRuleRouterProxyAddress`|`address`|Token Rule RouterProxy Address|


### checkAllRules

*Function mirrors that of the checkRuleStorages. This is the rule check function to be called by the AMM.*


```solidity
function checkAllRules(
    uint256 token0BalanceFrom,
    uint256 token1BalanceFrom,
    address _from,
    address _to,
    uint256 token_amount_0,
    uint256 token_amount_1,
    ApplicationRuleProcessorDiamondLib.ActionTypes _action
) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`token0BalanceFrom`|`uint256`|token balance of sender address|
|`token1BalanceFrom`|`uint256`|token balance of sender address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`token_amount_0`|`uint256`|number of tokens transferred|
|`token_amount_1`|`uint256`|number of tokens received|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


### assessFees

standard tagged and  rules do not apply when either to or from is an admin

*Assess all the fees for the transaction*


```solidity
function assessFees(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    ApplicationRuleProcessorDiamondLib.ActionTypes _action
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|Token balance of the sender address|
|`_balanceTo`|`uint256`|Token balance of the recipient address|
|`_from`|`address`|Sender address|
|`_to`|`address`|Recipient address|
|`_amount`|`uint256`|total number of tokens to be transferred|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|fees total assessed fee for transaction|


### _checkTaggedRules

this is to silence warning from unused parameters. NOTE: These parameters are in here for parity and possible future use.

*Rule tracks all purchases by account for purchase Period, the timestamp of the most recent purchase and purchases are within the purchase period.*


```solidity
function _checkTaggedRules(
    uint256 _token0BalanceFrom,
    uint256 _token1BalanceFrom,
    address _from,
    address _to,
    uint256 _token_amount_0,
    uint256 _token_amount_1
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0BalanceFrom`|`uint256`|token balance of sender address|
|`_token1BalanceFrom`|`uint256`|token balance of sender address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_token_amount_0`|`uint256`|number of tokens transferred|
|`_token_amount_1`|`uint256`|number of tokens received|


### _checkNonTaggedRules

We get all tags for sender and recipient
Pass in fromTags twice because AMM address will not have tags applied (AMM Address is address_to).
Token 0

*Rule tracks all sales by account for sell Period, the timestamp of the most recent sale and sales are within the sell period.*


```solidity
function _checkNonTaggedRules(
    uint256 _token0BalanceFrom,
    uint256 _token1BalanceFrom,
    address _from,
    address _to,
    uint256 _token_amount_0,
    uint256 _token_amount_1
) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token0BalanceFrom`|`uint256`|token balance of sender address|
|`_token1BalanceFrom`|`uint256`|token balance of sender address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_token_amount_0`|`uint256`|number of tokens transferred|
|`_token_amount_1`|`uint256`|number of tokens received|


### setPurchaseLimitRuleId

silencing unused variable warnings
Rule Setters and Getter            *******************************

that setting a rule will automatically activate it.

*Set the PurchaseLimitRuleId. Restricted to app administrators only.*


```solidity
function setPurchaseLimitRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activatePurchaseLimitRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activatePurchaseLimitRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getPurchaseLimitRuleId

*Retrieve the Purchase Limit rule id*


```solidity
function getPurchaseLimitRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|purchaseLimitRuleId|


### isPurchaseLimitActive

*Tells you if the Purchase Limit Rule is active or not.*


```solidity
function isPurchaseLimitActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setSellLimitRuleId

that setting a rule will automatically activate it.

*Set the SellLimitRuleId. Restricted to app administrators only.*


```solidity
function setSellLimitRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateSellLimitRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateSellLimitRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getSellLimitRuleId

*Retrieve the Purchase Limit rule id*


```solidity
function getSellLimitRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|oracleRuleId|


### isSellLimitActive

*Tells you if the Purchase Limit Rule is active or not.*


```solidity
function isSellLimitActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getLastPurchaseTime

*Get the block timestamp of the last purchase for account.*


```solidity
function getLastPurchaseTime(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|LastPurchaseTime for account|


### getLastSellTime

*Get the block timestamp of the last Sell for account.*


```solidity
function getLastSellTime(address account) external view appAdministratorOnly(appManagerAddress) returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|LastSellTime for account|


### getPurchasedWithinPeriod

*Get the cumulative total of the purchases for account in purchase period.*


```solidity
function getPurchasedWithinPeriod(address account)
    external
    view
    appAdministratorOnly(appManagerAddress)
    returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|purchasedWithinPeriod for account|


### getSalesWithinPeriod

*Get the cumulative total of the Sales for account during sell period.*


```solidity
function getSalesWithinPeriod(address account)
    external
    view
    appAdministratorOnly(appManagerAddress)
    returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|salesWithinPeriod for account|


### setMinTransferRuleId

that setting a rule will automatically activate it.

*Set the minTransferRuleId. Restricted to app administrators only.*


```solidity
function setMinTransferRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinTransferRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMinTransferRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getMinTransferRuleId

*Retrieve the minTransferRuleId*


```solidity
function getMinTransferRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minTransferRuleId|


### isMinTransferActive

*Tells you if the MinMaxBalanceRule is active or not.*


```solidity
function isMinTransferActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setMinMaxBalanceRuleIdToken0

that setting a rule will automatically activate it.

*Set the minMaxBalanceRuleId for token 0. Restricted to app administrators only.*


```solidity
function setMinMaxBalanceRuleIdToken0(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### setMinMaxBalanceRuleIdToken1

that setting a rule will automatically activate it.

*Set the minMaxBalanceRuleId for Token 1. Restricted to app administrators only.*


```solidity
function setMinMaxBalanceRuleIdToken1(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinMaxBalanceRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMinMaxBalanceRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getMinMaxBalanceRuleIdToken0

Get the minMaxBalanceRuleIdToken0.


```solidity
function getMinMaxBalanceRuleIdToken0() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minMaxBalance rule id for token 0.|


### getMinMaxBalanceRuleIdToken1

Get the minMaxBalanceRuleId for token 1.


```solidity
function getMinMaxBalanceRuleIdToken1() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minMaxBalance rule id for token 1.|


### isMinMaxBalanceActive

*Tells you if the MinMaxBalanceRule is active or not.*


```solidity
function isMinMaxBalanceActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setOracleRuleId

that setting a rule will automatically activate it.

*Set the oracleRuleId. Restricted to app administrators only.*


```solidity
function setOracleRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateOracleRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateOracleRule(bool _on) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getOracleRuleId

*Retrieve the oracle rule id*


```solidity
function getOracleRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|oracleRuleId|


### isOracleActive

*Tells you if the Oracle Rule is active or not.*


```solidity
function isOracleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setAMMFeeRuleId

that setting a rule will automatically activate it.

*Set the ammFeeRuleId. Restricted to app administrators only.*


```solidity
function setAMMFeeRuleId(uint32 _ruleId) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAMMFeeRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAMMFeeRule(bool on_off) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`on_off`|`bool`|boolean representing if a rule must be checked or not.|


### getAMMFeeRuleId

*Retrieve the AMM Fee rule id*


```solidity
function getAMMFeeRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ammFeeRuleId|


### isAMMFeeRuleActive

*Tells you if the AMM Fee Rule is active or not.*


```solidity
function isAMMFeeRuleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|



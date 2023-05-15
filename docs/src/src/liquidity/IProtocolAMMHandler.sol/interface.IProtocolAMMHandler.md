# IProtocolAMMHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/liquidity/IProtocolAMMHandler.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the ApplicationAMMHandler. This is only used by the client contracts that
implement any of the Protocol... Economic capable contracts. It is necessary because the function signature for checkRuleStorages is different for AMMs*


## Functions
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
|`token_amount_1`|`uint256`|number of tokens reciveved|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true and Failure equals false|


### assessFees

*Assess all the fees for the transaction*


```solidity
function assessFees(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    ApplicationRuleProcessorDiamondLib.ActionTypes _action
) external returns (uint256);
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



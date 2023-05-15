# IAssetHandlerLite
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/economic/IAssetHandlerLite.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the TokenRuleRouter. This is only used by the client contracts that
implement any of the Protocol capable contracts.*


## Functions
### checkAllRules

*Check the Rules for the protocol*


```solidity
function checkAllRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    ApplicationRuleProcessorDiamondLib.ActionTypes _action
) external returns (bool);
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
|`<none>`|`bool`|Success equals true and Failure equals false|


### isFeeActive

*returns the full mapping of fees*


```solidity
function isFeeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|feeActive fee activation status|


### getApplicableFees

*Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.*


```solidity
function getApplicableFees(address _from, uint256 _balanceFrom)
    external
    returns (address[] memory targetAccounts, int24[] memory feePercentages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|originating address|
|`_balanceFrom`|`uint256`|Token balance of the sender address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`targetAccounts`|`address[]`|list of where the fees are sent|
|`feePercentages`|`int24[]`|list of all applicable fees/discounts|



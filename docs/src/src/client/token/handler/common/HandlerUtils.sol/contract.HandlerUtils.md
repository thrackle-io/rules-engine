# HandlerUtils
[Git Source](https://github.com/thrackle-io/rules-engine/blob/54db83a2c72adaf3bc2196e69cb3cf728347d98b/src/client/token/handler/common/HandlerUtils.sol)


## Functions
### determineTransferAction

p2p transfer is position 0 and will be default unless other conditions are met.

*determines if a transfer is:
p2p transfer
buy
sell
mint
burn*


```solidity
function determineTransferAction(address _from, address _to, address _sender) internal returns (ActionTypes action);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|the address where the tokens are being moved from|
|`_to`|`address`|the address where the tokens are going to|
|`_sender`|`address`|the address triggering the transaction|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`action`|`ActionTypes`|intended in the transfer|


### isContract

*Check if the addresss is a contract*


```solidity
function isContract(address account) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|contract yes/no|


## Events
### Action

```solidity
event Action(uint8 _type);
```


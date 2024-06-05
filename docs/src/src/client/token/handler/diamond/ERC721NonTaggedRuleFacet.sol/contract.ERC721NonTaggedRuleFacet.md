# ERC721NonTaggedRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/f74908398c760797afd44dcdc70a8e3cb8ae80a1/src/client/token/handler/diamond/ERC721NonTaggedRuleFacet.sol)

**Inherits:**
[AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md), [HandlerAccountApproveDenyOracle](/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol/contract.HandlerAccountApproveDenyOracle.md), [HandlerTokenMaxSupplyVolatility](/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol/contract.HandlerTokenMaxSupplyVolatility.md), [HandlerTokenMaxTradingVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxTradingVolume.sol/contract.HandlerTokenMaxTradingVolume.md), [HandlerTokenMinTxSize](/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol/contract.HandlerTokenMinTxSize.md), [HandlerTokenMinHoldTime](/src/client/token/handler/ruleContracts/HandlerTokenMinHoldTime.sol/contract.HandlerTokenMinHoldTime.md), [HandlerTokenMaxDailyTrades](/src/client/token/handler/ruleContracts/HandlerTokenMaxDailyTrades.sol/contract.HandlerTokenMaxDailyTrades.md)


## Functions
### checkNonTaggedRules

*This function uses the protocol's ruleProcessorto perform the actual rule checks.*


```solidity
function checkNonTaggedRules(ActionTypes action, address _from, address _to, uint256 _amount, uint256 _tokenId)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`||
|`_tokenId`|`uint256`|id of the NFT being transferred|


### _checkTokenMinTxSizeRule

*Internal function to check the Token Min Transaction Size rule*


```solidity
function _checkTokenMinTxSizeRule(uint256 _amount, ActionTypes action, address handlerBase) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`handlerBase`|`address`|address of the handler proxy|


### _checkAccountApproveDenyOraclesRule

*Internal function to check the Account Approve Deny Oracle Rules*


```solidity
function _checkAccountApproveDenyOraclesRule(address _from, address _to, ActionTypes action, address handlerBase)
    internal
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`handlerBase`|`address`|address of the handler proxy|


### _checkTokenMaxTradingVolumeRule

The action type determines if the _to or _from is checked by the oracle
_from address is checked for Burn and Sell action types
_to address is checked  for Mint, Buy, Transfer actions

*Internal function to check the Token Max Trading Volume rule*


```solidity
function _checkTokenMaxTradingVolumeRule(uint256 _amount, address handlerBase) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|number of tokens transferred|
|`handlerBase`|`address`|address of the handler proxy|


### _checkTokenMaxSupplyVolatilityRule

*Internal function to check the Token Max Supply Volatility rule*


```solidity
function _checkTokenMaxSupplyVolatilityRule(address _to, uint256 _amount, address handlerBase) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|
|`handlerBase`|`address`|address of the handler proxy|


### _checkTokenMaxDailyTradesRule

rule requires ruleID and either to or from address be zero address (mint/burn)

*Internal function to check the TokenMaxDailyTrades rule*


```solidity
function _checkTokenMaxDailyTradesRule(ActionTypes action, uint256 _tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`_tokenId`|`uint256`|id of the NFT being transferred|


### _checkSimpleRules

*This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)*


```solidity
function _checkSimpleRules(ActionTypes _action, uint256 _tokenId, address handlerBase) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action to be checked|
|`_tokenId`|`uint256`|the specific token to check|
|`handlerBase`|`address`|address of the handler proxy|



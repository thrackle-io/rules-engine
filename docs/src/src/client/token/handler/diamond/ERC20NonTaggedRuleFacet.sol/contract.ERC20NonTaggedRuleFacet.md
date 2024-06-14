# ERC20NonTaggedRuleFacet
[Git Source](https://github.com/thrackle-io/tron/blob/7233064f299d77880af0e175a21e23e2f8b85f56/src/client/token/handler/diamond/ERC20NonTaggedRuleFacet.sol)

**Inherits:**
[AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md), [HandlerAccountApproveDenyOracle](/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol/contract.HandlerAccountApproveDenyOracle.md), [HandlerTokenMaxSupplyVolatility](/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol/contract.HandlerTokenMaxSupplyVolatility.md), [HandlerTokenMaxTradingVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxTradingVolume.sol/contract.HandlerTokenMaxTradingVolume.md), [HandlerTokenMinTxSize](/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol/contract.HandlerTokenMinTxSize.md)


## Functions
### checkNonTaggedRules

*This function uses the protocol's ruleProcessorto perform the actual rule checks.*


```solidity
function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|


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
_from address is checked for Burn
_to address is checked  for Mint
_from and _to address are checked for BUY, SELL, and P2P_TRANSFER

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



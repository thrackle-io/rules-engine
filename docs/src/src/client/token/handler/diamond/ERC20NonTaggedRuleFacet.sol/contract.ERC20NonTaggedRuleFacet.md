# ERC20NonTaggedRuleFacet
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/client/token/handler/diamond/ERC20NonTaggedRuleFacet.sol)

**Inherits:**
[AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [HandlerAccountApproveDenyOracle](/src/client/token/handler/ruleContracts/HandlerAccountApproveDenyOracle.sol/contract.HandlerAccountApproveDenyOracle.md), [HandlerTokenMaxSupplyVolatility](/src/client/token/handler/ruleContracts/HandlerTokenMaxSupplyVolatility.sol/contract.HandlerTokenMaxSupplyVolatility.md), [HandlerTokenMaxTradingVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxTradingVolume.sol/contract.HandlerTokenMaxTradingVolume.md), [HandlerTokenMinTxSize](/src/client/token/handler/ruleContracts/HandlerTokenMinTxSize.sol/contract.HandlerTokenMinTxSize.md)


## Functions
### checkNonTaggedRules

*This function uses the protocol's ruleProcessorto perform the actual rule checks.*


```solidity
function checkNonTaggedRules(address _from, address _to, address _sender, uint256 _amount, ActionTypes action)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|


### _checkTokenMinTxSizeRule

tokenMaxTradingVolume Burn
tokenMinTxSize Burn
tokenMaxTradingVolume Mint
tokenMinTxSize Mint
tokenMaxTradingVolume P2P_TRANSFER
tokenMinTxSize P2P_TRANSFER
non custodial buy
tokenMaxTradingVolume BUY
tokenMaxTradingVolume uses single rule id for all actions so check if Buy has rule id set ELSE check if sell has ruleId set
else if conditional used for tokenMaxTrading as there is only one ruleId used for this rule
tokenMinTxSize BUY
custodial buy
tokenMinTxSize BUY
non custodial sell
tokenMaxTradingVolume SELL
tokenMaxTradingVolume uses single rule id for all actions so check if Sell has rule id set ELSE check if sell has ruleId set
else if conditional used for tokenMaxTrading as there is only one ruleId used for this rule
tokenMinTxSize BUY
custodial sell
tokenMaxTradingVolume SELL
tokenMinTxSize SELL

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
function _checkAccountApproveDenyOraclesRule(
    address _from,
    address _to,
    address _sender,
    ActionTypes action,
    address handlerBase
) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|
|`handlerBase`|`address`|address of the handler proxy|


### _checkTokenMaxTradingVolumeRule

The action type determines if the _to or _from is checked by the oracle
_from address is checked for Burn
_to address is checked  for Mint
_from and _to address are checked for BUY, SELL, and P2P_TRANSFER
non custodial buy
custodial buy
non custodial sell
custodial sell

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



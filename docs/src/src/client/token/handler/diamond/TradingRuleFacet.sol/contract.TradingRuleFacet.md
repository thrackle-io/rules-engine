# TradingRuleFacet
[Git Source](https://github.com/thrackle-io/rules-engine/blob/5dd4d5c11842d5927a5d94b280633ba0762dc45b/src/client/token/handler/diamond/TradingRuleFacet.sol)

**Inherits:**
[HandlerAccountMaxTradeSize](/src/client/token/handler/ruleContracts/HandlerAccountMaxTradeSize.sol/contract.HandlerAccountMaxTradeSize.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [HandlerTokenMaxBuySellVolume](/src/client/token/handler/ruleContracts/HandlerTokenMaxBuySellVolume.sol/contract.HandlerTokenMaxBuySellVolume.md), [AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IHandlerDiamondErrors](/src/common/IErrors.sol/interface.IHandlerDiamondErrors.md)


## Functions
### checkTradingRules

*This function consolidates all the trading rules.*


```solidity
function checkTradingRules(
    address _from,
    address _to,
    address _sender,
    bytes32[] memory fromTags,
    bytes32[] memory toTags,
    uint256 _amount,
    ActionTypes action
) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`fromTags`|`bytes32[]`|tags of the from account|
|`toTags`|`bytes32[]`|tags of the from account|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|


### _checkTradeRulesBuyAction

non custodial buy
non custodial sell

*This function checks the trading rules for Buy actions*


```solidity
function _checkTradeRulesBuyAction(address _to, bytes32[] memory toTags, uint256 _amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_to`|`address`|address of the to account|
|`toTags`|`bytes32[]`|tags of the from account|
|`_amount`|`uint256`|number of tokens transferred|


### _checkTradeRulesSellAction

update with new blockTime if rule check is successful

*This function checks the trading rules for Sell actions*


```solidity
function _checkTradeRulesSellAction(address _from, bytes32[] memory fromTags, uint256 _amount) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`fromTags`|`bytes32[]`|tags of the from account|
|`_amount`|`uint256`|number of tokens transferred|



# ERC721TaggedRuleFacet
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/9e3814d522f1469f798bac69a12de09ee849e2da/src/client/token/handler/diamond/ERC721TaggedRuleFacet.sol)

**Inherits:**
[HandlerAccountMinMaxTokenBalance](/src/client/token/handler/ruleContracts/HandlerAccountMinMaxTokenBalance.sol/contract.HandlerAccountMinMaxTokenBalance.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [AppAdministratorOrOwnerOnlyDiamondVersion](/src/client/token/handler/common/AppAdministratorOrOwnerOnlyDiamondVersion.sol/contract.AppAdministratorOrOwnerOnlyDiamondVersion.md)


## Functions
### checkTaggedAndTradingRules

*This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.*


```solidity
function checkTaggedAndTradingRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount,
    ActionTypes action
) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|


### _checkTaggedIndividualRules

*This function consolidates all the tagged rules that utilize account tags plus all trading rules.*


```solidity
function _checkTaggedIndividualRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount,
    ActionTypes action
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`_amount`|`uint256`|number of tokens transferred|
|`action`|`ActionTypes`|if selling or buying (of ActionTypes type)|



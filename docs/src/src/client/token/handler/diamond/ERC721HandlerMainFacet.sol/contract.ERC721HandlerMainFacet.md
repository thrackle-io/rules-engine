# ERC721HandlerMainFacet
[Git Source](https://github.com/thrackle-io/tron/blob/baac0bbfdefb8a299b09493a3979f2ef5c07be0f/src/client/token/handler/diamond/ERC721HandlerMainFacet.sol)

**Inherits:**
[HandlerBase](/src/client/token/handler/ruleContracts/HandlerBase.sol/contract.HandlerBase.md), [HandlerAdminMinTokenBalance](/src/client/token/handler/ruleContracts/HandlerAdminMinTokenBalance.sol/contract.HandlerAdminMinTokenBalance.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [NFTValuationLimit](/src/client/token/handler/ruleContracts/NFTValuationLimit.sol/contract.NFTValuationLimit.md), [IHandlerDiamondErrors](/src/common/IErrors.sol/interface.IHandlerDiamondErrors.md), ERC173


## Functions
### initialize

*Initializer params*


```solidity
function initialize(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress)
    external
    onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|
|`_assetAddress`|`address`|address of the controlling asset.|


### checkAllRules

*This function is the one called from the contract that implements this handler. It's the entry point.*


```solidity
function checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _tokenId
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|token balance of sender address|
|`balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`_sender`|`address`|the address triggering the contract action|
|`_tokenId`|`uint256`|id of the NFT being transferred|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|



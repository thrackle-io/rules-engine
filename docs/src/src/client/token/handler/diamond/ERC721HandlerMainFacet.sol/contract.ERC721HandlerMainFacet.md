# ERC721HandlerMainFacet
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/47aa0c8585077f5b931483a9b3097e3fe330a3c3/src/client/token/handler/diamond/ERC721HandlerMainFacet.sol)

**Inherits:**
[HandlerBase](/src/client/token/handler/ruleContracts/HandlerBase.sol/contract.HandlerBase.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [NFTValuationLimit](/src/client/token/handler/ruleContracts/NFTValuationLimit.sol/contract.NFTValuationLimit.md), [IHandlerDiamondErrors](/src/common/IErrors.sol/interface.IHandlerDiamondErrors.md)


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

This function is called without passing in an action type.

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


### checkAllRules

*This function is the one called from the contract that implements this handler. It's the legacy entry point. This function only serves as a pass-through to the active function.*


```solidity
function checkAllRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    uint256 _tokenId,
    ActionTypes _action
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`_amount`|`uint256`|number of tokens transferred|
|`_tokenId`|`uint256`|the token's specific ID|
|`_action`|`ActionTypes`|Action Type defined by ApplicationHandlerLib -- (Purchase, Sell, Trade, Inquire) are the legacy options|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


### _checkAllRules

*This function contains the logic for checking all rules. It performs all the checks for the external functions.*


```solidity
function _checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _tokenId,
    ActionTypes _action
) internal returns (bool);
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
|`_action`|`ActionTypes`|the client determined action, if NONE then the action is dynamically determined|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### getAppManagerAddress

currently not supporting batch NFT transactions. Only single NFT transfers.
standard tagged and non-tagged rules do not apply when either to or from is a Treasury account

*This function returns the configured application manager's address.*


```solidity
function getAppManagerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|appManagerAddress address of the connected application manager|



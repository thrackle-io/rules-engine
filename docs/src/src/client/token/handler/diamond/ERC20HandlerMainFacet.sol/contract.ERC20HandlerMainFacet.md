# ERC20HandlerMainFacet
[Git Source](https://github.com/thrackle-io/tron/blob/d5c4da9c910c7f583b74a714399bd64fbb32b616/src/client/token/handler/diamond/ERC20HandlerMainFacet.sol)

**Inherits:**
[HandlerBase](/src/client/token/handler/ruleContracts/HandlerBase.sol/contract.HandlerBase.md), [HandlerAdminMinTokenBalance](/src/client/token/handler/ruleContracts/HandlerAdminMinTokenBalance.sol/contract.HandlerAdminMinTokenBalance.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [IHandlerDiamondErrors](/src/common/IErrors.sol/interface.IHandlerDiamondErrors.md), ERC173


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
    uint256 _amount
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
|`_amount`|`uint256`|number of tokens transferred|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### getAppManagerAddress

standard rules do not apply when either to or from is an admin

*This function returns the configured application manager's address.*


```solidity
function getAppManagerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|appManagerAddress address of the connected application manager|



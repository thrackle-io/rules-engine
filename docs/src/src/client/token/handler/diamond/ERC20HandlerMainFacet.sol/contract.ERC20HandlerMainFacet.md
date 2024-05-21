# ERC20HandlerMainFacet
[Git Source](https://github.com/thrackle-io/tron/blob/3811b4273256819e871165284a320ac92fbb3641/src/client/token/handler/diamond/ERC20HandlerMainFacet.sol)

**Inherits:**
[HandlerBase](/src/client/token/handler/ruleContracts/HandlerBase.sol/contract.HandlerBase.md), [HandlerUtils](/src/client/token/handler/common/HandlerUtils.sol/contract.HandlerUtils.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [IHandlerDiamondErrors](/src/common/IErrors.sol/interface.IHandlerDiamondErrors.md)


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
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`_sender`|`address`|the address triggering the contract action|
|`_amount`|`uint256`|number of tokens transferred|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### checkAllRules

*This function is the one called from the contract that implements this handler. It's the entry point.*


```solidity
function checkAllRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount,
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
|`_sender`|`address`|the address triggering the contract action|
|`_amount`|`uint256`|number of tokens transferred|
|`_action`|`ActionTypes`|Action Type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### _checkAllRules

*This function contains the logic for checking all rules. It performs all the checks for the external functions.*


```solidity
function _checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount,
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
|`_amount`|`uint256`|number of tokens transferred|
|`_action`|`ActionTypes`|Action Type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### getAppManagerAddress

standard rules do not apply when either to or from is a treasury account

*This function returns the configured application manager's address.*


```solidity
function getAppManagerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|appManagerAddress address of the connected application manager|



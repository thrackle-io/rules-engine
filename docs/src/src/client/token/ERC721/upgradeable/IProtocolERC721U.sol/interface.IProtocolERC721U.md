# IProtocolERC721U
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/client/token/ERC721/upgradeable/IProtocolERC721U.sol)

**Inherits:**
IERC721EnumerableUpgradeable

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is the base contract for all protocol ERC721Upgradeables


## Functions
### setAppManagerAddress

*Function to set the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses assigned as AppAdministrator can call function.*


```solidity
function setAppManagerAddress(address _appManagerAddress) external;
```

### getAppManagerAddress

*Function to get the appManagerAddress*

*AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.*


```solidity
function getAppManagerAddress() external view returns (address);
```

### getHandlerAddress

*this function returns the handler address*


```solidity
function getHandlerAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|handlerAddress|


### connectHandlerToToken

*Function to connect Token to previously deployed Handler contract*


```solidity
function connectHandlerToToken(address _deployedHandlerAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_deployedHandlerAddress`|`address`|address of the currently deployed Handler Address|


### totalSupply

*Function to return token's total circulating supply*


```solidity
function totalSupply() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|_totalSupply token's total circulating supply|


### initiateProtocol

*Function to connect Token to the protocol assets*


```solidity
function initiateProtocol(address _appManagerAddress, address _assetHandlerAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|address of the currently deployed app manager|
|`_assetHandlerAddress`|`address`|address of the currently deployed asset Handler|


## Events
### NewNFTDeployed

```solidity
event NewNFTDeployed(address indexed applicationNFT, address indexed appManagerAddress);
```

### HandlerConnected

```solidity
event HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
```

## Errors
### ZeroAddress

```solidity
error ZeroAddress();
```


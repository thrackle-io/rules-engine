# ProtocolHandlerCommon
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/token/ProtocolHandlerCommon.sol)

**Inherits:**
[IAppManagerUser](/src/application/IAppManagerUser.sol/interface.IAppManagerUser.md), [IOwnershipErrors](/src/interfaces/IErrors.sol/interface.IOwnershipErrors.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md), [ITokenHandlerEvents](/src/interfaces/IEvents.sol/interface.ITokenHandlerEvents.md), [IAssetHandlerErrors](/src/interfaces/IErrors.sol/interface.IAssetHandlerErrors.md), [AppAdministratorOrOwnerOnly](/src/economic/AppAdministratorOrOwnerOnly.sol/contract.AppAdministratorOrOwnerOnly.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract contains common variables and functions for all Protocol Asset Handlers


## State Variables
### newAppManagerAddress

```solidity
address private newAppManagerAddress;
```


### appManagerAddress

```solidity
address public appManagerAddress;
```


### ruleProcessor

```solidity
IRuleProcessor ruleProcessor;
```


### appManager

```solidity
IAppManager appManager;
```


### erc20Pricer

```solidity
IProtocolERC20Pricing erc20Pricer;
```


### nftPricer

```solidity
IProtocolERC721Pricing nftPricer;
```


### erc20PricingAddress

```solidity
address public erc20PricingAddress;
```


### nftPricingAddress

```solidity
address public nftPricingAddress;
```


### ERC20_PRICER

```solidity
bytes32 ERC20_PRICER;
```


## Functions
### proposeAppManagerAddress

*this function proposes a new appManagerAddress that is put in storage to be confirmed in a separate process*


```solidity
function proposeAppManagerAddress(address _newAppManagerAddress)
    external
    appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newAppManagerAddress`|`address`|the new address being proposed|


### confirmAppManagerAddress

*this function confirms a new appManagerAddress that was put in storageIt can only be confirmed by the proposed address*


```solidity
function confirmAppManagerAddress() external;
```

### setNFTPricingAddress

*sets the address of the nft pricing contract and loads the contract.*


```solidity
function setNFTPricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Nft Pricing Contract address.|


### setERC20PricingAddress

*sets the address of the erc20 pricing contract and loads the contract.*


```solidity
function setERC20PricingAddress(address _address) external appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|ERC20 Pricing Contract address.|


### getAccTotalValuation

This gets the account's balance in dollars.

*Get the account's balance in dollars. It uses the registered tokens in the app manager.*


```solidity
function getAccTotalValuation(address _account, uint256 _nftValuationLimit)
    public
    view
    returns (uint256 totalValuation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address to get the balance for|
|`_nftValuationLimit`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValuation`|`uint256`|of the account in dollars|


### _getERC20Price

check if _account is zero address. If zero address we return a valuation of zero to allow for burning tokens when rules that need valuations are active.
Loop through all Nfts and ERC20s and add values to balance for account valuation
First check to see if user owns the asset

This gets the token's value in dollars.

*Get the value for a specific ERC20. This is done by interacting with the pricing module*


```solidity
function _getERC20Price(address _tokenAddress) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price the price of 1 in dollars|


### _getNFTValuePerCollection

This gets the token's value in dollars.

*Get the value for a specific ERC721. This is done by interacting with the pricing module*


```solidity
function _getNFTValuePerCollection(address _tokenAddress, address _account, uint256 _tokenAmount)
    internal
    view
    returns (uint256 totalValueInThisContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|
|`_account`|`address`|of the token holder|
|`_tokenAmount`|`uint256`|amount of NFTs from _tokenAddress contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValueInThisContract`|`uint256`|in whole USD|


### _getNFTCollectionValue

This function gets the total token value in dollars of all tokens owned in each collection by address.

*Get the total value for all tokens held by wallet for specific collection. This is done by interacting with the pricing module*


```solidity
function _getNFTCollectionValue(address _tokenAddress, uint256 _tokenAmount)
    private
    view
    returns (uint256 totalValueInThisContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|
|`_tokenAmount`|`uint256`|amount of NFTs from _tokenAddress contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValueInThisContract`|`uint256`|total valuation of tokens by collection in whole USD|



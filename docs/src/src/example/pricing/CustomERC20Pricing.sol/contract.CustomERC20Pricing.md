# CustomERC20Pricing
[Git Source](https://github.com/thrackle-io/tron/blob/5bfb84a51be01d9a959b76979e9b34e41875da67/src/example/pricing/CustomERC20Pricing.sol)

**Inherits:**
Ownable, [IApplicationEvents](/src/common/IEvents.sol/interface.IApplicationEvents.md), [IProtocolERC20Pricing](/src/common/IProtocolERC20Pricing.sol/interface.IProtocolERC20Pricing.md), [AppAdministratorOnly](/src/protocol/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is an example of how one could implement a custom pricing solution. It uses a Chainlink Price Feed to get the token price


## State Variables
### aave

```solidity
address private aave = 0xD6DF932A45C0f255f85145f286eA0b292B21C90B;
```


### aaveFeed

```solidity
address private aaveFeed = 0x72484B12719E23115761D5DA1646945632979bB6;
```


### algo

```solidity
address private algo = 0xA8aa9dE3530ab3199a73C9F2115F6d37955546d7;
```


### algoFeed

```solidity
address private algoFeed = 0x03Bc6D9EFed65708D35fDaEfb25E87631a0a3437;
```


### doge

```solidity
address private doge = 0xD9d32b18Fd437F5de774e926CFFdad8F514EeED0;
```


### dogeFeed

```solidity
address private dogeFeed = 0xbaf9327b6564454F4a3364C33eFeEf032b4b4444;
```


### appManagerAddress

```solidity
address private immutable appManagerAddress;
```


## Functions
### constructor


```solidity
constructor(address _appManagerAddress);
```

### getTokenPrice

that the price is for the whole token and not of its atomic unit. This means that if
an ERC20 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000

*Gets the price of a Token. It will return the Token's specific price. This function is left here to preserve the function signature*


```solidity
function getTokenPrice(address tokenContract) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenContract`|`address`|is the address of the Token contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price of the Token in weis of dollars. 10^18 => $ 1.00 USD|


### getChainlinkDOGEtoUSDFeedPrice

*Gets the Chainlink price feed for DOGE in USD. This is an example that works for any decimal denomination.*


```solidity
function getChainlinkDOGEtoUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The current price in USD for this token according to Chainlink aggregation|


### getChainlinkAAVEtoUSDFeedPrice

This price feed is actually 8 decimals so it must be converted to 18.

*Gets the Chainlink price feed for AAVE in USD.*


```solidity
function getChainlinkAAVEtoUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The current price in USD for this token according to Chainlink aggregation|


### getChainlinkALGOtoUSDFeedPrice

This price feed is actually 8 decimals so it must be converted to 18.

*Gets the Chainlink price feed for AAVE in USD.*


```solidity
function getChainlinkALGOtoUSDFeedPrice() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price The current price in USD for this token according to Chainlink aggregation|


### setAAVEAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setAAVEAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setAAVEFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setAAVEFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setALGOAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setALGOAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setALGOFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setALGOFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setDOGEAddress

*This function allows appAdminstrators to set the token address*


```solidity
function setDOGEAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

### setDOGEFeedAddress

*This function allows appAdminstrators to set the Chainlink price feed address*


```solidity
function setDOGEFeedAddress(address _address) external appAdministratorOnly(appManagerAddress);
```

## Errors
### NoPriceFeed

```solidity
error NoPriceFeed(address tokenAddress);
```


# IApplicationEvents
[Git Source](https://github.com/thrackle-io/tron/blob/fceb75bbcbc9fcccdbb0ae49e82ea903ed8190d1/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Application Events Library

*This library for all events for the Application ecosystems. Each Contract should inherit this library for emitting events.*


## Events
### HandlerConnectedForUpgrade
Application Handler


```solidity
event HandlerConnectedForUpgrade(address indexed applicationHandler, address indexed assetAddress);
```

### HandlerConnected

```solidity
event HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
```

### NewTokenDeployed
ProtocolERC20


```solidity
event NewTokenDeployed(address indexed applicationCoin, address indexed appManagerAddress);
```

### NewNFTDeployed
ProtocolERC721 & ERC721A


```solidity
event NewNFTDeployed(address indexed applicationNFT, address indexed appManagerAddress);
```

### AllowedAddress
OracleAllowed


```solidity
event AllowedAddress(address indexed addr);
```

### AllowedAddressesAdded

```solidity
event AllowedAddressesAdded(address[] addrs);
```

### AllowedAddressAdded

```solidity
event AllowedAddressAdded(address addrs);
```

### AllowedAddressesRemoved

```solidity
event AllowedAddressesRemoved(address[] addrs);
```

### NotAllowedAddress

```solidity
event NotAllowedAddress(address indexed addr);
```

### SanctionedAddress
OracleRestricted


```solidity
event SanctionedAddress(address indexed addr);
```

### NonSanctionedAddress

```solidity
event NonSanctionedAddress(address indexed addr);
```

### SanctionedAddressesAdded

```solidity
event SanctionedAddressesAdded(address[] addrs);
```

### SanctionedAddressAdded

```solidity
event SanctionedAddressAdded(address addrs);
```

### SanctionedAddressesRemoved

```solidity
event SanctionedAddressesRemoved(address[] addrs);
```

### AMMDeployed
AMM


```solidity
event AMMDeployed(address indexed ammAddress);
```

### Swap

```solidity
event Swap(address indexed tokenIn, uint256 amountIn, uint256 amountOut);
```

### AddLiquidity

```solidity
event AddLiquidity(address token0, address token1, uint256 amount0, uint256 amount1);
```

### RemoveLiquidity

```solidity
event RemoveLiquidity(address token, uint256 amount);
```

### TokenPrice
ERC20Pricing


```solidity
event TokenPrice(address indexed token, uint256 indexed price);
```

### SingleTokenPrice
NFTPricing


```solidity
event SingleTokenPrice(address indexed collection, uint256 indexed tokenID, uint256 indexed price);
```

### CollectionPrice

```solidity
event CollectionPrice(address indexed collection, uint256 indexed price);
```

### FeeTypeAdded
Fees


```solidity
event FeeTypeAdded(
    bytes32 indexed tag,
    uint256 minBalance,
    uint256 maxBalance,
    int256 feePercentage,
    address targetAccount,
    uint256 date
);
```

### FeeTypeRemoved

```solidity
event FeeTypeRemoved(bytes32 indexed tag, uint256 date);
```

### AppManagerAddressSet
AppManager set


```solidity
event AppManagerAddressSet(address indexed _address);
```


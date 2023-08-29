# IAssetHandlerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/fceb75bbcbc9fcccdbb0ae49e82ea903ed8190d1/src/interfaces/IErrors.sol)


## Errors
### PricingModuleNotConfigured

```solidity
error PricingModuleNotConfigured(address _erc20PricingAddress, address nftPricingAddress);
```

### actionCheckFailed

```solidity
error actionCheckFailed();
```

### CannotTurnOffAccessLevel0WithAccessLevelBalanceActive

```solidity
error CannotTurnOffAccessLevel0WithAccessLevelBalanceActive();
```

### PeriodExceeds5Years

```solidity
error PeriodExceeds5Years();
```

### ZeroValueNotPermited

```solidity
error ZeroValueNotPermited();
```

### BatchMintBurnNotSupported

```solidity
error BatchMintBurnNotSupported();
```

### FeesAreGreaterThanTransactionAmount

```solidity
error FeesAreGreaterThanTransactionAmount(address);
```


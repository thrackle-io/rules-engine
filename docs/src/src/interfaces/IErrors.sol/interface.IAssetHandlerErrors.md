# IAssetHandlerErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/interfaces/IErrors.sol)


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


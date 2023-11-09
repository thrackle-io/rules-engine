# IAssetHandlerErrors
<<<<<<< HEAD
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/interfaces/IErrors.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/interfaces/IErrors.sol)
>>>>>>> external


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


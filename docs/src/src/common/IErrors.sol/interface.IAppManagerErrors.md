# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/common/IErrors.sol)

**Inherits:**
[INoAddressToRemove](/src/common/IErrors.sol/interface.INoAddressToRemove.md)


## Errors
### PricingModuleNotConfigured

```solidity
error PricingModuleNotConfigured(address _erc20PricingAddress, address nftPricingAddress);
```

### NotAccessLevelAdministrator

```solidity
error NotAccessLevelAdministrator(address _address);
```

### NotRiskAdmin

```solidity
error NotRiskAdmin(address _address);
```

### NotAUser

```solidity
error NotAUser(address _address);
```

### AddressAlreadyRegistered

```solidity
error AddressAlreadyRegistered();
```

### AdminMinTokenBalanceisActive

```solidity
error AdminMinTokenBalanceisActive();
```

### NotRegisteredHandler

```solidity
error NotRegisteredHandler(address);
```


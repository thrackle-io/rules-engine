# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/rules-engine/blob/54db83a2c72adaf3bc2196e69cb3cf728347d98b/src/common/IErrors.sol)

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

### NotRegisteredHandler

```solidity
error NotRegisteredHandler(address);
```

### ProposedAddressCannotBeSuperAdmin

```solidity
error ProposedAddressCannotBeSuperAdmin();
```


# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/845c12315ef4ac1a6cc2b1c3212b2b372da974eb/src/common/IErrors.sol)

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


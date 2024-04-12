# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/cbc87814d6bed0b3e71e8ab959486c532d05c771/src/common/IErrors.sol)

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


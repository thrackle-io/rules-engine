# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/interfaces/IErrors.sol)

**Inherits:**
[INoAddressToRemove](/src/interfaces/IErrors.sol/interface.INoAddressToRemove.md)


## Errors
### PricingModuleNotConfigured

```solidity
error PricingModuleNotConfigured(address _erc20PricingAddress, address nftPricingAddress);
```

### NotAccessTierAdministrator

```solidity
error NotAccessTierAdministrator(address _address);
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

### AdminWithdrawalRuleisActive

```solidity
error AdminWithdrawalRuleisActive();
```

### NotRegisteredHandler

```solidity
error NotRegisteredHandler(address);
```


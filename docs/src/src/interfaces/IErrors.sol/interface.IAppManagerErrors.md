# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/a2d57139b7236b5b0e9a0727e55f81e5332cd216/src/interfaces/IErrors.sol)


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

### NoAddressToRemove

```solidity
error NoAddressToRemove();
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


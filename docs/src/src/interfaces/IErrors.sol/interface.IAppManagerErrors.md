# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/interfaces/IErrors.sol)


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


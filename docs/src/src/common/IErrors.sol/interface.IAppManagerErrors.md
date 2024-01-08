# IAppManagerErrors
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/common/IErrors.sol)

**Inherits:**
[INoAddressToRemove](/src/common/IErrors.sol/interface.INoAddressToRemove.md)


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


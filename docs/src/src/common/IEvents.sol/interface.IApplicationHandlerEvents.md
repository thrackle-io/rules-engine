# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/common/IEvents.sol)

Application Handler Events Library

*This library is for all events in the Application Handler module for the protocol.*


## Events
### ApplicationHandlerDeployed

```solidity
event ApplicationHandlerDeployed(address indexed appManager);
```

### ApplicationRuleApplied

```solidity
event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);
```

### ERC721PricingAddressSet
Pricing


```solidity
event ERC721PricingAddressSet(address indexed _address);
```

### ERC20PricingAddressSet

```solidity
event ERC20PricingAddressSet(address indexed _address);
```


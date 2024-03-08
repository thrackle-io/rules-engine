# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/6347e28a06cfe8dcc416f54eea2d35ee6b0ce9fd/src/common/IEvents.sol)

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


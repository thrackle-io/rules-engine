# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/ce8f3ce20cc777375e5a3cbfcde63db2607acc28/src/common/IEvents.sol)

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


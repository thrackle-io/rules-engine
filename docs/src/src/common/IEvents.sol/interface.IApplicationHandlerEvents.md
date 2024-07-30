# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/0c22edbee3ca4c32dcba8042eeb10bc1a6c3bdd0/src/common/IEvents.sol)

Application Handler Events Library

*This library is for all events in the Application Handler module for the protocol.*


## Events
### AD1467_ApplicationHandlerDeployed

```solidity
event AD1467_ApplicationHandlerDeployed(address indexed appManager);
```

### AD1467_ApplicationRuleApplied

```solidity
event AD1467_ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);
```

### AD1467_ApplicationRuleApplied

```solidity
event AD1467_ApplicationRuleApplied(bytes32 indexed ruleType, ActionTypes indexed action, uint32 indexed ruleId);
```

### AD1467_ApplicationRuleAppliedFull

```solidity
event AD1467_ApplicationRuleAppliedFull(bytes32 indexed ruleType, ActionTypes[] actions, uint32[] ruleIds);
```

### AD1467_ERC721PricingAddressSet
Pricing


```solidity
event AD1467_ERC721PricingAddressSet(address indexed _address);
```

### AD1467_ERC20PricingAddressSet

```solidity
event AD1467_ERC20PricingAddressSet(address indexed _address);
```


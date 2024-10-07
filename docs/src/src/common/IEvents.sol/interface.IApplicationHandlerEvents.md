# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/6da66dae531fe9b9e3ff74f1c472024c95ff4417/src/common/IEvents.sol)

Application Handler Events Library

*This library is for all events in the Application Handler module for the protocol.*


## Events
### AD1467_ApplicationHandlerDeployed

```solidity
event AD1467_ApplicationHandlerDeployed(address indexed appManager, address indexed ruleProcessorAddress);
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


# ICommonApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/f405cfa7d52aca0d1bdf3d82da9748579a0bb635/src/common/IEvents.sol)

Common Application Handler Events Library

*This library is for all events in the Common Application Handler for the protocol. Each contract in the Protocol module should inherit this library for emitting events.*


## Events
### AD1467_ApplicationHandlerDeactivated
Rule deactivated


```solidity
event AD1467_ApplicationHandlerDeactivated(bytes32 indexed ruleType, ActionTypes[] actions);
```

### AD1467_ApplicationHandlerDeactivated

```solidity
event AD1467_ApplicationHandlerDeactivated(bytes32 indexed ruleType);
```

### AD1467_ApplicationHandlerActivated
Rule activated


```solidity
event AD1467_ApplicationHandlerActivated(bytes32 indexed ruleType);
```

### AD1467_ApplicationHandlerActivated

```solidity
event AD1467_ApplicationHandlerActivated(bytes32 indexed ruleType, ActionTypes[] actions);
```

### AD1467_RulesBypassedViaRuleBypassAccount

```solidity
event AD1467_RulesBypassedViaRuleBypassAccount(address indexed ruleBypassAccount, address indexed appManager);
```


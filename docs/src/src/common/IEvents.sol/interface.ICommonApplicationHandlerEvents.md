# ICommonApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ea7b4b1d8c8b9c92a6391cd0b67fbb323cf4419d/src/common/IEvents.sol)

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

### AD1467_RulesBypassedViaTreasuryAccount

```solidity
event AD1467_RulesBypassedViaTreasuryAccount(address indexed treasuryAccount, address indexed appManager);
```


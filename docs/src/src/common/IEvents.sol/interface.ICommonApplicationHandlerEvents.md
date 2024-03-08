# ICommonApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/common/IEvents.sol)

Common Application Handler Events Library

*This library is for all events in the Common Application Handler for the protocol. Each contract in the Protocol module should inherit this library for emitting events.*


## Events
### ApplicationHandlerDeactivated
Rule deactivated


```solidity
event ApplicationHandlerDeactivated(bytes32 indexed ruleType);
```

### ApplicationHandlerActivated
Rule activated


```solidity
event ApplicationHandlerActivated(bytes32 indexed ruleType);
```

### RulesBypassedViaRuleBypassAccount

```solidity
event RulesBypassedViaRuleBypassAccount(address indexed ruleBypassAccount, address indexed appManager);
```


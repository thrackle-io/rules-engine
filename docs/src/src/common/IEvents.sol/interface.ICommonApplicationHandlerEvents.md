# ICommonApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/common/IEvents.sol)

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


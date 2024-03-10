# ICommonApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/ce8f3ce20cc777375e5a3cbfcde63db2607acc28/src/common/IEvents.sol)

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


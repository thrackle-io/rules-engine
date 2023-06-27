# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Protocol Module Events Library

*This library for all events in the Protocol module for the protocol. Each contract in the Protocol module should inherit this library for emitting events.*


## Events
### ApplicationHandlerDeployed

```solidity
event ApplicationHandlerDeployed(address indexed deployedAddress, address indexed appManager);
```

### ApplicationRuleApplied

```solidity
event ApplicationRuleApplied(bytes32 indexed ruleType, uint32 indexed ruleId);
```


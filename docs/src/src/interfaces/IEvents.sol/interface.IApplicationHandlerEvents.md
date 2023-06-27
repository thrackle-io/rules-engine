# IApplicationHandlerEvents
[Git Source](https://github.com/thrackle-io/Tron/blob/68f4a826ed4aff2c87e6d1264dce053ee793c987/src/interfaces/IEvents.sol)

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


# ITokenHandlerEvents
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Handler Events Library

*This library for all protocol Handler Events. Each contract in the access module should inherit this library for emitting events.*


## Events
### HandlerDeployed
Handler


```solidity
event HandlerDeployed(address indexed applicationHandler, address indexed appManager);
```

### HandlerDeployedForUpgrade

```solidity
event HandlerDeployedForUpgrade(address indexed applicationHandler, address indexed appManager);
```

### ApplicationHandlerApplied
Rule applied


```solidity
event ApplicationHandlerApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint32 indexed ruleId);
```

### ApplicationHandlerSimpleApplied

```solidity
event ApplicationHandlerSimpleApplied(bytes32 indexed ruleType, address indexed handlerAddress, uint256 indexed param1);
```

### ApplicationHandlerDeactivated
Rule deactivated


```solidity
event ApplicationHandlerDeactivated(bytes32 indexed ruleType, address indexed handlerAddress);
```

### ApplicationHandlerActivated
Rule activated


```solidity
event ApplicationHandlerActivated(bytes32 indexed ruleType, address indexed handlerAddress);
```


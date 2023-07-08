# ITokenHandlerEvents
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/interfaces/IEvents.sol)

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


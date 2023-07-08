# IEconomicEvents
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Rule Processor Module Events Library

*This library for all events in the Rule Processor Module for the protocol. Each contract in the access module should inherit this library for emitting events.*


## Events
### ProtocolRuleCreated
Generic Rule Creation Event


```solidity
event ProtocolRuleCreated(bytes32 indexed ruleType, uint32 indexed ruleId, bytes32[] extraTags);
```

### newHandler
TokenRuleRouterProxy


```solidity
event newHandler(address indexed Handler);
```


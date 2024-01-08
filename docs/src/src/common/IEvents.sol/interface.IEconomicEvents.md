# IEconomicEvents
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/common/IEvents.sol)

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


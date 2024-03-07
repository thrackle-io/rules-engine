# IEconomicEvents
[Git Source](https://github.com/thrackle-io/tron/blob/d6cc09e8b231cc94d92dd93b6d49fb2728ede233/src/common/IEvents.sol)

Economic Module Events Library

*This library is for all events in the Economic Module for the protocol.*


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


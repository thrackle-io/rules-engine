# IEconomicEvents
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/common/IEvents.sol)

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


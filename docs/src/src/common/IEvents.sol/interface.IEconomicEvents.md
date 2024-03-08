# IEconomicEvents
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/common/IEvents.sol)

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


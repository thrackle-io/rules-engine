# ITokenHandlerEvents
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/0c22edbee3ca4c32dcba8042eeb10bc1a6c3bdd0/src/common/IEvents.sol)

**Inherits:**
[IAppManagerAddressSet](/src/common/IEvents.sol/interface.IAppManagerAddressSet.md)

Token Handler Events Library

*This library is for all Token Handler Events.*


## Events
### AD1467_ApplicationHandlerActionApplied
Rule applied


```solidity
event AD1467_ApplicationHandlerActionApplied(
    bytes32 indexed ruleType, ActionTypes indexed action, uint32 indexed ruleId
);
```

### AD1467_ApplicationHandlerActionAppliedFull

```solidity
event AD1467_ApplicationHandlerActionAppliedFull(bytes32 indexed ruleType, ActionTypes[] actions, uint32[] ruleIds);
```

### AD1467_ApplicationHandlerActionDeactivated
Rule deactivated


```solidity
event AD1467_ApplicationHandlerActionDeactivated(bytes32 indexed ruleType, ActionTypes[] actions);
```

### AD1467_ApplicationHandlerActionActivated
Rule activated


```solidity
event AD1467_ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes[] actions);
```

### AD1467_NFTValuationLimitUpdated
NFT Valuation Limit Updated


```solidity
event AD1467_NFTValuationLimitUpdated(uint256 indexed nftValuationLimit);
```

### AD1467_AppManagerAddressProposed

```solidity
event AD1467_AppManagerAddressProposed(address indexed _address);
```

### AD1467_FeeActivationSet
Fees


```solidity
event AD1467_FeeActivationSet(bool indexed _activation);
```

### AD1467_ERC721AddressSet
Configuration


```solidity
event AD1467_ERC721AddressSet(address indexed _address);
```


# ITokenHandlerEvents
[Git Source](https://github.com/thrackle-io/tron/blob/5d067d497731c6b73733c2217dfac1db063f1640/src/common/IEvents.sol)

**Inherits:**
[IAppManagerAddressSet](/src/common/IEvents.sol/interface.IAppManagerAddressSet.md)

Token Handler Events Library

*This library is for all Token Handler Events.*


## Events
### ApplicationHandlerActionApplied
Rule applied


```solidity
event ApplicationHandlerActionApplied(bytes32 indexed ruleType, ActionTypes indexed action, uint32 indexed ruleId);
```

### ApplicationHandlerSimpleActionApplied

```solidity
event ApplicationHandlerSimpleActionApplied(bytes32 indexed ruleType, ActionTypes action, uint256 indexed param1);
```

### ApplicationHandlerActionDeactivated
Rule deactivated


```solidity
event ApplicationHandlerActionDeactivated(bytes32 indexed ruleType, ActionTypes action);
```

### ApplicationHandlerActionActivated
Rule activated


```solidity
event ApplicationHandlerActionActivated(bytes32 indexed ruleType, ActionTypes action);
```

### NFTValuationLimitUpdated
NFT Valuation Limit Updated


```solidity
event NFTValuationLimitUpdated(uint256 indexed nftValuationLimit);
```

### AppManagerAddressProposed

```solidity
event AppManagerAddressProposed(address indexed _address);
```

### FeeActivationSet
Fees


```solidity
event FeeActivationSet(bool indexed _activation);
```

### ERC721AddressSet
Configuration


```solidity
event ERC721AddressSet(address indexed _address);
```


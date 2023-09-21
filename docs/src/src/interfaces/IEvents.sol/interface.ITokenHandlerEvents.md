# ITokenHandlerEvents
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/108c58e2bb8e5c2e5062cebb48a41dcaadcbfcd8/src/interfaces/IEvents.sol)

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

### NFTValuationLimitUpdated
NFT Valuation Limit Updated


```solidity
event NFTValuationLimitUpdated(uint256 indexed nftValuationLimit, address indexed handlerAddress);
```

### AppManagerAddressSet

```solidity
event AppManagerAddressSet(address indexed _address);
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

### ERC721PricingAddressSet
Pricing


```solidity
event ERC721PricingAddressSet(address indexed _address);
```

### ERC20PricingAddressSet

```solidity
event ERC20PricingAddressSet(address indexed _address);
```

### ERC721AddressSet
Configuration


```solidity
event ERC721AddressSet(address indexed _address);
```


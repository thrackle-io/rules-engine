# IOracleEvents
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/common/IEvents.sol)

Oracle Events Library

*The library for all events for the Oracle contracts for the protocol.*


## Events
### ApprovedAddress

```solidity
event ApprovedAddress(address indexed addr);
```

### NotApprovedAddress

```solidity
event NotApprovedAddress(address indexed addr);
```

### ApproveListOracleDeployed

```solidity
event ApproveListOracleDeployed();
```

### DeniedAddress

```solidity
event DeniedAddress(address indexed addr);
```

### NonDeniedAddress

```solidity
event NonDeniedAddress(address indexed addr);
```

### DeniedListOracleDeployed

```solidity
event DeniedListOracleDeployed();
```

### OracleListChanged

```solidity
event OracleListChanged(bool indexed add, address[] addresses);
```


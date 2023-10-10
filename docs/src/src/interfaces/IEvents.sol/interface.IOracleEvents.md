# IOracleEvents
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/interfaces/IEvents.sol)


## Events
### AllowedAddress

```solidity
event AllowedAddress(address indexed addr);
```

### NotAllowedAddress

```solidity
event NotAllowedAddress(address indexed addr);
```

### AllowListOracleDeployed

```solidity
event AllowListOracleDeployed();
```

### SanctionedAddress

```solidity
event SanctionedAddress(address indexed addr);
```

### NonSanctionedAddress

```solidity
event NonSanctionedAddress(address indexed addr);
```

### SanctionedListOracleDeployed

```solidity
event SanctionedListOracleDeployed();
```

### OracleListChanged

```solidity
event OracleListChanged(bool indexed add, address[] addresses);
```


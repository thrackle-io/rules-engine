# IOracleEvents
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/common/IEvents.sol)


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


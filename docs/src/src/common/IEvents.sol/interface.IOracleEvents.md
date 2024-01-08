# IOracleEvents
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/common/IEvents.sol)


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


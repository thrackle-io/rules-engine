# IAppLevelEvents
[Git Source](https://github.com/thrackle-io/forte-rules-engine/blob/9e3814d522f1469f798bac69a12de09ee849e2da/src/common/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Protocol Module Events Library

Appliction Module Events Library

*This library is for all events in the Protocol. Each contract should inherit thier specific library for emitting events.*

*The library for all events in the Application module for the protocol.*


## Events
### AD1467_AppManagerDeployed
AppManager


```solidity
event AD1467_AppManagerDeployed(address indexed superAndAppAdmin, string appName);
```

### AD1467_AppManagerDeployedForUpgrade

```solidity
event AD1467_AppManagerDeployedForUpgrade(address indexed superAndAppAdmin, string appName);
```

### AD1467_AppManagerDataUpgradeProposed

```solidity
event AD1467_AppManagerDataUpgradeProposed(address indexed deployedAddress, address replacedAddress);
```

### AD1467_DataContractsMigrated

```solidity
event AD1467_DataContractsMigrated(address indexed ownerAddress);
```

### AD1467_RemoveFromRegistry

```solidity
event AD1467_RemoveFromRegistry(string contractName, address contractAddress);
```

### AD1467_AppNameChanged

```solidity
event AD1467_AppNameChanged(string appName);
```

### AD1467_TokenRegistered
Registrations


```solidity
event AD1467_TokenRegistered(string _token, address indexed _address, uint8 indexed _type);
```

### AD1467_TokenNameUpdated

```solidity
event AD1467_TokenNameUpdated(string _token, address indexed _address);
```

### AD1467_AMMRegistered

```solidity
event AD1467_AMMRegistered(address indexed _address);
```

### AD1467_TradingRuleAddressAllowlist

```solidity
event AD1467_TradingRuleAddressAllowlist(address indexed _address, bool indexed isApproved);
```

### AD1467_TagProviderSet
Tags


```solidity
event AD1467_TagProviderSet(address indexed _address);
```

### AD1467_Tag

```solidity
event AD1467_Tag(address indexed _address, bytes32 indexed _tag, bool indexed add);
```

### AD1467_TagAlreadyApplied

```solidity
event AD1467_TagAlreadyApplied(address indexed _address);
```

### AD1467_AccessLevelProviderSet
AccessLevels


```solidity
event AD1467_AccessLevelProviderSet(address indexed _address);
```

### AD1467_AccessLevelAdded

```solidity
event AD1467_AccessLevelAdded(address indexed _address, uint8 indexed _level);
```

### AD1467_AccessLevelRemoved

```solidity
event AD1467_AccessLevelRemoved(address indexed _address);
```

### AD1467_PauseRuleProviderSet
PauseRules


```solidity
event AD1467_PauseRuleProviderSet(address indexed _address);
```

### AD1467_PauseRuleEvent

```solidity
event AD1467_PauseRuleEvent(uint256 indexed pauseStart, uint256 indexed pauseStop, bool indexed add);
```

### AD1467_RiskProviderSet
RiskScores


```solidity
event AD1467_RiskProviderSet(address indexed _address);
```

### AD1467_RiskScoreAdded

```solidity
event AD1467_RiskScoreAdded(address indexed _address, uint8 _score);
```

### AD1467_RiskScoreRemoved

```solidity
event AD1467_RiskScoreRemoved(address indexed _address);
```


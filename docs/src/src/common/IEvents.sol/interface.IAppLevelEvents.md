# IAppLevelEvents
[Git Source](https://github.com/thrackle-io/tron/blob/4674814db01d3b90ed90d394187432e47d662f5c/src/common/IEvents.sol)

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
event AD1467_AppManagerDeployed(address indexed superAndAppAdmin, string indexed appName);
```

### AD1467_AppManagerDeployedForUpgrade

```solidity
event AD1467_AppManagerDeployedForUpgrade(address indexed superAndAppAdmin, string indexed appName);
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

### AD1467_RuleAdmin

```solidity
event AD1467_RuleAdmin(address indexed admin, bool indexed add);
```

### AD1467_RiskAdmin

```solidity
event AD1467_RiskAdmin(address indexed admin, bool indexed add);
```

### AD1467_AccessLevelAdmin

```solidity
event AD1467_AccessLevelAdmin(address indexed admin, bool indexed add);
```

### AD1467_AppAdministrator

```solidity
event AD1467_AppAdministrator(address indexed admin, bool indexed add);
```

### AD1467_SuperAdministrator

```solidity
event AD1467_SuperAdministrator(address indexed admin, bool indexed add);
```

### AD1467_RuleBypassAccount

```solidity
event AD1467_RuleBypassAccount(address indexed bypassAccount, bool indexed add);
```

### AD1467_AppNameChanged

```solidity
event AD1467_AppNameChanged(string indexed appName);
```

### AD1467_TokenRegistered
Registrations


```solidity
event AD1467_TokenRegistered(string indexed _token, address indexed _address);
```

### AD1467_TokenNameUpdated

```solidity
event AD1467_TokenNameUpdated(string indexed _token, address indexed _address);
```

### AD1467_AMMRegistered

```solidity
event AD1467_AMMRegistered(address indexed _address);
```

### AD1467_TreasuryRegistered

```solidity
event AD1467_TreasuryRegistered(address indexed _address);
```

### AD1467_TradingRuleAddressAllowlist

```solidity
event AD1467_TradingRuleAddressAllowlist(address indexed _address, bool indexed isApproved);
```

### AD1467_AccountProviderSet
Accounts


```solidity
event AD1467_AccountProviderSet(address indexed _address);
```

### AD1467_AccountAdded

```solidity
event AD1467_AccountAdded(address indexed account);
```

### AD1467_AccountRemoved

```solidity
event AD1467_AccountRemoved(address indexed account);
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


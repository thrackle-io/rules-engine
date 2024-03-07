# IAppLevelEvents
[Git Source](https://github.com/thrackle-io/tron/blob/46cb5e729fbe3c8dc7b7ecacae59ec49544d86f9/src/common/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Protocol Module Events Library

Appliction Module Events Library

*This library is for all events in the Protocol. Each contract should inherit thier specific library for emitting events.*

*The library for all events in the Application module for the protocol.*


## Events
### HandlerConnected
AppManager


```solidity
event HandlerConnected(address indexed handlerAddress, address indexed appManager);
```

### RoleCheck

```solidity
event RoleCheck(string contractName, string functionName, address checkedAddress, bytes32 checkedRole);
```

### AppManagerDeployed

```solidity
event AppManagerDeployed(address indexed superAndAppAdmin, string indexed appName);
```

### AppManagerDeployedForUpgrade

```solidity
event AppManagerDeployedForUpgrade(address indexed superAndAppAdmin, string indexed appName);
```

### AppManagerUpgrade

```solidity
event AppManagerUpgrade(address indexed deployedAddress, address replacedAddress);
```

### AppManagerDataUpgradeProposed

```solidity
event AppManagerDataUpgradeProposed(address indexed deployedAddress, address replacedAddress);
```

### DataContractsMigrated

```solidity
event DataContractsMigrated(address indexed ownerAddress);
```

### RemoveFromRegistry

```solidity
event RemoveFromRegistry(string contractName, address contractAddress);
```

### RuleAdmin

```solidity
event RuleAdmin(address indexed admin, bool indexed add);
```

### RiskAdmin

```solidity
event RiskAdmin(address indexed admin, bool indexed add);
```

### AccessLevelAdmin

```solidity
event AccessLevelAdmin(address indexed admin, bool indexed add);
```

### AppAdministrator

```solidity
event AppAdministrator(address indexed admin, bool indexed add);
```

### SuperAdministrator

```solidity
event SuperAdministrator(address indexed admin, bool indexed add);
```

### RuleBypassAccount

```solidity
event RuleBypassAccount(address indexed bypassAccount, bool indexed add);
```

### TokenRegistered
Registrations


```solidity
event TokenRegistered(string indexed _token, address indexed _address);
```

### TokenNameUpdated

```solidity
event TokenNameUpdated(string indexed _token, address indexed _address);
```

### AMMRegistered

```solidity
event AMMRegistered(address indexed _address);
```

### TreasuryRegistered

```solidity
event TreasuryRegistered(address indexed _address);
```

### TradingRuleAddressAllowlist

```solidity
event TradingRuleAddressAllowlist(address indexed _address, bool indexed isApproved);
```

### AccountProviderSet
Accounts


```solidity
event AccountProviderSet(address indexed _address);
```

### AccountAdded

```solidity
event AccountAdded(address indexed account);
```

### AccountRemoved

```solidity
event AccountRemoved(address indexed account);
```

### TagProviderSet
Tags


```solidity
event TagProviderSet(address indexed _address);
```

### Tag

```solidity
event Tag(address indexed _address, bytes32 indexed _tag, bool indexed add);
```

### TagAlreadyApplied

```solidity
event TagAlreadyApplied(address indexed _address);
```

### AccessLevelProviderSet
AccessLevels


```solidity
event AccessLevelProviderSet(address indexed _address);
```

### AccessLevelAdded

```solidity
event AccessLevelAdded(address indexed _address, uint8 indexed _level);
```

### AccessLevelRemoved

```solidity
event AccessLevelRemoved(address indexed _address);
```

### PauseRuleProviderSet
PauseRules


```solidity
event PauseRuleProviderSet(address indexed _address);
```

### PauseRuleEvent

```solidity
event PauseRuleEvent(uint256 indexed pauseStart, uint256 indexed pauseStop, bool indexed add);
```

### RiskProviderSet
RiskScores


```solidity
event RiskProviderSet(address indexed _address);
```

### RiskScoreAdded

```solidity
event RiskScoreAdded(address indexed _address, uint8 _score);
```

### RiskScoreRemoved

```solidity
event RiskScoreRemoved(address indexed _address);
```


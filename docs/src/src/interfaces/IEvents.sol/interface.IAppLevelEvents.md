# IAppLevelEvents
[Git Source](https://github.com/thrackle-io/tron/blob/2e0bd455865a1259ae742cba145517a82fc00f5d/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Protocol Module Events Library

*This library for all events in the Protocol module for the protocol. Each contract in the Protocol module should inherit this library for emitting events.*


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
event AppManagerDeployed(address indexed deployedAddress);
```

### AppManagerDeployedForUpgrade

```solidity
event AppManagerDeployedForUpgrade(address indexed deployedAddress);
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

### RuleAdminAdded

```solidity
event RuleAdminAdded(address newAdmin);
```

### RuleAdminRemoved

```solidity
event RuleAdminRemoved(address removedAdmin);
```

### RiskAdminAdded

```solidity
event RiskAdminAdded(address newAdmin);
```

### RiskAdminRemoved

```solidity
event RiskAdminRemoved(address removedAdmin);
```

### AccessTierAdded

```solidity
event AccessTierAdded(address newAdmin);
```

### AccessTierRemoved

```solidity
event AccessTierRemoved(address removedAdmin);
```

### AddAppAdministrator

```solidity
event AddAppAdministrator(address newAppAdministrator);
```

### RemoveAppAdministrator

```solidity
event RemoveAppAdministrator(address removedAppAdministrator);
```

### TokenRegistered
Registrations


```solidity
event TokenRegistered(string indexed _token, address indexed _address);
```

### AMMRegistered

```solidity
event AMMRegistered(address indexed _address);
```

### TreasuryRegistered

```solidity
event TreasuryRegistered(address indexed _address);
```

### AccountProviderSet
Accounts


```solidity
event AccountProviderSet(address indexed _address);
```

### AccountAdded

```solidity
event AccountAdded(address indexed account, uint256 date);
```

### AccountRemoved

```solidity
event AccountRemoved(address indexed account, uint256 date);
```

### GeneralTagProviderSet
GeneralTags


```solidity
event GeneralTagProviderSet(address indexed _address);
```

### GeneralTagAdded

```solidity
event GeneralTagAdded(address indexed _address, bytes32 indexed _tag, uint256 date);
```

### GeneralTagRemoved

```solidity
event GeneralTagRemoved(address indexed _address, bytes32 indexed _tag, uint256 date);
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
event AccessLevelAdded(address indexed _address, uint8 indexed _level, uint256 date);
```

### AccessLevelRemoved

```solidity
event AccessLevelRemoved(address indexed _address, uint256 date);
```

### PauseRuleProviderSet
PauseRules


```solidity
event PauseRuleProviderSet(address indexed _address);
```

### PauseRuleAdded

```solidity
event PauseRuleAdded(uint256 indexed pauseStart, uint256 indexed pauseStop);
```

### PauseRuleRemoved

```solidity
event PauseRuleRemoved(uint256 indexed pauseStart, uint256 indexed pauseStop);
```

### RiskProviderSet
RiskScores


```solidity
event RiskProviderSet(address indexed _address);
```

### RiskScoreAdded

```solidity
event RiskScoreAdded(address indexed _address, uint8 _score, uint256 date);
```

### RiskScoreRemoved

```solidity
event RiskScoreRemoved(address indexed _address, uint256 date);
```


# IAppLevelEvents
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/interfaces/IEvents.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Protocol Module Events Library

*This library for all events in the Protocol module for the protocol. Each contract in the Protocol module should inherit this library for emitting events.*


## Events
### RoleCheck
AppManager


```solidity
event RoleCheck(string contractName, string functionName, address checkedAddress, bytes32 checkedRole);
```

### AppManagerDeployed

```solidity
event AppManagerDeployed(address indexed deployedAddress);
```

### ApplicationHandlerDeployed

```solidity
event ApplicationHandlerDeployed(address indexed deployedAddress);
```

### AppManagerDeployedForUpgrade

```solidity
event AppManagerDeployedForUpgrade(address indexed deployedAddress);
```

### AppManagerUpgrade

```solidity
event AppManagerUpgrade(address indexed deployedAddress, address replacedAddress);
```

### RemoveFromRegistry

```solidity
event RemoveFromRegistry(string contractName, address contractAddress);
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

### AccountAdded
Accounts


```solidity
event AccountAdded(address indexed account, uint256 date);
```

### AccountRemoved

```solidity
event AccountRemoved(address indexed account, uint256 date);
```

### GeneralTagAdded
GeneralTags


```solidity
event GeneralTagAdded(address indexed _address, bytes32 indexed _tag, uint256 date);
```

### GeneralTagRemoved

```solidity
event GeneralTagRemoved(address indexed _address, bytes32 indexed _tag, uint256 date);
```

### AccessLevelAdded
AccessLevels


```solidity
event AccessLevelAdded(address indexed _address, uint8 indexed _level, uint256 date);
```

### AccessLevelRemoved

```solidity
event AccessLevelRemoved(address indexed _address, uint256 date);
```

### PauseRuleAdded
PauseRules


```solidity
event PauseRuleAdded(uint256 pauseStart, uint256 pauseStop);
```

### PauseRuleRemoved

```solidity
event PauseRuleRemoved(uint256 pauseStart, uint256 pauseStop);
```

### RiskScoreAdded
RiskScores


```solidity
event RiskScoreAdded(address indexed _address, uint8 _score, uint256 date);
```

### RiskScoreRemoved

```solidity
event RiskScoreRemoved(address indexed _address, uint256 date);
```


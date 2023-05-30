# ApplicationAppManager
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/b3877670eae43a9723081d42c4401502ebd5b9f6/src/example/ApplicationAppManager.sol)

**Inherits:**
[AppManager](/src/application/AppManager.sol/contract.AppManager.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs can use.

*During deployment _ownerAddress = First Application Administrators set in constructor*


## Functions
### constructor

*constructor sets the owner address, application name, and upgrade mode at deployment*


```solidity
constructor(address _ownerAddress, string memory _appName, address _ruleProcessorProxyAddress, bool upgradeMode)
    AppManager(_ownerAddress, _appName, _ruleProcessorProxyAddress, upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ownerAddress`|`address`|Address of deployer wallet|
|`_appName`|`string`|Application Name String|
|`_ruleProcessorProxyAddress`|`address`|of the Protocol's rule processor|
|`upgradeMode`|`bool`|specifies whether this is a fresh AppManager or an upgrade replacement.|



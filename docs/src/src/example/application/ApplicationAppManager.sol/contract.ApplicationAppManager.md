# ApplicationAppManager
[Git Source](https://github.com/thrackle-io/rules-engine/blob/ce3e124fbb7b1c9745b955077cf9cd260c5eabe5/src/example/application/ApplicationAppManager.sol)

**Inherits:**
[AppManager](/src/client/application/AppManager.sol/contract.AppManager.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs can use.

*During deployment _ownerAddress = First Application Administrators set in constructor*


## Functions
### constructor

*Constructor sets the owner address, application name, and upgrade mode at deployment*


```solidity
constructor(address _ownerAddress, string memory _appName, bool upgradeMode)
    AppManager(_ownerAddress, _appName, upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ownerAddress`|`address`|Address of deployer wallet|
|`_appName`|`string`|Application Name String|
|`upgradeMode`|`bool`|specifies whether this is a fresh AppManager or an upgrade replacement.|



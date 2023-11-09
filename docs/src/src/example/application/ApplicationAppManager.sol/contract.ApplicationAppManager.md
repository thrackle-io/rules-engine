# ApplicationAppManager
<<<<<<< HEAD:docs/src/src/example/ApplicationAppManager.sol/contract.ApplicationAppManager.md
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/ApplicationAppManager.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/application/ApplicationAppManager.sol)
>>>>>>> external:docs/src/src/example/application/ApplicationAppManager.sol/contract.ApplicationAppManager.md

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
constructor(address _ownerAddress, string memory _appName, bool upgradeMode)
    AppManager(_ownerAddress, _appName, upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ownerAddress`|`address`|Address of deployer wallet|
|`_appName`|`string`|Application Name String|
|`upgradeMode`|`bool`|specifies whether this is a fresh AppManager or an upgrade replacement.|



# ApplicationAppManager
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/example/ApplicationAppManager.sol)

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
constructor(address _ownerAddress, string memory _appName, address _tokenRuleRouterAddress, bool upgradeMode)
    AppManager(_ownerAddress, _appName, _tokenRuleRouterAddress, upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ownerAddress`|`address`|Address of deployer wallet|
|`_appName`|`string`|Application Name String|
|`_tokenRuleRouterAddress`|`address`|Address of the Protocol's token rule router|
|`upgradeMode`|`bool`|specifies whether this is a fresh AppManager or an upgrade replacement.|



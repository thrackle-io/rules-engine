# ApplicationHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/example/application/ApplicationHandler.sol)

**Inherits:**
[ProtocolApplicationHandler](/src/application/ProtocolApplicationHandler.sol/contract.ProtocolApplicationHandler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the connector between the AppManagerRulesDiamond and the Application App Managers. It is maintained by the client application.
Deployment happens automatically when the AppManager is deployed.

*This contract is injected into the appManagerss.*


## Functions
### constructor

*Initializes the contract setting the owner as the one provided.*


```solidity
constructor(address _tokenRuleRouterAddress, address _appManagerAddress)
    ProtocolApplicationHandler(_tokenRuleRouterAddress, _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenRuleRouterAddress`|`address`|address of the protocol's TokenRuleRouter contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|



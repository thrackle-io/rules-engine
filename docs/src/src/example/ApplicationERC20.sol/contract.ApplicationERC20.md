# ApplicationERC20
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/example/ApplicationERC20.sol)

**Inherits:**
[ProtocolERC20](/src/token/ProtocolERC20.sol/contract.ProtocolERC20.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.

*During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor*


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(
    string memory _name,
    string memory _symbol,
    address _appManagerAddress,
    address _ruleProcessorProxyAddress,
    bool _upgradeMode
) ProtocolERC20(_name, _symbol, _appManagerAddress, _ruleProcessorProxyAddress, _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of the token|
|`_symbol`|`string`| Symbol of the token|
|`_appManagerAddress`|`address`|App Manager address|
|`_ruleProcessorProxyAddress`|`address`|of token rule router proxy address|
|`_upgradeMode`|`bool`||



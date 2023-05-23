# ApplicationERC20
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/example/ApplicationERC20.sol)

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
constructor(string memory _name, string memory _symbol, address _appManagerAddress, address _erc20HandlerAddress)
    ProtocolERC20(_name, _symbol, _appManagerAddress, _erc20HandlerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of the token|
|`_symbol`|`string`| Symbol of the token|
|`_appManagerAddress`|`address`|App Manager address|
|`_erc20HandlerAddress`|`address`|The ERC20's handler address|



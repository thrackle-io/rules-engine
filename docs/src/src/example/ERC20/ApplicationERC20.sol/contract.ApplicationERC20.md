# ApplicationERC20
<<<<<<< HEAD:docs/src/src/example/ApplicationERC20.sol/contract.ApplicationERC20.md
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/ApplicationERC20.sol)
=======
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/example/ERC20/ApplicationERC20.sol)
>>>>>>> external:docs/src/src/example/ERC20/ApplicationERC20.sol/contract.ApplicationERC20.md

**Inherits:**
[ProtocolERC20](/src/token/ERC20/ProtocolERC20.sol/contract.ProtocolERC20.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This is an example implementation that App Devs should use.

*During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor*


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(string memory _name, string memory _symbol, address _appManagerAddress)
    ProtocolERC20(_name, _symbol, _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|Name of the token|
|`_symbol`|`string`| Symbol of the token|
|`_appManagerAddress`|`address`|App Manager address|


### mint

*Function mints new tokens. Allows for free and open minting of tokens. Comment out to use appAdministatorOnly minting.*


```solidity
function mint(address to, uint256 amount) public override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens to mint|



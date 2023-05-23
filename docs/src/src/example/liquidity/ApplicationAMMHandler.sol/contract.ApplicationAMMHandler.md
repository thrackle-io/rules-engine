# ApplicationAMMHandler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/example/liquidity/ApplicationAMMHandler.sol)

**Inherits:**
[ProtocolAMMHandler](/src/liquidity/ProtocolAMMHandler.sol/contract.ProtocolAMMHandler.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Any rule checks may be updated by modifying this contract and redeploying.

*This contract performs all the rule checks related to the the AMM that implements it.*


## Functions
### constructor

*Constructor sets the App Manager and token rule router Address*


```solidity
constructor(address _appManagerAddress, address _tokenRuleRouterAddress)
    ProtocolAMMHandler(_appManagerAddress, _tokenRuleRouterAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|App Manager Address|
|`_tokenRuleRouterAddress`|`address`|Token Rule Router Proxy Address|



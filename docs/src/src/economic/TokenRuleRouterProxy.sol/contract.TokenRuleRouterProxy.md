# TokenRuleRouterProxy
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/TokenRuleRouterProxy.sol)

**Inherits:**
[Initializable](/src/helpers/Initializable.sol/abstract.Initializable.md), ProxyAdmin, [IEconomicEvents](/src/interfaces/IEvents.sol/interface.IEconomicEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

All calls to the TokenRuleRouter will be pointed here and delegated to the router.

*This contract is the proxy interface of the Token Rule Router.*


## State Variables
### tokenRuleRouter

```solidity
address tokenRuleRouter;
```


### admin

```solidity
address private admin;
```


## Functions
### constructor

*Constructor sets the Token Rule Router address of implememtation contract*


```solidity
constructor(address _tokenRuleRouter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenRuleRouter`|`address`|Address of Token Rule Router|


### fallback

*Fallback to delegate calls to the implementation contract TokenRuleRouter.sol*


```solidity
fallback() external payable;
```

### receive

*Recieve function for calls with no data*


```solidity
receive() external payable;
```

### newImplementationAddr

*Function sets new implementation address after upgrade. Requires that the new address is not 0 address and caller is Admin.*


```solidity
function newImplementationAddr(address _newHandler) public onlyOwner returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newHandler`|`address`|Address of new Implementation contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|tokenRuleRouter Address of new implementation contract|


### getAdmin


```solidity
function getAdmin() public view returns (address);
```


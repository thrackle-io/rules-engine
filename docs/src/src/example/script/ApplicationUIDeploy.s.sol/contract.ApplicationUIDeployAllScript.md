# ApplicationUIDeployAllScript
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/example/script/ApplicationUIDeploy.s.sol)

**Inherits:**
Script


## State Variables
### applicationCoinHandler

```solidity
ApplicationERC20Handler applicationCoinHandler;
```


### applicationCoinHandler2

```solidity
ApplicationERC20Handler applicationCoinHandler2;
```


### applicationCoinHandler3

```solidity
ApplicationERC20Handler applicationCoinHandler3;
```


### applicationNFTHandler

```solidity
ApplicationERC721Handler applicationNFTHandler;
```


### applicationAMMHandler

```solidity
ApplicationAMMHandler applicationAMMHandler;
```


### yieldPerTimeUnitArray

```solidity
uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
```


### yieldPerTimeUnitArray2

```solidity
uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
```


### applicationNFTAddresses

```solidity
address[] applicationNFTAddresses;
```


## Functions
### setUp


```solidity
function setUp() public;
```

### run


```solidity
function run() public;
```


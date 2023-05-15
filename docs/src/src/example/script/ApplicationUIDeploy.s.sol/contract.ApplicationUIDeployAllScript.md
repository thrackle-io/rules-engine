# ApplicationUIDeployAllScript
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/example/script/ApplicationUIDeploy.s.sol)

**Inherits:**
Script


## State Variables
### applicationCoinHandler

```solidity
ApplicationERC20Handler applicationCoinHandler;
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


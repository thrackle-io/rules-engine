# ApplicationDeployAllScript
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/49ab19f6a1a98efed1de2dc532ff3da9b445a7cb/src/example/script/ApplicationDeployAll.s.sol)

**Inherits:**
Script

Deploys the application App Manager, AppManager, ERC20, ERC721, and associated handlers, pricing and oracle contracts.

*This script will deploy all application contracts needed to test the protocol interactions.*


## State Variables
### applicationCoinHandler

```solidity
ApplicationERC20Handler applicationCoinHandler;
```


### applicationCoinHandler2

```solidity
ApplicationERC20Handler applicationCoinHandler2;
```


### applicationNFTHandler

```solidity
ApplicationERC721Handler applicationNFTHandler;
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


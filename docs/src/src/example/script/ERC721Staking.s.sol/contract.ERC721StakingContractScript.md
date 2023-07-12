# ERC721StakingContractScript
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/de9d46fc7f857fca8d253f1ed09221b1c3873dd9/src/example/script/ERC721Staking.s.sol)

**Inherits:**
Script

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*creates a staking contracts with APPLICATION_ERC20_ADDRESS_2 as rewards token and APPLICATION_ERC721_ADDRESS_1 as stakeable NFT*


## State Variables
### applicationTokenAddressArray

```solidity
address[] applicationTokenAddressArray;
```


### yieldPerTimeUnitArray

```solidity
uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
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


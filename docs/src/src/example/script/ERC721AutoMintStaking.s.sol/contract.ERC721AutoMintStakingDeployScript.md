# ERC721AutoMintStakingDeployScript
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/example/script/ERC721AutoMintStaking.s.sol)

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


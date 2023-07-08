# ERC721AutoMintStaking
[Git Source](https://github.com/thrackle-io/Tron/blob/239d60d1c3cbbef1a9f14ff953593a8a908ddbe0/src/example/staking/ERC721AutoMintStaking.sol)

**Inherits:**
[IERC721Staking](/src/staking/IERC721Staking.sol/abstract.IERC721Staking.md), IERC721Receiver, Context, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract allows for staking of multiple ERC721 token collections asigned at construction or updated after deployment.

*This is an example of a staking contract for ERC721 tokens with ERC20 reward token minted at reward claim.*


## State Variables
### appManager

```solidity
IAppManager appManager;
```


### rewardToken

```solidity
ApplicationERC20 rewardToken;
```


### stakedCollections
Collections Addresses that can be staked


```solidity
address[] public stakedCollections;
```


### totalStaked
contract balances


```solidity
uint256 public totalStaked;
```


### rewardsPerTimeUnitPerTokenAddressStaked
rewardsPerTimeUnitPerTokenStaked rule value

it should be in the same order as TIME_UNITS_TO_SECS:
[secs, mins, hours, days, weeks, 30-day months, 365-day years]
Each NFT address may be staked at different rates


```solidity
mapping(address => uint128[7]) rewardsPerTimeUnitPerTokenAddressStaked;
```


### stakeableCollections
Stakeable NFT Collection addresses


```solidity
mapping(address => bool) public stakeableCollections;
```


### stakesPerAddress
Stakes per address @notice that stakes are stored in an array


```solidity
mapping(address => Stake[]) public stakesPerAddress;
```


### totalStakedPerAddress

```solidity
mapping(address => uint256) public totalStakedPerAddress;
```


## Functions
### constructor

that rules can change at any time, but it won't affect past staking processes. It would
only affect future staking.

*constructor*


```solidity
constructor(
    address _rewardTokenAddress,
    address[] memory _stakingTokenAddresses,
    uint128[7][] memory _rewardsPerAddress,
    address _appManagerAddress
);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rewardTokenAddress`|`address`|ERC20 token address that will be delivered as rewards for staking|
|`_stakingTokenAddresses`|`address[]`|ERC721 address to stake for rewards|
|`_rewardsPerAddress`|`uint128[7][]`|reward structure for each staked address|
|`_appManagerAddress`|`address`|address of the application AppManager.|


### stake

Assign each of the _stakingTokenAddresses to the mapping for approved staking addresses and set the rewards structure
load the reward structure too. This has to be done an element at a time since memory array not convertible to storage

that you can stake more than once. Each stake can be for a different time period and with different
amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.

this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
enough reward tokens in the contract to pay you.

*stake your tokens*


```solidity
function stake(address stakedToken, uint256 tokenId, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime)
    external
    override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`stakedToken`|`address`|address of the NFT collection of the token to be staked|
|`tokenId`|`uint256`|id of token to stake|
|`_unitsOfTime`|`uint8`|references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]|
|`_stakingForUnitsOfTime`|`uint8`|amount of (secs/mins/days/weeks/months/years) to stake for.|


### claimRewards

check stake time is valid
check that tokenId being staked is valid collection/class
transferring tokens to start staking
we get the rewards rate from the rules
we create the the stake object
we calculate this stake rewards
the contract will revert if this stake will yield zero rewards
We update the total amount of tokens staked in this contract
and we store the stake in the array for the staker

that you will get all of your rewards available in the contract, and expired stakes will
be erased once claimed. Your available stakes to withdraw will also be updated.

*claim your available rewards*


```solidity
function claimRewards() external override;
```

### _removeStake

initialize rewards variable
we initialize freed stakes
initialize iterator
we will loop through the stake array until the end
we create flag for the following while loop
we will remain in the same position of the array as long as we keep finding expired stakes here, since
we are deleting expired stakes in the process which will replace the stake in this position with the
last stake in the array.
we retrieve the stake at current position
if this stake is ready for claim
we accumulate this stake rewards
We update the total amount of tokens staked in this contract
transfer staked token back to user
we remove this stake
if current position didn't cointain a stake ready for claim, then we pass to the next position.
if there are no rewards owed to user, then transaction will fail
Contract pays the staker

*internal function that takes care of deleting an expired stake*


```solidity
function _removeStake(uint256 i) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`i`|`uint256`|index of the stake in the stake array to delete|


### calculateRewards

*helper function for frontend that gets available rewards for a staker*


```solidity
function calculateRewards(address staker) external view override returns (uint256 rewards);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|address of the staker to get available rewards for|


### updateRewardsPerTokenStakedAddressPerTimeUnit

that rewards must be specified in the smallest unit of the reward token, and the million staked
tokens are also in the smallest units of the staked token. Most ERC20s use 18 decimals, so 1 -> 1/10^18.

*update the APY (indirectly) for this staking contract*


```solidity
function updateRewardsPerTokenStakedAddressPerTimeUnit(
    address _stakedToken,
    uint128[7] calldata _rewardsPerTimeUnitPerTokenStaked
) external appAdministratorOnly(address(appManager));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakedToken`|`address`|address of the token to be staked|
|`_rewardsPerTimeUnitPerTokenStaked`|`uint128[7]`|yield array. This specifies the amount of reward tokens yielded per staked token per unit of time. Therefore this array MUST follow the same structure as the TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years].|


### addNewStakingCollectionAddress

*function adds additional approved staking ERC721 collections*


```solidity
function addNewStakingCollectionAddress(address _stakedToken, uint128[7] calldata _rewardsPerTimeUnitPerTokenStaked)
    external
    appAdministratorOnly(address(appManager));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakedToken`|`address`|address of the NFT collection of the token to be claimed|
|`_rewardsPerTimeUnitPerTokenStaked`|`uint128[7]`|yield array. This specifies the amount of reward tokens yielded per staked token per unit of time. Therefore this array MUST follow the same structure as the TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years].|


### onERC721Received


```solidity
function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data)
    external
    pure
    returns (bytes4);
```

## Errors
### InputArraysMustHaveSameLength

```solidity
error InputArraysMustHaveSameLength();
```

## Structs
### Stake

```solidity
struct Stake {
    uint256 tokenId;
    uint256 stakingSince;
    uint8 stakingForUnitsOfTime;
    uint8 unitsOfTime;
    uint128 rewardsPerTimeUnitPerTokenIdStaked;
    address tokenAddress;
}
```


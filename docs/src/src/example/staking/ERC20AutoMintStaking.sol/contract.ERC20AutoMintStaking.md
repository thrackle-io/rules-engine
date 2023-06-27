# ERC20AutoMintStaking
[Git Source](https://github.com/thrackle-io/Tron/blob/68f4a826ed4aff2c87e6d1264dce053ee793c987/src/example/staking/ERC20AutoMintStaking.sol)

**Inherits:**
[IERC20Staking](/src/staking/IERC20Staking.sol/abstract.IERC20Staking.md), Context, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract automatically mints reward tokens for users upon claim. Reward is calculated in stake function.

*This is an example of a staking contract for ERC20 tokens where the reward token
is different from the staking token.*


## State Variables
### appManager

```solidity
IAppManager appManager;
```


### rewardToken

```solidity
ApplicationERC20 rewardToken;
```


### stakedToken
tokens


```solidity
IERC20 public stakedToken;
```


### totalStaked
contract balances


```solidity
uint256 public totalStaked;
```


### minimumAmount
rules
minimumAmount rule value


```solidity
uint256 public minimumAmount;
```


### rewardsPerTimeUnitPerMillStaked
rewardsPerTimeUnitPerMillStaked rule value

it should be in the same order as TIME_UNITS_TO_SECS:
[secs, mins, hours, days, weeks, 30-day months, 365-day years]


```solidity
uint128[7] public rewardsPerTimeUnitPerMillStaked;
```


### stakesPerAddress
stakes per address @notice that stakes are stored in an array


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
constructor(address _rewardTokenAddress, address _stakingTokenAddress, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rewardTokenAddress`|`address`|ERC20 token address that will be delivered as rewards for staking|
|`_stakingTokenAddress`|`address`|ERC20 token address to stake for rewards|
|`_appManagerAddress`|`address`|address of the application AppManager.|


### stake

that you can stake more than once. Each stake can be for a different time period and with different
amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.

this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
enough reward tokens in the contract to pay you.

*stake your tokens*


```solidity
function stake(uint256 amount, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime) external override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|to stake in smallest staking-ERC20-token unit (most use 18 decimals, so 1 = 1/10^18)|
|`_unitsOfTime`|`uint8`|references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]|
|`_stakingForUnitsOfTime`|`uint8`|amount of (secs/mins/days/weeks/months/years) to stake for.|


### claimRewards

enforce minimum-stake rule
making sure the stake inputs makes sense
transferring tokens to start staking
we get the rewards rate from the rules
we create the the stake object
we calculate this stake rewards to do some checks and updates
the contract will revert if this stake will yield zero rewards
finally, we update the total amount staked in this contract
and we store the stake in the array for the staker

that you will get all of your rewards available in the contract, and expired stakes will
be erased once claimed. Your available stakes to withdraw will also be updated.

*claim your available rewards*


```solidity
function claimRewards() external override;
```

### _removeStake

we initialize rewards variable
we initialize freed stakes
we initialize iterator
we will loop through the stake array until the end
we create flag for the following while loop
we will remain in the same position of the array as long as we keep finding expired stakes here, since
we are deleting expired stakes in the process which will replace the stake in this position with the
last stake in the array.
we retrieve the stake at current position
if this stake is ready for claim
we accumulate this stake rewards
we update the stake available for withdrawal
we remove this stake
if current position didn't cointain a stake ready for claim, then we pass to the next position.
if there are no rewards owed to user, then transaction will fail
finally, the contract pays the staker

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


### updateMinStakeAllowed

*update the minimumAmount rule for this staking contract*


```solidity
function updateMinStakeAllowed(uint256 _minimumAmount) external appAdministratorOnly(address(appManager));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minimumAmount`|`uint256`|minimum amount to stake in this rule|


### updateRewardsPerMillStakedPerTimeUnit

that rewards must be specified in the smallest unit of the reward token, and the million staked
tokens are also in the smallest units of the staked token. Most ERC20s use 18 decimals, so 1 -> 1/10^18.

*update the APY (indirectly) for this staking contract*


```solidity
function updateRewardsPerMillStakedPerTimeUnit(uint128[7] calldata _rewardsPerTimeUnitPerMillStaked)
    external
    appAdministratorOnly(address(appManager));
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rewardsPerTimeUnitPerMillStaked`|`uint128[7]`|yield array. This specifies the amount of reward tokens yielded per million units of staked tokens per unit of time. Therefore this array MUST follow the same structure as the TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years].|


## Structs
### Stake

```solidity
struct Stake {
    uint256 staked;
    uint256 stakingSince;
    uint8 stakingForUnitsOfTime;
    uint8 unitsOfTime;
    uint128 rewardsPerTimeUnitPerMillStaked;
}
```


# IERC20Staking
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/staking/IERC20Staking.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*abstract contract was needed instead of an Interface so we can store
the TIME_UNITS_TO_SECS 'constant'*


## State Variables
### TIME_UNITS_TO_SECS
constant array for time units MOVE TO ABSTRACT CONTRACT


```solidity
uint32[] TIME_UNITS_TO_SECS = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];
```


## Functions
### stake

that you can stake more than once. Each stake can be for a different time period and with different
amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.

this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
enough reward tokens in the contract to pay you after staking.

*stake your tokens*


```solidity
function stake(uint256 amount, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime) external virtual;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|to stake in smallest staking-ERC20-token unit (most use 18 decimals, so 1 = 1/10^18)|
|`_unitsOfTime`|`uint8`|references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]|
|`_stakingForUnitsOfTime`|`uint8`|amount of (secs/mins/days/weeks/months/years) to stake for.|


### claimRewards

that you will get all of your rewards available in the contract, and expaired stakes will
be erased once claimed. Your available stakes to withdraw will also be updated.

*claim your available rewards*


```solidity
function claimRewards() external virtual;
```

### calculateRewards

*helper function for frontend that gets available rewards for a staker*


```solidity
function calculateRewards(address staker) external view virtual returns (uint256 rewards);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`staker`|`address`|address of the staker to get available rewards|


## Events
### NewStake

```solidity
event NewStake(
    address indexed staker, uint256 indexed staked, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince
);
```

### RewardsClaimed

```solidity
event RewardsClaimed(
    address indexed staker, uint256 indexed staked, uint256 rewards, uint256 indexed stakingSince, uint256 date
);
```

### StakeWithdrawal

```solidity
event StakeWithdrawal(address indexed staker, uint256 indexed amount, uint256 date);
```

## Errors
### DepositFailed

```solidity
error DepositFailed();
```

### NotStakingEnough

```solidity
error NotStakingEnough(uint256 minStake);
```

### NotStakingForAnyTime

```solidity
error NotStakingForAnyTime();
```

### RewardPoolLow

```solidity
error RewardPoolLow(uint256 balance);
```

### NoRewardsToClaim

```solidity
error NoRewardsToClaim();
```

### RewardsWillBeZero

```solidity
error RewardsWillBeZero();
```

### InvalidTimeUnit

```solidity
error InvalidTimeUnit();
```


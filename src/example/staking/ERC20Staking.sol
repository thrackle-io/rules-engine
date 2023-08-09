// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/utils/Context.sol";
import "../../staking/IERC20Staking.sol";
import "../../economic/AppAdministratorOnly.sol";
import "../../application/IAppManager.sol";

/**
 * @title ERC20 Staking Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This is an example of a staking contract for ERC20 tokens where the reward token
 * is different from the staking token.
 */
contract ERC20Staking is IERC20Staking, Context, AppAdministratorOnly {
    /// tokens
    IERC20 public rewardToken;
    IERC20 public stakedToken;

    /// contract balances
    uint256 public totalStaked;
    uint256 public totalRewardsOwed;

    /// rules
    /// minimumAmount rule value
    uint256 public minimumAmount;
    /// rewardsPerTimeUnitPerMillStaked rule value
    /// @notice it should be in the same order as TIME_UNITS_TO_SECS:
    /// [secs, mins, hours, days, weeks, 30-day months, 365-day years]
    uint128[7] public rewardsPerTimeUnitPerMillStaked;

    IAppManager appManager;

    struct Stake {
        uint256 staked;
        uint256 stakingSince;
        uint8 stakingForUnitsOfTime;
        uint8 unitsOfTime; // sec, min, hour, day, week, month, year, decade, century
        uint128 rewardsPerTimeUnitPerMillStaked;
    }

    /** stakes per address @notice that stakes are stored in an array */
    mapping(address => Stake[]) public stakesPerAddress;
    mapping(address => uint256) public totalStakedPerAddress;

    /**
     * @dev constructor
     * @param _rewardTokenAddress ERC20 token address that will be delivered as rewards for staking
     * @param _stakingTokenAddress ERC20 token address to stake for rewards
     * @param _appManagerAddress address of the application AppManager.
     * @notice that rules can change at any time, but it won't affect past staking processes. It would
     * only affect future staking.
     */
    constructor(address _rewardTokenAddress, address _stakingTokenAddress, address _appManagerAddress) {
        rewardToken = IERC20(_rewardTokenAddress);
        stakedToken = IERC20(_stakingTokenAddress);
        appManager = IAppManager(_appManagerAddress);
        emit ERC20StakingFixedDeployed(_appManagerAddress, _stakingTokenAddress, _rewardTokenAddress, false);
    }

    /**
     * @dev stake your tokens
     * @param amount to stake in smallest staking-ERC20-token unit (most use 18 decimals, so 1 = 1/10^18)
     * @param _unitsOfTime references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]
     * @param _stakingForUnitsOfTime amount of (secs/mins/days/weeks/months/years) to stake for.
     * @notice that you can stake more than once. Each stake can be for a different time period and with different
     * amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.
     * @notice this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
     * enough reward tokens in the contract to pay you.
     */
    function stake(uint amount, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime) external override {
        /// enforce minimum-stake rule
        if (amount == 0 || amount < minimumAmount) revert NotStakingEnough(minimumAmount);
        /// making sure the stake input makes sense
        if (_stakingForUnitsOfTime == 0) revert NotStakingForAnyTime();
        /// transferring tokens to start staking
        if (!stakedToken.transferFrom(_msgSender(), address(this), amount)) revert DepositFailed();
        if (_unitsOfTime > 6) revert InvalidTimeUnit();
        /// we get the rewards rate from the rules
        uint128 _rewardRate = rewardsPerTimeUnitPerMillStaked[_unitsOfTime];
        /// we create the the stake object
        Stake memory newStake = Stake(amount, block.timestamp, _stakingForUnitsOfTime, _unitsOfTime, _rewardRate);
        /// we calculate this stake rewards to do some checks and updates
        uint256 thisStakeRewards = (uint256(_stakingForUnitsOfTime) * amount * uint256(_rewardRate)) / 1_000_000;
        /// the contract will revert if this stake will yield zero rewards
        if (thisStakeRewards == 0) revert RewardsWillBeZero();
        /// we update the total amount of rewards we owe to stakers;
        totalRewardsOwed += thisStakeRewards;
        /// we make sure that we have enough reward tokens to pay for this stake
        if (totalRewardsOwed > rewardToken.balanceOf(address(this))) revert RewardPoolLow(rewardToken.balanceOf(address(this)));
        /// finally, we update the total amount staked in this contract
        totalStaked += amount;
        totalStakedPerAddress[_msgSender()] += amount;
        /// and we store the stake in the array for the staker
        stakesPerAddress[_msgSender()].push(newStake);
        emit NewStake(_msgSender(), amount, uint256(_stakingForUnitsOfTime) * uint256(TIME_UNITS_TO_SECS[_unitsOfTime]), block.timestamp);
    }

    /**
     * @dev claim your available rewards
     * @notice that you will get all of your rewards available in the contract, and expired stakes will
     * be erased once claimed. Your available stakes to withdraw will also be updated.
     */
    function claimRewards() external override {
        /// we initialize rewards variable
        uint256 rewards;
        /// we initialize freed stakes
        uint256 availableToWithdraw;
        /// we initialize iterator
        uint256 i;
        /// we will loop through the stake array until the end
        while (i < stakesPerAddress[_msgSender()].length) {
            /// we create flag for the following while loop
            bool exit;
            /// we will remain in the same position of the array as long as we keep finding expired stakes here, since
            /// we are deleting expired stakes in the process which will replace the stake in this position with the
            /// last stake in the array.
            while (stakesPerAddress[_msgSender()].length > 0 && i < stakesPerAddress[_msgSender()].length && !exit) {
                /// we retrieve the stake at current position
                Stake memory _stake = stakesPerAddress[_msgSender()][i];
                /// if this stake is ready for claim
                if ((block.timestamp - _stake.stakingSince) >= (uint256(TIME_UNITS_TO_SECS[_stake.unitsOfTime]) * uint256(_stake.stakingForUnitsOfTime))) {
                    /// we accumulate this stake rewards
                    rewards += (uint256(_stake.stakingForUnitsOfTime) * _stake.staked * uint256(_stake.rewardsPerTimeUnitPerMillStaked)) / 1_000_000;
                    /// we update the stake available for withdrawal
                    availableToWithdraw += _stake.staked;
                    /// we remove this stake
                    _removeStake(i);
                    emit RewardsClaimedERC20(_msgSender(), _stake.staked, rewards, _stake.stakingSince);
                } else {
                    /// if current position didn't cointain a stake ready for claim, then we pass to the next position.
                    exit = true;
                }
            }
            unchecked {
                ++i;
            }
        }
        /// if there are no rewards available, then transaction will fail
        if (rewards == 0) revert NoRewardsToClaim();
        /// we update the total rewards the contract owes to stakers
        totalRewardsOwed -= rewards;
        totalStaked -= availableToWithdraw;
        totalStakedPerAddress[_msgSender()] -= availableToWithdraw;
        /// finally, the contract pays the staker
        rewardToken.transfer(_msgSender(), rewards);
        stakedToken.transfer(_msgSender(), availableToWithdraw);
        emit StakeWithdrawal(_msgSender(), availableToWithdraw, block.timestamp);
    }

    /**
     * @dev internal function that takes care of deleting an expired stake
     * @param i index of the stake in the stake array to delete
     */
    function _removeStake(uint256 i) internal {
        Stake memory lastStake = stakesPerAddress[_msgSender()][stakesPerAddress[_msgSender()].length - 1];
        stakesPerAddress[_msgSender()][i] = lastStake;
        stakesPerAddress[_msgSender()].pop();
    }

    /**
     * @dev helper function for frontend that gets available rewards for a staker
     * @param staker address of the staker to get available rewards for
     */
    function calculateRewards(address staker) external view override returns (uint256 rewards) {
        for (uint256 i; i < stakesPerAddress[staker].length; ) {
            Stake memory _stake = stakesPerAddress[staker][i];
            if ((block.timestamp - _stake.stakingSince) >= (uint256(TIME_UNITS_TO_SECS[_stake.unitsOfTime]) * uint256(_stake.stakingForUnitsOfTime)))
                rewards += (uint256(_stake.stakingForUnitsOfTime) * _stake.staked * uint256(_stake.rewardsPerTimeUnitPerMillStaked)) / 1_000_000;
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev update the minimumAmount rule for this staking contract
     * @param _minimumAmount minimum amount to stake in this rule
     */
    function updateMinStakeAllowed(uint256 _minimumAmount) external appAdministratorOnly(address(appManager)) {
        minimumAmount = _minimumAmount;
    }

    /**
     * @dev update the APY (indirectly) for this staking contract
     * @param _rewardsPerTimeUnitPerMillStaked yield array. This specifies the amount of reward tokens yielded
     * per million units of staked tokens per unit of time. Therefore this array MUST follow the same structure
     * as the TIME_UNITS_TO_SECS:
     * [secs, mins, hours, days, weeks, 30-day months, 365-day years].
     * @notice that rewards must be specified in the smallest unit of the reward token, and the million staked
     * tokens are also in the smallest units of the staked token. Most ERC20s use 18 decimals, so 1 -> 1/10^18.
     */
    function updateRewardsPerMillStakedPerTimeUnit(uint128[7] calldata _rewardsPerTimeUnitPerMillStaked) external appAdministratorOnly(address(appManager)) {
        rewardsPerTimeUnitPerMillStaked = _rewardsPerTimeUnitPerMillStaked;
        emit RewardsPerTimeUnit(address(stakedToken), _rewardsPerTimeUnitPerMillStaked);
    }
}

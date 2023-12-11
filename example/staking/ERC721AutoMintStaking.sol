// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "src/client/staking/IERC721Staking.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/client/application/IAppManager.sol";
import "../ERC20/ApplicationERC20.sol";

/**
 * @title ERC721 Staking Contract that automatically mints reward tokens to user at claim.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This is an example of a staking contract for ERC721 tokens with ERC20 reward token minted at reward claim.
 * @notice This contract allows for staking of multiple ERC721 token collections asigned at construction or updated after deployment.
 */
contract ERC721AutoMintStaking is IERC721Staking, IERC721Receiver, Context, AppAdministratorOnly {
    IAppManager appManager;
    ApplicationERC20 rewardToken;
    /// Collections Addresses that can be staked
    address[] public stakedCollections;
    /// contract balances
    uint256 public totalStaked;

    error InputArraysMustHaveSameLength();

    /// rewardsPerTimeUnitPerTokenStaked rule value
    /// @notice it should be in the same order as TIME_UNITS_TO_SECS:
    /// [secs, mins, hours, days, weeks, 30-day months, 365-day years]
    /// Each NFT address may be staked at different rates
    mapping(address => uint128[7]) rewardsPerTimeUnitPerTokenAddressStaked;

    struct Stake {
        uint256 tokenId;
        uint256 stakingSince;
        uint8 stakingForUnitsOfTime;
        uint8 unitsOfTime; // sec, min, hour, day, week, month, year, decade, century
        uint128 rewardsPerTimeUnitPerTokenIdStaked;
        address tokenAddress;
    }

    /// Stakeable NFT Collection addresses
    mapping(address => bool) public stakeableCollections;
    /// Stakes per address @notice that stakes are stored in an array
    mapping(address => Stake[]) public stakesPerAddress;
    mapping(address => uint256) public totalStakedPerAddress;

    /**
     * @dev constructor
     * @param _rewardTokenAddress ERC20 token address that will be delivered as rewards for staking
     * @param _stakingTokenAddresses ERC721 address to stake for rewards
     * @param _rewardsPerAddress reward structure for each staked address
     * @param _appManagerAddress address of the application AppManager.
     * @notice that rules can change at any time, but it won't affect past staking processes. It would
     * only affect future staking.
     */
    constructor(address _rewardTokenAddress, address[] memory _stakingTokenAddresses, uint128[7][] memory _rewardsPerAddress, address _appManagerAddress) {
        if (_rewardsPerAddress.length != _stakingTokenAddresses.length) {
            revert InputArraysMustHaveSameLength();
        }
        rewardToken = ApplicationERC20(_rewardTokenAddress);
        appManager = IAppManager(_appManagerAddress);
        ///Assign each of the _stakingTokenAddresses to the mapping for approved staking addresses and set the rewards structure
        for (uint256 i; i < _stakingTokenAddresses.length; ++i) {
            stakeableCollections[_stakingTokenAddresses[i]] = true;
            ///load the reward structure too. This has to be done an element at a time since memory array not convertible to storage
            for (uint256 j; j < _rewardsPerAddress[i].length; ++j) {
                rewardsPerTimeUnitPerTokenAddressStaked[_stakingTokenAddresses[i]][j] = _rewardsPerAddress[i][j];
            }
        }
    }

    /**
     * @dev stake your tokens
     * @param stakedToken address of the NFT collection of the token to be staked
     * @param tokenId id of token to stake
     * @param _unitsOfTime references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]
     * @param _stakingForUnitsOfTime amount of (secs/mins/days/weeks/months/years) to stake for.
     * @notice that you can stake more than once. Each stake can be for a different time period and with different
     * amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.
     * @notice this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
     * enough reward tokens in the contract to pay you.
     */
    function stake(address stakedToken, uint tokenId, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime) external override {
        /// check stake time is valid
        if (_stakingForUnitsOfTime == 0) revert NotStakingForAnyTime();
        /// check that tokenId being staked is valid collection/class
        if (stakeableCollections[address(stakedToken)] != true) revert TokenNotValidToStake();
        if (_unitsOfTime > 6) revert InvalidTimeUnit();
        /// transferring tokens to start staking
        IERC721(stakedToken).safeTransferFrom(_msgSender(), address(this), tokenId);
        /// we get the rewards rate from the rules
        uint128 _rewardRate = rewardsPerTimeUnitPerTokenAddressStaked[stakedToken][_unitsOfTime];
        /// we create the the stake object
        Stake memory newStake = Stake(tokenId, block.timestamp, _stakingForUnitsOfTime, _unitsOfTime, _rewardRate, stakedToken);
        /// we calculate this stake rewards
        uint256 thisStakeRewards = uint256(_stakingForUnitsOfTime) * _rewardRate;
        /// the contract will revert if this stake will yield zero rewards
        if (thisStakeRewards == 0) revert RewardsWillBeZero();
        /// We update the total amount of tokens staked in this contract
        totalStaked += 1;
        totalStakedPerAddress[_msgSender()] += 1;
        /// and we store the stake in the array for the staker
        stakesPerAddress[_msgSender()].push(newStake);
        emit NewStake(_msgSender(), tokenId, uint256(_stakingForUnitsOfTime) * uint256(TIME_UNITS_TO_SECS[_unitsOfTime]), block.timestamp);
    }

    /**
     * @dev claim your available rewards
     * @notice that you will get all of your rewards available in the contract, and expired stakes will
     * be erased once claimed. Your available stakes to withdraw will also be updated.
     */
    function claimRewards() external override {
        /// initialize rewards variable
        uint256 rewards;
        /// we initialize freed stakes
        uint256 availableToWithdraw;
        /// initialize iterator
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
                    rewards += uint256(_stake.rewardsPerTimeUnitPerTokenIdStaked) * uint256(_stake.stakingForUnitsOfTime);
                    uint256 tokenId = _stake.tokenId;
                    address collection = _stake.tokenAddress;
                    /// We update the total amount of tokens staked in this contract
                    totalStaked -= 1;
                    availableToWithdraw += 1;
                    /// transfer staked token back to user
                    IERC721(collection).safeTransferFrom(address(this), _msgSender(), tokenId);
                    /// we remove this stake
                    _removeStake(i);
                    emit RewardsClaimed(_msgSender(), _stake.tokenId, rewards, _stake.stakingSince, block.timestamp);
                } else {
                    /// if current position didn't cointain a stake ready for claim, then we pass to the next position.
                    exit = true;
                }
            }
            unchecked {
                ++i;
            }
        }
        /// if there are no rewards owed to user, then transaction will fail
        if (rewards == 0) revert NoRewardsToClaim();
        /// Contract pays the staker
        rewardToken.mint(_msgSender(), rewards);
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
                rewards += uint256(_stake.rewardsPerTimeUnitPerTokenIdStaked) * uint256(_stake.stakingForUnitsOfTime);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev update the APY (indirectly) for this staking contract
     * @param _stakedToken address of the token to be staked
     * @param _rewardsPerTimeUnitPerTokenStaked yield array. This specifies the amount of reward tokens yielded
     * per staked token per unit of time. Therefore this array MUST follow the same structure
     * as the TIME_UNITS_TO_SECS:
     * [secs, mins, hours, days, weeks, 30-day months, 365-day years].
     * @notice that rewards must be specified in the smallest unit of the reward token, and the million staked
     * tokens are also in the smallest units of the staked token. Most ERC20s use 18 decimals, so 1 -> 1/10^18.
     */
    function updateRewardsPerTokenStakedAddressPerTimeUnit(address _stakedToken, uint128[7] calldata _rewardsPerTimeUnitPerTokenStaked) external appAdministratorOnly(address(appManager)) {
        rewardsPerTimeUnitPerTokenAddressStaked[_stakedToken] = _rewardsPerTimeUnitPerTokenStaked;
    }

    /**
     * @dev function adds additional approved staking ERC721 collections
     * @param _stakedToken address of the NFT collection of the token to be claimed
     * @param _rewardsPerTimeUnitPerTokenStaked yield array. This specifies the amount of reward tokens yielded
     * per staked token per unit of time. Therefore this array MUST follow the same structure
     * as the TIME_UNITS_TO_SECS:
     * [secs, mins, hours, days, weeks, 30-day months, 365-day years].
     */
    function addNewStakingCollectionAddress(address _stakedToken, uint128[7] calldata _rewardsPerTimeUnitPerTokenStaked) external appAdministratorOnly(address(appManager)) {
        stakeableCollections[_stakedToken] = true;
        rewardsPerTimeUnitPerTokenAddressStaked[_stakedToken] = _rewardsPerTimeUnitPerTokenStaked;
        emit NewStakingAddress(_stakedToken);
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return this.onERC721Received.selector;
    }
}

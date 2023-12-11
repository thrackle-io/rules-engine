// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title ERC721 Staking Contract Model
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev abstract contract was needed instead of an Interface so we can store
 * the TIME_UNITS_TO_SECS 'constant'
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { IStakingErrors, IERC721StakingErrors } from "src/common/IErrors.sol";

abstract contract IERC721Staking is IStakingErrors, IERC721StakingErrors{
    

    event NewStake(address indexed staker, uint256 indexed tokenId, uint256 stakingPeriodInSeconds, uint256 indexed stakingSince);
    event RewardsClaimed(address indexed staker, uint256 indexed tokenId, uint256 rewards, uint256 indexed stakingSince, uint256 date);
    event StakeWithdrawal(address indexed staker, uint256 indexed tokenId, uint256 date);
    event NewStakingAddress(address indexed newStakingAddress);

    /// constant array for time units
    uint32[] TIME_UNITS_TO_SECS = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];

    /**
     * @dev stake your tokens
     * @param stakedToken address of the NFT collection of the token to be staked
     * @param tokenId to stake
     * @param _unitsOfTime references TIME_UNITS_TO_SECS: [secs, mins, hours, days, weeks, 30-day months, 365-day years]
     * @param _stakingForUnitsOfTime amount of (secs/mins/days/weeks/months/years) to stake for.
     * @notice that you can stake more than once. Each stake can be for a different time period and with different
     * amount. Also, a different rule set (APY%, minimum stake) MIGHT apply.
     * @notice this contract won't let you stake if your rewards after staking are going to be zero, or if there isn't
     * enough reward tokens in the contract to pay you after staking.
     */
    function stake(address stakedToken, uint256 tokenId, uint8 _unitsOfTime, uint8 _stakingForUnitsOfTime) external virtual;

    /**
     * @dev claim your available rewards
     * @notice that you will get all of your rewards available in the contract, and expaired stakes will
     * be erased once claimed. Your available stakes to withdraw will also be updated.
     */
    function claimRewards() external virtual;

    /**
     * @dev helper function for frontend that gets available rewards for a staker
     * @param staker address of the staker to get available rewards
     */
    function calculateRewards(address staker) external view virtual returns (uint256 rewards);
}

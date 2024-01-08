// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/example/staking/ERC20Staking.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amountA of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC20StakingTest is TestCommonFoundry {
    ApplicationERC20 stakingCoin;
    ApplicationERC20 rewardCoin;
    ERC20Staking stakingContract;
    address _user1 = address(0xAAA);
    address _user2 = address(0xBBB);
    address _user3 = address(0xCCC);
    uint128[7] ruleAArray = [1, 60, 3600, 86400, 604800, 2592000, 31536000];
    uint128[7] ruleBArray = [0, 1, 60, 1440, 10080, 43200, 525600];
    uint256[7] timeUnits = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        // Create two tokens and mint a bunch
        stakingCoin = new ApplicationERC20("stakingCoin", "STK", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(stakingCoin), false);
        stakingCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationAppManager.registerToken("stakingCoin", address(stakingCoin));
        stakingCoin.mint(_user1, 2_000_000_000_000_000_000_000_000);

        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(applicationAppManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(rewardCoin), false);
        rewardCoin.connectHandlerToToken(address(applicationCoinHandler2));
        applicationAppManager.registerToken("rewardCoin", address(rewardCoin));

        stakingContract = new ERC20Staking(address(rewardCoin), address(stakingCoin), address(applicationAppManager));

        stakingContract.updateMinStakeAllowed(1000);
        stakingContract.updateRewardsPerMillStakedPerTimeUnit(ruleAArray); //1 per mill per sec -> 3153% APY

        rewardCoin.mint(address(stakingContract), 2_000_000_000_000);

        vm.warp(Blocktime);
    }

    function testStaking(uint72 amountA, uint72 amountB, uint8 _unitsOfTime, uint8 forXUnitsOfTime) public {
        vm.assume(forXUnitsOfTime > 0);
        vm.stopPrank();
        vm.startPrank(_user1);

        uint8 unitsOfTime = uint8((uint16(_unitsOfTime) * 6) / 252);
        forXUnitsOfTime = forXUnitsOfTime > 4 ? forXUnitsOfTime : 4;
        uint256 rewardsA = (uint256(forXUnitsOfTime) * amountA * uint256(ruleAArray[unitsOfTime])) / 1_000_000;
        uint256 rewardsB = (uint256(forXUnitsOfTime) * amountB * uint256(ruleBArray[unitsOfTime])) / 1_000_000;

        stakingCoin.approve(address(stakingContract), amountA);

        if (amountA < 1000 || rewardsA > 2_000_000_000_000 || rewardsA == 0) vm.expectRevert();
        stakingContract.stake(amountA, unitsOfTime, forXUnitsOfTime);
        switchToAppAdministrator();
        /// making sure that updating the rule after staking doesn't affect the past one
        stakingContract.updateMinStakeAllowed(2_000_000);
        stakingContract.updateRewardsPerMillStakedPerTimeUnit(ruleBArray); //1 per mill per minute -> 52.5%APY
        
        vm.stopPrank();
        vm.startPrank(_user1);
        if (amountA >= 1000 && rewardsA <= 2_000_000_000_000 && rewardsA != 0) {
            stakingContract.stakesPerAddress(_user1, 0);
            assertEq(stakingCoin.balanceOf(_user1), 2_000_000_000_000_000_000_000_000 - amountA);
            /// go to the middle of the staking period
            vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * uint256(ruleAArray[unitsOfTime]))) / 2);
            stakingCoin.approve(address(stakingContract), amountB);

            /// now we try to stake again another amount under different rules this time
            if (amountB < 2_000_000 || rewardsA + rewardsB > 2_000_000_000_000 || rewardsB == 0) vm.expectRevert();
            stakingContract.stake(amountB, unitsOfTime, forXUnitsOfTime);

            /// if we were able to stake again...
            if (amountB >= 2_000_000 && rewardsA + rewardsB <= 2_000_000_000_000 && rewardsB != 0) {
                stakingContract.stakesPerAddress(_user1, 1);
                /// go to the end of the first staking period
                vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) / 2 + 1);

                assertEq(rewardsA, stakingContract.calculateRewards(address(_user1)));
                //if(rewardsA == 0) vm.expectRevert();
                stakingContract.claimRewards();
                assertEq(rewardCoin.balanceOf(address(_user1)), rewardsA);
                vm.expectRevert();
                stakingContract.stakesPerAddress(_user1, 1);

                vm.expectRevert();
                stakingContract.claimRewards();

                vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) / 2 + 1);

                assertEq(rewardsB, stakingContract.calculateRewards(address(_user1)));
                // if(rewardsB + rewardsA > 200_000) vm.expectRevert();
                stakingContract.claimRewards();
                assertEq(rewardCoin.balanceOf(address(_user1)), rewardsA + rewardsB);
                vm.expectRevert();
                stakingContract.stakesPerAddress(_user1, 0);

                assertEq(stakingCoin.balanceOf(_user1), 2_000_000_000_000_000_000_000_000);
            }
        }
    }
}

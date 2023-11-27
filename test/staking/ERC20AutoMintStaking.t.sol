// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../../src/example/ERC20/ApplicationERC20.sol";
import "../../src/example/application/ApplicationAppManager.sol";
import "../../src/example/application/ApplicationHandler.sol";
import "../diamond/DiamondTestUtil.sol";

import "../../src/example/ERC20/ApplicationERC20Handler.sol";
import "../diamond/RuleProcessorDiamondTestUtil.sol";

import "../../src/example/staking/ERC20AutoMintStaking.sol";

import {TaggedRuleDataFacet} from "../../src/economic/ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title Test ERC20 Auto Mint Rewards Staking Contract
 * @notice This tests every function related to the ERC20 Auto Mint Rewards Staking Contract
 * @dev Rewards are calculated at stake and minted to user at claim.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC20AutoMintStakingTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC20 stakingCoin;
    ApplicationERC20 rewardCoin;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;

    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationAppManager appManager;

    ApplicationHandler public applicationHandler;

    ERC20AutoMintStaking stakingContract;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(0xAAA);
    address user2 = address(0xBBB);
    address user3 = address(0xCCC);
    address rich_user = address(0xDDD);
    uint256 Blocktime = 1675723152;
    uint128[7] ruleAArray = [1, 60, 3600, 86400, 604800, 2592000, 31536000];
    uint128[7] ruleBArray = [0, 1, 60, 1440, 10080, 43200, 525600];
    uint256[7] timeUnits = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];

    function setUp() public {
        vm.startPrank(superAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        // Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        // Deploy app manager
        appManager = new ApplicationAppManager(superAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        // Create two tokens and mint a bunch
        stakingCoin = new ApplicationERC20("stakingCoin", "STK", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), address(stakingCoin), false);
        stakingCoin.connectHandlerToToken(address(applicationCoinHandler));
        appManager.registerToken("stakingCoin", address(stakingCoin));
        stakingCoin.mint(user1, 2_000_000_000_000_000_000_000_000);

        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(appManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), address(rewardCoin), false);
        rewardCoin.connectHandlerToToken(address(applicationCoinHandler2));
        appManager.registerToken("rewardCoin", address(rewardCoin));
        stakingContract = new ERC20AutoMintStaking(address(rewardCoin), address(stakingCoin), address(appManager));

        stakingContract.updateMinStakeAllowed(1000);
        stakingContract.updateRewardsPerMillStakedPerTimeUnit(ruleAArray); //1 per mill per sec -> 3153% APY
        /// Register stakingContract for Minting
        appManager.registerStaking(address(stakingContract));
        vm.warp(Blocktime);
    }

    function testStakingAutoMinting() public {
        ///User1 stakes 10K tokens and transfer to User 2 & 3
        vm.stopPrank();
        vm.startPrank(user1);
        stakingCoin.transfer(user2, 10000);
        stakingCoin.transfer(user3, 12000);
        stakingCoin.approve(address(stakingContract), 20000);
        stakingContract.stake(10000, 3, 1); ///stake for 1 day

        ///User2 Stakes 5K
        vm.stopPrank();
        vm.startPrank(user2);
        stakingCoin.approve(address(stakingContract), 20000);
        stakingContract.stake(5000, 3, 1); ///stake for 1 day

        ///User3 Stakes 8K
        vm.stopPrank();
        vm.startPrank(user3);
        stakingCoin.approve(address(stakingContract), 20000);
        stakingContract.stake(8000, 3, 1); ///stake for 1 day

        ///Move time & CalulateRewards
        vm.warp(Blocktime + 1 days);

        uint256 user1Reward = stakingContract.calculateRewards(user1);
        uint256 user2Reward = stakingContract.calculateRewards(user2);
        uint256 user3Reward = stakingContract.calculateRewards(user3);
        console.log("User1 Reward Total =", user1Reward);
        console.log("User2 Reward Total =", user2Reward);
        console.log("User3 Reward Total =", user3Reward);

        ///User1 stakes 5k more
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(5000, 3, 1); ///stake for 1 day
        ///User2 stakes 5k more
        vm.stopPrank();
        vm.startPrank(user2);
        stakingContract.stake(5000, 3, 1); ///stake for 1 day
        ///User3 stakes 4K more
        vm.stopPrank();
        vm.startPrank(user3);
        stakingContract.stake(4000, 3, 1); ///stake for 1 day
        ///Move time, calculateRewards and Claim
        vm.warp(Blocktime + 2 days);

        uint256 user1Rewards = stakingContract.calculateRewards(user1);
        uint256 user2Rewards = stakingContract.calculateRewards(user2);
        uint256 user3Rewards = stakingContract.calculateRewards(user3);
        console.log("User1 Reward Total =", user1Rewards);
        console.log("User2 Reward Total =", user2Rewards);
        console.log("User3 Reward Total =", user3Rewards);
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.claimRewards();

        vm.stopPrank();
        vm.startPrank(user2);
        stakingContract.claimRewards();

        vm.stopPrank();
        vm.startPrank(user3);
        stakingContract.claimRewards();

        assertEq(rewardCoin.balanceOf(user1), user1Rewards);
        assertEq(rewardCoin.balanceOf(user2), user2Rewards);
        assertEq(rewardCoin.balanceOf(user3), user3Rewards);

        ///Prove that the staking contract holds no rewardCoin
        assertEq(rewardCoin.balanceOf(address(stakingContract)), 0);
    }

    function testStakingFuzz(uint72 amountA, uint72 amountB, uint8 _unitsOfTime, uint8 forXUnitsOfTime) public {
        vm.assume(forXUnitsOfTime > 0);
        vm.stopPrank();
        vm.startPrank(user1);

        uint8 unitsOfTime = uint8((uint16(_unitsOfTime) * 6) / 252);
        forXUnitsOfTime = forXUnitsOfTime > 4 ? forXUnitsOfTime : 4;
        uint256 rewardsA = (uint256(forXUnitsOfTime) * amountA * uint256(ruleAArray[unitsOfTime])) / 1_000_000;
        uint256 rewardsB = (uint256(forXUnitsOfTime) * amountB * uint256(ruleBArray[unitsOfTime])) / 1_000_000;

        stakingCoin.approve(address(stakingContract), amountA);

        if (amountA < 1000 || rewardsA == 0) vm.expectRevert();
        stakingContract.stake(amountA, unitsOfTime, forXUnitsOfTime);
        /// making sure that updating the rule after staking doesn't affect the past one
        stakingContract.updateMinStakeAllowed(2_000_000);
        stakingContract.updateRewardsPerMillStakedPerTimeUnit(ruleBArray); //1 per mill per minute -> 52.5%APY

        if (amountA >= 1000 && rewardsA != 0) {
            stakingContract.stakesPerAddress(user1, 0);
            assertEq(stakingCoin.balanceOf(user1), 2_000_000_000_000_000_000_000_000 - amountA);
            /// go to the middle of the staking period
            vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * uint256(ruleAArray[unitsOfTime]))) / 2);
            stakingCoin.approve(address(stakingContract), amountB);

            /// now we try to stake again another amount under different rules this time
            if (amountB < 2_000_000 || rewardsB == 0) vm.expectRevert();
            stakingContract.stake(amountB, unitsOfTime, forXUnitsOfTime);

            /// if we were able to stake again...
            if (amountB >= 2_000_000 && rewardsB != 0) {
                stakingContract.stakesPerAddress(user1, 1);
                /// go to the end of the first staking period
                vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) / 2 + 1);

                assertEq(rewardsA, stakingContract.calculateRewards(address(user1)));
                //if(rewardsA == 0) vm.expectRevert();
                stakingContract.claimRewards();
                assertEq(rewardCoin.balanceOf(address(user1)), rewardsA);
                vm.expectRevert();
                stakingContract.stakesPerAddress(user1, 1);

                vm.expectRevert();
                stakingContract.claimRewards();

                vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) / 2 + 1);

                assertEq(rewardsB, stakingContract.calculateRewards(address(user1)));
                // if(rewardsB + rewardsA > 200_000) vm.expectRevert();
                stakingContract.claimRewards();
                assertEq(rewardCoin.balanceOf(address(user1)), rewardsA + rewardsB);
                vm.expectRevert();
                stakingContract.stakesPerAddress(user1, 0);

                assertEq(stakingCoin.balanceOf(user1), 2_000_000_000_000_000_000_000_000);
            }
        }
    }
}

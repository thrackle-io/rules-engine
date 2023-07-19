// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC20.sol";
import {ApplicationERC721} from "../src/example/ApplicationERC721.sol";
import {ApplicationERC721A} from "../src/example/ApplicationERC721A.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC20Handler.sol";
import {ApplicationERC721Handler} from "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/example/staking/ERC721Staking.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title Test ERC721 Staking for multiple ERC721 Contracts with ERC20 rewards
 * @notice This tests the ERC721 Staking contract with pre-minted erc20 rewards
 * @dev A testNFT contract is created in set up to test adding a new ERC721 address for staking
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC721StakingTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC20 rewardCoin;
    ApplicationERC721 applicationNFT;
    ApplicationERC721A applicationNFTA;
    ApplicationERC721 testNFT;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationERC721Handler applicationNFTAHandler;
    ApplicationAppManager appManager;
    ERC721Staking stakingContract;
    ApplicationHandler public applicationHandler;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(0xAAA);
    address user2 = address(0xBBB);
    address user3 = address(0xCCC);
    address rich_user = address(0xDDD);
    uint256 Blocktime = 1675723152;
    uint128[7] ruleAArray = [1, 60, 3600, 86400, 604800, 2592000, 31536000];
    uint128[7] ruleBArray = [2, 120, 7200, 43200, 1209600, 5184000, 63072000];
    uint256[7] timeUnits = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];
    address[] applicationTokens;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// connect the appHandler to the appManager
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        /// deploying the ERC721  contract
        applicationNFT = new ApplicationERC721("PudgyParakeet", "THRK", address(appManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));

        appManager.registerToken("THRK", address(applicationNFT));
        /// deploy ERC721A contract
        applicationNFTA = new ApplicationERC721A("PudgyParakeet", "THRKA", address(appManager), "https://SampleApp.io");
        applicationNFTAHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), false);
        applicationNFTA.connectHandlerToToken(address(applicationNFTAHandler));
        appManager.registerToken("THRKA", address(applicationNFTA));
        // Create Reward Coin
        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), address(rewardCoin), false);
        rewardCoin.connectHandlerToToken(address(applicationCoinHandler));
        ///Create ERC721 Staking Contract
        applicationTokens = [address(applicationNFT), address(applicationNFTA)];
        uint128[7][] memory rewardsPerAddress = new uint128[7][](2);
        rewardsPerAddress[0] = ruleAArray;
        rewardsPerAddress[1] = ruleBArray;
        ///Test NFT for testing staking collection update function (not wired up to handlers)
        testNFT = new ApplicationERC721("TestOnly", "TST", address(appManager), "https://SampleApp.io");
        stakingContract = new ERC721Staking(address(rewardCoin), applicationTokens, rewardsPerAddress, address(appManager));

        rewardCoin.mint(address(stakingContract), 2_000_000_000_000);
        vm.warp(Blocktime);
    }

    function testConstructorLoop() public {
        bool address1 = stakingContract.stakeableCollections(address(applicationNFT));
        assertEq(address1, true);
        bool address2 = stakingContract.stakeableCollections(address(applicationNFTA));
        assertEq(address2, true);
        bool addressTest = stakingContract.stakeableCollections(address(testNFT));
        assertEq(addressTest, false);
    }

    function testConstructorInvalidSetup() public {
        ///Test NFT for testing staking collection update function (not wired up to handlers)
        ApplicationERC721 nft1 = new ApplicationERC721("TestOnly", "TST", address(appManager), "https://SampleApp.io");
        uint128[7][] memory rewardsPerAddress = new uint128[7][](1);
        rewardsPerAddress[0] = ruleAArray;
        // Create Reward Coin
        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(appManager));
        ///Create ERC721 Staking Contract
        applicationTokens = [address(nft1), address(applicationNFTA)];
        vm.expectRevert(0x028a6c58);
        stakingContract = new ERC721Staking(address(rewardCoin), applicationTokens, rewardsPerAddress, address(appManager));
    }

    function testStakingNFT() public {
        ///Mint NFTs and transfer to users
        setUpUsers();
        ///User 1 stakes NFTs
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(address(applicationNFT), 0, 3, 3);
        stakingContract.stake(address(applicationNFT), 1, 3, 3);
        ///Move forward to end of staking time
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        vm.warp(Blocktime + 2 weeks);
        ///Rewardcheck user 1
        uint256 userReward = stakingContract.calculateRewards(address(user1));
        console.log("user1 Reward =", userReward);
        ///Claim rewards and NFTs for all users
        vm.stopPrank();
        vm.startPrank(user1);
        ///collect reward tokens and 1 NFT
        stakingContract.claimRewards();
        assertEq(applicationNFT.balanceOf(user1), 2);
        uint256 balance = rewardCoin.balanceOf(user1);
        console.log("User1 Balance =", balance); ///balance literal: 518400 rewardCoin
        assertEq(rewardCoin.balanceOf(user1), 518400);

        ///stake multiple users for different times
        vm.warp(1675726752); /// 1675726752
        ///user 1 stakes
        applicationNFT.approve(address(stakingContract), 0);
        applicationNFT.approve(address(stakingContract), 1);
        stakingContract.stake(address(applicationNFT), 0, 1, 1);
        ///user 2 stakes
        vm.stopPrank();
        vm.startPrank(user2);
        stakingContract.stake(address(applicationNFT), 2, 2, 2);
        ///user 3 stakes
        vm.stopPrank();
        vm.startPrank(user3);
        stakingContract.stake(address(applicationNFT), 4, 3, 3);

        ///balance checks (each user should have applicationNFT balance of 1)
        assertEq(applicationNFT.balanceOf(user1), 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user3), 1);
        ///wait
        vm.warp(1675726752 + 1 hours);
        ///user 1 stakes again
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(address(applicationNFT), 1, 1, 1);
        ///wait
        vm.warp(1675726752 + 1 hours);
        ///Rewardcheck user 1
        uint256 user1reward = stakingContract.calculateRewards(address(user1));
        console.log("user1 Reward =", user1reward);
        ///user 2 and 3 stake again
        vm.stopPrank();
        vm.startPrank(user2);
        stakingContract.stake(address(applicationNFT), 3, 2, 2);
        ///user 3 stakes
        vm.stopPrank();
        vm.startPrank(user3);
        stakingContract.stake(address(applicationNFT), 5, 3, 3);

        vm.warp(1675726752 + 1 weeks);
        ///Rewardcheck user 1
        stakingContract.calculateRewards(address(user1));
        ///finish time and withdrawals
        vm.warp(1675726752 + 2 weeks);
        ///CalculateRewards check
        uint256 user1rewards = stakingContract.calculateRewards(address(user1));
        uint256 user2rewards = stakingContract.calculateRewards(address(user2));
        uint256 user3rewards = stakingContract.calculateRewards(address(user3));
        console.log("user1 Rewards =", user1rewards);
        console.log("user2 Rewards =", user2rewards);
        console.log("user3 Rewards =", user3rewards);

        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.claimRewards();
        assertEq(applicationNFT.balanceOf(user1), 2);
        uint256 newBalance = rewardCoin.balanceOf(user1);
        console.log("User1 Balance =", newBalance); ///balance expected: 518520 rewardCoin
        assertEq(rewardCoin.balanceOf(user1), 518520);

        ///User 2 withdrawals
        vm.stopPrank();
        vm.startPrank(user2);
        stakingContract.claimRewards();
        assertEq(applicationNFT.balanceOf(user2), 2);
        uint256 user2Balance = rewardCoin.balanceOf(user2);
        console.log("User2 Balance =", user2Balance); ///balance expected: 14400 rewardCoin
        // stakingContract.claimAvailableTokens(address(applicationNFT), 3);
        // assertEq(applicationNFT.balanceOf(user2), 2);
        assertEq(rewardCoin.balanceOf(user2), 14400);
        ///User 3 withdrawals
        vm.stopPrank();
        vm.startPrank(user3);
        stakingContract.claimRewards();
        assertEq(applicationNFT.balanceOf(user3), 2);
        uint256 user3Balance = rewardCoin.balanceOf(user3);
        console.log("User3 Balance =", user3Balance); ///balance expected: 518400 rewardCoin
        // stakingContract.claimAvailableTokens(address(applicationNFT), 5);
        // assertEq(applicationNFT.balanceOf(user3), 2);
        assertEq(rewardCoin.balanceOf(user3), 518400);
        ///Ensure calculateReward to claimReward parity
        assertEq(rewardCoin.balanceOf(user1), user1rewards + balance); ///User1 balance carries over from first stake
        assertEq(rewardCoin.balanceOf(user2), user2rewards);
        assertEq(rewardCoin.balanceOf(user3), user3rewards);

        ///Failure cases
        ///try to claim before stake period is finished
        vm.warp(1676932752);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.approve(address(stakingContract), 0);
        applicationNFT.approve(address(stakingContract), 1);
        stakingContract.stake(address(applicationNFT), 0, 3, 3);

        vm.warp(1676932752 + 1 hours);
        vm.expectRevert(0x73380d99);
        stakingContract.claimRewards();

        ///try to claim tokenId that isn't yours
        vm.warp(1676932752 + 2 weeks);
        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x73380d99);
        stakingContract.claimRewards();
    }

    function setUpUsers() public {
        ///ApplicationERC721
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user2);
        applicationNFT.safeMint(user2);
        applicationNFT.safeMint(user3);
        applicationNFT.safeMint(user3);
        assertEq(applicationNFT.balanceOf(user1), 2);
        assertEq(applicationNFT.balanceOf(user2), 2);
        assertEq(applicationNFT.balanceOf(user3), 2);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTA.mint(1);
        applicationNFT.approve(address(stakingContract), 0);
        applicationNFT.approve(address(stakingContract), 1);
        applicationNFTA.approve(address(stakingContract), 0);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTA.mint(1);
        applicationNFT.approve(address(stakingContract), 2);
        applicationNFT.approve(address(stakingContract), 3);
        applicationNFTA.approve(address(stakingContract), 1);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFTA.mint(1);
        applicationNFT.approve(address(stakingContract), 4);
        applicationNFT.approve(address(stakingContract), 5);
        applicationNFTA.approve(address(stakingContract), 2);
    }

    function testApplicationERC721AStakingNFT() public {
        ///Mint NFTs and transfer to users
        setUpUsers();
        ///User 1 stakes NFTs
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(address(applicationNFTA), 0, 3, 2);
        ///Move forward to end of staking time
        vm.warp(Blocktime + 2 weeks);
        ///collect reward tokens and 1 NFT
        stakingContract.claimRewards();
        assertEq(applicationNFTA.balanceOf(user1), 1);
        uint256 balance = rewardCoin.balanceOf(user1);
        console.log("User1 Balance =", balance); ///balance expected: 259200 rewardCoin
        assertEq(rewardCoin.balanceOf(user1), 86400);
    }

    function testAdminFunction() public {
        stakingContract.addNewStakingCollectionAddress(address(testNFT), ruleAArray);
        stakingContract.updateRewardsPerTokenStakedAddressPerTimeUnit(address(testNFT), ruleBArray);
    }

    function testERC721StakingFuz(uint8 _unitsOfTime, uint8 forXUnitsOfTime) public {
        ///Mint NFTs and transfer to users
        setUpUsers();
        vm.assume(forXUnitsOfTime > 0);
        uint8 unitsOfTime = uint8((uint16(_unitsOfTime) * 6) / 252);
        forXUnitsOfTime = forXUnitsOfTime > 4 ? forXUnitsOfTime : 4;
        uint256 rewardsA = (uint256(forXUnitsOfTime) * uint256(ruleAArray[unitsOfTime]));

        vm.stopPrank();
        vm.startPrank(user1);
        if (rewardsA > 2_000_000_000_000 || rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFT), 0, unitsOfTime, forXUnitsOfTime);
        if (rewardsA <= 2_000_000_000_000 && rewardsA != 0) {
            stakingContract.stake(address(applicationNFT), 1, unitsOfTime, forXUnitsOfTime);
            vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) + 1);
            stakingContract.claimRewards();
        }
        ///test multiple stakers for multiple times
        vm.stopPrank();
        vm.startPrank(user2);
        if (rewardsA > 2_000_000_000_000 || rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFT), 2, unitsOfTime, forXUnitsOfTime);
        if (rewardsA <= 2_000_000_000_000 && rewardsA != 0) {
            stakingContract.stake(address(applicationNFT), 3, unitsOfTime, forXUnitsOfTime);
        }
        vm.stopPrank();
        vm.startPrank(user3);
        if (rewardsA > 2_000_000_000_000 || rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFTA), 2, unitsOfTime, forXUnitsOfTime);
        if (rewardsA <= 2_000_000_000_000 && rewardsA != 0) {
            stakingContract.stake(address(applicationNFT), 5, unitsOfTime, forXUnitsOfTime);
        }
        /// try and claim before time is done
        vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * uint256(ruleAArray[unitsOfTime]))) / 2);
        ///User 3
        vm.expectRevert();
        stakingContract.claimRewards();
        ///User 2
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        stakingContract.claimRewards();
        ///skip to end of stake and claim
        vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) / 2 + 1);
        ///User 2 claims
        uint256 user2Rewards = stakingContract.calculateRewards(address(user2));
        stakingContract.claimRewards();
        assertEq(rewardCoin.balanceOf(user2), user2Rewards);
        ///User 3 Claims
        vm.stopPrank();
        vm.startPrank(user3);
        uint256 user3Rewards = stakingContract.calculateRewards(address(user3));
        stakingContract.claimRewards();
        assertEq(rewardCoin.balanceOf(user3), user3Rewards);
    }
}

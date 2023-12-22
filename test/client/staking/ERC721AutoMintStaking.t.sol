// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/example/staking/ERC721AutoMintStaking.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title Test ERC721 Staking for multiple ERC721 Contracts with ERC20 rewards that are minted at claim.
 * @notice This tests the ERC721 Staking contract with erc20 rewards minted at claim.
 * @dev A testNFT contract is created in set up to test adding a new ERC721 address for staking
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC721AutoMintStakingTest is TestCommonFoundry {
    ApplicationERC20 rewardCoin;
    ApplicationERC721 applicationNFTA;
    ApplicationERC721Handler applicationNFTAHandler;
    ApplicationERC721 testNFT;
    ERC721AutoMintStaking stakingContract;
    uint128[7] ruleAArray = [1, 60, 3600, 86400, 604800, 2592000, 31536000];
    uint128[7] ruleBArray = [2, 120, 7200, 43200, 1209600, 5184000, 63072000];
    uint256[7] timeUnits = [1, 1 minutes, 1 hours, 1 days, 1 weeks, 30 days, 365 days];
    address[] applicationTokens;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        /// deploying the ERC721  contract
        applicationNFT = new ApplicationERC721("PudgyParakeet", "THRK", address(applicationAppManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFT), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));

        applicationAppManager.registerToken("THRK", address(applicationNFT));
        /// deploy ERC721A contract
        applicationNFTA = new ApplicationERC721("PudgyParakeet", "THRKA", address(applicationAppManager), "https://SampleApp.io");
        applicationNFTAHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFTA), false);
        applicationNFTA.connectHandlerToToken(address(applicationNFTAHandler));
        applicationNFTAHandler.setERC721Address(address(applicationNFTA));
        applicationAppManager.registerToken("THRKA", address(applicationNFTA));
        // Create Reward Coin
        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(rewardCoin), false);
        rewardCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationAppManager.registerToken("rewardCoin", address(rewardCoin));
        ///Create ERC721 Staking Contract
        applicationTokens = [address(applicationNFT), address(applicationNFTA)];
        uint128[7][] memory rewardsPerAddress = new uint128[7][](2);
        rewardsPerAddress[0] = ruleAArray;
        rewardsPerAddress[1] = ruleBArray;
        ///Test NFT for testing staking collection update function (not wired up to handlers)
        testNFT = new ApplicationERC721("TestOnly", "TST", address(applicationAppManager), "https://SampleApp.io");
        testNFT.connectHandlerToToken(address(new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(testNFT), false)));
        stakingContract = new ERC721AutoMintStaking(address(rewardCoin), applicationTokens, rewardsPerAddress, address(applicationAppManager));

        /// Register stakingContract for Minting
        applicationAppManager.registerStaking(address(stakingContract));
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
        ApplicationERC721 nft1 = new ApplicationERC721("TestOnly", "TST", address(applicationAppManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));
        uint128[7][] memory rewardsPerAddress = new uint128[7][](1);
        rewardsPerAddress[0] = ruleAArray;
        // Create Reward Coin
        rewardCoin = new ApplicationERC20("rewardCoin", "RWD", address(applicationAppManager));
        ///Create ERC721 Staking Contract
        applicationTokens = [address(nft1), address(applicationNFTA)];
        vm.expectRevert(0x028a6c58);
        stakingContract = new ERC721AutoMintStaking(address(rewardCoin), applicationTokens, rewardsPerAddress, address(applicationAppManager));
    }

    function testStakingNftAutoMint() public {
        ///Mint NFTs and transfer to users
        setUpUsers();
        ///User 1 stakes NFTs
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(address(applicationNFT), 0, 3, 3);
        stakingContract.stake(address(applicationNFT), 1, 3, 3);
        ///Move forward to end of staking time
        vm.stopPrank();
        vm.startPrank(superAdmin);
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

        applicationNFTA.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.approve(address(stakingContract), 0);
        applicationNFT.approve(address(stakingContract), 1);
        applicationNFTA.approve(address(stakingContract), 0);

        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationNFTA.safeMint(user2);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.approve(address(stakingContract), 2);
        applicationNFT.approve(address(stakingContract), 3);
        applicationNFTA.approve(address(stakingContract), 1);

        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationNFTA.safeMint(user3);
        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFT.approve(address(stakingContract), 4);
        applicationNFT.approve(address(stakingContract), 5);
        applicationNFTA.approve(address(stakingContract), 2);
    }

    function testMultiCollectionStaking() public {
        ///Mint NFTs and transfer to users
        setUpUsers();
        ///User 1 stakes NFTs with same tokenID from different collections
        vm.stopPrank();
        vm.startPrank(user1);
        stakingContract.stake(address(applicationNFTA), 0, 3, 3);
        stakingContract.stake(address(applicationNFT), 0, 2, 1);
        vm.warp(Blocktime + 2 days); /// Wait longe enough for second stake to expire but not the first
        stakingContract.claimRewards();
        assertEq(applicationNFTA.balanceOf(user1), 0);
        assertEq(applicationNFT.balanceOf(user1), 2); /// Prove that only the collection that has expired stake is withdrawn
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
        if (rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFT), 0, unitsOfTime, forXUnitsOfTime);
        if (rewardsA != 0) {
            stakingContract.stake(address(applicationNFT), 1, unitsOfTime, forXUnitsOfTime);
            vm.warp(block.timestamp + ((uint256(forXUnitsOfTime) * timeUnits[unitsOfTime])) + 1);
            stakingContract.claimRewards();
        }
        ///test multiple stakers for multiple times
        vm.stopPrank();
        vm.startPrank(user2);
        if (rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFT), 2, unitsOfTime, forXUnitsOfTime);
        if (rewardsA <= 2_000_000_000_000 && rewardsA != 0) {
            stakingContract.stake(address(applicationNFT), 3, unitsOfTime, forXUnitsOfTime);
        }
        vm.stopPrank();
        vm.startPrank(user3);
        if (rewardsA == 0) vm.expectRevert();
        stakingContract.stake(address(applicationNFTA), 2, unitsOfTime, forXUnitsOfTime);
        if (rewardsA != 0) {
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

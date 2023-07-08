// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC721A.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";

import "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";

import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";

contract ERC721ATest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC721A applicationNFT;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;

    ApplicationERC721Handler applicationNFTHandler;
    ApplicationAppManager appManager;

    ApplicationHandler public applicationHandler;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address ac;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        // Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        // Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);

        applicationNFT = new ApplicationERC721A("PudgyParakeet", "THRK", address(appManager), "https://SampleApp.io");
        applicationNFTHandler = ApplicationERC721Handler(applicationNFT.handlerAddress());
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));
    }

    function testMintA() public {
        applicationNFT.mint(1);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 1);
    }

    function testTransfer() public {
        applicationNFT.mint(1);
        applicationNFT.transferFrom(defaultAdmin, appAdministrator, 0);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 1);
    }

    function testPassMinMaxAccountBalanceRule() public {
        // mint 6 NFTs to defaultAdmin for transfer
        applicationNFT.mint(6);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 6);

        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(1);
        max[0] = uint256(6);

        // set up a non admin user with tokens
        //transfer tokenId 0 and 1 to rich_user
        applicationNFT.safeTransferFrom(defaultAdmin, rich_user, 1);
        applicationNFT.transferFrom(defaultAdmin, rich_user, 2);
        assertEq(applicationNFT.balanceOf(rich_user), 2);

        //transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(defaultAdmin, user1, 3);
        applicationNFT.transferFrom(defaultAdmin, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);

        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);

        //Add GeneralTag to account
        appManager.addGeneralTag(user1, "Oscar"); //add tag
        assertTrue(appManager.hasTag(user1, "Oscar"));
        appManager.addGeneralTag(user2, "Oscar"); //add tag
        assertTrue(appManager.hasTag(user2, "Oscar"));
        appManager.addGeneralTag(user3, "Oscar"); //add tag
        assertTrue(appManager.hasTag(user3, "Oscar"));
        //perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);

        //update ruleId in application NFT handler
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationNFTHandler.setMinMaxBalanceRuleId(ruleId);
        // make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        applicationNFT.transferFrom(user1, user3, 4);

        //make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        //user1 mints to 6 total (limit)
        applicationNFT.mint(6);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.mint(1);
        //transfer to user1 to exceed limit
        vm.expectRevert(0x24691f6b);
        applicationNFT.transferFrom(user2, user1, 3);
    }
}

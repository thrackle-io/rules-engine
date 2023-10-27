// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {TaggedRuleDataFacet} from "src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/economic/ruleStorage/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/economic/ruleStorage/AppRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "src/economic/ruleStorage/RuleDataInterfaces.sol";

import "src/example/ERC1155/ApplicationERC1155.sol";
import "src/example/ERC1155/ApplicationERC1155Handler.sol";

import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";

import "test/helpers/TestCommonFoundry.sol";

contract ApplicationERC1155Test is TestCommonFoundry {
    ApplicationERC1155Handler applicationERC1155Handler;
    ApplicationERC1155 applicationERC1155;

    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;

    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address user4 = address(44);
    address user5 = address(55);
    address user6 = address(66);
    address user7 = address(77);
    address user8 = address(88);
    address user9 = address(99);
    address user10 = address(100);
    address transferFromUser = address(110);
    address accessTier = address(3);
    address rich_user = address(45);
    address[] badBoys;
    address[] goodBoys;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        applicationERC1155 = new ApplicationERC1155("https://test", address(applicationAppManager));
        applicationERC1155Handler = new ApplicationERC1155Handler(address(ruleProcessor), address(applicationAppManager), address(applicationERC1155), false);
        applicationERC1155.connectHandlerToToken(address(applicationERC1155Handler));
        applicationAppManager.registerToken("1155x", address(applicationERC1155));
        applicationERC1155.mint(appAdministrator, 0, 1 * 10 ** 36, "");
        applicationERC1155.mint(appAdministrator, 1, 1 * 10 ** 18, "");
        applicationERC1155.mint(appAdministrator, 2, 1 * 10 ** 9, "");
        applicationERC1155.mint(appAdministrator, 3, 1_000, "");
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
        // applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * (10 ** 18));
        vm.warp(Blocktime);
    }

    function testERC1155AndHandlerVersions() public {
        string memory version = applicationERC1155Handler.version();
        assertEq(version, "1.1.0");
    }

    // Test Mint
    function testMint() public {
        applicationERC1155.mint(appAdministrator, type(uint256).max, 1000, "");
        assertEq(applicationERC1155.balanceOf(appAdministrator, type(uint256).max), 1000);
    }

    /// test updating min transfer rule
    function testERC1155PassesMinTransferRule() public {
        uint256[] memory ids = new uint256[](4);
        uint256[] memory amounts = new uint256[](4);
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(applicationAppManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(applicationAppManager), 10);

        /// we update the rule id in the token
        applicationERC1155Handler.setMinTransferRuleId(ruleId);
        switchToAppAdministrator();
        /// now we transfer a chunk of the tokens to non admin user
        ids[0] = 0;
        amounts[0] = 1000000;
        ids[1] = 1;
        amounts[1] = 1000000;
        ids[2] = 2;
        amounts[2] = 1000000;
        ids[3] = 3;
        amounts[3] = 1000;
        applicationERC1155.safeBatchTransferFrom(appAdministrator, rich_user, ids, amounts, "");
        assertEq(applicationERC1155.balanceOf(rich_user, 0), 1000000);
        assertEq(applicationERC1155.balanceOf(rich_user, 1), 1000000);
        assertEq(applicationERC1155.balanceOf(rich_user, 2), 1000000);
        assertEq(applicationERC1155.balanceOf(rich_user, 3), 1000);
        ids = new uint256[](4);
        amounts = new uint256[](4);

        vm.stopPrank();
        vm.startPrank(rich_user);
        // now we check for proper failure
        amounts[0] = 5;
        vm.expectRevert(0x70311aa2);
        applicationERC1155.safeBatchTransferFrom(rich_user, user3, ids, amounts, "");
        // now we check for success at the minimum
        amounts[0] = 10;
        applicationERC1155.safeBatchTransferFrom(rich_user, user3, ids, amounts, "");

        // now add the rule to the token and see if it works
        switchToRuleAdmin();
        applicationERC1155Handler.setTokenMinTransferRuleId(0, ruleId);
        // now we check for proper failure
        vm.stopPrank();
        vm.startPrank(rich_user);
        amounts[0] = 5;
        vm.expectRevert(0x70311aa2);
        applicationERC1155.safeBatchTransferFrom(rich_user, user3, ids, amounts, "");
        // now we check for success at the minimum
        amounts[0] = 10;
        applicationERC1155.safeBatchTransferFrom(rich_user, user3, ids, amounts, "");
        // now we check for success at the minimum with additionals
        amounts[0] = 10;
        amounts[1] = 10;
        ids[1] = 1;
        applicationERC1155.safeBatchTransferFrom(rich_user, user2, ids, amounts, "");
        assertEq(applicationERC1155.balanceOf(user2, 0), 10);
        assertEq(applicationERC1155.balanceOf(user2, 1), 10);

        // now add the rule to multiple tokenId's and check the transfers
        // now add the rule to the token and see if it works
        switchToRuleAdmin();
        applicationERC1155Handler.setTokenMinTransferRuleId(2, ruleId);
        vm.stopPrank();
        vm.startPrank(rich_user);
        ids = new uint256[](4);
        amounts = new uint256[](4);
        ids[0] = 0;
        amounts[0] = 10;
        ids[1] = 1;
        amounts[1] = 5;
        ids[2] = 2;
        amounts[2] = 5;
        ids[3] = 3;
        amounts[3] = 5;
        vm.expectRevert(0x70311aa2);
        applicationERC1155.safeBatchTransferFrom(rich_user, user1, ids, amounts, "");
        ids[0] = 0;
        amounts[0] = 10;
        ids[1] = 1;
        amounts[1] = 5;
        ids[2] = 2;
        amounts[2] = 10;
        ids[3] = 3;
        amounts[3] = 5;
        applicationERC1155.safeBatchTransferFrom(rich_user, user1, ids, amounts, "");
        assertEq(applicationERC1155.balanceOf(user1, 0), 10);
        assertEq(applicationERC1155.balanceOf(user1, 1), 5);
    }

    /// test min transfer rule
    function testFuzzERC1155PassesMinTransferRule(uint256 _minimum, uint256 _transfer) public {
        _minimum = bound(_minimum, 1, type(uint256).max);
        _transfer = bound(_transfer, 1, type(uint256).max);
        uint256[] memory ids = new uint256[](1);
        uint256[] memory amounts = new uint256[](1);
        applicationERC1155.mint(user, 4, type(uint256).max, "");
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(applicationAppManager), _minimum);
        /// we update the rule id in the token
        applicationERC1155Handler.setMinTransferRuleId(ruleId);
        switchToUser();
        ids[0] = 4;
        amounts[0] = _transfer;
        if (_transfer < _minimum) vm.expectRevert(0x70311aa2);
        applicationERC1155.safeBatchTransferFrom(user, user1, ids, amounts, "");
    }
}

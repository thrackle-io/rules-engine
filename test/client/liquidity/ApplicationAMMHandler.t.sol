// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/ProtocolERC20AMM.sol";
import "example/OracleDenied.sol";
import "example/OracleAllowed.sol";
import "test/util/TestCommonFoundry.sol";
import {ApplicationAMMHandler} from "example/liquidity/ApplicationAMMHandler.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/protocol/economic/ruleProcessor/AppRuleDataFacet.sol";
import {ApplicationAccessLevelProcessorFacet} from "src/protocol/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import {ERC20RuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import {ConstantRatio} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";

/**
 * @title Application AMM Handler  Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the Application AMM Handler.
 * @notice It simulates the input from a token contract and the AMM contract
 */
contract ApplicationAMMHandlerTest is TestCommonFoundry {
    address rich_user = address(44);
    address user1 = address(0x111);
    address user2 = address(0x222);
    address user3 = address(0x333);
    address user4 = address(0x444);
    address[] badBoys;
    address[] goodBoys;
    ApplicationAMMHandler applicationAMMHandler;
    OracleDenied oracleRestricted;
    OracleAllowed oracleAllowed;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleDenied();

        /// Set up the AMM
        protocolAMMFactory = createProtocolAMMFactory();
        ConstantRatio memory cr = ConstantRatio(1, 1);
        protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createConstantAMM(address(applicationCoin), address(applicationCoin2),cr, address(applicationAppManager)));
        /// Set up the ApplicationAMMHandler
        applicationAMMHandler = new ApplicationAMMHandler(address(applicationAppManager), address(ruleProcessor), address(protocolAMM));
        protocolAMM.connectHandlerToAMM(address(applicationAMMHandler));
        /// Register AMM
        applicationAppManager.registerAMM(address(protocolAMM));
        vm.warp(Blocktime);
    }

    function testTurningOnOffRules() public {
        /// Purchase Rule
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory purchaseAmounts = new uint256[](1);
        uint16[] memory purchasePeriods = new uint16[](1);
        uint64[] memory startTime = new uint64[](1);
        accs[0] = bytes32("PURCHASE_RULE");
        purchaseAmounts[0] = uint192(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint16(36); ///Hours
        startTime[0] = uint64(Blocktime); ///Hours

        /// Set the rule data
        applicationAppManager.addGeneralTag(user1, "PURCHASE_RULE");
        applicationAppManager.addGeneralTag(user2, "PURCHASE_RULE");
        assertTrue(applicationAppManager.hasTag(user1, "PURCHASE_RULE"));
        assertTrue(applicationAppManager.hasTag(user2, "PURCHASE_RULE"));
        accs[0] = bytes32("PURCHASE_RULE");
        purchaseAmounts[0] = uint256(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint16(36); ///Hours Purchase Period lasts
        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, purchaseAmounts, purchasePeriods, uint64(Blocktime));
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setPurchaseLimitRuleId(ruleId);
        applicationAMMHandler.activatePurchaseLimitRule(true);

        ///Sell Rule
        bytes32[] memory sellAccs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        sellAccs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint16(36); ///Hours

        // add the actual rule
        uint32 sellRuleId = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), sellAccs, sellAmounts, sellPeriod, uint64(Blocktime));
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setSellLimitRuleId(sellRuleId);
        applicationAMMHandler.activateSellLimitRule(true);
        ///Add GeneralTag to account
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user1, "SellRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "SellRule"));
        applicationAppManager.addGeneralTag(user2, "SellRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "SellRule"));
    }

    ///Test setting and checking purchase Rule
    function testPurchaseLimitRule() public {
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory purchaseAmounts = new uint256[](1);
        uint16[] memory purchasePeriods = new uint16[](1);
        accs[0] = bytes32("PurchaseRule");
        purchaseAmounts[0] = uint256(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint16(12); ///Hours

        // add the actual rule
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, purchaseAmounts, purchasePeriods, uint64(Blocktime));
        ///update ruleId in application coin rule handler
        applicationAMMHandler.setPurchaseLimitRuleId(ruleId);
        applicationAMMHandler.activatePurchaseLimitRule(true);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user1, "PurchaseRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "PurchaseRule"));
        applicationAppManager.addGeneralTag(user2, "PurchaseRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "PurchaseRule"));
        //Attempt to turn off rule as non-admin
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xd66c3008);
        applicationAMMHandler.activatePurchaseLimitRule(false);
        vm.expectRevert(0xd66c3008);
        applicationAMMHandler.setPurchaseLimitRuleId(15);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getPurchaseRule(ruleId, "PurchaseRule");
        ///1675723152 = Feb 6 2023 22hrs 39min 12 sec
        /// Check Rule passes
        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 50, 50, address(applicationCoin), ActionTypes.PURCHASE);
        uint256 lastPurchaseTotal = applicationAMMHandler.getPurchasedWithinPeriod(user2);
        assertEq(lastPurchaseTotal, 50);
        /// Check Rule Fails
        vm.expectRevert(0xa7fb7b4b);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.PURCHASE);
        ///Move into new Purchase Period
        vm.warp(Blocktime + 14 hours);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.PURCHASE);
        uint256 purchaseTotal = applicationAMMHandler.getPurchasedWithinPeriod(user2);
        assertEq(purchaseTotal, 551);
    }

    function testSellLimitRule() public {
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        accs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint16(12); ///Hours

        // add the actual rule
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, uint64(Blocktime));
        ///update ruleId in application coin rule handler
        applicationAMMHandler.setSellLimitRuleId(ruleId);
        applicationAMMHandler.activateSellLimitRule(true);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user1, "SellRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "SellRule"));
        applicationAppManager.addGeneralTag(user2, "SellRule"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "SellRule"));
        //Attempt to turn off rule as non-admin
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xd66c3008);
        applicationAMMHandler.activateSellLimitRule(false);
        vm.expectRevert(0xd66c3008);
        applicationAMMHandler.setSellLimitRuleId(15);

        /// Check Rule passes
        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 50, 50, address(applicationCoin), ActionTypes.SELL);

        switchToAppAdministrator();
        uint256 lastSellTotal = applicationAMMHandler.getSalesWithinPeriod(user1);
        assertEq(lastSellTotal, 50);

        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        /// Check Rule Fails
        vm.expectRevert(0xc11d5f20);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.SELL);
        ///Move into new Sell Period
        vm.warp(Blocktime + 14 hours);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.SELL);
        switchToAppAdministrator();
        uint256 sellTotal = applicationAMMHandler.getSalesWithinPeriod(user1);
        assertEq(sellTotal, 551);
    }

    /// test updating min transfer rule
    function testPassesMinTransferRule() public {
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 10);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        /// These should all pass
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 10, 10, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 11, 11, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 10000000000, 1000, address(applicationCoin), ActionTypes.TRADE));

        // now we check for proper failure
        vm.expectRevert(0x70311aa2);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 9, 9, address(applicationCoin), ActionTypes.TRADE);
        /// no2 change the rule and recheck
        switchToRuleAdmin();
        ruleId = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 100);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        /// These should all pass
        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 100, 100, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 111, 100, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 10000000000, 1000, address(applicationCoin), ActionTypes.TRADE));
        // now we check for proper failure
        vm.expectRevert(0x70311aa2);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 99, 99, address(applicationCoin), ActionTypes.TRADE);
    }

    function testMinMaxAccountBalanceRule() public {
        /// First Rule
        bytes32[] memory _accountTypes = new bytes32[](1);
        uint256[] memory _minimum = new uint256[](1);
        uint256[] memory _maximum = new uint256[](1);

        /// Set the min/max rule data
        applicationAppManager.addGeneralTag(user1, "WHALE");
        applicationAppManager.addGeneralTag(user2, "WHALE");
        _accountTypes[0] = "WHALE";
        _minimum[0] = 10;
        _maximum[0] = 1000;

        /// Second Rule
        bytes32[] memory _accs = new bytes32[](1);
        uint256[] memory _min = new uint256[](1);
        uint256[] memory _max = new uint256[](1);

        /// Set the min/max rule data
        applicationAppManager.addGeneralTag(user1, "MINMAX");
        applicationAppManager.addGeneralTag(user2, "MINMAX");
        _accs[0] = "MINMAX";
        _min[0] = 15;
        _max[0] = 1100;
        // add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), _accountTypes, _minimum, _maximum);

        uint32 ruleId2 = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), _accs, _min, _max);
        /// connect the rule to this handler
        applicationAMMHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        applicationAMMHandler.setMinMaxBalanceRuleIdToken1(ruleId2);
        vm.stopPrank();
        vm.startPrank(address(protocolAMM));
        /// execute a passing check for the minimum
        applicationAMMHandler.checkAllRules(200, 200, user1, address(protocolAMM), 10, 10, address(applicationCoin), ActionTypes.TRADE);

        /// execute a passing check for the maximum
        applicationAMMHandler.checkAllRules(500, 500, user1, address(protocolAMM), 50, 50, address(applicationCoin), ActionTypes.TRADE);

        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationAMMHandler.checkAllRules(20, 1000, user1, address(protocolAMM), 15, 15, address(applicationCoin), ActionTypes.TRADE);
        // execute a passing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationAMMHandler.checkAllRules(1000, 800, user1, address(protocolAMM), 500, 500, address(applicationCoin), ActionTypes.TRADE);
    }
}

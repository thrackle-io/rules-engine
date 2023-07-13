// // SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./DiamondTestUtil.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/ApplicationERC20.sol";
import "../src/example/liquidity/ApplicationAMM.sol";
import "../src/example/liquidity/ApplicationAMMCalcLinear.sol";
import "../src/example/liquidity/ApplicationAMMCalcCP.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "../src/example/application/ApplicationHandler.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import {ApplicationAMMHandler} from "../src/example/liquidity/ApplicationAMMHandler.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";

/**
 * @title Application AMM Handler  Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests the Application AMM Handler.
 * @notice It simulates the input from a token contract and the AMM contract
 */
contract ApplicationAMMHandlerTest is Test, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    AppManager public appManager;
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(1);
    address user2 = address(2);
    address user3 = address(33);
    address user4 = address(44);
    address accessTier = address(3);
    address rich_user = address(44);
    address ac;
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    ApplicationERC20 applicationCoin;
    ApplicationERC20 applicationCoin2;
    RuleProcessorDiamond ruleProcessor;
    ApplicationHandler public applicationHandler;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationAMMHandler applicationAMMHandler;
    ApplicationERC20Handler applicationCoinHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationAMM applicationAMM;
    ApplicationAMMCalcLinear applicationAMMLinearCalc;
    ApplicationAMMCalcCP applicationAMMCPCalc;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the rule processor diamonds
        ruleProcessor = getRuleProcessorDiamond();

        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// add the AccessLevelAdmin address as a AccessLevel admin
        appManager.addAccessTier(accessTier);
        ac = address(appManager);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        /// Set up the ApplicationERC20Handler
        applicationAMMHandler = new ApplicationAMMHandler(address(appManager), address(ruleProcessor));

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();

        /// Create calculators for the AMM
        applicationAMMLinearCalc = new ApplicationAMMCalcLinear();
        applicationAMMCPCalc = new ApplicationAMMCalcCP();
        /// Set up the AMM
        applicationAMM = new ApplicationAMM(address(applicationCoin), address(applicationCoin2), address(appManager), address(applicationAMMLinearCalc));
        vm.warp(Blocktime);
    }

    function testTurningOnOffRules() public {
        /// Purchase Rule
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory purchaseAmounts = new uint256[](1);
        uint32[] memory purchasePeriods = new uint32[](1);
        uint32[] memory startTime = new uint32[](1);
        accs[0] = bytes32("PURCHASE_RULE");
        purchaseAmounts[0] = uint192(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint32(36); ///Hours
        startTime[0] = uint32(12); ///Hours

        /// Set the rule data
        appManager.addGeneralTag(user1, "PURCHASE_RULE");
        appManager.addGeneralTag(user2, "PURCHASE_RULE");
        assertTrue(appManager.hasTag(user1, "PURCHASE_RULE"));
        assertTrue(appManager.hasTag(user2, "PURCHASE_RULE"));
        accs[0] = bytes32("PURCHASE_RULE");
        purchaseAmounts[0] = uint256(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint32(36); ///Hours Purchase Period lasts
        startTime[0] = uint32(12); ///Hours rule starts after block.timestamp
        // add the rule.
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(address(appManager), accs, purchaseAmounts, purchasePeriods, startTime);
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setPurchaseLimitRuleId(ruleId);
        applicationAMMHandler.activatePurchaseLimitRule(true);

        ///Sell Rule
        bytes32[] memory sellAccs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint32[] memory sellPeriod = new uint32[](1);
        uint32[] memory sellStartTime = new uint32[](1);
        sellAccs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint32(36); ///Hours
        startTime[0] = uint32(12); ///Hours

        // add the actual rule
        uint32 sellRuleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(appManager), sellAccs, sellAmounts, sellPeriod, sellStartTime);
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setSellLimitRuleId(sellRuleId);
        applicationAMMHandler.activateSellLimitRule(true);
        ///Add GeneralTag to account
        appManager.addGeneralTag(user1, "SellRule"); ///add tag
        assertTrue(appManager.hasTag(user1, "SellRule"));
        appManager.addGeneralTag(user2, "SellRule"); ///add tag
        assertTrue(appManager.hasTag(user2, "SellRule"));
    }

    ///Test setting and checking purchase Rule
    function testPurchaseLimitRule() public {
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory purchaseAmounts = new uint256[](1);
        uint32[] memory purchasePeriods = new uint32[](1);
        uint32[] memory startTime = new uint32[](1);
        accs[0] = bytes32("PurchaseRule");
        purchaseAmounts[0] = uint256(600); ///Amount to trigger purchase freeze rules
        purchasePeriods[0] = uint32(36); ///Hours
        startTime[0] = uint32(12); ///Hours

        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(address(appManager), accs, purchaseAmounts, purchasePeriods, startTime);
        ///update ruleId in application coin rule handler
        applicationAMMHandler.setPurchaseLimitRuleId(ruleId);
        applicationAMMHandler.activatePurchaseLimitRule(true);

        appManager.addGeneralTag(user1, "PurchaseRule"); ///add tag
        assertTrue(appManager.hasTag(user1, "PurchaseRule"));
        appManager.addGeneralTag(user2, "PurchaseRule"); ///add tag
        assertTrue(appManager.hasTag(user2, "PurchaseRule"));
        //Attempt to turn off rule as non-admin
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xba80c9e5);
        applicationAMMHandler.activatePurchaseLimitRule(false);
        vm.expectRevert(0xba80c9e5);
        applicationAMMHandler.setPurchaseLimitRuleId(15);

        TaggedRuleDataFacet(address(ruleStorageDiamond)).getPurchaseRule(ruleId, "PurchaseRule");
        ///1675723152 = Feb 6 2023 22hrs 39min 12 sec
        /// Check Rule passes
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 50, 50, address(applicationCoin), ActionTypes.PURCHASE);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 lastPurchaseTotal = applicationAMMHandler.getPurchasedWithinPeriod(user2);
        assertEq(lastPurchaseTotal, 50);
        /// Check Rule Fails
        vm.expectRevert(0xa7fb7b4b);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.PURCHASE);
        ///Move into new Purchase Period
        vm.warp(Blocktime + 14 hours);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.PURCHASE);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 purchaseTotal = applicationAMMHandler.getPurchasedWithinPeriod(user2);
        assertEq(purchaseTotal, 551);
    }

    function testSellLimitRule() public {
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint32[] memory sellPeriod = new uint32[](1);
        uint32[] memory startTime = new uint32[](1);
        accs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint32(36); ///Hours
        startTime[0] = uint32(12); ///Hours

        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(appManager), accs, sellAmounts, sellPeriod, startTime);
        ///update ruleId in application coin rule handler
        applicationAMMHandler.setSellLimitRuleId(ruleId);
        applicationAMMHandler.activateSellLimitRule(true);

        appManager.addGeneralTag(user1, "SellRule"); ///add tag
        assertTrue(appManager.hasTag(user1, "SellRule"));
        appManager.addGeneralTag(user2, "SellRule"); ///add tag
        assertTrue(appManager.hasTag(user2, "SellRule"));
        //Attempt to turn off rule as non-admin
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xba80c9e5);
        applicationAMMHandler.activateSellLimitRule(false);
        vm.expectRevert(0xba80c9e5);
        applicationAMMHandler.setSellLimitRuleId(15);

        /// Check Rule passes
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 50, 50, address(applicationCoin), ActionTypes.SELL);

        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 lastSellTotal = applicationAMMHandler.getSalesWithinPeriod(user1);
        assertEq(lastSellTotal, 50);

        vm.stopPrank();
        vm.startPrank(user1);
        /// Check Rule Fails
        vm.expectRevert(0xc11d5f20);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.SELL);
        ///Move into new Sell Period
        vm.warp(Blocktime + 14 hours);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 551, 55, address(applicationCoin), ActionTypes.SELL);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 sellTotal = applicationAMMHandler.getSalesWithinPeriod(user1);
        assertEq(sellTotal, 551);
    }

    /// test updating min transfer rule
    function testPassesMinTransferRule() public {
        /// We add the empty rule at index 0
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 10);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        /// These should all pass
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 10, 10, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 11, 11, address(applicationCoin), ActionTypes.TRADE));
        assertTrue(applicationAMMHandler.checkAllRules(0, 0, user1, user2, 10000000000, 1000, address(applicationCoin), ActionTypes.TRADE));

        // now we check for proper failure
        vm.expectRevert(0x70311aa2);
        applicationAMMHandler.checkAllRules(0, 0, user1, user2, 9, 9, address(applicationCoin), ActionTypes.TRADE);
        /// no2 change the rule and recheck
        ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 100);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        /// These should all pass
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
        appManager.addGeneralTag(user1, "WHALE");
        appManager.addGeneralTag(user2, "WHALE");
        _accountTypes[0] = "WHALE";
        _minimum[0] = 10;
        _maximum[0] = 1000;

        /// Second Rule
        bytes32[] memory _accs = new bytes32[](1);
        uint256[] memory _min = new uint256[](1);
        uint256[] memory _max = new uint256[](1);

        /// Set the min/max rule data
        appManager.addGeneralTag(user1, "MINMAX");
        appManager.addGeneralTag(user2, "MINMAX");
        _accs[0] = "MINMAX";
        _min[0] = 15;
        _max[0] = 1100;
        // add the rule.
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);

        uint32 ruleId2 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accs, _min, _max);
        /// connect the rule to this handler
        applicationAMMHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        applicationAMMHandler.setMinMaxBalanceRuleIdToken1(ruleId2);
        /// execute a passing check for the minimum
        applicationAMMHandler.checkAllRules(200, 200, user1, address(applicationAMM), 10, 10, address(applicationCoin), ActionTypes.TRADE);

        /// execute a passing check for the maximum
        applicationAMMHandler.checkAllRules(500, 500, user1, address(applicationAMM), 50, 50, address(applicationCoin), ActionTypes.TRADE);

        // execute a failing check for the minimum
        vm.expectRevert(0xf1737570);
        applicationAMMHandler.checkAllRules(20, 1000, user1, address(applicationAMM), 15, 15, address(applicationCoin), ActionTypes.TRADE);
        // execute a passing check for the maximum
        vm.expectRevert(0x24691f6b);
        applicationAMMHandler.checkAllRules(1000, 800, user1, address(applicationAMM), 500, 500, address(applicationCoin), ActionTypes.TRADE);
    }
}
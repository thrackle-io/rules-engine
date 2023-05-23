// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC20.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/economic/TokenRuleRouter.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import {TaggedRuleProcessorDiamondTestUtil} from "./TaggedRuleProcessorDiamondTestUtil.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";

contract ApplicationERC20Test is TaggedRuleProcessorDiamondTestUtil, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC20 applicationCoin;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    RuleStorageDiamond ruleStorageDiamond;
    TokenRuleRouter tokenRuleRouter;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationAppManager appManager;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    ApplicationHandler public applicationHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    TokenRuleRouterProxy ruleRouterProxy;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
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
    uint256 Blocktime = 1675723152;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        /// Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Diploy the token rule processor diamond
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        ///connect data diamond with Tagged Rule Processor diamond
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleRouter = new TokenRuleRouter();
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        /// connect the TokenRuleRouter to its child Diamond
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", address(ruleRouterProxy), false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// add the AccessLevelAdmin address as a AccessLevel admin
        appManager.addAccessTier(accessTier);
        /// add Risk Admin
        appManager.addRiskAdmin(riskAdmin);
        applicationHandler = ApplicationHandler(appManager.getApplicationHandlerAddress());
        /// Set up the ApplicationERC20Handler
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleRouterProxy), address(appManager), false);

        applicationCoin = new ApplicationERC20("FRANK", "FRANK", address(appManager), address(applicationCoinHandler));
        applicationCoin.mint(defaultAdmin, 10000000000000000000000 * (10 ** 18));
        /// register the token
        appManager.registerToken("FRANK", address(applicationCoin));
        /// set the token price
        erc20Pricer = new ApplicationERC20Pricing();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        /// connect ERC20 pricer to applicationCoinHandler
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
        vm.warp(Blocktime);
    }

    /// Test balance
    function testBalance() public {
        console.logUint(applicationCoin.totalSupply());
        assertEq(applicationCoin.balanceOf(defaultAdmin), 10000000000000000000000 * (10 ** 18));
    }

    /// Test Mint and Mint Fail
    function testMint() public {
        applicationCoin.mint(defaultAdmin, 1000);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x8f802168);
        applicationCoin.mint(user1, 10000);
    }

    /// Test token transfer
    function testTransfer() public {
        applicationCoin.transfer(appAdministrator, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(appAdministrator), 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(defaultAdmin), 9999999999999999999990 * (10 ** 18));
    }

    /// test updating min transfer rule
    function testPassesMinTransferRule() public {
        /// We add the empty rule at index 0
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 10);

        appManager.addPauseRule(Blocktime + 1000, Blocktime + 1010);
        /// we update the rule id in the token
        applicationCoinHandler.setMinTransferRuleId(ruleId);

        /// now we perform the transfer
        applicationCoin.transfer(rich_user, 1000000);
        assertEq(applicationCoin.balanceOf(rich_user), 1000000);
        vm.stopPrank();

        vm.startPrank(rich_user);
        // now we check for proper failure
        vm.expectRevert(0x70311aa2);
        applicationCoin.transfer(user3, 5);
    }

    function testPassMinMaxAccountBalanceRuleApplicationERC20() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);

        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(10);
        max[0] = uint256(1000);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);
        ///update ruleId in coin rule handler
        applicationCoinHandler.setMinMaxBalanceRuleId(ruleId);
        ///Add GeneralTag to account
        appManager.addGeneralTag(user1, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user1, "Oscar"));
        appManager.addGeneralTag(user2, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user2, "Oscar"));
        appManager.addGeneralTag(user3, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user3, "Oscar"));

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        assertEq(applicationCoin.balanceOf(user1), 990);

        // make sure the minimum rules fail results in revert
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationCoin.transfer(user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        // vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationCoin.transfer(user2, 10091);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testOracle() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        // add the rule.
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationCoin.transfer(address(69), 10);
        assertEq(applicationCoin.balanceOf(address(69)), 0);
        // check the allowed list type
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        // add an allowed address
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationCoin.transfer(address(59), 10);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoin.transfer(address(88), 10);

        // Finally, check the invalid type
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 2, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2a15491e);
        applicationCoin.transfer(user2, 10);
    }

    /**
     * @dev Test the Balance By AccessLevel rule
     */
    function testCoinBalanceByAccessLevelRulePasses() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 100000 * (10 ** 18));

        // add the rule.
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 0;
        balanceAmounts[1] = 100;
        balanceAmounts[2] = 500;
        balanceAmounts[3] = 1000;
        balanceAmounts[4] = 10000;
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(appManager), balanceAmounts);
        uint256 balance = AppRuleDataFacet(address(ruleStorageDiamond)).getAccessLevelBalanceRule(_index, 2);
        assertEq(balance, 500);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);

        ///perform transfer that checks rule when account does not have AccessLevel(should fail)
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(user2, 11 * (10 ** 18));

        /// Add access levellevel to whale
        address whale = address(99);
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(whale, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(whale, 10001 * (10 ** 18));
        /// this one is within the limit and should pass
        applicationCoin.transfer(whale, 10000 * (10 ** 18));

        /// create secondary token, mint, and transfer to user
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        ApplicationERC20 draculaCoin = new ApplicationERC20("application2", "DRAC", address(appManager), address(applicationCoinHandler));
        /// register the token
        appManager.registerToken("DRAC", address(draculaCoin));
        draculaCoin.mint(defaultAdmin, 10000000000000000000000 * (10 ** 18));
        draculaCoin.transfer(user1, 100000 * (10 ** 18));
        assertEq(draculaCoin.balanceOf(user1), 100000 * (10 ** 18));
        erc20Pricer.setSingleTokenPrice(address(draculaCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(draculaCoin)), 1 * (10 ** 18));
        // set the access levellevel for the user4
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(user4, 3);

        vm.stopPrank();
        vm.startPrank(user1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail regardless of other balance)
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(user4, 1001 * (10 ** 18));
        /// perform transfer that checks user with AccessLevel and existing balances(should fail because of other balance)
        draculaCoin.transfer(user4, 999 * (10 ** 18));
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(user4, 2 * (10 ** 18));

        /// perform transfer that checks user with AccessLevel and existing balances(should pass)
        applicationCoin.transfer(user4, 1 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 1 * (10 ** 18));
    }

    function testPauseRulesViaAppManager() public {
        ///Test transfers without pause rule
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);
        applicationCoin.transfer(appAdministrator, 100000);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 1000);

        ///set pause rule and check check that the transaction reverts
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1000);

        ///Check that appAdministrators can still transfer within pausePeriod
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationCoin.transfer(defaultAdmin, 1000);
        ///move blocktime after pause to resume transfers
        vm.warp(Blocktime + 1600);
        ///transfer again to check
        applicationCoin.transfer(user2, 1000);

        ///Set multiple pause rules
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
        appManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
        appManager.addPauseRule(Blocktime + 3000, Blocktime + 3500);
        ///warp between periods to test pause effect

        ///Pause window 1
        vm.warp(Blocktime + 1755);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1200);
        ///Pause window 2
        vm.warp(Blocktime + 2150);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1300);
        ///In between 2 and 3
        vm.warp(Blocktime + 2675);
        applicationCoin.transfer(user2, 1000);
        ///Pause window 3
        vm.warp(Blocktime + 3333);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1400);
        ///After pause window 3
        vm.warp(Blocktime + 3775);
        applicationCoin.transfer(user2, 1000);

        assertEq(applicationCoin.balanceOf(user2), 4000);
    }

    function testTransactionLimitByRiskScore() public {
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory txnLimits = new uint48[](6);
        riskScores[0] = 0;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        txnLimits[0] = 10000000;
        txnLimits[1] = 1000000;
        txnLimits[2] = 100000;
        txnLimits[3] = 10000;
        txnLimits[4] = 1000;
        txnLimits[5] = 10;
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), riskScores, txnLimits);

        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 10000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 10000000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, riskScores[0]);
        appManager.addRiskScore(user2, riskScores[1]);

        ///Switch to Default admin and set up ERC20Pricer and activate TransactionLimitByRiskScore Rule
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        applicationCoinHandler.setTransactionLimitByRiskRuleId(index);

        ///User2 sends User1 amount under transaction limit, expect passing
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.transfer(user1, 1 * (10 ** 18));

        ///Transfer expected to fail
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x9fe6aeac);
        applicationCoin.transfer(user2, 1000001 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(riskAdmin);
        ///Test in between Risk Score Values
        appManager.addRiskScore(user3, 49);
        appManager.addRiskScore(user4, 81);

        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.transfer(user3, 1500 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 1500 * (10 ** 18));
        applicationCoin.transfer(user4, 1000000 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x9fe6aeac);
        applicationCoin.transfer(user4, 10001 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user3, 10 * (10 ** 18));

        vm.expectRevert(0x9fe6aeac);
        applicationCoin.transfer(user3, 1001 * (10 ** 18));
    }

    function testBalanceLimitByRiskScoreERC20() public {
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory balanceLimits = new uint48[](6);
        riskScores[0] = 0;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        balanceLimits[0] = 1000000;
        balanceLimits[1] = 100000;
        balanceLimits[2] = 10000;
        balanceLimits[3] = 1000;
        balanceLimits[4] = 100;
        balanceLimits[5] = 1;
        uint32 index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(appManager), riskScores, balanceLimits);

        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 1000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 1000 * (10 ** 18));
        applicationCoin.transfer(user2, 101 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 101 * (10 ** 18));
        applicationCoin.transfer(user3, 1000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 1000 * (10 ** 18));
        applicationCoin.transfer(user4, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 10 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, riskScores[1]); ///Max 100000
        appManager.addRiskScore(user2, riskScores[3]); ///Max 1000
        appManager.addRiskScore(user3, 49); ///RiskLevel[2] Max 10000
        appManager.addRiskScore(user4, 81); ///RiskeLevel[3] Max 1000

        ///Switch to Default admin and set up ERC20Pricer and activate AccountBalanceByRiskScore Rule
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        applicationHandler.setAccountBalanceByRiskRuleId(index);

        ///User2 sends User1 amount under balance limit, expect passing
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 11 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.transfer(user1, 10 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.transfer(user1, 15 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        applicationCoin.transfer(user4, 5 * (10 ** 18));

        ///Transfer expected to fail
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user2, 1000 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user4, 1001 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user4);
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user3, 10 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user4);
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user3, 6 * (10 ** 18));
    }

    /// test updating min transfer rule
    function testPassesAccessLevel0RuleCoin() public {
        /// load non admin user with application coin
        applicationCoin.transfer(rich_user, 1000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 1000000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// check transfer without access levelscore but with the rule turned off
        applicationCoin.transfer(user3, 5 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 5 * (10 ** 18));
        /// now turn the rule on so the transfer will fail
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationHandler.activateAccessLevel0Rule(true);
        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        applicationCoin.transfer(user3, 5 * (10 ** 18));
        // set AccessLevel and try again
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(user3, 1);
        vm.stopPrank();
        vm.startPrank(rich_user);
        applicationCoin.transfer(user3, 5 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10 * (10 ** 18));
    }

    /// test Minimum Balance By Date rule
    function testPassesMinBalByDateCoin() public {
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = uint256(1000 * (10 ** 18));
        holdAmounts[1] = uint256(2000 * (10 ** 18));
        holdAmounts[2] = uint256(3000 * (10 ** 18));
        uint256[] memory holdPeriods = new uint256[](3);
        holdPeriods[0] = uint32(720); // one month
        holdPeriods[1] = uint32(4380); // six months
        holdPeriods[2] = uint32(17520); // two years
        uint256[] memory holdTimestamps = new uint256[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(appManager), accs, holdAmounts, holdPeriods, holdTimestamps);
        assertEq(_index, 0);
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user3, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10000 * (10 ** 18));
        applicationCoinHandler.setMinBalByDateRuleId(_index);
        /// tag the user
        appManager.addGeneralTag(rich_user, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(rich_user, "Oscar"));
        appManager.addGeneralTag(user2, "Tayler"); ///add tag
        assertTrue(appManager.hasTag(user2, "Tayler"));
        appManager.addGeneralTag(user3, "Shane"); ///add tag
        assertTrue(appManager.hasTag(user3, "Shane"));
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// attempt a transfer that violates the rule
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 9001 * (10 ** 18));
        /// make sure a transfer that is acceptable will still pass within the freeze window.
        applicationCoin.transfer(user1, 9000 * (10 ** 18));
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 1 * (10 ** 18));
        /// add enough time so that it should pass
        vm.warp(Blocktime + (720 * 1 hours));
        applicationCoin.transfer(user1, 1 * (10 ** 18));

        /// try tier 2
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(user2);
        /// attempt a transfer that violates the rule
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 8001 * (10 ** 18));
    }

    ///Test transferring coins with fees enabled
    function testTransactionFeeTableCoin() public {
        applicationCoin.transfer(user4, 100000 * (10 ** 18));
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 10000000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        applicationCoinHandler.addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        appManager.addGeneralTag(defaultAdmin, "cheap"); ///add tag
        applicationCoin.transfer(user2, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 100 * (10 ** 18));

        // now test the fee assessment
        appManager.addGeneralTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99900 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure when fees are active, that non qualifying users are not affected
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.transfer(user5, 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.transfer(user6, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user6), 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure multiple fees work by adding additional rule and applying to user4
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        appManager.addGeneralTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99800 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * (10 ** 18)); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * (10 ** 18)); // treasury gets fees

        // make sure discounts work by adding a discount to user4
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.addFee("discount", minBalance, maxBalance, -200, address(0));
        appManager.addGeneralTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user8, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99700 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury gets fees(added from previous...6 + 2)
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury gets fees(added from previous...6 + 5)

        // make sure deactivation works
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.setFeeActivation(false);
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user9, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99600 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * (10 ** 18)); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury remains the same
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury remains the same
    }

    ///Test transferring coins with fees enabled using transferFrom
    function testTransactionFeeTableTransferFrom() public {
        applicationCoin.transfer(user4, 100000 * (10 ** 18));
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 10000000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        applicationCoinHandler.addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        Fees.Fee memory fee = applicationCoinHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        appManager.addGeneralTag(defaultAdmin, "cheap"); ///add tag
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(defaultAdmin, user2, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 100 * (10 ** 18));

        // now test the fee assessment
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        appManager.addGeneralTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99900 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure when fees are active, that non qualifying users are not affected
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin.transfer(user5, 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user5, user6, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user6), 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure multiple fees work by adding additional rule and applying to user4
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        appManager.addGeneralTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user7, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99800 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * (10 ** 18)); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * (10 ** 18)); // treasury gets fees

        // make sure discounts work by adding a discount to user4
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.addFee("discount", minBalance, maxBalance, -200, address(0));
        appManager.addGeneralTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user8, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99700 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury gets fees(added from previous...6 + 2)
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury gets fees(added from previous...6 + 5)

        // make sure deactivation works
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoinHandler.setFeeActivation(false);
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user9, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99600 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * (10 ** 18)); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury remains the same
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury remains the same
    }
}

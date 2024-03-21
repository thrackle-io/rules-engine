// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";
import "test/client/token/ERC20/integration/ERC20CommonTests.t.sol";

contract ApplicationERC20Test is ERC20CommonTests {


    function setUp() public endWithStopPrank() {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        testCaseToken = applicationCoin;
        vm.warp(Blocktime);
    }

    function testERC20_ApplicationERC20_TokenMaxSupplyVolatility() public endWithStopPrank() {
        switchToAppAdministrator();
        /// burn tokens to specific supply
        applicationCoin.burn(10_000_000_000_000_000_000_000 * ATTO);
        applicationCoin.mint(appAdministrator, 100_000 * ATTO);
        applicationCoin.transfer(user1, 5000 * ATTO);

        /// create rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(1000, 24, Blocktime, 0);
        setTokenMaxSupplyVolatilityRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        /// move within period
        vm.warp(Blocktime + 13 hours);
        console.log(applicationCoin.totalSupply());
        vm.stopPrank();
        vm.startPrank(user1);
        /// mint tokens to the cap
        applicationCoin.mint(user1, 1);
        applicationCoin.mint(user1, 1000 * ATTO);
        applicationCoin.mint(user1, 8000 * ATTO);
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert(0xc406d470);
        applicationCoin.mint(user1, 6500 * ATTO);

        /// move out of rule period
        vm.warp(Blocktime + 40 hours);
        applicationCoin.mint(user1, 2550 * ATTO);

        /// burn tokens
        /// move into fresh period
        vm.warp(Blocktime + 95 hours);
        applicationCoin.burn(1000 * ATTO);
        applicationCoin.burn(1000 * ATTO);
        applicationCoin.burn(8000 * ATTO);

        vm.expectRevert(0xc406d470);
        applicationCoin.burn(2550 * ATTO);

        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
        applicationCoin.mint(user1, 2550 * ATTO);
        applicationCoin.burn(2550 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoin() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addTag(superAdmin, "cheap"); ///add tag
        applicationCoin.transfer(user2, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 100 * ATTO);

        // now test the fee assessment
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        // make sure when fees are active, that non qualifying users are not affected
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.transfer(user6, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user6), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        // make sure multiple fees work by adding additional rule and applying to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees

        // make sure discounts work by adding a discount to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user8, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99700 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * ATTO); // treasury gets fees(added from previous...6 + 2)
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * ATTO); // treasury gets fees(added from previous...6 + 5)

        // make sure deactivation works
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
        
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user9, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99600 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * ATTO); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * ATTO); // treasury remains the same
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * ATTO); // treasury remains the same
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoinBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        /// Now add another fee and make sure it accumulates. 
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees    
    }

    function testERC20_ApplicationERC20_TransactionFeeTableDiscountsCoin() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 100;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("fee1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("fee1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create a discount
        switchToRuleAdmin();
        feePercentage = -9000;
        FeesFacet(address(applicationCoinHandler)).addFee("discount1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create another discount that makes it more than the fee
        switchToRuleAdmin();
        feePercentage = -2000;
        FeesFacet(address(applicationCoinHandler)).addFee("discount2", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = FeesFacet(address(applicationCoinHandler)).getFee("discount2");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);

        // now test the fee assessment
        applicationAppManager.addTag(user4, "discount1"); ///add tag
        applicationAppManager.addTag(user4, "discount2"); ///add tag
        applicationAppManager.addTag(user4, "fee1"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // discounts are greater than fees so it should put fees to 0
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 0 * ATTO);
    }

    function testERC20_ApplicationERC20_TransactionFeeTableTransferFrom() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addTag(appAdministrator, "cheap"); ///add tag
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(appAdministrator, user2, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 100 * ATTO);

        // now test the fee assessment
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        // make sure when fees are active, that non qualifying users are not affected
        vm.stopPrank();
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user5, user6, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user6), 100 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        // make sure multiple fees work by adding additional rule and applying to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user7, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * ATTO); // treasury gets fees

        // make sure discounts work by adding a discount to user4
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user8, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99700 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * ATTO); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * ATTO); // treasury gets fees(added from previous...6 + 2)
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * ATTO); // treasury gets fees(added from previous...6 + 5)

        // make sure deactivation works
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.approve(address(transferFromUser), 100 * ATTO);
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(user4, user9, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99600 * ATTO); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * ATTO); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * ATTO); // treasury remains the same
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * ATTO); // treasury remains the same
    }

    function testERC20_ApplicationERC20_TransactionFeeTableCoinGt100() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user4, 100000 * ATTO);
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fee memory fee = FeesFacet(address(applicationCoinHandler)).getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, FeesFacet(address(applicationCoinHandler)).getFeeTotal());

        // now test the fee assessment
        applicationAppManager.addTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99900 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * ATTO);

        // add a fee to bring it to 100 percent
        switchToRuleAdmin();
        feePercentage = 9700;
        FeesFacet(address(applicationCoinHandler)).addFee("less cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        applicationCoin.transfer(user3, 100 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // previous 3 + current 3
        assertEq(applicationCoin.balanceOf(targetAccount2), 97 * ATTO); // current 7

        // add a fee to bring it over 100 percent
        switchToRuleAdmin();
        feePercentage = 10;
        FeesFacet(address(applicationCoinHandler)).addFee("super cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addTag(user4, "super cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        bytes4 selector = bytes4(keccak256("FeesAreGreaterThanTransactionAmount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, user4));
        applicationCoin.transfer(user3, 200 * ATTO);
        // make sure nothing changed
        assertEq(applicationCoin.balanceOf(user4), 99800 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 97 * ATTO);
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * ATTO); // previous 3 + current 3
        assertEq(applicationCoin.balanceOf(targetAccount2), 97 * ATTO); // current 7
    }

    /*********************** Atomic Rule Setting Tests ************************************/
    /* These tests ensure that the atomic setting/application of rules is functioning properly */

    /* MinMaxTokenBalance */
    function testERC20_ApplicationERC20_AccountMinMaxTokenBalanceAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(1000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(2), createUint256Array(2000));
        ruleIds[2] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Tayler"), createUint256Array(3), createUint256Array(3000));
        ruleIds[3] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(4), createUint256Array(4000));
        ruleIds[4] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Shane"), createUint256Array(5), createUint256Array(5000));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BUY));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.MINT));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BURN));
    }

    function testApplicationERC20_AccountMinMaxTokenBalanceAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(1000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(2), createUint256Array(2000));
        ruleIds[2] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Tayler"), createUint256Array(3), createUint256Array(3000));
        ruleIds[3] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(4), createUint256Array(4000));
        ruleIds[4] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(5), createUint256Array(5000));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);

        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(10000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(1), createUint256Array(20000));
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
         setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT),0);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.MINT));
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BURN));
    }

    /* AdminMinTokenBalance */
    function testApplicationERC20_AdminMinTokenBalanceAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAdminMinTokenBalanceRule(1, Blocktime + 100);
        ruleIds[1] = createAdminMinTokenBalanceRule(2, Blocktime + 200);
        ruleIds[2] = createAdminMinTokenBalanceRule(3, Blocktime + 300);
        ruleIds[3] = createAdminMinTokenBalanceRule(4, Blocktime + 400);
        ruleIds[4] = createAdminMinTokenBalanceRule(5, Blocktime + 500);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAdminMinTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BUY));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.MINT));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BURN));
    }

    function testApplicationERC20_AdminMinTokenBalanceAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAdminMinTokenBalanceRule(1, Blocktime + 100);
        ruleIds[1] = createAdminMinTokenBalanceRule(2, Blocktime + 200);
        ruleIds[2] = createAdminMinTokenBalanceRule(3, Blocktime + 300);
        ruleIds[3] = createAdminMinTokenBalanceRule(4, Blocktime + 400);
        ruleIds[4] = createAdminMinTokenBalanceRule(5, Blocktime + 500);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAdminMinTokenBalanceRule(6, Blocktime + 600);
        ruleIds[1] = createAdminMinTokenBalanceRule(7, Blocktime + 600);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAdminMinTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.MINT),0);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.MINT));
        assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BURN));
    }
    
    /* AccountMaxBuySize */
    function testApplicationERC20_AccountMaxBuySizeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createAccountMaxBuySizeRule("Oscar", 1, 1);
        // Apply the rules to all actions
        setAccountMaxBuySizeRule(address(applicationCoinHandler), ruleIds[0]);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxBuySizeId(),ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxBuySizeActive());
    }

    function testApplicationERC20_AccountMaxBuySizeAtomicFullReSet() public {
         uint32 ruleId;
        // Set up rule(This one is different because it can only apply to buys)
        ruleId = createAccountMaxBuySizeRule("Oscar", 100, 5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the rules to all actions
        ruleId = createAccountMaxBuySizeRule("Oscar", 100, 5);
        actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMaxBuySizeRule(address(applicationCoinHandler), ruleId);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxBuySizeId(),ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxBuySizeActive());
    }

    /* AccountMaxSellSize */
    function testApplicationERC20_AccountMaxSellSizeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createAccountMaxSellSizeRule("Oscar", 1, 1);
        // Apply the rules to all actions
        setAccountMaxSellSizeRule(address(applicationCoinHandler), ruleIds[0]);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxSellSizeId(),ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxSellSizeActive());
    }

    function testApplicationERC20_AccountMaxSellSizeAtomicFullReSet() public {
         uint32 ruleId;
        // Set up rule(This one is different because it can only apply to buys)
        ruleId = createAccountMaxSellSizeRule("Oscar", 100, 5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setAccountMaxSellSizeRule(address(applicationCoinHandler), ruleId);
        // Apply the rules to all actions
        ruleId = createAccountMaxSellSizeRule("Oscar", 200, 5);
        actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMaxSellSizeRule(address(applicationCoinHandler), ruleId);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxSellSizeId(),ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxSellSizeActive());
    }

    /* TokenMaxBuyVolume */
    function testApplicationERC20_TokenMaxBuyVolumeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createTokenMaxBuyVolumeRule(10, 48, 0, Blocktime);
        // Apply the rules to all actions
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleIds[0]);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxBuyVolumeId(),ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxBuyVolumeActive());
    }

    function testApplicationERC20_TokenMaxBuyVolumeAtomicFullReSet() public {
         uint32 ruleId;
        // Set up rule(This one is different because it can only apply to buys)
        ruleId = createTokenMaxBuyVolumeRule(10, 24, 0, Blocktime);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleId);
        // Apply the rules to all actions
        ruleId = createTokenMaxBuyVolumeRule(10, 48, 0, Blocktime);
        actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleId);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxBuyVolumeId(),ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxBuyVolumeActive());
    }

      /* TokenMaxSellVolume */
    function testApplicationERC20_TokenMaxSellVolumeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createTokenMaxSellVolumeRule(10, 48, 0, Blocktime);
        // Apply the rules to all actions
        setTokenMaxSellVolumeRule(address(applicationCoinHandler), ruleIds[0]);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxSellVolumeId(),ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxSellVolumeActive());
    }

    function testApplicationERC20_TokenMaxSellVolumeAtomicFullReSet() public {
        uint32 ruleId;
        // Set up rule(This one is different because it can only apply to buys)
        ruleId = createTokenMaxSellVolumeRule(10, 24, 0, Blocktime);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxSellVolumeRule(address(applicationCoinHandler), ruleId);
        // Apply the rules to all actions
        ruleId = createTokenMaxSellVolumeRule(10, 48, 0, Blocktime);
        actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxSellVolumeRule(address(applicationCoinHandler), ruleId);
        // Verify that all the rule id's were set correctly 
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxSellVolumeId(),ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxSellVolumeActive());
    }


    /* AccountApproveDenyOracle */
    function testApplicationERC20_AccountApproveDenyOracleAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for(uint i; i < 5;i++){
            for(uint j; j<5;j++){
                actions[mainIndex] = ActionTypes(actionIndex);
                ruleIds[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }
        
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly and are active(Had to go old school with control break logic)
        mainIndex = 0;
        uint256 internalIndex;
        ActionTypes lastAction;
        for(uint i; i < 5;i++){
            if(actions[mainIndex] != lastAction){
                internalIndex = 0;
            }
            for(uint j; j < 5; j++){
                assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex])[internalIndex],ruleIds[mainIndex]);
                assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex],ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
        
    }

    function testApplicationERC20_AccountApproveDenyOracleAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for(uint i; i < 5;i++){
            for(uint j; j<5;j++){
                actions[mainIndex] = ActionTypes(actionIndex);
                ruleIds[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }
        
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        uint32[] memory ruleIds2 = new uint32[](24);
        ActionTypes[] memory actions2 = new ActionTypes[](24);
        actionIndex = 0;
        mainIndex = 0;
        for(uint i; i < 3;i++){
            for(uint j; j<8;j++){
                actions2[mainIndex] = ActionTypes(actionIndex);
                ruleIds2[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }
        // Apply the new set of rules
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions2, ruleIds2);
        // Verify that all the rule id's were set correctly and are active(Had to go old school with control break logic)
        mainIndex = 0;
        uint256 internalIndex;
        ActionTypes lastAction;
        for(uint i; i < 3;i++){
            if(actions2[mainIndex] != lastAction){
                internalIndex = 0;
            }
            for(uint j; j < 8; j++){
                assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions2[mainIndex])[internalIndex],ruleIds2[mainIndex]);
                assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions2[mainIndex],ruleIds2[mainIndex]));
                lastAction = actions2[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }

        // Verify that all the rule id's were cleared for the previous set of rules(Had to go old school with control break logic)
        mainIndex = 0;
        internalIndex = 0;
        lastAction = ActionTypes(0);
        for(uint i; i < 5;i++){
            if(actions[mainIndex] != lastAction){
                internalIndex = 0;
            }
            for(uint j; j < 5; j++){
                uint32[] memory ruleIds3 = ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex]);
                // If a value was returned it must not match a previous rule
                if(ruleIds3.length>0){
                    assertFalse(ruleIds3[internalIndex]==ruleIds[mainIndex]);
                }
                assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex],ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
    }

    /* TokenMaxSupplyVolatility */
    function testApplicationERC20_TokenMaxSupplyVolatilityAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2000, 4, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(3000, 5, Blocktime, 0);
        ruleIds[2] = createTokenMaxSupplyVolatilityRule(4000, 6, Blocktime, 0);
        ruleIds[3] = createTokenMaxSupplyVolatilityRule(5000, 7, Blocktime, 0);
        ruleIds[4] = createTokenMaxSupplyVolatilityRule(6000, 8, Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    function testApplicationERC20_TokenMaxSupplyVolatilityAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2000, 4, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(3000, 5, Blocktime, 0);
        ruleIds[2] = createTokenMaxSupplyVolatilityRule(4000, 6, Blocktime, 0);
        ruleIds[3] = createTokenMaxSupplyVolatilityRule(5000, 7, Blocktime, 0);
        ruleIds[4] = createTokenMaxSupplyVolatilityRule(6000, 8, Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2011, 6, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(2022, 7, Blocktime, 0);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

     /* TokenMaxTradingVolume */
    function testApplicationERC20_TokenMaxTradingVolumeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxTradingVolumeRule(1000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(2000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[2] = createTokenMaxTradingVolumeRule(3000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[3] = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[4] = createTokenMaxTradingVolumeRule(5000, 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

    function testApplicationERC20_TokenMaxTradingVolumeAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxTradingVolumeRule(1000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(2000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[2] = createTokenMaxTradingVolumeRule(3000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[3] = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[4] = createTokenMaxTradingVolumeRule(5000, 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxTradingVolumeRule(6000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(7000, 2, Blocktime, 100_000 * ATTO);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

     /* TokenMinimumTransaction */
    function testApplicationERC20_TokenMinimumTransactionAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMinimumTransactionRule(1);
        ruleIds[1] = createTokenMinimumTransactionRule(2);
        ruleIds[2] = createTokenMinimumTransactionRule(3);
        ruleIds[3] = createTokenMinimumTransactionRule(4);
        ruleIds[4] = createTokenMinimumTransactionRule(5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BUY));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.MINT));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BURN));
    }

    function testApplicationERC20_TokenMinimumTransactionAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMinimumTransactionRule(1);
        ruleIds[1] = createTokenMinimumTransactionRule(2);
        ruleIds[2] = createTokenMinimumTransactionRule(3);
        ruleIds[3] = createTokenMinimumTransactionRule(4);
        ruleIds[4] = createTokenMinimumTransactionRule(5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMinimumTransactionRule(6);
        ruleIds[1] = createTokenMinimumTransactionRule(7);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT),0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.MINT));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BURN));
    }
}
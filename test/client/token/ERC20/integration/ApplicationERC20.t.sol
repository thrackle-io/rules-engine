// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract ApplicationERC20Test is TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * (10 ** 18));
        vm.warp(Blocktime);
    }

    function testERC20AndHandlerVersions() public {
        string memory version = applicationCoinHandler.version();
        assertEq(version, "1.1.0");
    }

    /// Test balance
    function testBalance() public {
        console.logUint(applicationCoin.totalSupply());
        assertEq(applicationCoin.balanceOf(appAdministrator), 10000000000000000000000 * (10 ** 18));
    }

    /// Test Mint
    function testMint() public {
        applicationCoin.mint(superAdmin, 1000);
        vm.stopPrank();
        vm.startPrank(user1);
    }

    /// Test token transfer
    function testTransfer() public {
        applicationCoin.transfer(user, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user), 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(appAdministrator), 9999999999999999999990 * (10 ** 18));
    }

    function testZeroAddressChecksERC20() public {
        vm.expectRevert();
        new ApplicationERC20("FRANK", "FRANK", address(0x0));
        vm.expectRevert();
        applicationCoin.connectHandlerToToken(address(0));
    }

    /// test updating min transfer rule
    function testPassesMinTransferRule() public {
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 10);

        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1010);
        /// we update the rule id in the token
        applicationCoinHandler.setMinTransferRuleId(ruleId);
        switchToAppAdministrator();
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

        bytes32[] memory accs = createBytes32SizeOneArray("Oscar");
        uint256[] memory min = createUint256SizeOneArray(10);
        uint256[] memory max = createUint256SizeOneArray(1000);
        // add the actual rule
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        ///update ruleId in coin rule handler
        applicationCoinHandler.setMinMaxBalanceRuleId(ruleId);
        switchToAppAdministrator();
        ///Add GeneralTag to account
        applicationAppManager.addGeneralTag(user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        applicationAppManager.addGeneralTag(user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
        applicationAppManager.addGeneralTag(user3, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Oscar"));

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
        // see if approving for another user bypasses rule
        applicationCoin.approve(address(888), 989);
        vm.stopPrank();
        vm.startPrank(address(888));
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationCoin.transferFrom(user1, user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        // vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationCoin.transfer(user2, 10091);
    }

    /**
     * @dev Test the oracle rule, both allow and deny types
     */
    function testOracleERC20() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        // add a blocked address
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationCoin.transfer(address(69), 10);
        assertEq(applicationCoin.balanceOf(address(69)), 0);
        // check the allowed list type

        switchToRuleAdmin();
        uint32 _indexAllowed = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_indexAllowed);
        switchToAppAdministrator();

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

        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));

        /// test burning while oracle rule is active (allow list active)
        applicationCoinHandler.setOracleRuleId(_indexAllowed);
        /// first mint to user
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 10000);
        /// burn some tokens as user
        /// burns do not check for the recipient address as it is address(0)
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.burn(5000);
        /// add address(0) to deny list and switch oracle rule to deny list
        switchToRuleAdmin();
        applicationCoinHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// attempt to burn (should fail)
        vm.stopPrank();
        vm.startPrank(user5);
        vm.expectRevert(0x2767bda4);
        applicationCoin.burn(5000);
    }

    /**
     * @dev Test the oracle rule, both allow and deny types
     */
    function testOracleAddSingleAddressERC20() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        /// Test adding single address to allow list 
        switchToRuleAdmin();
        uint32 _indexAllowed = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_indexAllowed);
        switchToAppAdministrator();
        oracleAllowed.addAddressToAllowList(address(59));

        vm.stopPrank();
        vm.startPrank(user1);
        ///perform transfer that checks rule
        applicationCoin.transfer(address(59), 10);
        assertEq(applicationCoin.balanceOf(address(59)), 10);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationCoin.transfer(address(60), 11);
        assertEq(applicationCoin.balanceOf(address(60)), 0);

        /// Test adding single address to deny list 

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        /// connect the rule to this handler
        applicationCoinHandler.setOracleRuleId(_index);
        switchToAppAdministrator();

        oracleDenied.addAddressToDeniedList(address(60)); 

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationCoin.transfer(address(60), 25);
        assertEq(applicationCoin.balanceOf(address(60)), 0);
    }

    /**
     * @dev Test the Balance By AccessLevel rule
     */
    function testCoinBalanceByAccessLevelRulePasses() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 100000 * (10 ** 18));

        // add the rule.
        uint48[] memory balanceAmounts = createUint48SizeFiveArray(0, 100, 500, 1000, 10000);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccessLevelBalanceRule(_index, 2);
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
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(whale, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xdd76c810);
        applicationCoin.transfer(whale, 10001 * (10 ** 18));
        /// this one is within the limit and should pass
        applicationCoin.transfer(whale, 10000 * (10 ** 18));

        /// create secondary token, mint, and transfer to user
        switchToSuperAdmin();
        ApplicationERC20 draculaCoin = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(draculaCoin), false);
        draculaCoin.connectHandlerToToken(address(applicationCoinHandler2));
        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(draculaCoin));
        draculaCoin.mint(appAdministrator, 10000000000000000000000 * (10 ** 18));
        draculaCoin.transfer(user1, 100000 * (10 ** 18));
        assertEq(draculaCoin.balanceOf(user1), 100000 * (10 ** 18));
        erc20Pricer.setSingleTokenPrice(address(draculaCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(draculaCoin)), 1 * (10 ** 18));
        // set the access levellevel for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user4, 3);

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

        /// test burning is allowed while rule is active
        applicationCoin.burn(1 * (10 ** 18));
        /// burn remaining balance to ensure rule limit is not checked on burns
        applicationCoin.burn(89998000000000000000000);
        /// test burn with account that has access level assign
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.burn(1 * (10 ** 18));
        /// test the user account balance is decreased from burn and can receive tokens
        vm.stopPrank();
        vm.startPrank(whale);
        applicationCoin.transfer(user4, 1 * (10 ** 18));
        /// now whale account burns
        applicationCoin.burn(1 * (10 ** 18));
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
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1000);

        ///Check that appAdministrators can still transfer within pausePeriod
        switchToAppAdministrator();
        applicationCoin.transfer(superAdmin, 1000);
        ///move blocktime after pause to resume transfers
        vm.warp(Blocktime + 1600);
        ///transfer again to check
        applicationCoin.transfer(user2, 1000);

        ///Set multiple pause rules
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
        applicationAppManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
        applicationAppManager.addPauseRule(Blocktime + 3000, Blocktime + 3500);
        switchToAppAdministrator();
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

    function testTransactionLimitByRiskScoreFT() public {
        uint8[] memory riskScores = createUint8SizeFourArray(10, 40, 80, 99);
        uint48[] memory txnLimits = createUint48SizeFourArray(1000000, 100000, 10000, 1000);
        switchToRuleAdmin();
        uint32 index = TaggedRuleDataFacet(address(ruleProcessor)).addTransactionLimitByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 10000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 10000000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user5, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user5), 10000 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user5, riskScores[3]);

        ///Switch to app admin and set up ERC20Pricer and activate TransactionLimitByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        switchToRuleAdmin();
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

        switchToRiskAdmin();
        ///Test in between Risk Score Values
        applicationAppManager.addRiskScore(user3, 49);
        applicationAppManager.addRiskScore(user4, 81);

        switchToAppAdministrator();
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

        //vm.expectRevert(0x9fe6aeac);
        applicationCoin.transfer(user3, 1001 * (10 ** 18));

        /// test burning tokens while rule is active
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.burn(999 * (10 ** 18));
        vm.expectRevert(0x9fe6aeac);
        applicationCoin.burn(1001 * (10 ** 18));
        applicationCoin.burn(1000 * (10 ** 18));
    }

    function testBalanceLimitByRiskScoreERC20() public {
        uint8[] memory riskScores = createUint8SizeThreeArray(25, 50, 75);
        uint48[] memory balanceLimits = createUint48SizeThreeArray(500, 250, 100);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountBalanceByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 999 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 999 * (10 ** 18));
        applicationCoin.transfer(user2, 249 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 249 * (10 ** 18));
        applicationCoin.transfer(user3, 499 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 499 * (10 ** 18));
        applicationCoin.transfer(user4, 99 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99 * (10 ** 18));
        applicationCoin.transfer(user5, 1000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user5), 1000000 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, 1); ///Max NO LIMIT
        applicationAppManager.addRiskScore(user2, 50); ///Max 250
        applicationAppManager.addRiskScore(user3, 25); ///Max 500
        applicationAppManager.addRiskScore(user4, 75); ///Max 100

        ///Switch to Super admin and set up ERC20Pricer and activate AccountBalanceByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        switchToRuleAdmin();
        applicationHandler.setAccountBalanceByRiskRuleId(index);

        ///Transfer funds to all that will put them one from limit(should all pass)
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.transfer(user1, 1 * (10 ** 18));
        applicationCoin.transfer(user2, 1 * (10 ** 18));
        applicationCoin.transfer(user3, 1 * (10 ** 18));
        applicationCoin.transfer(user4, 1 * (10 ** 18));

        ///Transfers expected to fail
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user2, 1 * (10 ** 18));
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user3, 1 * (10 ** 18));
        vm.expectRevert(0x58b13098);
        applicationCoin.transfer(user4, 1 * (10 ** 18));
    }

    /// test updating min transfer rule
    function testPassesAccessLevel0RuleCoin() public {
        /// load non admin user with application coin
        applicationCoin.transfer(rich_user, 1000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 1000000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// check transfer without access level but with the rule turned off
        applicationCoin.transfer(user3, 5 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 5 * (10 ** 18));
        /// now turn the rule on so the transfer will fail
        switchToRuleAdmin();
        applicationHandler.activateAccessLevel0Rule(true);
        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        applicationCoin.transfer(user3, 5 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d);
        applicationCoin.transfer(rich_user, 5 * (10 ** 18));

        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user3, 1);

        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        applicationCoin.transfer(user3, 5 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        applicationCoin.transfer(rich_user, 5 * (10 ** 18));

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(rich_user, 1);

        vm.stopPrank();
        vm.startPrank(rich_user);
        applicationCoin.transfer(user3, 5 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        applicationCoin.transfer(rich_user, 5 * (10 ** 18));

        /// test that burn works when user has accessLevel above 0
        applicationCoin.burn(5 * (10 ** 18));
        /// test burn fails when rule active and user has access level 0
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(rich_user, 0);

        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        applicationCoin.burn(1 * (10 ** 18));
    }

    function testAccessLevelWithdrawalRule() public {
        /// load non admin user with application coin
        applicationCoin.transfer(user1, 1000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 1000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user1);
        /// check transfer without access level with the rule turned off
        applicationCoin.transfer(user3, 50 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 50 * (10 ** 18));
        /// price the tokens
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        /// create and activate rule
        switchToRuleAdmin();
        uint48[] memory withdrawalLimits = createUint48SizeFiveArray(10, 100, 1000, 10000, 100000);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelWithdrawalRule(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setWithdrawalLimitByAccessLevelRuleId(index);
        /// test transfers pass under rule value
        //User 1 currently has 950 tokens valued at $950
        //User3 currently has 50 tokens valued at $50
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        applicationAppManager.addAccessLevel(user3, 0);
        applicationAppManager.addAccessLevel(user4, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user3, 50 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 100 * (10 ** 18));
        applicationCoin.transfer(user4, 50 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 50 * (10 ** 18));
        /// User 1 now at "withdrawal" limit for kyc level
        vm.stopPrank();
        vm.startPrank(user3);
        applicationCoin.transfer(user4, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 60 * (10 ** 18));
        /// User3 now at "withdrawal" limit for kyc level

        /// test transfers fail over rule value
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2bbc9aea);
        applicationCoin.transfer(user3, 50 * (10 ** 18));

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x2bbc9aea);
        applicationCoin.transfer(user4, 50 * (10 ** 18));
        /// reduce price and test pass fail situations
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 5 * (10 ** 17));
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 5 * (10 ** 17));

        vm.stopPrank();
        vm.startPrank(user4);
        /// successful transfer as the new price is $.50USD (can transfer up to $10)
        applicationCoin.transfer(user4, 20 * (10 ** 18));
        /// transfer fails because user reached KYC limit
        vm.expectRevert(0x2bbc9aea);
        applicationCoin.transfer(user3, 10 * (10 ** 18));
    }

    /// test Minimum Balance By Date rule
    function testPassesMinBalByDateCoin() public {
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32SizeThreeArray("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256SizeThreeArray((1000 * (10 ** 18)), (2000 * (10 ** 18)), (3000 * (10 ** 18)));
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory holdPeriods = createUint16SizeThreeArray(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        applicationCoinHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user3, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10000 * (10 ** 18));
        /// tag the user
        applicationAppManager.addGeneralTag(rich_user, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(rich_user, "Oscar"));
        applicationAppManager.addGeneralTag(user2, "Tayler"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Tayler"));
        applicationAppManager.addGeneralTag(user3, "Shane"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Shane"));
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
        switchToRuleAdmin();
        applicationCoinHandler.addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addGeneralTag(superAdmin, "cheap"); ///add tag
        applicationCoin.transfer(user2, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 100 * (10 ** 18));

        // now test the fee assessment
        applicationAppManager.addGeneralTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99900 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure when fees are active, that non qualifying users are not affected
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.transfer(user6, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user6), 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // make sure multiple fees work by adding additional rule and applying to user4
        switchToRuleAdmin();
        applicationCoinHandler.addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user7, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99800 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user7), 91 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * (10 ** 18)); // treasury gets fees(added from previous)
        assertEq(applicationCoin.balanceOf(targetAccount2), 6 * (10 ** 18)); // treasury gets fees

        // make sure discounts work by adding a discount to user4
        switchToRuleAdmin();
        applicationCoinHandler.addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user4, "discount"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user8, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99700 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user8), 93 * (10 ** 18)); // to account gets amount - fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury gets fees(added from previous...6 + 2)
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury gets fees(added from previous...6 + 5)

        // make sure deactivation works
        switchToRuleAdmin();
        applicationCoinHandler.setFeeActivation(false);
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user9, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99600 * (10 ** 18)); //from account decrements properly
        assertEq(applicationCoin.balanceOf(user9), 100 * (10 ** 18)); // to account gets amount while ignoring fees
        assertEq(applicationCoin.balanceOf(targetAccount), 8 * (10 ** 18)); // treasury remains the same
        assertEq(applicationCoin.balanceOf(targetAccount2), 11 * (10 ** 18)); // treasury remains the same
    }

    ///Test transferring coins with fees and discounts where the discounts are greater than the fees
    function testTransactionFeeTableDiscountsCoin() public {
        applicationCoin.transfer(user4, 100000 * (10 ** 18));
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 10000000 * 10 ** 18;
        int24 feePercentage = 100;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        applicationCoinHandler.addFee("fee1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee("fee1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create a discount
        switchToRuleAdmin();
        feePercentage = -9000;
        applicationCoinHandler.addFee("discount1", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = applicationCoinHandler.getFee("discount1");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        // create another discount that makes it more than the fee
        switchToRuleAdmin();
        feePercentage = -2000;
        applicationCoinHandler.addFee("discount2", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        fee = applicationCoinHandler.getFee("discount2");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);

        // now test the fee assessment
        applicationAppManager.addGeneralTag(user4, "discount1"); ///add tag
        applicationAppManager.addGeneralTag(user4, "discount2"); ///add tag
        applicationAppManager.addGeneralTag(user4, "fee1"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // discounts are greater than fees so it should put fees to 0
        applicationCoin.transfer(user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99900 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 0 * (10 ** 18));
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
        switchToRuleAdmin();
        applicationCoinHandler.addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());
        // make sure fees don't affect Application Administrators(even if tagged)
        applicationAppManager.addGeneralTag(appAdministrator, "cheap"); ///add tag
        applicationCoin.approve(address(transferFromUser), 100 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(transferFromUser);
        applicationCoin.transferFrom(appAdministrator, user2, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 100 * (10 ** 18));

        // now test the fee assessment
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user4, "cheap"); ///add tag
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
        vm.startPrank(appAdministrator);
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
        switchToRuleAdmin();
        applicationCoinHandler.addFee("less cheap", minBalance, maxBalance, 600, targetAccount2);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user4, "less cheap"); ///add tag
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
        switchToRuleAdmin();
        applicationCoinHandler.addFee("discount", minBalance, maxBalance, -200, address(0));
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user4, "discount"); ///add tag
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
        switchToRuleAdmin();
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

    ///Test transferring coins with fees enabled
    function testTransactionFeeTableCoinGt100() public {
        applicationCoin.transfer(user4, 100000 * (10 ** 18));
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 10000000 * 10 ** 18;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        // create a fee
        switchToRuleAdmin();
        applicationCoinHandler.addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        // now test the fee assessment
        applicationAppManager.addGeneralTag(user4, "cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works
        applicationCoin.transfer(user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99900 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 3 * (10 ** 18));

        // add a fee to bring it to 100 percent
        switchToRuleAdmin();
        feePercentage = 9700;
        applicationCoinHandler.addFee("less cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addGeneralTag(user4, "less cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        applicationCoin.transfer(user3, 100 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 99800 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * (10 ** 18)); // previous 3 + current 3
        assertEq(applicationCoin.balanceOf(targetAccount2), 97 * (10 ** 18)); // current 7

        // add a fee to bring it over 100 percent
        switchToRuleAdmin();
        feePercentage = 10;
        applicationCoinHandler.addFee("super cheap", minBalance, maxBalance, feePercentage, targetAccount2);
        switchToAppAdministrator();
        // now test the fee assessment
        applicationAppManager.addGeneralTag(user4, "super cheap"); ///add tag
        vm.stopPrank();
        vm.startPrank(user4);
        // make sure standard fee works(other fee will also be assessed)
        bytes4 selector = bytes4(keccak256("FeesAreGreaterThanTransactionAmount(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, user4));
        applicationCoin.transfer(user3, 200 * (10 ** 18));
        // make sure nothing changed
        assertEq(applicationCoin.balanceOf(user4), 99800 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 97 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(targetAccount), 6 * (10 ** 18)); // previous 3 + current 3
        assertEq(applicationCoin.balanceOf(targetAccount2), 97 * (10 ** 18)); // current 7
    }

    /// test the token transfer volume rule in erc20
    function testTokenTransferVolumeRuleCoin() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, Blocktime, 0);
        assertEq(_index, 0);
        switchToAppAdministrator();
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 4000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        /// burn all default supply down and mint a manageable number
        applicationCoin.burn(10_000_000_000_000_000_000_000 * (10 ** 18));
        applicationCoin.mint(appAdministrator, 100_000 * (10 ** 18));
        /// load non admin users with game coin
        /// apply the rule
        switchToRuleAdmin();
        applicationCoinHandler.setTokenTransferVolumeRuleId(_index);
        switchToAppAdministrator();
        applicationCoin.transfer(rich_user, 100_000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 100_000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// make sure that transfer under the threshold works
        applicationCoin.transfer(user1, 39_000 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_000 * (10 ** 18));
        /// now take it right up to the threshold(39,999)
        applicationCoin.transfer(user1, 999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * (10 ** 18));
        /// now violate the rule and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * (10 ** 18));
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * (10 ** 18));
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 39_999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * (10 ** 18));
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationCoin.transfer(user1, 39_999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * (10 ** 18));
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * (10 ** 18));
    }

    /// test the token transfer volume rule in erc20 when they give a total supply instead of relying on ERC20
    function testTokenTransferVolumeRuleCoinWithSupplySet() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, Blocktime, 100_000 * (10 ** 18));
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 4000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        /// load non admin users with game coin
        applicationCoin.transfer(rich_user, 100_000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 100_000 * (10 ** 18));
        /// apply the rule
        switchToRuleAdmin();
        applicationCoinHandler.setTokenTransferVolumeRuleId(_index);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// make sure that transfer under the threshold works
        applicationCoin.transfer(user1, 39_000 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_000 * (10 ** 18));
        /// now take it right up to the threshold(39,999)
        applicationCoin.transfer(user1, 999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * (10 ** 18));
        /// now violate the rule and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * (10 ** 18));
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * (10 ** 18));
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 39_999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * (10 ** 18));
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationCoin.transfer(user1, 39_999 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * (10 ** 18));
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationCoin.transfer(user1, 1 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * (10 ** 18));
    }

    /// test supply volatility rule
    function testSupplyVolatilityRule() public {
        /// burn tokens to specific supply
        applicationCoin.burn(10_000_000_000_000_000_000_000 * (10 ** 18));
        applicationCoin.mint(appAdministrator, 100_000 * (10 ** 18));
        applicationCoin.transfer(user1, 5000 * (10 ** 18));

        /// create rule params
        uint16 volatilityLimit = 1000; /// 10%
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startingTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token

        /// set rule id and activate
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), volatilityLimit, rulePeriod, startingTime, tokenSupply);
        applicationCoinHandler.setTotalSupplyVolatilityRuleId(_index);
        switchToAppAdministrator();
        /// move within period
        vm.warp(Blocktime + 13 hours);
        console.log(applicationCoin.totalSupply());
        vm.stopPrank();
        vm.startPrank(user1);
        /// mint tokens to the cap
        applicationCoin.mint(user1, 1);
        applicationCoin.mint(user1, 1000 * (10 ** 18));
        applicationCoin.mint(user1, 8000 * (10 ** 18));
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert(0x81af27fa);
        applicationCoin.mint(user1, 6500 * (10 ** 18));

        /// move out of rule period
        vm.warp(Blocktime + 40 hours);
        applicationCoin.mint(user1, 2550 * (10 ** 18));

        /// burn tokens
        /// move into fresh period
        vm.warp(Blocktime + 95 hours);
        applicationCoin.burn(1000 * (10 ** 18));
        applicationCoin.burn(1000 * (10 ** 18));
        applicationCoin.burn(8000 * (10 ** 18));

        vm.expectRevert(0x81af27fa);
        applicationCoin.burn(2550 * (10 ** 18));

        applicationCoin.mint(user1, 2550 * (10 ** 18));
        applicationCoin.burn(2550 * (10 ** 18));
        applicationCoin.mint(user1, 2550 * (10 ** 18));
        applicationCoin.burn(2550 * (10 ** 18));
        applicationCoin.mint(user1, 2550 * (10 ** 18));
        applicationCoin.burn(2550 * (10 ** 18));
        applicationCoin.mint(user1, 2550 * (10 ** 18));
        applicationCoin.burn(2550 * (10 ** 18));
    }

    function testDataContractMigration() public {
        /// put data in the old rule handler
        /// Fees
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee
        switchToRuleAdmin();
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        /// create new handler
        ApplicationERC20Handler applicationCoinHandlerNew = new ApplicationERC20Handler(address(ruleProcessor), address(applicationAppManager), address(applicationCoin), true);
        /// migrate data contracts to new handler
        console.log(applicationCoinHandler.owner());
        console.log(address(applicationCoin));
        /// connect the old data contract to the new handler
        applicationCoinHandler.proposeDataContractMigration(address(applicationCoinHandlerNew));
        applicationCoinHandlerNew.confirmDataContractMigration(address(applicationCoinHandler));
        // applicationCoinHandlerNew.connectDataContracts(address(applicationCoinHandler));
        /// test that the data is accessible only from the new handler
        fee = applicationCoinHandlerNew.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandlerNew.getFeeTotal());

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xba80c9e5);
        applicationCoinHandlerNew.confirmDataContractMigration(address(applicationCoinHandler));
    }

    function testHandlerUpgradingWithFeeMigration() public {
        ///deploy new modified appliction asset handler contract
        ApplicationAssetHandlerMod assetHandler = new ApplicationAssetHandlerMod(address(ruleProcessor), address(applicationAppManager), address(applicationCoin), true);
        ///connect to apptoken
        applicationCoin.connectHandlerToToken(address(assetHandler));
        applicationAppManager.deregisterToken("FRANK");
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
        bytes32 tag1 = "cheap";
        uint256 minBalance = 10 * 10 ** 18;
        uint256 maxBalance = 1000 * 10 ** 18;
        int24 feePercentage = 300;
        address feeCollectorAccount = appAdministrator;
        // create one fee in old handler
        switchToRuleAdmin();
        applicationCoinHandler.addFee(tag1, minBalance, maxBalance, feePercentage, feeCollectorAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationCoinHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, applicationCoinHandler.getFeeTotal());

        applicationCoinHandler.proposeDataContractMigration(address(assetHandler));
        assetHandler.confirmDataContractMigration(address(applicationCoinHandler));

        // verify fees are still there
        fee = assetHandler.getFee(tag1);
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, minBalance);
        assertEq(fee.maxBalance, maxBalance);
        assertEq(1, assetHandler.getFeeTotal());
        bytes32[] memory accs = createBytes32SizeThreeArray("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256SizeThreeArray((1000 * (10 ** 18)), (2000 * (10 ** 18)), (3000 * (10 ** 18)));
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory holdPeriods = createUint16SizeThreeArray(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        assetHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();

        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user3, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10000 * (10 ** 18));
        switchToRuleAdmin();
        assetHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();
        /// tag the user
        applicationAppManager.addGeneralTag(rich_user, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(rich_user, "Oscar"));
        applicationAppManager.addGeneralTag(user2, "Tayler"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Tayler"));
        applicationAppManager.addGeneralTag(user3, "Shane"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Shane"));
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

        console.log(assetHandler.newTestFunction());
    }

    function testHandlerUpgradingWithoutFeeMigration() public {
        ///deploy new modified appliction asset handler contract
        ApplicationAssetHandlerMod assetHandler = new ApplicationAssetHandlerMod(address(ruleProcessor), address(applicationAppManager), address(applicationCoin), true);
        ///connect to apptoken
        applicationCoin.connectHandlerToToken(address(assetHandler));
        applicationAppManager.deregisterToken("FRANK");
        applicationAppManager.registerToken("FRANK", address(applicationCoin));

        applicationCoinHandler.proposeDataContractMigration(address(assetHandler));
        assetHandler.confirmDataContractMigration(address(applicationCoinHandler));
        bytes32[] memory accs = createBytes32SizeThreeArray("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256SizeThreeArray((1000 * (10 ** 18)), (2000 * (10 ** 18)), (3000 * (10 ** 18)));
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory holdPeriods = createUint16SizeThreeArray(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        assetHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();

        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user3, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 10000 * (10 ** 18));
        switchToRuleAdmin();
        assetHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();
        /// tag the user
        applicationAppManager.addGeneralTag(rich_user, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(rich_user, "Oscar"));
        applicationAppManager.addGeneralTag(user2, "Tayler"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Tayler"));
        applicationAppManager.addGeneralTag(user3, "Shane"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Shane"));
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

        console.log(assetHandler.newTestFunction());
    }

    function testUpgradeAppManager20() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager appManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        applicationCoin.proposeAppManagerAddress(address(appManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        appManager2.confirmAppManager(address(applicationCoin));
        /// test to ensure it still works
        switchToAppAdministrator();
        applicationCoin.transfer(user, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user), 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(appAdministrator), 9999999999999999999990 * (10 ** 18));

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        applicationCoin.proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        appManager2.confirmAppManager(address(applicationCoin));
        // non proposer tries to confirm
        applicationCoin.proposeAppManagerAddress(address(appManager2));
        ApplicationAppManager appManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        vm.expectRevert(0x41284967);
        appManager3.confirmAppManager(address(applicationCoin));
    }
}

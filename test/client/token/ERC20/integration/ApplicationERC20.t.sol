// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";

contract ApplicationERC20Test is TestCommonFoundry, DummyAMM {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        vm.warp(Blocktime);
    }

    function testERC20_ERC20AndHandlerVersions() public {
        string memory version = VersionFacet(address(applicationCoinHandler)).version();
        assertEq(version, "1.1.0");
    }

     function test_ERC20OnlyTokenCanCallCheckAllRules() public{
        address handler = applicationCoin.getHandlerAddress();
        assertEq(handler, address(applicationCoinHandler));
        address owner = ERC173Facet(address(applicationCoinHandler)).owner();
        assertEq(owner, address(applicationCoin));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC20_AlreadyInitialized() public{
        vm.stopPrank();
        vm.startPrank(address(applicationCoin));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC20HandlerMainFacet(address(applicationCoinHandler)).initialize(user1, user2, user3);
    }

    /// Test balance
    function testERC20_Balance() public {
        console.logUint(applicationCoin.totalSupply());
        assertEq(applicationCoin.balanceOf(appAdministrator), 10000000000000000000000 * ATTO);
    }

    /// Test Mint
    function testERC20_Mint() public {
        applicationCoin.mint(superAdmin, 1000);
        vm.stopPrank();
        vm.startPrank(user1);
    }

    /// Test token transfer
    function testERC20_Transfer() public {
        applicationCoin.transfer(user, 10 * ATTO);
        assertEq(applicationCoin.balanceOf(user), 10 * ATTO);
        assertEq(applicationCoin.balanceOf(appAdministrator), 9999999999999999999990 * ATTO);
    }

    function testERC20_ZeroAddressChecksERC20() public {
        vm.expectRevert();
        new ApplicationERC20("FRANK", "FRANK", address(0x0));
        vm.expectRevert();
        applicationCoin.connectHandlerToToken(address(0));
    }

    /// test updating min transfer rule
    function testERC20_testTokenMinTransactionSize() public {
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 1);

        // Then we add the actual rule. Its index should be 1
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 10);

        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1010);
        /// we update the rule id in the token
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMinTxSizeId(_createActionsArray(), ruleId);
        switchToAppAdministrator();
        /// now we perform the transfer
        applicationCoin.transfer(rich_user, 1000000);
        assertEq(applicationCoin.balanceOf(rich_user), 1000000);
        vm.stopPrank();

        vm.startPrank(rich_user);
        // now we check for proper failure
        vm.expectRevert(0x7a78c901);
        applicationCoin.transfer(user3, 5);
    }

    function testERC20_AccountMinMaxTokenBalance() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);

        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(1000);
        uint16[] memory empty;
        // add the actual rule
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        ///update ruleId in coin rule handler
        // create the default actions array
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.SELL;
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToAppAdministrator();
        ///Add Tag to account
        applicationAppManager.addTag(user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        applicationAppManager.addTag(user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
        applicationAppManager.addTag(user3, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Oscar"));

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        assertEq(applicationCoin.balanceOf(user1), 990);

        // make sure the minimum rules fail results in revert
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0x3e237976);
        applicationCoin.transfer(user3, 989);
        // see if approving for another user bypasses rule
        applicationCoin.approve(address(888), 989);
        vm.stopPrank();
        vm.startPrank(address(888));
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0x3e237976);
        applicationCoin.transferFrom(user1, user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        // vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x1da56a44);
        applicationCoin.transfer(user2, 10091);
    }

    function testERC20_AccountMinMaxTokenBalanceBlankTag() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);

        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(1000);
        uint16[] memory empty;
        // add the actual rule
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        ///update ruleId in coin rule handler
        // create the default actions array
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.SELL;
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        switchToAppAdministrator();

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        assertEq(applicationCoin.balanceOf(user1), 990);

        // make sure the minimum rules fail results in revert
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0x3e237976);
        applicationCoin.transfer(user3, 989);
        // see if approving for another user bypasses rule
        applicationCoin.approve(address(888), 989);
        vm.stopPrank();
        vm.startPrank(address(888));
        //vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0x3e237976);
        applicationCoin.transferFrom(user1, user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        // vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x1da56a44);
        applicationCoin.transfer(user2, 10091);
    }

    /**
     * @dev Test the oracle rule, both approve and deny types
     */
    function testERC20_AccountApproveDenyOracle() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        /// connect the rule to this handler
        ActionTypes[] memory actionTypes = new ActionTypes[](3);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.BURN;
        actionTypes[2] = ActionTypes.MINT;
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(actionTypes, _index);
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
        // check the approved list type

        switchToRuleAdmin();
        uint32 _indexAllowed = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
        /// connect the rule to this handler
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(actionTypes, _indexAllowed);
        switchToAppAdministrator();

        // add approved addresses
        goodBoys.push(address(59));
        goodBoys.push(address(user5));
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationCoin.transfer(address(59), 10);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        applicationCoin.transfer(address(88), 10);

        // Finally, check the invalid type

        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 2, address(oracleApproved));

        /// test burning while oracle rule is active (allow list active)
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(actionTypes, _indexAllowed);
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
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(actionTypes, _index);
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
    function testERC20_AccountApproveDenyOracleAddSingleAddress() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        /// Test adding single address to allow list 
        switchToRuleAdmin();
        uint32 _indexAllowed = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
        /// connect the rule to this handler
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), _indexAllowed);
        switchToAppAdministrator();
        oracleApproved.addAddressToApprovedList(address(59));

        vm.stopPrank();
        vm.startPrank(user1);
        ///perform transfer that checks rule
        applicationCoin.transfer(address(59), 10);
        assertEq(applicationCoin.balanceOf(address(59)), 10);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        applicationCoin.transfer(address(60), 11);
        assertEq(applicationCoin.balanceOf(address(60)), 0);

        /// Test adding single address to deny list 

        // add the rule.
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).activateAccountApproveDenyOracle(_createActionsArray(), false, _indexAllowed);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        /// connect the rule to this handler
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), _index);
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
     * @dev Test the Max Balance By AccessLevel rule
     */
    function testERC20_AccountMaxValueByAccessLevel() public {
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 100000 * ATTO);

        // add the rule.
        uint48[] memory balanceAmounts = createUint48Array(0, 100, 500, 1000, 10000);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueByAccessLevel(_index, 2);
        assertEq(balance, 500);

        /// create secondary token, mint, and transfer to user
        switchToSuperAdmin();
        ApplicationERC20 draculaCoin = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(draculaCoin));
        draculaCoin.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(draculaCoin));
        draculaCoin.mint(appAdministrator, 10000000000000000000000 * ATTO);
        draculaCoin.transfer(user1, 100000 * ATTO);
        assertEq(draculaCoin.balanceOf(user1), 100000 * ATTO);
        erc20Pricer.setSingleTokenPrice(address(draculaCoin), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(draculaCoin)), 1 * ATTO);

        /// connect the rule to this handler
        switchToRuleAdmin();
        applicationHandler.setAccountMaxValueByAccessLevelId(_index);

        ///perform transfer that checks rule when account does not have AccessLevel(should fail)
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(user2, 11 * ATTO);

        /// Add access level to whale
        address whale = address(99);
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(whale, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.stopPrank();
        vm.startPrank(user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(whale, 10001 * ATTO);
        /// this one is within the limit and should pass
        applicationCoin.transfer(whale, 10000 * ATTO);

        // set the access level for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user4, 3);

        vm.stopPrank();
        vm.startPrank(user1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail regardless of other balance)
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(user4, 1001 * ATTO);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail because of other balance)
        draculaCoin.transfer(user4, 999 * ATTO);
        vm.expectRevert(0xaee8b993);
        applicationCoin.transfer(user4, 2 * ATTO);

        /// perform transfer that checks user with AccessLevel and existing balances(should pass)
        applicationCoin.transfer(user4, 1 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 1 * ATTO);

        /// test burning is allowed while rule is active
        applicationCoin.burn(1 * ATTO);
        /// burn remaining balance to ensure rule limit is not checked on burns
        applicationCoin.burn(89998000000000000000000);
        /// test burn with account that has access level assign
        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.burn(1 * ATTO);
        /// test the user account balance is decreased from burn and can receive tokens
        vm.stopPrank();
        vm.startPrank(whale);
        applicationCoin.transfer(user4, 1 * ATTO);
        /// now whale account burns
        applicationCoin.burn(1 * ATTO);
    }

    function testERC20_PauseRulesViaAppManager() public {
        ///Test transfers without pause rule
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);
        applicationCoin.transfer(ruleBypassAccount, 100000);
        assertEq(applicationCoin.balanceOf(ruleBypassAccount), 100000);
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

        ///Check that rule bypass accounts can still transfer within pausePeriod
        switchToRuleBypassAccount();

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

    function testERC20_AccountMaxTransactionValueByRiskScore() public {
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
        uint48[] memory txnLimits = createUint48Array(1000000, 100000, 10000, 1000);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 10000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user1), 10000000 * (10 ** 18));
        applicationCoin.transfer(user2, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user2), 10000 * (10 ** 18));
        applicationCoin.transfer(user3, 1500 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user3), 1500 * (10 ** 18));
        applicationCoin.transfer(user4, 1000000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user4), 1000000 * (10 ** 18));
        applicationCoin.transfer(user5, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(user5), 10000 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user5, riskScores[3]);

        ///Switch to app admin and set up ERC20Pricer and activate AccountMaxTxValueByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        ///User2 sends User1 amount under transaction limit, expect passing
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.transfer(user1, 1 * (10 ** 18));

        ///Transfer expected to fail
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1000001 * (10 ** 18));

        switchToRiskAdmin();
        ///Test in between Risk Score Values
        applicationAppManager.addRiskScore(user3, 49);
        applicationAppManager.addRiskScore(user4, 81);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
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
        vm.expectRevert();
        applicationCoin.burn(1001 * (10 ** 18));
        applicationCoin.burn(1000 * (10 ** 18));
    }

    /// test updating min transfer rule
    function testERC20_PassesAccountDenyForNoAccessLevelRuleCoin() public {
        /// load non admin user with application coin
        applicationCoin.transfer(rich_user, 1000000 * ATTO);
        assertEq(applicationCoin.balanceOf(rich_user), 1000000 * ATTO);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// check transfer without access level but with the rule turned off
        applicationCoin.transfer(user3, 5 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 5 * ATTO);
        /// now turn the rule on so the transfer will fail
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(true);
        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        applicationCoin.transfer(user3, 5 * ATTO);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d);
        applicationCoin.transfer(rich_user, 5 * ATTO);

        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user3, 1);

        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        applicationCoin.transfer(user3, 5 * ATTO);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        applicationCoin.transfer(rich_user, 5 * ATTO);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(rich_user, 1);

        vm.stopPrank();
        vm.startPrank(rich_user);
        applicationCoin.transfer(user3, 5 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 10 * ATTO);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationCoin.transfer(rich_user, 5 * ATTO);

        /// test that burn works when user has accessLevel above 0
        applicationCoin.burn(5 * ATTO);
        /// test burn fails when rule active and user has access level 0
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(rich_user, 0);

        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        applicationCoin.burn(1 * ATTO);
    }

    function testERC20_MaxValueOutByAccessLevel() public {
        /// load non admin user with application coin
        applicationCoin.transfer(user1, 1000 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 1000 * ATTO);
        vm.stopPrank();
        vm.startPrank(user1);
        /// check transfer without access level with the rule turned off
        applicationCoin.transfer(user3, 50 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 50 * ATTO);
        /// price the tokens
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * ATTO);
        /// create and activate rule
        switchToRuleAdmin();
        uint48[] memory withdrawalLimits = createUint48Array(10, 100, 1000, 10000, 100000);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setAccountMaxValueOutByAccessLevelId(index);
        /// test transfers pass under rule value
        //User 1 currently has 950 tokens valued at $950
        //User3 currently has 50 tokens valued at $50
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        applicationAppManager.addAccessLevel(user3, 0);
        applicationAppManager.addAccessLevel(user4, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user3, 50 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 100 * ATTO);
        applicationCoin.transfer(user4, 50 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 50 * ATTO);
        /// User 1 now at "withdrawal" limit for access level
        vm.stopPrank();
        vm.startPrank(user3);
        applicationCoin.transfer(user4, 10 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 60 * ATTO);
        /// User3 now at "withdrawal" limit for access level

        /// test transfers fail over rule value
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x8d857c50);
        applicationCoin.transfer(user3, 50 * ATTO);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x8d857c50);
        applicationCoin.transfer(user4, 50 * ATTO);
        /// reduce price and test pass fail situations
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 5 * (10 ** 17));
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 5 * (10 ** 17));

        vm.stopPrank();
        vm.startPrank(user4);
        /// successful transfer as the new price is $.50USD (can transfer up to $10)
        applicationCoin.transfer(user4, 20 * ATTO);
        /// transfer fails because user reached ACCESS limit
        vm.expectRevert(0x8d857c50);
        applicationCoin.transfer(user3, 10 * ATTO);
    }

    /// test account min max balance rule for blank tags
    function testERC20_AccountMinMaxTokenBalance2() public {
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory minAmounts = createUint256Array((1000 * ATTO), (2000 * ATTO), (3000 * ATTO));
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
        assertEq(_index, 0);
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(_createActionsArray(), _index);
        switchToAppAdministrator();
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * ATTO);
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * ATTO);
        applicationCoin.transfer(user2, 10000 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 10000 * ATTO);
        applicationCoin.transfer(user3, 10000 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 10000 * ATTO);
        /// tag the user
        applicationAppManager.addTag(rich_user, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(rich_user, "Oscar"));
        applicationAppManager.addTag(user2, "Tayler"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Tayler"));
        applicationAppManager.addTag(user3, "Shane"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Shane"));
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// attempt a transfer that violates the rule
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 9001 * ATTO);
        /// make sure a transfer that is acceptable will still pass within the freeze window.
        applicationCoin.transfer(user1, 9000 * ATTO);
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 1 * ATTO);
        /// add enough time so that it should pass
        vm.warp(Blocktime + (720 * 1 hours));
        applicationCoin.transfer(user1, 1 * ATTO);

        /// try tier 2
        /// switch to the user
        vm.stopPrank();
        vm.startPrank(user2);
        /// attempt a transfer that violates the rule
        vm.expectRevert(0xa7fb7b4b);
        applicationCoin.transfer(user1, 8001 * ATTO);
    }

    /// test account min max balance rule for blank tags
    function testERC20_AccountMinMaxTokenBalanceBlankTag2() public {
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory minAmounts = createUint256Array((1000 * (10 ** 18)));
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
        assertEq(_index, 0);
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(_createActionsArray(), _index);
        switchToAppAdministrator();
        /// load non admin users with application coin
        applicationCoin.transfer(rich_user, 10000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(rich_user), 10000 * (10 ** 18));
        /// tag the users(unnecessary but won't hurt)
        applicationAppManager.addTag(rich_user, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(rich_user, "Oscar"));
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
    }

    ///Test transferring coins with fees enabled
    function testERC20_TransactionFeeTableCoin() public {
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

    ///Test transferring coins with fees enabled with blank tags
    function testERC20_TransactionFeeTableCoinBlankTag() public {
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

    ///Test transferring coins with fees and discounts where the discounts are greater than the fees
    function testERC20_TransactionFeeTableDiscountsCoin() public {
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

    ///Test transferring coins with fees enabled using transferFrom
    function testERC20_TransactionFeeTableTransferFrom() public {
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
        vm.startPrank(appAdministrator);
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

    ///Test transferring coins with fees enabled
    function testERC20_TransactionFeeTableCoinGt100() public {
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

    /// test the token AccountMaxTransactionValueByRiskScore in erc20
    function testERC20_AccountMaxTransactionValueByRiskScoreWithPeriod() public {
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
        uint48[] memory txnLimits = createUint48Array(1000000, 100000, 10000, 1000);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 24, uint64(block.timestamp));
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 10000000 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 10000000 * ATTO);
        applicationCoin.transfer(user2, 10000 * ATTO);
        assertEq(applicationCoin.balanceOf(user2), 10000 * ATTO);
        applicationCoin.transfer(user3, 1500 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 1500 * ATTO);
        applicationCoin.transfer(user4, 1000000 * ATTO);
        assertEq(applicationCoin.balanceOf(user4), 1000000 * ATTO);
        applicationCoin.transfer(user5, 10000 * ATTO);
        assertEq(applicationCoin.balanceOf(user5), 10000 * ATTO);

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user5, riskScores[3]);

        ///Switch to app admin and set up ERC20Pricer and activate AccountMaxTxValueByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * ATTO);
        switchToRuleAdmin();
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);

        ///Transfer expected to fail in one large transaction
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationCoin.transfer(user2, 1000001 * ATTO);

        switchToRiskAdmin();
        ///Test in between Risk Score Values
        applicationAppManager.addRiskScore(user3, 49);
        applicationAppManager.addRiskScore(user4, 81);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
        applicationCoin.transfer(user4, 10001 * ATTO);

        vm.stopPrank();
        vm.startPrank(user4);
        applicationCoin.transfer(user3, 10 * ATTO);

        //vm.expectRevert(0x9fe6aeac);
        applicationCoin.transfer(user3, 1001 * ATTO);

        /// test burning tokens while rule is active
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.burn(999 * ATTO);
        vm.expectRevert();
        applicationCoin.burn(1001 * ATTO);
        applicationCoin.burn(1000 * ATTO);

        /// let's test in a new period with a couple small txs:
        vm.warp(block.timestamp + 48 hours);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user6, 1000002 / 2 * ATTO);
        vm.expectRevert();
        applicationCoin.transfer(user6, 1000002 / 2 * ATTO);
    }

    /// test the token max trading volume rule in erc20 when they give a total supply instead of relying on ERC20
    function testERC20_TokenMaxTradingVolumeWithSupplySet() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 4000, 2, Blocktime, 100_000 * ATTO);
        assertEq(_index, 0);
        NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
        assertEq(rule.max, 4000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        /// load non admin users with game coin
        applicationCoin.transfer(rich_user, 100_000 * ATTO);
        assertEq(applicationCoin.balanceOf(rich_user), 100_000 * ATTO);
        /// apply the rule
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMaxTradingVolumeId(_createActionsArray(), _index);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// make sure that transfer under the threshold works
        applicationCoin.transfer(user1, 39_000 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 39_000 * ATTO);
        /// now take it right up to the threshold(39,999)
        applicationCoin.transfer(user1, 999 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * ATTO);
        /// now violate the rule and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationCoin.transfer(user1, 1 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 39_999 * ATTO);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationCoin.transfer(user1, 1 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * ATTO);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationCoin.transfer(user1, 39_999 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 40_000 * ATTO);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationCoin.transfer(user1, 39_999 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * ATTO);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        applicationCoin.transfer(user1, 1 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 79_999 * ATTO);
    }

    /// test supply volatility rule
    function testERC20_TokenMaxSupplyVolatility() public {
        /// burn tokens to specific supply
        applicationCoin.burn(10_000_000_000_000_000_000_000 * ATTO);
        applicationCoin.mint(appAdministrator, 100_000 * ATTO);
        applicationCoin.transfer(user1, 5000 * ATTO);

        /// create rule params
        uint16 volatilityLimit = 1000; /// 10%
        uint8 rulePeriod = 24; /// 24 hours
        uint64 _startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token

        /// set rule id and activate
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), volatilityLimit, rulePeriod, _startTime, tokenSupply);
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        // load actions with mint and burn rather than P2P_Transfer
        actionTypes[0] = ActionTypes.BURN;
        actionTypes[1] = ActionTypes.MINT;
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMaxSupplyVolatilityId(actionTypes, _index);
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

    function _tradeRuleSetup() internal returns(DummyAMM){
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = initializeAMMAndUsers();
        applicationCoin2.transfer(user1, 50_000_000 * ATTO);
        applicationCoin2.transfer(user2, 30_000_000 * ATTO);
        applicationCoin.transfer(user1, 50_000_000 * ATTO);
        applicationCoin.transfer(user2, 30_000_000 * ATTO);
        assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * ATTO);
        return amm;
    }

    function _setupAccountMaxSellSize() internal {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory maxSizes = new uint192[](1);
        uint16[] memory period = new uint16[](1);
        accs[0] = bytes32("AccountMaxSellSize");
        maxSizes[0] = uint192(600); ///Amount to trigger Sell freeze rules
        period[0] = uint16(36); ///Hours

        /// Set the rule data
        applicationAppManager.addTag(user1, "AccountMaxSellSize");
        applicationAppManager.addTag(user2, "AccountMaxSellSize");
        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, maxSizes, period, uint64(Blocktime));
        ///update ruleId in application AMM rule handler
        TradingRuleFacet(address(applicationCoinHandler)).setAccountMaxSellSizeId(ruleId);
    }

    function _setupAccountMaxSellSizeBlankTag() internal {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory maxSizes = new uint192[](1);
        uint16[] memory period = new uint16[](1);
        accs[0] = bytes32("");
        maxSizes[0] = uint192(600); ///Amount to trigger Sell freeze rules
        period[0] = uint16(36); ///Hours

        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, maxSizes, period, uint64(Blocktime));
        ///update ruleId in token handler
        TradingRuleFacet(address(applicationCoinHandler)).setAccountMaxSellSizeId(ruleId);
    }

    function _setupAccountMaxBuySizeRule() internal {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory amounts = new uint256[](1);
        uint16[] memory period = new uint16[](1);
        accs[0] = bytes32("MaxBuySize");
        amounts[0] = uint256(600); ///Amount to trigger Purchase freeze rules
        period[0] = uint16(36); ///Hours

        /// Set the rule data
        applicationAppManager.addTag(user1, accs[0]);
        applicationAppManager.addTag(user2, accs[0]);
        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, amounts, period, uint64(Blocktime));
        ///update ruleId in token handler
        TradingRuleFacet(address(applicationCoinHandler)).setAccountMaxBuySizeId(ruleId);
    }

    function _setupAccountMaxBuySizeRuleBlankTag() internal {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory amounts = new uint256[](1);
        uint16[] memory period = new uint16[](1);
        accs[0] = bytes32("");
        amounts[0] = uint256(600); ///Amount to trigger Purchase freeze rules
        period[0] = uint16(36); ///Hours

        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, amounts, period, uint64(Blocktime));
        ///update ruleId in token handler
        TradingRuleFacet(address(applicationCoinHandler)).setAccountMaxBuySizeId(ruleId);
    }

    ///TODO Test sell rule through AMM once Purchase functionality is created
    function testERC20_AccountMaxSellSize() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 50000);
        _setupAccountMaxSellSize();
        
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);

        /// Swap that fails
        vm.expectRevert(0x91985774);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);
    }

    ///TODO Test sell rule through AMM once Purchase functionality is created
    function testERC20_AccountMaxSellSizeBlankTag() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 50000);
        _setupAccountMaxSellSizeBlankTag();
        
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);

        /// Swap that fails
        vm.expectRevert(0x91985774);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);
    }

    function testERC20_AccountMaxBuySizeRule() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxBuySizeRule();
        
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(applicationCoin), 500, 500, true);

        /// Swap that fails
        vm.expectRevert(0xa7fb7b4b);
        amm.dummyTrade(address(applicationCoin2), address(applicationCoin), 500, 500, true);
    }

    function testERC20_AccountMaxBuySizeRuleBlankTag() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxBuySizeRuleBlankTag();
        
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(applicationCoin), 500, 500, true);

        /// Swap that fails
        vm.expectRevert(0xa7fb7b4b);
        amm.dummyTrade(address(applicationCoin2), address(applicationCoin), 500, 500, true);
    }

    function _setupTokenMaxBuyVolumeRule() internal {    
        uint16 tokenPercentage = 5000; /// 50%
        uint16 period = 24; /// 24 hour periods
        uint256 _totalSupply = 100_000_000;
        uint64 ruleStartTime = Blocktime;
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        /// add and activate rule
        TradingRuleFacet(address(applicationCoinHandler)).setTokenMaxBuyVolumeId(ruleId);
    }

    function _setupTokenMaxBuyVolumeRuleB() internal {    
        uint16 tokenPercentage = 1; /// 0.01%
        uint16 period = 24; /// 24 hour periods
        uint256 _totalSupply = 100_000;
        uint64 ruleStartTime = Blocktime;
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        /// add and activate rule
        TradingRuleFacet(address(applicationCoinHandler)).setTokenMaxBuyVolumeId(ruleId);
    }


    function testERC20_TokenMaxBuyVolumeRule() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuyVolumeRule();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        uint256 initialCoinBalance = applicationCoin.balanceOf(user1);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 40_000_000, 40_000_000, false); /// percentage limit hit now
        assertEq(applicationCoin.balanceOf(user1), initialCoinBalance + 40_000_000);
        /// test swaps after we hit limit
        vm.expectRevert(0x6a46d1f4);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, false);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        vm.expectRevert(0x6a46d1f4);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, false);
        /// wait until new period
        vm.warp(Blocktime + 36 hours + 30 hours);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, false);

        /// check that rule does not apply to coin 0 as this would be a sell
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, true);

        /// Low percentage rule checks
        switchToRuleAdmin();
        /// create new rule
        _setupTokenMaxBuyVolumeRuleB();
        vm.warp(Blocktime + 96 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 1, 1, false);

        vm.expectRevert(0x6a46d1f4);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 9, 9, false);
    }
    
    function _setupTokenMaxSellVolumeRule() internal {
        uint16 tokenPercentage = 5000; /// 50%
        uint16 period = 24; /// 24 hour periods
        uint256 _totalSupply = 100_000_000;
        uint64 ruleStartTime = Blocktime;
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxSellVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        /// add and activate rule
        TradingRuleFacet(address(applicationCoinHandler)).setTokenMaxSellVolumeId(ruleId);
    }

    function testERC20_TokenMaxSellVolumeRule() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxSellVolumeRule();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 40_000_000, 40_000_000, true); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0x806a3391);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, true);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        vm.expectRevert(0x806a3391);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, true);
        /// wait until new period
        vm.warp(Blocktime + 36 hours + 30 hours);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 10_000_000, 10_000_000, true);

        /// check that rule does not apply to coin 0 as this would be a sell
        // amm.swap(address(applicationCoin2), 60_000_000);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, false);
    }

    function testERC20_TradeRuleByPasserRule() public {
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleWhitelist(user1, true);

        /// SELL PERCENTAGE RULE
        _setupTokenMaxSellVolumeRule();
        vm.warp(Blocktime + 36 hours);
        /// WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, true);
        /// NOT WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 40_000_000, 40_000_000, true);
        vm.expectRevert(0x806a3391);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 20_000_000, 20_000_000, true);

        //BUY PERCENTAGE RULE
        _setupTokenMaxBuyVolumeRule();
        /// WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, false);
        /// NOT WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user2);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 30_000_000, 30_000_000, false);
        vm.expectRevert(0x6a46d1f4);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 30_000_000, 30_000_000, false);

        /// SELL RULE
        _setupAccountMaxSellSize();
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 500, 500, true);
    }

     function initializeAMMAndUsers() public returns (DummyAMM amm){
        amm = new DummyAMM();
        applicationCoin2.mint(appAdministrator, 1_000_000_000_000 * ATTO);
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(amm), 1_000_000 * ATTO);
        applicationCoin2.approve(address(amm), 1_000_000 * ATTO);
        /// Transfer the tokens into the AMM
        applicationCoin.transfer(address(amm), 1_000_000 * ATTO);
        applicationCoin2.transfer(address(amm), 1_000_000 * ATTO);
        /// Make sure the tokens made it
        assertEq(applicationCoin.balanceOf(address(amm)), 1_000_000 * ATTO);
        assertEq(applicationCoin2.balanceOf(address(amm)), 1_000_000 * ATTO);
        applicationCoin.transfer(user1, 1000 * ATTO);
        applicationCoin.transfer(user2, 1000 * ATTO);
        applicationCoin.transfer(user3, 1000 * ATTO);
        applicationCoin.transfer(rich_user, 1000 * ATTO);
        applicationCoin2.transfer(user1, 1000 * ATTO);
        applicationCoin2.transfer(user2, 1000 * ATTO);
        applicationCoin.transfer(address(69), 1000 * ATTO);
        applicationCoin2.transfer(address(69), 1000 * ATTO);
    }

}

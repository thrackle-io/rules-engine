// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

contract ApplicationERC20Test is TestCommonFoundry, ERC20Util,DummyAMM {

    uint32[][] ruleId2D;
    uint32[][] ruleId2D_2;

    function setUp() public {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 10_000_000_000_000_000_000_000 * ATTO);
        vm.warp(Blocktime);
        vm.stopPrank();
    }

    function testERC20_ApplicationERC20_ERC20AndHandlerVersions() public {
        string memory version = VersionFacet(address(applicationCoinHandler)).version();
        assertEq(version, "1.1.0");
    }

    function testERC20_ApplicationERC20_DeregisterTokenEmission() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,true,false,false);
        emit AD1467_RemoveFromRegistry("FRANK", address(applicationCoin));
        applicationAppManager.deregisterToken("FRANK");
    }

    function testERC20_ApplicationERC20_UpdateTokenEmission() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,true,false,false);
        emit AD1467_TokenNameUpdated("FRANK", address(applicationCoin));
        applicationAppManager.registerToken("FRANK", address(applicationCoin));
    }

    function testERC20_ApplicationERC20_ProposeAndConfirmAppManager() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,false,false,false);
        emit AD1467_AppManagerAddressProposed(address(applicationAppManager));
        HandlerBase(address(applicationCoinHandler)).proposeAppManagerAddress(address(applicationAppManager));

        vm.expectEmit(true,false,false,false);
        emit AD1467_AppManagerAddressSet(address(applicationAppManager));
        applicationAppManager.confirmAppManager(address(applicationCoinHandler));
    }

    function testERC20_ApplicationERC20_OracleApproveEventEmission() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,false,false,false);
        emit AD1467_OracleListChanged(true, ADDRESSES);
        oracleApproved.addToApprovedList(ADDRESSES);
    }

    function testERC20_ApplicationERC20_ActionAppliedEventEmission() public endWithStopPrank() {
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(1000));
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        switchToRuleAdmin();
        vm.expectEmit(true,true,true,false);
        emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MIN_MAX_TOKEN_BALANCE, ActionTypes.P2P_TRANSFER, ruleId);
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
    }

    function testERC20_ApplicationERC20_OracleDeniedEventEmission() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,false,false,false);
        emit AD1467_OracleListChanged(true, ADDRESSES);
        oracleDenied.addToDeniedList(ADDRESSES);
    }

     function testERC20_ApplicationERC20_OnlyTokenCanCallCheckAllRules() public{
        address handler = applicationCoin.getHandlerAddress();
        assertEq(handler, address(applicationCoinHandler));
        address owner = ERC173Facet(address(applicationCoinHandler)).owner();
        assertEq(owner, address(applicationCoin));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC20_ApplicationERC20_AlreadyInitialized() public endWithStopPrank(){
        vm.startPrank(address(applicationCoin));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC20HandlerMainFacet(address(applicationCoinHandler)).initialize(user1, user2, user3);
    }

    /// Test balance
    function testERC20_ApplicationERC20_Balance() public {
        console.logUint(applicationCoin.totalSupply());
        assertEq(applicationCoin.balanceOf(appAdministrator), 10000000000000000000000 * ATTO);
    }

    function testERC20_ApplicationERC20_Mint() public {
        applicationCoin.mint(superAdmin, 1000);
    }

    /// Test token transfer
    function testERC20_ApplicationERC20_Transfer() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user, 10 * ATTO);
        assertEq(applicationCoin.balanceOf(user), 10 * ATTO);
        assertEq(applicationCoin.balanceOf(appAdministrator), 9999999999999999999990 * ATTO);
    }

    function testERC20_ApplicationERC20_ZeroAddressChecksERC20() public {
        vm.expectRevert();
        new ApplicationERC20("FRANK", "FRANK", address(0x0));
        vm.expectRevert();
        applicationCoin.connectHandlerToToken(address(0));
    }

    function testERC20_ApplicationERC20_testTokenMinTransactionSize() public endWithStopPrank() {
        uint32 ruleId = createTokenMinimumTransactionRule(10);
        setTokenMinimumTransactionRule(address(applicationCoinHandler), ruleId);
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

    function testERC20_ApplicationERC20_AccountMinMaxTokenBalance() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(1000)); 
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
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
        vm.expectRevert(0x3e237976);
        applicationCoin.transfer(user3, 989);
        // see if approving for another user bypasses rule
        applicationCoin.approve(address(888), 989);
        vm.stopPrank();
        vm.startPrank(address(888));
        vm.expectRevert(0x3e237976);
        applicationCoin.transferFrom(user1, user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x1da56a44);
        applicationCoin.transfer(user2, 10091);
    }

    function testERC20_ApplicationERC20_AccountMinMaxTokenBalanceBlankTag3() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(rich_user, 100000);
        assertEq(applicationCoin.balanceOf(rich_user), 100000);
        applicationCoin.transfer(user1, 1000);
        assertEq(applicationCoin.balanceOf(user1), 1000);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(10), createUint256Array(1000));
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.transfer(user2, 10);
        assertEq(applicationCoin.balanceOf(user2), 10);
        assertEq(applicationCoin.balanceOf(user1), 990);

        // make sure the minimum rules fail results in revert
        vm.expectRevert(0x3e237976);
        applicationCoin.transfer(user3, 989);
        // see if approving for another user bypasses rule
        applicationCoin.approve(address(888), 989);
        vm.stopPrank();
        vm.startPrank(address(888));
        vm.expectRevert(0x3e237976);
        applicationCoin.transferFrom(user1, user3, 989);

        /// make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        vm.expectRevert(0x1da56a44);
        applicationCoin.transfer(user2, 10091);
    }

    function testERC20_ApplicationERC20_AccountApproveDenyOracle() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
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

        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
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
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
        /// test burning while oracle rule is active (allow list active)
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        /// first mint to user
        switchToAppAdministrator();
        applicationCoin.transfer(user5, 10000);
        /// burn some tokens as user
        /// burns do not check for the recipient address as it is address(0)
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.burn(5000);
        /// add address(0) to deny list and switch oracle rule to deny list
        ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// attempt to burn (should fail)
        vm.stopPrank();
        vm.startPrank(user5);
        vm.expectRevert(0x2767bda4);
        applicationCoin.burn(5000);
    }

    function testERC20_ApplicationERC20_AccountApproveDenyOracleAddSingleAddress() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000);
        assertEq(applicationCoin.balanceOf(user1), 100000);

        /// Test adding single address to allow list 
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
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
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).activateAccountApproveDenyOracle(_createActionsArray(), false, ruleId);
        ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        /// connect the rule to this handler
        switchToRuleAdmin();
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), ruleId);
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

    function testERC20_ApplicationERC20_AccountMaxValueByAccessLevel() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        applicationCoin.transfer(user1, 100000 * ATTO);
        assertEq(applicationCoin.balanceOf(user1), 100000 * ATTO);
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

        /// create and connect the rule to this handler
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, 100, 500, 1000, 10000);
        setAccountMaxValueByAccessLevelRule(ruleId);
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
 
    function testERC20_ApplicationERC20_PauseRulesViaAppManager() public endWithStopPrank() {
        switchToAppAdministrator();
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

    function testERC20_ApplicationERC20_AccountMaxTransactionValueByRiskScore() public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
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

        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(1000000, 100000, 10000, 1000));
        setAccountMaxTxValueByRiskRule(ruleId);
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

        applicationCoin.transfer(user3, 1001 * (10 ** 18));

        /// test burning tokens while rule is active
        vm.stopPrank();
        vm.startPrank(user5);
        applicationCoin.burn(999 * (10 ** 18));
        vm.expectRevert();
        applicationCoin.burn(1001 * (10 ** 18));
        applicationCoin.burn(1000 * (10 ** 18));
    }

    function testERC20_ApplicationERC20_PassesAccountDenyForNoAccessLevelRuleCoin() public endWithStopPrank() {
        switchToAppAdministrator();
        /// load non admin user with application coin
        applicationCoin.transfer(rich_user, 1000000 * ATTO);
        assertEq(applicationCoin.balanceOf(rich_user), 1000000 * ATTO);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// check transfer without access level but with the rule turned off
        applicationCoin.transfer(user3, 5 * ATTO);
        assertEq(applicationCoin.balanceOf(user3), 5 * ATTO);
        /// now turn the rule on so the transfer will fail
        createAccountDenyForNoAccessLevelRule(); 
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

    function testERC20_ApplicationERC20_MaxValueOutByAccessLevel() public endWithStopPrank() {
        switchToAppAdministrator();
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
        uint32 ruleId = createAccountMaxValueOutByAccessLevelRule(10, 100, 1000, 10000, 100000);
        setAccountMaxValueOutByAccessLevelRule(ruleId); 
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

    function testERC20_ApplicationERC20_AccountMinMaxTokenBalance2() public endWithStopPrank() {
        switchToAppAdministrator();
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
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
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

    function testERC20_ApplicationERC20_AccountMinMaxTokenBalanceBlankTag2() public endWithStopPrank() {
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory minAmounts = createUint256Array((1000 * (10 ** 18)));
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
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

    function testERC20_ApplicationERC20_AddFeeEventEmission() public endWithStopPrank() {
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        vm.expectEmit(true,true,true,true);
        emit AD1467_FeeType("cheap",true, minBalance, maxBalance, feePercentage, targetAccount);
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
    }

    function testERC20_ApplicationERC20_SetFeeEventEmission() public endWithStopPrank() {
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);

        vm.expectEmit(true,true,true,true);
        emit AD1467_FeeActivationSet(false);
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
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

    /// test the token AccountMaxTransactionValueByRiskScore in erc20
    function testERC20_ApplicationERC20_AccountMaxTransactionValueByRiskScoreWithPeriod() public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
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
        uint8 period = 24; 
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(1000000, 100000, 10000, 1000), period); 
        setAccountMaxTxValueByRiskRule(ruleId);
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

    function testERC20_ApplicationERC20_TokenMaxTradingVolumeWithSupplySet() public endWithStopPrank() {
        switchToAppAdministrator();
        /// load non admin users with game coin
        applicationCoin.transfer(rich_user, 100_000 * ATTO);
        assertEq(applicationCoin.balanceOf(rich_user), 100_000 * ATTO);
        /// apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        setTokenMaxTradingVolumeRule(address(applicationCoinHandler), ruleId);
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

    function _setupAccountMaxSellSize() internal endWithStopPrank() {
        switchToSuperAdmin();
        ///Add tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "AccountMaxSellSize");
        applicationAppManager.addTag(user2, "AccountMaxSellSize");
        /// add the rule. 
        uint32 ruleId = createAccountMaxSellSizeRule("AccountMaxSellSize", 600, 36);
        setAccountMaxSellSizeRule(address(applicationCoinHandler), ruleId);
    }

    function _setupAccountMaxSellSizeBlankTag() internal {
        /// add the rule.
        uint32 ruleId = createAccountMaxSellSizeRule("", 600, 36);
        setAccountMaxSellSizeRule(address(applicationCoinHandler), ruleId);
    }

    function _setupAccountMaxBuySizeRule() internal endWithStopPrank() {
        switchToAppAdministrator();
        /// Add tag to users
        applicationAppManager.addTag(user1, "MaxBuySize");
        applicationAppManager.addTag(user2, "MaxBuySize");
        /// add the rule.
        uint32 ruleId = createAccountMaxBuySizeRule("MaxBuySize", 600, 36); 
        setAccountMaxBuySizeRule(address(applicationCoinHandler), ruleId);
    }

    function _setupAccountMaxBuySizeRuleBlankTag() internal {
        uint32 ruleId = createAccountMaxBuySizeRule("", 600, 36);
        setAccountMaxBuySizeRule(address(applicationCoinHandler), ruleId);
    }

    ///TODO Test sell rule through AMM once Purchase functionality is created
    function testERC20_ApplicationERC20_AccountMaxSellSize() public endWithStopPrank() {
        switchToAppAdministrator();
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
    function testERC20_ApplicationERC20_AccountMaxSellSizeBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
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

    function testERC20_ApplicationERC20_AccountMaxBuySizeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxBuySizeRule();
        switchToAppAdministrator();
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

    function testERC20_ApplicationERC20_AccountMaxBuySizeRuleBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
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

    function testERC20_ApplicationERC20_TokenMaxBuyVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        uint32 ruleId = createTokenMaxBuyVolumeRule(5000, 24, 100_000_000, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleId);
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
        ruleId = createTokenMaxBuyVolumeRule(1, 24, 100_000, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleId);
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

    function testERC20_ApplicationERC20_TokenMaxSellVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        uint32 ruleId = createTokenMaxSellVolumeRule(5000, 24, 100_000_000, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationCoinHandler), ruleId);
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

    function testERC20_ApplicationERC20_TradeRuleByPasserRule() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);

        /// SELL PERCENTAGE RULE
        uint32 ruleId = createTokenMaxSellVolumeRule(5000, 24, 100_000_000, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationCoinHandler), ruleId);
        vm.warp(Blocktime + 36 hours);
        /// ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, true);
        /// NOT ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 40_000_000, 40_000_000, true);
        vm.expectRevert(0x806a3391);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 20_000_000, 20_000_000, true);

        //BUY PERCENTAGE RULE
        uint32 ruleIdBuy = createTokenMaxBuyVolumeRule(5000, 24, 100_000_000, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationCoinHandler), ruleIdBuy);
        /// ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        amm.dummyTrade(address(applicationCoin), address(applicationCoin2), 60_000_000, 60_000_000, false);
        /// NOT ALLOWLISTED USER
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

    /*********************** Atomic Rule Setting Tests ************************************/
    /* These tests insure that the atomic setting/application of rules is functioning properly */

    /* MinMaxTokenBalance */
    function testApplicationERC20_AccountMinMaxTokenBalanceAtomicFullSet() public {
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
        // Set up rule
        for(uint i; i < 5;i++){
            ruleId2D.push([createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0)]);
        }
        
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes(0), ActionTypes(1), ActionTypes(2), ActionTypes(3), ActionTypes(4));
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleId2D);
        // Verify that all the rule id's were set correctly and are active
        for(uint i; i < 5;i++){
            for(uint j; j < 4; j++){
                assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes(i))[j],ruleId2D[i][j]);
                assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes(i),ruleId2D[i][j]));
            }
        }
        
    }

    function testApplicationERC20_AccountApproveDenyOracleAtomicFullReSet() public {
        // Set up rule
        for(uint i; i < 5;i++){
            ruleId2D.push([createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0)]);
        }
        
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleId2D);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        for(uint i; i < 2;i++){
            ruleId2D_2.push([createAccountApproveDenyOracleRule(0),createAccountApproveDenyOracleRule(0)]);
        }
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleId2D_2);
        // // Verify that all the rule id's were set correctly 
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.SELL)[0],ruleId2D_2[0][0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.SELL)[1],ruleId2D_2[0][1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BUY)[0],ruleId2D_2[1][0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BUY)[1],ruleId2D_2[1][1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.MINT).length,0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BURN).length,0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.SELL,ruleId2D_2[0][0]));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.SELL,ruleId2D_2[0][1]));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BUY,ruleId2D_2[1][0]));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BUY,ruleId2D_2[1][1]));
        // // // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.MINT,ruleId2D[0][0]));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.MINT,ruleId2D[0][1]));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.MINT,ruleId2D[0][2]));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BURN,ruleId2D[0][0]));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BURN,ruleId2D[0][1]));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BURN,ruleId2D[0][2]));
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
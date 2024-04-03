// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";

abstract contract ERC20CommonTests is TestCommonFoundry, DummyAMM, ERC20Util {
    IERC20 testCaseToken;

    function testERC20_ERC20CommonTests_ERC20AndHandlerVersions() public view {
        string memory version = VersionFacet(address(applicationCoinHandler)).version();
        assertEq(version, "1.1.0");
    }

    function testERC20_ERC20CommonTests_DeregisterTokenEmission_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_RemoveFromRegistry("FRANK", address(testCaseToken));
        applicationAppManager.deregisterToken("FRANK");
    }

    function testERC20_ERC20CommonTests_DeregisterTokenEmission_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectRevert(0x7de8c17d);
        // Using a token name that is not already registered.
        applicationAppManager.deregisterToken("FRANKYBOY");
    }

    function testERC20_ERC20CommonTests_UpdateTokenEmission_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, true, false, false);
        emit AD1467_TokenNameUpdated("FRANK", address(testCaseToken));
        applicationAppManager.registerToken("FRANK", address(testCaseToken));
    }

    function testERC20_ERC20CommonTests_UpdateTokenEmission_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectRevert(0xd92e233d);
        // Attempting to register the zero address
        applicationAppManager.registerToken("FRANK", address(0));
    }

    function testERC20_ERC20CommonTests_ProposeAndConfirmAppManager_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, false, false, false);
        emit AD1467_AppManagerAddressProposed(address(applicationAppManager));
        HandlerBase(address(applicationCoinHandler)).proposeAppManagerAddress(address(applicationAppManager));

        vm.expectEmit(true, false, false, false);
        emit AD1467_AppManagerAddressSet(address(applicationAppManager));
        applicationAppManager.confirmAppManager(address(applicationCoinHandler));
    }

    function testERC20_ERC20CommonTests_ProposeAndConfirmAppManager_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, false, false, false);
        emit AD1467_AppManagerAddressProposed(address(applicationAppManager));
        HandlerBase(address(applicationCoinHandler)).proposeAppManagerAddress(address(applicationAppManager));

        vm.expectRevert(0x821e0eeb);
        // confirming a different address than was proposed.
        applicationAppManager.confirmAppManager(address(testCaseToken));
    }

    function testERC20_ERC20CommonTests_OracleApproveEventEmission_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, false, false, false);
        emit AD1467_OracleListChanged(true, ADDRESSES);
        oracleApproved.addToApprovedList(ADDRESSES);
    }

    function testERC20_ERC20CommonTests_OracleApproveEventEmission_Negative() public endWithStopPrank {
        // switch to an address other than the owner
        switchToSuperAdmin();
        vm.expectRevert("Ownable: caller is not the owner");
        oracleApproved.addToApprovedList(ADDRESSES);
    }

    function testERC20_ERC20CommonTests_ActionAppliedEventEmission_Positive() public endWithStopPrank {
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(1000));
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        switchToRuleAdmin();
        vm.expectEmit(true, true, true, false);
        emit AD1467_ApplicationHandlerActionApplied(ACCOUNT_MIN_MAX_TOKEN_BALANCE, ActionTypes.P2P_TRANSFER, ruleId);
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
    }

    function testERC20_ERC20CommonTests_ActionAppliedEventEmission_Negative() public endWithStopPrank {
        createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(1000));
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        switchToRuleAdmin();
        vm.expectRevert(0x4bdf3b46);
        // Use a rule id that doesn't map to an actual rule
        ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(actionTypes, 123);
    }

    function testERC20_ERC20CommonTests_OracleDeniedEventEmission_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, false, false, false);
        emit AD1467_OracleListChanged(true, ADDRESSES);
        oracleDenied.addToDeniedList(ADDRESSES);
    }

    function testERC20_ERC20CommonTests_OracleDeniedEventEmission_Negative() public endWithStopPrank {
        // switch to an address other than the owner
        switchToSuperAdmin();
        vm.expectRevert("Ownable: caller is not the owner");
        oracleDenied.addToDeniedList(ADDRESSES);
    }

    function testERC20_ERC20CommonTests_AddFeeEventEmission() public endWithStopPrank {
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        vm.expectEmit(true, true, true, true);
        emit AD1467_FeeType("cheap", true, minBalance, maxBalance, feePercentage, targetAccount);
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);
    }

    function testERC20_ERC20CommonTests_SetFeeEventEmission() public endWithStopPrank {
        uint256 minBalance = 10 * ATTO;
        uint256 maxBalance = 10000000 * ATTO;
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        // create a fee
        switchToRuleAdmin();
        FeesFacet(address(applicationCoinHandler)).addFee("cheap", minBalance, maxBalance, feePercentage, targetAccount);

        vm.expectEmit(true, true, true, true);
        emit AD1467_FeeActivationSet(false);
        FeesFacet(address(applicationCoinHandler)).setFeeActivation(false);
    }

    function testERC20_ERC20CommonTests_OnlyTokenCanCallCheckAllRules() public endWithStopPrank {
        address handler = IProtocolTokenMin(address(testCaseToken)).getHandlerAddress();
        assertEq(handler, address(applicationCoinHandler));
        address owner = ERC173Facet(address(applicationCoinHandler)).owner();
        assertEq(owner, address(testCaseToken));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC20_ERC20CommonTests_AlreadyInitialized() public endWithStopPrank {
        vm.startPrank(address(testCaseToken));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC20HandlerMainFacet(address(applicationCoinHandler)).initialize(user1, user2, user3);
    }

    /// Test balance
    function testERC20_ERC20CommonTests_Balance_Positive() public view {
        console.logUint(testCaseToken.totalSupply());
        assertEq(testCaseToken.balanceOf(appAdministrator), 10000000000000000000000 * ATTO);
    }

    function testERC20_ERC20CommonTests_Balance_Negative() public view {
        console.logUint(testCaseToken.totalSupply());
        assertFalse(testCaseToken.balanceOf(appAdministrator) == (10000000000000000000 * ATTO));
    }

    function testERC20_ERC20CommonTests_Mint() public endWithStopPrank {
        switchToAppAdministrator();
        ProtocolERC20(address(testCaseToken)).mint(superAdmin, 1000);
        assertEq(testCaseToken.balanceOf(superAdmin), 1000);
    }

    /// Test token transfer
    function testERC20_ERC20CommonTests_Transfer_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        testCaseToken.transfer(user, 10 * ATTO);
        assertEq(testCaseToken.balanceOf(user), 10 * ATTO);
        assertEq(testCaseToken.balanceOf(appAdministrator), 9999999999999999999990 * ATTO);
    }

    function testERC20_ERC20CommonTests_Transfer_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        testCaseToken.transfer(user, 10000000000000000000001 * ATTO);
    }

    function testERC20_ERC20CommonTests_ZeroAddressCheckERC20Token() public {
        vm.expectRevert(0xd92e233d);
        new ApplicationERC20("FRANK", "FRANK", address(0x0));
    }

    function testERC20_ERC20CommonTests_ZeroAddressCheckERC20HandlerConnection() public {
        vm.expectRevert(0xba80c9e5);
        IProtocolTokenMin(address(testCaseToken)).connectHandlerToToken(address(0));
    }

    /// Token Minimum Transaction Size Tests
    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_P2PTransfer_Positive() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        vm.startPrank(rich_user);
        // now we check for an allowed transfer
        testCaseToken.transfer(user3, 10);
        assertEq(testCaseToken.balanceOf(user3), 10);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_P2PTransfer_Negative() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        vm.startPrank(rich_user);
        // now we check for proper failure
        vm.expectRevert(0x7a78c901);
        testCaseToken.transfer(user3, 5);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Sell_Positive() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.SELL);
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(rich_user);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Sell_Negative() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.SELL);
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(rich_user);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(0x7a78c901);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 5, 5, true);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Buy_Positive() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.BUY);
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.startPrank(rich_user);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Buy_Negative() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.BUY);
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();

        vm.startPrank(rich_user);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(0x7a78c901);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 5, 5, true);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Mint_Positive() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        switchToAppAdministrator();
        // now we check for an allowed transfer
        ProtocolERC20(address(testCaseToken)).mint(user3, 10);
        assertEq(testCaseToken.balanceOf(user3), 10);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Mint_Negative() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        switchToAppAdministrator();
        vm.expectRevert(0x7a78c901);
        ProtocolERC20(address(testCaseToken)).mint(user3, 5);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Burn_Positive() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        vm.startPrank(rich_user);
        // now we check for an allowed transfer
        ERC20Burnable(address(testCaseToken)).burn(10);
        assertEq(testCaseToken.balanceOf(rich_user), 999990);
    }

    function testERC20_ERC20CommonTests_testTokenMinTransactionSize_Burn_Negative() public endWithStopPrank {
        _tokenMinTransactionSetup(ActionTypes.P2P_TRANSFER);
        vm.startPrank(rich_user);
        vm.expectRevert(0x7a78c901);
        ERC20Burnable(address(testCaseToken)).burn(5);
    }

    /// Account Min Max Token Balance Tests
    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(true, false);
        ///perform transfer that checks rule but is allowed
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
        assertEq(testCaseToken.balanceOf(user1), 990);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_P2PTransfer_Positive() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.P2P_TRANSFER);
        ///perform transfer that checks rule but is allowed
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
        assertEq(testCaseToken.balanceOf(user1), 90);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_P2PTransfer_Negative() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.P2P_TRANSFER);
        ///perform transfer that checks rule but is allowed
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        testCaseToken.transfer(user2, 99);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Buy_Positive() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.BUY);
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = new DummyAMM();
        testCaseToken.approve(address(amm), 50);
        applicationCoin2.approve(address(amm), 50);
        vm.startPrank(rich_user);
        testCaseToken.transfer(address(amm), 900);
        applicationCoin2.transfer(address(amm), 900);
        applicationCoin2.transfer(user1, 900);
        vm.startPrank(user1);

        assertEq(testCaseToken.balanceOf(user1), 100);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Buy_Negative() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.BUY);
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = new DummyAMM();
        vm.startPrank(rich_user);
        testCaseToken.transfer(address(amm), 950);
        applicationCoin2.transfer(address(amm), 950);
        applicationCoin2.transfer(user1, 950);
        vm.startPrank(user1);

        assertEq(testCaseToken.balanceOf(user1), 100);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 901, 901, true);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Sell_Positive() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.SELL);
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = new DummyAMM();
        testCaseToken.approve(address(amm), 50);
        applicationCoin2.approve(address(amm), 50);
        vm.startPrank(rich_user);
        testCaseToken.transfer(address(amm), 900);
        applicationCoin2.transfer(address(amm), 900);
        vm.startPrank(user1);

        assertEq(testCaseToken.balanceOf(user1), 100);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Sell_Negative() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.SELL);
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = new DummyAMM();
        vm.startPrank(rich_user);
        testCaseToken.transfer(address(amm), 900);
        applicationCoin2.transfer(address(amm), 900);
        vm.startPrank(user1);

        assertEq(testCaseToken.balanceOf(user1), 100);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 100, 100, true);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Mint_Positive() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.MINT);
        ///perform transfer that checks rule but is allowed
        switchToAppAdministrator();
        ProtocolERC20(address(testCaseToken)).mint(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
        assertEq(testCaseToken.balanceOf(user1), 100);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Mint_Negative() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.MINT);
        ///perform transfer that checks rule but is allowed
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ProtocolERC20(address(testCaseToken)).mint(user2, 1001);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Burn_Positive() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.BURN);
        ///perform transfer that checks rule but is allowed
        vm.startPrank(user1);
        ERC20Burnable(address(testCaseToken)).burn(10);
        assertEq(testCaseToken.balanceOf(user1), 90);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Burn_Negative() public endWithStopPrank {
        _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes.BURN);
        ///perform transfer that checks rule but is allowed
        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ERC20Burnable(address(testCaseToken)).burn(100);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Minimum() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(true, false);
        vm.startPrank(user1);
        // make sure the minimum rules fail results in revert
        vm.expectRevert(0x3e237976);
        testCaseToken.transfer(user3, 999);
        // see if approving for another user bypasses rule
        testCaseToken.approve(address(888), 999);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Maximum() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(true, false);
        /// make sure the maximum rule fail results in revert
        vm.startPrank(rich_user);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        testCaseToken.transfer(user2, 10091);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_Period() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(true, true);
        vm.startPrank(rich_user);
        /// make sure a transfer that is acceptable will still pass within the freeze window.
        testCaseToken.transfer(user1, 1000);
        vm.expectRevert(0xa7fb7b4b);
        testCaseToken.transfer(user1, 1);
        /// add enough time so that it should pass
        vm.warp(Blocktime + (720 * 1 hours));
        testCaseToken.transfer(user1, 1);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_BlankTag() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(false, false);
        ///perform transfer that checks rule
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
        assertEq(testCaseToken.balanceOf(user1), 990);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_BlankTag_Minimum() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(false, false);
        ///perform transfer that checks rule
        vm.startPrank(user1);

        // make sure the minimum rules fail results in revert
        vm.expectRevert(0x3e237976);
        testCaseToken.transfer(user3, 999);
        // see if approving for another user bypasses rule
        testCaseToken.approve(address(888), 999);
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalance_BlankTag_Maximum() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup(false, false);
        /// make sure the maximum rule fail results in revert
        vm.startPrank(rich_user);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        testCaseToken.transfer(user2, 10091);
    }

    /// Account Approve Deny Oracle Tests
    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 100000);
        assertEq(testCaseToken.balanceOf(user1), 100000);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        // add a blocked address
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        ///perform transfer that checks rule
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        testCaseToken.transfer(address(69), 10);
        assertEq(testCaseToken.balanceOf(address(69)), 0);
    }

    function _accountApproveDenyOracle_Setup(ActionTypes action, bool deny) public endWithStopPrank returns (DummyAMM) {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 100000);
        assertEq(testCaseToken.balanceOf(user1), 100000);
        testCaseToken.transfer(address(69), 1000);
        // add the rule.
        uint32[] memory ruleIds = new uint32[](1);
        if (deny) {
            ruleIds[0] = createAccountApproveDenyOracleRule(0);
        } else {
            ruleIds[0] = createAccountApproveDenyOracleRule(1);
        }
        setAccountApproveDenyOracleRuleFull(address(applicationCoinHandler), createActionTypeArray(action), ruleIds);

        switchToSuperAdmin();
        applicationCoin2 = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin2));
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(applicationCoin2));
        applicationCoin2.mint(appAdministrator, 10000000000000000000000 * ATTO);
        applicationCoin2.mint(rich_user, 10000);

        switchToAppAdministrator();
        DummyAMM amm = new DummyAMM();

        if (deny) {
            // add a blocked address
            badBoys.push(address(69));
            oracleDenied.addToDeniedList(badBoys);
        } else {
            // add approved addresses
            goodBoys.push(address(59));
            goodBoys.push(address(user1));
            goodBoys.push(address(rich_user));
            goodBoys.push(address(amm));
            oracleApproved.addToApprovedList(goodBoys);
        }

        ProtocolERC20(address(testCaseToken)).mint(rich_user, 10000);
        ///perform buy that checks rule
        testCaseToken.approve(address(amm), 50);
        applicationCoin2.approve(address(amm), 50);
        vm.startPrank(rich_user);
        testCaseToken.transfer(address(amm), 900);
        applicationCoin2.transfer(address(amm), 900);
        applicationCoin2.transfer(user1, 900);
        applicationCoin2.transfer(address(69), 900);
        return amm;
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Transfer_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.P2P_TRANSFER, true);

        ///perform transfer that checks rule
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 10);
        assertEq(testCaseToken.balanceOf(user2), 10);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Transfer_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.P2P_TRANSFER, true);
        vm.startPrank(user1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        testCaseToken.transfer(address(69), 10);
        assertEq(testCaseToken.balanceOf(address(69)), 1000);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Transfer_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.P2P_TRANSFER, false);

        ///perform transfer that checks rule
        vm.startPrank(user1);
        testCaseToken.transfer(address(59), 10);
        assertEq(testCaseToken.balanceOf(address(59)), 10);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Transfer_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.P2P_TRANSFER, false);
        vm.startPrank(user1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        testCaseToken.transfer(address(69), 10);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Buy_Positive() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.BUY, true);
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
        assertEq(testCaseToken.balanceOf(user1), 100010);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Buy_Negative() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.BUY, true);
        vm.startPrank(address(69));
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Buy_Positive() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.BUY, false);
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
        assertEq(testCaseToken.balanceOf(user1), 100010);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Buy_Negative() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.BUY, false);
        vm.startPrank(address(69));
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Sell_Positive() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.SELL, true);
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
        assertEq(testCaseToken.balanceOf(user1), 99990);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Sell_Negative() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.SELL, true);
        vm.startPrank(address(69));
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Sell_Positive() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.SELL, false);
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
        assertEq(testCaseToken.balanceOf(user1), 99990);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Sell_Negative() public endWithStopPrank {
        DummyAMM amm = _accountApproveDenyOracle_Setup(ActionTypes.SELL, false);
        vm.startPrank(address(69));
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10, 10, true);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Burn_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.BURN, true);
        vm.startPrank(user1);
        ERC20Burnable(address(testCaseToken)).burn(100);
        assertEq(testCaseToken.balanceOf(user1), 99900);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Burn_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.BURN, true);
        vm.startPrank(address(69));
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC20Burnable(address(testCaseToken)).burn(100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Burn_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.BURN, false);
        vm.startPrank(user1);
        ERC20Burnable(address(testCaseToken)).burn(100);
        assertEq(testCaseToken.balanceOf(user1), 99900);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Burn_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.BURN, false);
        vm.startPrank(address(69));
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ERC20Burnable(address(testCaseToken)).burn(100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Mint_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.MINT, true);
        switchToAppAdministrator();
        ProtocolERC20(address(testCaseToken)).mint(user1, 100);
        assertEq(testCaseToken.balanceOf(user1), 100100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_DeniedList_Mint_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.MINT, true);
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ProtocolERC20(address(testCaseToken)).mint(address(69), 100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Mint_Positive() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.MINT, false);
        switchToAppAdministrator();
        ProtocolERC20(address(testCaseToken)).mint(user1, 100);
        assertEq(testCaseToken.balanceOf(user1), 100100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList_Mint_Negative() public endWithStopPrank {
        _accountApproveDenyOracle_Setup(ActionTypes.MINT, false);
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ProtocolERC20(address(testCaseToken)).mint(address(69), 100);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ApprovedList() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 100000);
        assertEq(testCaseToken.balanceOf(user1), 100000);

        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();

        // add approved addresses
        goodBoys.push(address(59));
        goodBoys.push(address(user5));
        oracleApproved.addToApprovedList(goodBoys);
        vm.startPrank(user1);
        // This one should pass
        testCaseToken.transfer(address(59), 10);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        testCaseToken.transfer(address(88), 10);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_InvalidOracleType() public endWithStopPrank {
        // Finally, check the invalid type
        switchToRuleAdmin();
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_Burning() public endWithStopPrank {
        /// test burning while oracle rule is active (allow list active)
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        /// first mint to user
        switchToAppAdministrator();
        goodBoys.push(address(user5));
        oracleApproved.addToApprovedList(goodBoys);
        switchToAppAdministrator();
        testCaseToken.transfer(user5, 10000);
        /// burn some tokens as user
        /// burns do not check for the recipient address as it is address(0)
        vm.startPrank(user5);
        ERC20Burnable(address(testCaseToken)).burn(5000);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_ZeroAddress() public endWithStopPrank {
        /// add address(0) to deny list and switch oracle rule to deny list
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandler), ruleId);
        switchToAppAdministrator();
        testCaseToken.transfer(user5, 10000);
        badBoys.push(address(user5));
        oracleDenied.addToDeniedList(badBoys);
        /// attempt to burn (should fail)
        vm.startPrank(user5);
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC20Burnable(address(testCaseToken)).burn(5000);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_AddSingleAddress_Approved() public endWithStopPrank {
        switchToAppAdministrator();
        oracleApproved.addAddressToApprovedList(address(59));
        assertEq(oracleApproved.isApproved(address(59)), true);
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracle_AddSingleAddress_Denied() public endWithStopPrank {
        switchToAppAdministrator();
        oracleDenied.addAddressToDeniedList(address(69));
        assertEq(oracleDenied.isDenied(address(69)), true);
    }

    /// Account Max Value By Access Level Tests
    function testERC20_ERC20CommonTests_AccountMaxValueByAccessLevel_NoAccessLevel() public endWithStopPrank {
        _accountMaxValueByAccessLevelSetup(ActionTypes.P2P_TRANSFER);
        ///perform transfer that checks rule when account does not have AccessLevel(should fail)
        vm.startPrank(user1);
        vm.expectRevert(0xaee8b993);
        testCaseToken.transfer(user2, 11 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxValueByAccessLevel_NoBalance_Transfer_Positive() public endWithStopPrank {
        _accountMaxValueByAccessLevelSetup(ActionTypes.P2P_TRANSFER);
        /// Add access level to whale
        address whale = address(99);
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(whale, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.startPrank(user1);
        /// this one is within the limit and should pass
        testCaseToken.transfer(whale, 10000 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxValueByAccessLevel_NoBalance_Transfer_Negative() public endWithStopPrank {
        _accountMaxValueByAccessLevelSetup(ActionTypes.P2P_TRANSFER);
        /// Add access level to whale
        address whale = address(99);
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(whale, 4);

        /// perform transfer that checks user with AccessLevel and no balances
        vm.startPrank(user1);
        /// this one is over the limit and should fail
        vm.expectRevert(0xaee8b993);
        testCaseToken.transfer(whale, 10001 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxValueByAccessLevel_Combination() public endWithStopPrank {
        _accountMaxValueByAccessLevelSetup(ActionTypes.P2P_TRANSFER);
        // set the access level for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user4, 3);

        vm.startPrank(user1);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail regardless of other balance)
        vm.expectRevert(0xaee8b993);
        testCaseToken.transfer(user4, 1001 * ATTO);
        /// perform transfer that checks user with AccessLevel and existing balances(should fail because of other balance)
        applicationCoin2.transfer(user4, 999 * ATTO);
        vm.expectRevert(0xaee8b993);
        testCaseToken.transfer(user4, 2 * ATTO);

        /// perform transfer that checks user with AccessLevel and existing balances(should pass)
        testCaseToken.transfer(user4, 1 * ATTO);
        assertEq(testCaseToken.balanceOf(user4), 1 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxValueByAccessLevel_Burning() public endWithStopPrank {
        _accountMaxValueByAccessLevelSetup(ActionTypes.P2P_TRANSFER);
        address whale = address(99);
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(whale, 4);
        applicationAppManager.addAccessLevel(user4, 3);
        vm.startPrank(user1);
        /// this one is within the limit and should pass
        testCaseToken.transfer(whale, 10000 * ATTO);
        testCaseToken.transfer(user4, 1 * ATTO);

        /// test burning is allowed while rule is active
        ERC20Burnable(address(testCaseToken)).burn(1 * ATTO);
        /// burn remaining balance to ensure rule limit is not checked on burns
        ERC20Burnable(address(testCaseToken)).burn(89998000000000000000000);
        /// test burn with account that has access level assign
        vm.startPrank(user4);
        ERC20Burnable(address(testCaseToken)).burn(1 * ATTO);
        assertEq(testCaseToken.balanceOf(user4), 0);
    }

    /// Pause Rule Tests
    function testERC20_ERC20CommonTests_PauseRulesViaAppManager() public endWithStopPrank {
        _pauseRuleSetup();
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        testCaseToken.transfer(user2, 1000);
    }

    function testERC20_ERC20CommonTests_PauseRulesViaAppManager_Bypass() public endWithStopPrank {
        _pauseRuleSetup();
        ///Check that rule bypass accounts can still transfer within pausePeriod
        switchToRuleBypassAccount();

        testCaseToken.transfer(superAdmin, 1000);
        assertEq(testCaseToken.balanceOf(superAdmin), 1000);
    }

    function testERC20_ERC20CommonTests_PauseRulesViaAppManager_MultipleWindows() public endWithStopPrank {
        _pauseRuleSetup();
        ///Set multiple pause rules
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
        applicationAppManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
        applicationAppManager.addPauseRule(Blocktime + 3000, Blocktime + 3500);

        ///warp between periods to test pause effect
        ///Pause window 1
        vm.warp(Blocktime + 1755);
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1700, Blocktime + 2000));
        testCaseToken.transfer(user2, 1200);
        ///Pause window 2
        vm.warp(Blocktime + 2150);
        selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 2100, Blocktime + 2500));
        testCaseToken.transfer(user2, 1300);
        ///In between 2 and 3
        vm.warp(Blocktime + 2675);
        testCaseToken.transfer(user2, 1000);
        ///Pause window 3
        vm.warp(Blocktime + 3333);
        selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 3000, Blocktime + 3500));
        testCaseToken.transfer(user2, 1400);
        ///After pause window 3
        vm.warp(Blocktime + 3775);
        testCaseToken.transfer(user2, 1000);

        assertEq(testCaseToken.balanceOf(user2), 3000);
    }

    /// Account Max Transaciton Value By Risk Score Tests
    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScore_Passes() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        ///User2 sends User1 amount under transaction limit, expect passing
        vm.startPrank(user2);
        testCaseToken.transfer(user1, 1 * (10 ** 18));
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScore_Negative() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        ///Transfer expected to fail
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 1000000000000000000000000));
        testCaseToken.transfer(user2, 1000001 * (10 ** 18));
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScore_Mixed() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        switchToRiskAdmin();
        ///Test in between Risk Score Values
        applicationAppManager.addRiskScore(user3, 49);
        applicationAppManager.addRiskScore(user4, 81);

        vm.startPrank(user3);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 81, 10000000000000000000000));
        testCaseToken.transfer(user4, 10001 * (10 ** 18));

        vm.startPrank(user4);
        testCaseToken.transfer(user3, 10 * (10 ** 18));

        testCaseToken.transfer(user3, 1001 * (10 ** 18));
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScore_Burning() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        /// test burning tokens while rule is active
        vm.startPrank(user5);
        ERC20Burnable(address(testCaseToken)).burn(999 * (10 ** 18));
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 99, 1000000000000000000000));
        ERC20Burnable(address(testCaseToken)).burn(1001 * (10 ** 18));
        ERC20Burnable(address(testCaseToken)).burn(1000 * (10 ** 18));
    }

    // Account Deny For No Access Level Tests
    function testERC20_ERC20CommonTests_PassesAccountDenyForNoAccessLevelRuleCoin_NoAccessLevels() public endWithStopPrank {
        _passesAccountDenyForNoAccessLevelRuleCoinSetup();
        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        testCaseToken.transfer(user3, 5 * ATTO);

        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d);
        testCaseToken.transfer(rich_user, 5 * ATTO);
    }

    function testERC20_ERC20CommonTests_PassesAccountDenyForNoAccessLevelRuleCoin_OneSided() public endWithStopPrank {
        _passesAccountDenyForNoAccessLevelRuleCoinSetup();
        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user3, 1);

        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        testCaseToken.transfer(user3, 5 * ATTO);

        vm.startPrank(user3);
        vm.expectRevert(0x3fac082d); /// this fails because rich_user is still accessLevel0
        testCaseToken.transfer(rich_user, 5 * ATTO);
    }

    function testERC20_ERC20CommonTests_PassesAccountDenyForNoAccessLevelRuleCoin_Positive() public endWithStopPrank {
        _passesAccountDenyForNoAccessLevelRuleCoinSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user3, 1);
        applicationAppManager.addAccessLevel(rich_user, 1);

        vm.startPrank(rich_user);
        testCaseToken.transfer(user3, 5 * ATTO);
        assertEq(testCaseToken.balanceOf(user3), 10 * ATTO);

        vm.startPrank(user3);
        testCaseToken.transfer(rich_user, 5 * ATTO);
    }

    function testERC20_ERC20CommonTests_PassesAccountDenyForNoAccessLevelRuleCoin_Burning() public endWithStopPrank {
        _passesAccountDenyForNoAccessLevelRuleCoinSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user3, 1);
        applicationAppManager.addAccessLevel(rich_user, 1);

        vm.startPrank(user3);
        /// test that burn works when user has accessLevel above 0
        ERC20Burnable(address(testCaseToken)).burn(5 * ATTO);
        /// test burn fails when rule active and user has access level 0
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(rich_user, 0);

        vm.startPrank(rich_user);
        vm.expectRevert(0x3fac082d);
        ERC20Burnable(address(testCaseToken)).burn(1 * ATTO);
    }

    /// Max Value Out
    function testERC20_ERC20CommonTests_MaxValueOutByAccessLevel_Passes() public endWithStopPrank {
        _maxValueOutByAccessLevelSetup();
        vm.startPrank(user1);
        testCaseToken.transfer(user3, 50 * ATTO);
        testCaseToken.transfer(user4, 50 * ATTO);
        /// User 1 now at "withdrawal" limit for access level
        vm.startPrank(user3);
        testCaseToken.transfer(user4, 10 * ATTO);
        assertEq(testCaseToken.balanceOf(user4), 60 * ATTO);
    }

    function testERC20_ERC20CommonTests_MaxValueOutByAccessLevel_Negative() public endWithStopPrank {
        /// test transfers fail over rule value
        _maxValueOutByAccessLevelSetup();
        vm.startPrank(user1);
        testCaseToken.transfer(user3, 50 * ATTO);
        testCaseToken.transfer(user4, 50 * ATTO);

        vm.expectRevert(0x8d857c50);
        testCaseToken.transfer(user3, 50 * ATTO);

        vm.startPrank(user3);
        testCaseToken.transfer(user4, 10 * ATTO);
        vm.expectRevert(0x8d857c50);
        testCaseToken.transfer(user4, 50 * ATTO);
    }

    function testERC20_ERC20CommonTests_MaxValueOutByAccessLevel_ReducedPrice() public endWithStopPrank {
        /// reduce price and test pass fail situations
        _maxValueOutByAccessLevelSetup();
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(testCaseToken), 5 * (10 ** 17));
        assertEq(erc20Pricer.getTokenPrice(address(testCaseToken)), 5 * (10 ** 17));

        vm.startPrank(user1);
        testCaseToken.transfer(user4, 50 * ATTO);
        vm.startPrank(user3);
        testCaseToken.transfer(user4, 10 * ATTO);

        vm.startPrank(user4);
        /// successful transfer as the new price is $.50USD (can transfer up to $10)
        testCaseToken.transfer(user4, 20 * ATTO);
        /// transfer fails because user reached ACCESS limit
        vm.expectRevert(0x8d857c50);
        testCaseToken.transfer(user3, 10 * ATTO);
    }

    /// Account Max Transaction Value By Risk Score With Period Tests
    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScoreWithPeriod_Negative() public endWithStopPrank {
        ///Transfer expected to fail in one large transaction
        _accountMaxTransactionValueByRiskScoreWithPeriodSetup();
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 1000000000000000000000000));
        testCaseToken.transfer(user2, 1000001 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScoreWithPeriod_Mixed() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreWithPeriodSetup();
        switchToRiskAdmin();
        ///Test in between Risk Score Values
        applicationAppManager.addRiskScore(user3, 49);
        applicationAppManager.addRiskScore(user4, 81);

        vm.startPrank(user3);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 81, 10000000000000000000000));
        testCaseToken.transfer(user4, 10001 * ATTO);

        vm.startPrank(user4);
        testCaseToken.transfer(user3, 10 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScoreWithPeriod_Burning() public endWithStopPrank {
        /// test burning tokens while rule is active
        _accountMaxTransactionValueByRiskScoreWithPeriodSetup();
        vm.startPrank(user5);
        ERC20Burnable(address(testCaseToken)).burn(999 * ATTO);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 99, 1000000000000000000000));
        ERC20Burnable(address(testCaseToken)).burn(1001 * ATTO);
        ERC20Burnable(address(testCaseToken)).burn(1000 * ATTO);
    }

    function testERC20_ERC20CommonTests_AccountMaxTransactionValueByRiskScoreWithPeriod_NewPeriod() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreWithPeriodSetup();
        /// let's test in a new period with a couple small txs:
        vm.warp(block.timestamp + 48 hours);
        vm.startPrank(user1);
        testCaseToken.transfer(user6, (1000002 / 2) * ATTO);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 1000000000000000000000000));
        testCaseToken.transfer(user6, (1000002 / 2) * ATTO);
    }

    /// Token Max Trading Volume With Supply Set Tests
    function testERC20_ERC20CommonTests_TokenMaxTradingVolumeWithSupplySet_Passes() public endWithStopPrank {
        _tokenMaxTradingVolumeWithSupplySetSetup();
        vm.startPrank(rich_user);
        /// make sure that transfer under the threshold works
        testCaseToken.transfer(user1, 39_000 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 39_000 * ATTO);
        /// now take it right up to the threshold(39,999)
        testCaseToken.transfer(user1, 999 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 39_999 * ATTO);
    }

    function testERC20_ERC20CommonTests_TokenMaxTradingVolumeWithSupplySet_Negative() public endWithStopPrank {
        _tokenMaxTradingVolumeWithSupplySetSetup();
        vm.startPrank(rich_user);
        testCaseToken.transfer(user1, 39_000 * ATTO);
        testCaseToken.transfer(user1, 999 * ATTO);
        /// now violate the rule and ensure revert
        vm.expectRevert(0x009da0ce);
        testCaseToken.transfer(user1, 1 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 39_999 * ATTO);
    }

    function testERC20_ERC20CommonTests_TokenMaxTradingVolumeWithSupplySet_Period() public endWithStopPrank {
        _tokenMaxTradingVolumeWithSupplySetSetup();
        vm.startPrank(rich_user);
        testCaseToken.transfer(user1, 39_000 * ATTO);
        testCaseToken.transfer(user1, 999 * ATTO);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        testCaseToken.transfer(user1, 1 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 40_000 * ATTO);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        testCaseToken.transfer(user1, 39_999 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 40_000 * ATTO);
    }

    /// Account Max Sell Size Tests
    function testERC20_ERC20CommonTests_AccountMaxTradeSizeSell_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeSell();
        /// Swap that passes rule check
        vm.startPrank(user1);
        /// Approve transfer(1M)
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeSell_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeSell();
        vm.startPrank(user1);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
        /// Swap that fails
        vm.expectRevert(0x523976c2);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeSell_BlankTag_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeSellBlankTag();
        /// Swap that passes rule check
        vm.startPrank(user1);
        /// Approve transfer(1M)
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeSell_BlankTag_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeSellBlankTag();
        vm.startPrank(user1);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
        /// Swap that fails
        vm.expectRevert(0x523976c2);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
    }

    // Account Max Buy Size Tests
    function testERC20_ERC20CommonTests_AccountMaxTradeSizeBuyRule_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeBuyRule();
        /// Swap that passes rule check
        vm.startPrank(user1);
        /// Approve transfer(1M)
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeBuyRule_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeBuyRule();
        vm.startPrank(user1);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
        /// Swap that fails
        vm.expectRevert(0x523976c2);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeRuleInvalidAction_Negative() public endWithStopPrank {
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.MINT);
        uint32 ruleId = createAccountMaxTradeSizeRule("", 600, 36);
        switchToRuleAdmin();
        vm.expectRevert("Action Validation Failed");
        TradingRuleFacet(address(applicationCoinHandler)).setAccountMaxTradeSizeId(actionTypes, ruleId);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeBuyRule_BlankTag_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeBuyRuleBlankTag();
        /// Swap that passes rule check
        vm.startPrank(user1);
        /// Approve transfer(1M)
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeBuyRule_BlankTag_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        vm.startPrank(user1);
        applicationCoin2.approve(address(amm), 50000);
        _setupAccountMaxTradeSizeBuyRuleBlankTag();
        vm.startPrank(user1);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
        /// Swap that fails
        vm.expectRevert(0x523976c2);
        amm.dummyTrade(address(applicationCoin2), address(testCaseToken), 500, 500, true);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRuleBuyAction_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleBuyAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        uint256 initialCoinBalance = testCaseToken.balanceOf(user1);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, false); /// percentage limit hit now
        assertEq(testCaseToken.balanceOf(user1), initialCoinBalance + 40_000_000);
        /// check that rule does not apply to coin 0 as this would be a sell
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 60_000_000, 60_000_000, true);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRuleBuyAction_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleBuyAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, false); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, false);
        /// switch users and test rule still fails
        vm.startPrank(user2);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, false);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRule_Period() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleBuyAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, false); /// percentage limit hit now
        /// wait until new period
        vm.warp(Blocktime + 36 hours + 30 hours);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, false);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRule_NewRule() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// Low percentage rule checks
        switchToRuleAdmin();
        /// create new rule
        _setupTokenMaxBuySellVolumeRuleBuyActionB();
        vm.warp(Blocktime + 96 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 1, 1, false);

        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 9, 9, false);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRuleSellAction_Passes() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleSellAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, true); /// percentage limit hit now
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRuleSellAction_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleSellAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, true); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, true);
        /// switch users and test rule still fails
        vm.startPrank(user2);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, true);
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeRuleSellAction_Period() public endWithStopPrank {
        switchToAppAdministrator();
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = _tradeRuleSetup();
        /// set up rule
        _setupTokenMaxBuySellVolumeRuleSellAction();
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, true); /// percentage limit hit now
        /// wait until new period
        vm.warp(Blocktime + 36 hours + 30 hours);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 10_000_000, 10_000_000, true);

        /// check that rule does not apply to coin 0 as this would be a sell
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 60_000_000, 60_000_000, false);
    }

    function testERC20_ERC20CommonTests_TradeRuleByPasserRule_BuySellPercentage_Allowed() public endWithStopPrank {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);

        /// SELL PERCENTAGE RULE
        _setupTokenMaxBuySellVolumeRuleSellAction();
        vm.warp(Blocktime + 36 hours);
        /// ALLOWLISTED USER
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 60_000_000, 60_000_000, true);
    }

    function testERC20_ERC20CommonTests_TradeRuleByPasserRule_BuySellPercentageSellAction_NotAllowed() public endWithStopPrank {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);

        /// SELL PERCENTAGE RULE
        _setupTokenMaxBuySellVolumeRuleSellAction();
        vm.warp(Blocktime + 36 hours);
        /// NOT ALLOWLISTED USER
        vm.startPrank(user2);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 40_000_000, 40_000_000, true);
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 20_000_000, 20_000_000, true);
    }

    function testERC20_ERC20CommonTests_TradeRuleByPasserRule_BuyPercentage_Allowed() public endWithStopPrank {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);
        //BUY PERCENTAGE RULE
        _setupTokenMaxBuySellVolumeRuleBuyAction();
        vm.warp(Blocktime + 36 hours);
        /// ALLOWLISTED USER
        vm.startPrank(user1);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 60_000_000, 60_000_000, false);
    }

    function testERC20_ERC20CommonTests_TradeRuleByPasserRule_BuySellPercentage_NotAllowed() public endWithStopPrank {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);
        _setupTokenMaxBuySellVolumeRuleBuyAction();
        vm.warp(Blocktime + 36 hours);
        /// NOT ALLOWLISTED USER
        vm.startPrank(user2);
        testCaseToken.approve(address(amm), 10000 * ATTO);
        applicationCoin2.approve(address(amm), 10000 * ATTO);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 30_000_000, 30_000_000, false);
        vm.expectRevert(0xfa006f25);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 30_000_000, 30_000_000, false);
    }

    function testERC20_ERC20CommonTests_TradeRuleByPasserRule_SellPercentage() public endWithStopPrank {
        switchToAppAdministrator();
        DummyAMM amm = _tradeRuleSetup();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user1, true);
        /// SELL RULE
        _setupAccountMaxTradeSizeSell();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        testCaseToken.approve(address(amm), 50000);
        applicationCoin2.approve(address(amm), 50000);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
        amm.dummyTrade(address(testCaseToken), address(applicationCoin2), 500, 500, true);
    }

    /*********************** Atomic Rule Setting Tests ************************************/
    /* These tests ensure that the atomic setting/application of rules is functioning properly */

    /* MinMaxTokenBalance */
    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalanceAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        bytes32[5] memory tags = [bytes32("Oscar"), bytes32("RJ"), bytes32("Tayler"), bytes32("Michael"), bytes32("Michael")];
        for (uint i; i < ruleIds.length; i++) createAccountMinMaxTokenBalanceRule(createBytes32Array(tags[i]), createUint256Array(i + 1), createUint256Array((i + 1) * 1000));

        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        for (uint i; i < 5; i++) assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes(i)));
    }

    function testERC20_ERC20CommonTests_AccountMinMaxTokenBalanceAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        bytes32[5] memory tags = [bytes32("Oscar"), bytes32("RJ"), bytes32("Tayler"), bytes32("Michael"), bytes32("Michael")];
        for (uint i; i < ruleIds.length; i++) createAccountMinMaxTokenBalanceRule(createBytes32Array(tags[i]), createUint256Array(i + 1), createUint256Array((i + 1) * 1000));
        // Set up rule
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
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT), 0);
        assertEq(ERC20TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.MINT));
        assertFalse(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BURN));
    }

    /* AdminMinTokenBalance */
    function testERC20_ERC20CommonTests_AdminMinTokenBalanceAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](3);
        // Set up rule
        for (uint i; i < 3; i++) ruleIds[i] = createAdminMinTokenBalanceRule(i + 1, uint64(Blocktime + ((i + 1) * 100)));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BURN);
        // Apply the rules to all actions
        setAdminMinTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BURN), ruleIds[2]);
        // Verify that all the rules were activated
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BURN));
    }

    function testERC20_ERC20CommonTests_AdminMinTokenBalanceAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        for (uint i; i < 5; i++) ruleIds[i] = createAdminMinTokenBalanceRule(i + 1, uint64(Blocktime + ((i + 1) * 100)));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BURN);
        // Apply the rules to all actions
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](1);
        ruleIds[0] = createAdminMinTokenBalanceRule(6, Blocktime + 600);
        actions = createActionTypeArray(ActionTypes.SELL);
        // Apply the new set of rules
        setAdminMinTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.SELL), ruleIds[0]);
        // Verify that the old ones were cleared
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC20HandlerMainFacet(address(applicationCoinHandler)).getAdminMinTokenBalanceId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.SELL));
        // Verify that the old rules are not activated
        assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20HandlerMainFacet(address(applicationCoinHandler)).isAdminMinTokenBalanceActive(ActionTypes.BURN));
    }

    /* AccountMaxTradeSize */
    function testERC20_ERC20CommonTests_AccountMaxTradeSizeAtomicFullSetSell() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createAccountMaxTradeSizeRule("Oscar", 1, 1);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL);
        // Apply the rules to all actions
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleIds[0]);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxTradeSizeId(ActionTypes.SELL), ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxTradeSizeActive(ActionTypes.SELL));
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeAtomicFullReSetBuy() public {
        uint32 ruleId = createAccountMaxTradeSizeRule("Oscar", 100, 5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the rules to all actions
        ruleId = createAccountMaxTradeSizeRule("Oscar", 100, 5);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actions, ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxTradeSizeId(ActionTypes.BUY), ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxTradeSizeId(ActionTypes.BUY), ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxTradeSizeActive(ActionTypes.BUY));
    }

    /* AccountMaxTradeSize */
    function testERC20_ERC20CommonTests_AccountMaxTradeSizeAtomicFullSetBuy() public {
        uint32[] memory ruleIds = new uint32[](1);
        // Set up rule(This one is different because it can only apply to buys)
        ruleIds[0] = createAccountMaxTradeSizeRule("Oscar", 1, 1);
        // Apply the rules to all actions
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleIds[0]);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxTradeSizeId(ActionTypes.BUY), ruleIds[0]);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxTradeSizeActive(ActionTypes.BUY));
    }

    function testERC20_ERC20CommonTests_AccountMaxTradeSizeAtomicFullReSetSell() public {
        uint32 ruleId = createAccountMaxTradeSizeRule("Oscar", 100, 5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actions, ruleId);
        // Apply the rules to all actions
        ruleId = createAccountMaxTradeSizeRule("Oscar", 200, 5);
        // Apply the new set of rules
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getAccountMaxTradeSizeId(ActionTypes.SELL), ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isAccountMaxTradeSizeActive(ActionTypes.SELL));
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeBuyActionAtomicFullReSet() public {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(10, 24, 0, Blocktime);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actions, ruleId);
        // Apply the rules to all actions
        ruleId = createTokenMaxBuySellVolumeRule(10, 48, 0, Blocktime);
        actions = createActionTypeArray(ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actions, ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxBuySellVolumeId(ActionTypes.BUY), ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxBuySellVolumeActive(ActionTypes.BUY));
    }

    /* TokenMaxBuySellVolume */
    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeAtomicFullSet() public {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(10, 48, 0, Blocktime);
        // Apply the rules to all actions
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actions, ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxBuySellVolumeId(ActionTypes.BUY), ruleId);
        // Verify that all the rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxBuySellVolumeActive(ActionTypes.BUY));
    }

    function testERC20_ERC20CommonTests_TokenMaxBuySellVolumeAtomicFullReSet() public {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(10, 24, 0, Blocktime);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actions, ruleId);
        // Apply the rules to all actions
        ruleId = createTokenMaxBuySellVolumeRule(10, 48, 0, Blocktime);
        // Apply the new set of rules
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actions, ruleId);
        // Verify that all the rule id's were set correctly
        assertEq(TradingRuleFacet(address(applicationCoinHandler)).getTokenMaxBuySellVolumeId(ActionTypes.BUY), ruleId);
        // Verify that the new rules were activated
        assertTrue(TradingRuleFacet(address(applicationCoinHandler)).isTokenMaxBuySellVolumeActive(ActionTypes.BUY));
    }

    /* AccountApproveDenyOracle */
    function testERC20_ERC20CommonTests_AccountApproveDenyOracleAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for (uint i; i < 5; i++) {
            for (uint j; j < 5; j++) {
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
        for (uint i; i < 5; i++) {
            if (actions[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 5; j++) {
                assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex])[internalIndex], ruleIds[mainIndex]);
                assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex], ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
    }

    function testERC20_ERC20CommonTests_AccountApproveDenyOracleAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for (uint i; i < 5; i++) {
            for (uint j; j < 5; j++) {
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
        for (uint i; i < 3; i++) {
            for (uint j; j < 8; j++) {
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
        for (uint i; i < 3; i++) {
            if (actions2[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 8; j++) {
                assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions2[mainIndex])[internalIndex], ruleIds2[mainIndex]);
                assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions2[mainIndex], ruleIds2[mainIndex]));
                lastAction = actions2[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }

        // Verify that all the rule id's were cleared for the previous set of rules(Had to go old school with control break logic)
        mainIndex = 0;
        internalIndex = 0;
        lastAction = ActionTypes(0);
        for (uint i; i < 5; i++) {
            if (actions[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 5; j++) {
                uint32[] memory ruleIds3 = ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex]);
                // If a value was returned it must not match a previous rule
                if (ruleIds3.length > 0) {
                    assertFalse(ruleIds3[internalIndex] == ruleIds[mainIndex]);
                }
                assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex], ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
    }

    /* TokenMaxSupplyVolatility */
    function testERC20_ERC20CommonTests_TokenMaxSupplyVolatilityAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](2);
        // Set up rule
        for (uint i; i < ruleIds.length; i++) ruleIds[i] = createTokenMaxSupplyVolatilityRule(uint16(2000 + (i * 1000)), uint8(i + 4), Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < ruleIds.length; i++) assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(actions[i]), ruleIds[i]);
        // Verify that all the rules were activated
        for (uint i; i < ruleIds.length; i++) assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(actions[i]));
    }

    function testERC20_ERC20CommonTests_TokenMaxSupplyVolatilityAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](2);
        // Set up rule
        for (uint i; i < ruleIds.length; i++) ruleIds[i] = createTokenMaxSupplyVolatilityRule(uint16(2000 + (i * 1000)), uint8(i + 4), Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](1);
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2011, 6, Blocktime, 0);
        actions = createActionTypeArray(ActionTypes.MINT);
        // Apply the new set of rules
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        for (uint i; i < ruleIds.length; i++) assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(actions[i]), ruleIds[i]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    /* TokenMaxTradingVolume */
    function testERC20_ERC20CommonTests_TokenMaxTradingVolumeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](4);
        // Set up rule
        for (uint i; i < 4; i++) ruleIds[i] = createTokenMaxTradingVolumeRule(uint24(1000 * (i + 1)), 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT);
        // Apply the rules to all actions
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT), ruleIds[3]);
        // Verify that all the rules were activated
        for (uint i; i < 4; i++) assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes(i)));
    }

    function testERC20_ERC20CommonTests_TokenMaxTradingVolumeAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](4);
        // Set up rule
        for (uint i; i < 4; i++) ruleIds[i] = createTokenMaxTradingVolumeRule(uint24(1000 * (i + 1)), 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT);
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
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT), 0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
    }

    /* TokenMinimumTransaction */
    function testERC20_ERC20CommonTests_TokenMinimumTransactionAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        for (uint i; i < 5; i++) ruleIds[i] = createTokenMinimumTransactionRule(i + 1);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        for (uint i; i < 5; i++) assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes(i)));
    }

    function testERC20_ERC20CommonTests_TokenMinimumTransactionAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        for (uint i; i < 5; i++) ruleIds[i] = createTokenMinimumTransactionRule(i + 1);
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
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT), 0);
        assertEq(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.SELL));
        assertTrue(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.MINT));
        assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BURN));
    }

    /// Utility Helper Functions
    function _tokenMinTransactionSetup(ActionTypes action) private endWithStopPrank {
        /// We add the empty rule at index 0
        switchToRuleAdmin();
        uint32 ruleId = createTokenMinimumTransactionRule(10);
        setTokenMinimumTransactionRule(address(applicationCoinHandler), ruleId);
        switchToRuleAdmin();
        /// we update the rule id in the token
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMinTxSizeId(_createActionsArray(action), ruleId);

        switchToSuperAdmin();
        applicationCoin2 = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin2));
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(applicationCoin2));
        applicationCoin2.mint(appAdministrator, 10000000000000000000000 * ATTO);

        switchToAppAdministrator();
        /// now we perform the transfer
        testCaseToken.transfer(rich_user, 1000000);
        applicationCoin2.transfer(rich_user, 1000000);
    }

    function _accountMaxValueByAccessLevelSetup(ActionTypes action) private endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 100000 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 100000 * ATTO);
        /// create secondary token, mint, and transfer to user
        switchToSuperAdmin();
        applicationCoin2 = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin2));
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(applicationCoin2));
        applicationCoin2.mint(appAdministrator, 10000000000000000000000 * ATTO);
        applicationCoin2.transfer(user1, 100000 * ATTO);
        assertEq(applicationCoin2.balanceOf(user1), 100000 * ATTO);
        erc20Pricer.setSingleTokenPrice(address(applicationCoin2), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin2)), 1 * ATTO);

        switchToRuleAdmin();
        uint32[] memory ruleIds = new uint32[](1);
        ruleIds[0] = createAccountMaxValueByAccessLevelRule(0, 100, 500, 1000, 10000);
        setAccountMaxValueByAccessLevelRuleFull(createActionTypeArray(action), ruleIds);
    }

    function _accountMinMaxTokenBalanceSetup(bool tag, bool period) private endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(rich_user, 100000);
        testCaseToken.transfer(user1, 1000);
        if (period) {
            vm.warp(Blocktime);
            uint16[] memory periods = createUint16Array(720);
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(2000), periods);
            setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
        } else {
            if (tag) {
                uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(10), createUint256Array(1000));
                setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
            } else {
                uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(10), createUint256Array(1000));
                setAccountMinMaxTokenBalanceRule(address(applicationCoinHandler), ruleId);
            }
        }
        switchToAppAdministrator();

        if (tag) {
            ///Add Tag to account
            applicationAppManager.addTag(user1, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
            applicationAppManager.addTag(user2, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
            applicationAppManager.addTag(user3, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user3, "Oscar"));
        }
    }

    function _accountMinMaxTokenBalanceIndividualActionSetup(ActionTypes action) private endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        testCaseToken.transfer(rich_user, 100000);
        testCaseToken.transfer(user1, 100);
        uint32[] memory ruleIds = new uint32[](1);
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(10), createUint256Array(1000));
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), createActionTypeArray(action), ruleIds);

        switchToSuperAdmin();
        applicationCoin2 = new ApplicationERC20("application2", "DRAC", address(applicationAppManager));
        switchToAppAdministrator();
        applicationCoinHandler2 = _createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationCoin2));
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        /// register the token
        applicationAppManager.registerToken("DRAC", address(applicationCoin2));
        applicationCoin2.mint(appAdministrator, 10000000000000000000000 * ATTO);
        applicationCoin2.mint(rich_user, 10000);
    }

    function _maxValueOutByAccessLevelSetup() private endWithStopPrank {
        switchToAppAdministrator();
        /// load non admin user with application coin
        testCaseToken.transfer(user1, 1000 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 1000 * ATTO);
        vm.startPrank(user1);
        /// check transfer without access level with the rule turned off
        testCaseToken.transfer(user3, 50 * ATTO);
        assertEq(testCaseToken.balanceOf(user3), 50 * ATTO);
        /// price the tokens
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(testCaseToken), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(testCaseToken)), 1 * ATTO);
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
    }

    function _pauseRuleSetup() private endWithStopPrank {
        switchToAppAdministrator();
        ///Test transfers without pause rule
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 100000);
        assertEq(testCaseToken.balanceOf(user1), 100000);
        testCaseToken.transfer(ruleBypassAccount, 100000);
        assertEq(testCaseToken.balanceOf(ruleBypassAccount), 100000);
        vm.startPrank(user1);
        testCaseToken.transfer(user2, 1000);

        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);
    }

    function _accountMaxTransactionValueByRiskScoreSetup() private endWithStopPrank {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 10000000 * (10 ** 18));
        assertEq(testCaseToken.balanceOf(user1), 10000000 * (10 ** 18));
        testCaseToken.transfer(user2, 10000 * (10 ** 18));
        assertEq(testCaseToken.balanceOf(user2), 10000 * (10 ** 18));
        testCaseToken.transfer(user3, 1500 * (10 ** 18));
        assertEq(testCaseToken.balanceOf(user3), 1500 * (10 ** 18));
        testCaseToken.transfer(user4, 1000000 * (10 ** 18));
        assertEq(testCaseToken.balanceOf(user4), 1000000 * (10 ** 18));
        testCaseToken.transfer(user5, 10000 * (10 ** 18));
        assertEq(testCaseToken.balanceOf(user5), 10000 * (10 ** 18));

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user5, riskScores[3]);

        ///Switch to app admin and set up ERC20Pricer and activate AccountMaxTxValueByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(testCaseToken), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(testCaseToken)), 1 * (10 ** 18));

        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(1000000, 100000, 10000, 1000));
        setAccountMaxTxValueByRiskRule(ruleId);
    }

    function _passesAccountDenyForNoAccessLevelRuleCoinSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// load non admin user with application coin
        testCaseToken.transfer(rich_user, 1000000 * ATTO);
        assertEq(testCaseToken.balanceOf(rich_user), 1000000 * ATTO);
        vm.startPrank(rich_user);
        /// check transfer without access level but with the rule turned off
        testCaseToken.transfer(user3, 5 * ATTO);
        assertEq(testCaseToken.balanceOf(user3), 5 * ATTO);
        /// now turn the rule on
        createAccountDenyForNoAccessLevelRule();
    }

    function _accountMaxTransactionValueByRiskScoreWithPeriodSetup() private endWithStopPrank {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
        /// set up a non admin user with tokens
        testCaseToken.transfer(user1, 10000000 * ATTO);
        assertEq(testCaseToken.balanceOf(user1), 10000000 * ATTO);
        testCaseToken.transfer(user2, 10000 * ATTO);
        assertEq(testCaseToken.balanceOf(user2), 10000 * ATTO);
        testCaseToken.transfer(user3, 1500 * ATTO);
        assertEq(testCaseToken.balanceOf(user3), 1500 * ATTO);
        testCaseToken.transfer(user4, 1000000 * ATTO);
        assertEq(testCaseToken.balanceOf(user4), 1000000 * ATTO);
        testCaseToken.transfer(user5, 10000 * ATTO);
        assertEq(testCaseToken.balanceOf(user5), 10000 * ATTO);

        ///Assign Risk scores to user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user5, riskScores[3]);

        ///Switch to app admin and set up ERC20Pricer and activate AccountMaxTxValueByRiskScore Rule
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(testCaseToken), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(testCaseToken)), 1 * ATTO);
        uint8 period = 24;
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(1000000, 100000, 10000, 1000), period);
        setAccountMaxTxValueByRiskRule(ruleId);
    }

    function _tokenMaxTradingVolumeWithSupplySetSetup() private endWithStopPrank {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToAppAdministrator();
        /// load non admin users with game coin
        testCaseToken.transfer(rich_user, 100_000 * ATTO);
        assertEq(testCaseToken.balanceOf(rich_user), 100_000 * ATTO);
        /// apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        setTokenMaxTradingVolumeRule(address(applicationCoinHandler), ruleId);
    }

    function _tradeRuleSetup() private returns (DummyAMM) {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        DummyAMM amm = initializeAMMAndUsers();
        applicationCoin2.transfer(user1, 50_000_000 * ATTO);
        applicationCoin2.transfer(user2, 30_000_000 * ATTO);
        testCaseToken.transfer(user1, 50_000_000 * ATTO);
        testCaseToken.transfer(user2, 30_000_000 * ATTO);
        assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * ATTO);
        return amm;
    }

    function _setupAccountMaxTradeSizeSell() private endWithStopPrank {
        ///Add tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "AccountMaxSellSize");
        applicationAppManager.addTag(user2, "AccountMaxSellSize");
        /// add the rule.
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL);
        uint32 ruleId = createAccountMaxTradeSizeRule("AccountMaxSellSize", 600, 36);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupAccountMaxTradeSizeSellBlankTag() private {
        /// add the rule.
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL);
        uint32 ruleId = createAccountMaxTradeSizeRule("", 600, 36);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupAccountMaxTradeSizeBuyRule() private endWithStopPrank {
        switchToAppAdministrator();
        /// Add tag to users
        applicationAppManager.addTag(user1, "MaxBuySize");
        applicationAppManager.addTag(user2, "MaxBuySize");
        /// add the rule.
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY);
        uint32 ruleId = createAccountMaxTradeSizeRule("MaxBuySize", 600, 36);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupAccountMaxTradeSizeBuyRuleBlankTag() private {
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY);
        uint32 ruleId = createAccountMaxTradeSizeRule("", 600, 36);
        setAccountMaxTradeSizeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupTokenMaxBuySellVolumeRuleBuyAction() internal endWithStopPrank {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(5000, 24, 100_000_000, Blocktime);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupTokenMaxBuySellVolumeRuleBuyActionB() internal endWithStopPrank {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(1, 24, 100_000, Blocktime);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function _setupTokenMaxBuySellVolumeRuleSellAction() internal endWithStopPrank {
        uint32 ruleId = createTokenMaxBuySellVolumeRule(5000, 24, 100_000_000, Blocktime);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.SELL);
        setTokenMaxBuySellVolumeRule(address(applicationCoinHandler), actionTypes, ruleId);
    }

    function initializeAMMAndUsers() public returns (DummyAMM amm) {
        amm = new DummyAMM();
        applicationCoin2.mint(appAdministrator, 1_000_000_000_000 * ATTO);
        /// Approve the transfer of tokens into AMM
        testCaseToken.approve(address(amm), 1_000_000 * ATTO);
        applicationCoin2.approve(address(amm), 1_000_000 * ATTO);
        /// Transfer the tokens into the AMM
        testCaseToken.transfer(address(amm), 1_000_000 * ATTO);
        applicationCoin2.transfer(address(amm), 1_000_000 * ATTO);
        /// Make sure the tokens made it
        assertEq(testCaseToken.balanceOf(address(amm)), 1_000_000 * ATTO);
        assertEq(applicationCoin2.balanceOf(address(amm)), 1_000_000 * ATTO);
        testCaseToken.transfer(user1, 1000 * ATTO);
        testCaseToken.transfer(user2, 1000 * ATTO);
        testCaseToken.transfer(user3, 1000 * ATTO);
        testCaseToken.transfer(rich_user, 1000 * ATTO);
        applicationCoin2.transfer(user1, 1000 * ATTO);
        applicationCoin2.transfer(user2, 1000 * ATTO);
        testCaseToken.transfer(address(69), 1000 * ATTO);
        applicationCoin2.transfer(address(69), 1000 * ATTO);
    }
}

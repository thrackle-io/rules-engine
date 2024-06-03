// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC20/util/ERC20Util.sol";
import "src/example/ERC20/upgradeable/ApplicationERC20UMin.sol";
import "src/example/ERC20/upgradeable/ApplicationERC20UMinUpgAdminMint.sol";

contract ApplicationEC20UMinTest is TestCommonFoundry, ERC20Util {

    function setUp() public {
        vm.warp(Blocktime);
        setUpProtocolAndAppManagerAndTokensUpgradeable();
        vm.warp(Blocktime);
    }

    function testERC20_ApplicationERC20U_Mint() public endWithStopPrank {
        switchToAppAdministrator();
        /// Owner Mints new coins
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
        /// Owner Mints a second new coins
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 200);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 300);
    }

    function testERC20_ApplicationERC20UMin_AdminMintOnly() public endWithStopPrank {
        // Make sure no non-admins can mint tokens
        switchToUser();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);

        switchToAccessLevelAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);

        switchToRuleAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);

        switchToRiskAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
    }

    function testERC20_ApplicationERC20UMin_Transfer() public endWithStopPrank {
        // Make sure a user can transfer coins
        switchToAppAdministrator();
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 100);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user), 100);
    }

    function testERC20_ApplicationERC20UMin_Burn_Positive() public endWithStopPrank {
        // Make sure a user can burn coins 
        switchToAppAdministrator();
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 100);

        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).burn(appAdministrator, 50);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 50);
    }

    function testERC20_ApplicationERC20UMin_Burn_Negative() public endWithStopPrank {
        // Make sure a user cant burn more than their balance allows
        switchToAppAdministrator();
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 100);

        vm.expectRevert("ERC20: burn amount exceeds balance");
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).burn(appAdministrator, 500);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalanceRule_Minimum() public endWithStopPrank {
        /// make sure the minimum rules fail results in revert
        _accountMinMaxTokenBalanceRuleSetup();
        vm.startPrank(user1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 50);
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 50);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalanceRule_Maximum() public endWithStopPrank {
        ///make sure the maximum rule fail results in revert
        _accountMinMaxTokenBalanceRuleSetup();
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 100);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalanceRule_Upgrade() public endWithStopPrank {
        // upgrade the token and make sure the rule still works
        _accountMinMaxTokenBalanceRuleSetup();
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
        // transfer should still fail
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 100);
    }

    function testERC20_ApplicationERC20UMin_AccountDenyOracle_Negative() public endWithStopPrank {
        _accountDenyOracleSetup();
        vm.startPrank(user1);

        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(address(69), 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(address(69)), 0);
    }

    function testERC20_ApplicationERC20UMin_AccountApproveOracle_Negative() public endWithStopPrank {
        _accountApproveOracleSetup();
        vm.startPrank(user1);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(address(88), 3);
    }

    function testERC20_ApplicationERC20UMin_AccountApproveDenyOracle_Invalid() public endWithStopPrank {
        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC20_ApplicationERC20UMin_PauseRulesViaAppManager_Negative() public endWithStopPrank {
        _pauseRulesViaAppManagerSetup();
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(address(59), 2);
    }

    function testERC20_ApplicationERC20UMin_PauseRulesViaAppManager_Upgrade() public endWithStopPrank {
        // upgrade the coin and make sure it still works
        _pauseRulesViaAppManagerSetup();
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(address(59), 2);
    }

    function testERC20_ApplicationERC20UMin_AccountMaxTransactionValueByRiskScore_Negative() public endWithStopPrank {
        ///Fail cases
        _accountMaxTransactionValueByRiskScoreSetup();
        vm.startPrank(user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 70 * ATTO);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 60 * ATTO);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 50 * ATTO);

        vm.startPrank(user2);
        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 40 * ATTO);
    }

    function testERC20_ApplicationERC20UMin_AccountMaxTransactionValueByRiskScore_PriceChange() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        ///simulate price changes
        switchToAppAdministrator();

        erc20Pricer.setSingleTokenPrice(address(applicationCoinProxy), 10 * ATTO);

        vm.startPrank(user2);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 1);

        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 15 * ATTO);
    }

    function testERC20_ApplicationERC20UMin_AccountMaxTransactionValueByRiskScore_Upgrade() public endWithStopPrank {
        /// upgrade the coin and make sure it still fails
        _accountMaxTransactionValueByRiskScoreSetup();
        ///simulate price changes
        switchToAppAdministrator();

        erc20Pricer.setSingleTokenPrice(address(applicationCoinProxy), 10 * ATTO);

        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
        vm.startPrank(user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 1000000000000000000));
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 40 * ATTO);

        vm.startPrank(user2);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 1);
    }

    function testERC20_ApplicationERC20UMin_AccountDenyForNoAccessLevel_Negative() public endWithStopPrank {
        // transfers should not work for addresses without AccessLevel
        _accountDenyForNoAccessLevelInCoinSetup();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
    }

    function testERC20_ApplicationERC20UMin_AccountDenyForNoAccessLevel_Upgrade() public endWithStopPrank {
        // upgrade the coin and make sure it still fails
        _accountDenyForNoAccessLevelInCoinSetup();
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
    }

    function testERC20_ApplicationERC20UMin_AccountDenyForNoAccessLevel_AccessLevelFail() public endWithStopPrank {
        // set AccessLevel and try again
        _accountDenyForNoAccessLevelInCoinSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// user 1 accessLevel is still 0 so tx reverts
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
    }

    function testERC20_ApplicationERC20UMin_AccountDenyForNoAccessLevel_AccessLevelPass() public endWithStopPrank {
        _accountDenyForNoAccessLevelInCoinSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        applicationAppManager.addAccessLevel(user2, 1);
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 1);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalance_Negative() public endWithStopPrank {
        /// Transfers failing (below min value limit)
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 400); ///User 1 has min limit of 100
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 400);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 101);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 200);

        vm.startPrank(user2);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 400); ///User 2 has min limit of 200
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 300);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 101);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 300);

        vm.startPrank(user3);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 400); ///User 3 has min limit of 300
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 200);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 101);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user3), 400);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalance_Upgrade() public endWithStopPrank {
        // upgrade the coin and make sure it still fails
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 701); ///User 3 has min limit of 300
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user3), 1000);
    }

    function testERC20_ApplicationERC20UMin_AccountMinMaxTokenBalance_Period() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 999);

        vm.startPrank(user2);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 999);

        vm.startPrank(user3);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(rich_user, 999);
    }

    function testERC20_ApplicationERC20UMin_UpgradeAppManagerERC20UMin_FailZeroAddress() public endWithStopPrank {
        _upgradeAppManagerERC20UMinSetup();
        /// Test fail scenarios
        switchToAppAdministrator();
        // zero address
        vm.expectRevert(0xd92e233d);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).proposeAppManagerAddress(address(0));
    }

    function testERC20_ApplicationERC20UMin_UpgradeAppManagerERC20UMin_FailNoProposedAddress() public endWithStopPrank {
        _upgradeAppManagerERC20UMinSetup();
        switchToAppAdministrator();
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        applicationAppManager2.confirmAppManager(address(minimalUCoin));
    }

    function testERC20_ApplicationERC20UMin_UpgradeAppManagerERC20UMin_NonProposerConfirm() public endWithStopPrank {
        _upgradeAppManagerERC20UMinSetup();
        switchToAppAdministrator();
        
        // non proposer tries to confirm
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).proposeAppManagerAddress(address(applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Frankensteins Lab2", false);
        switchToNewAdmin();
        applicationAppManager3.addAppAdministrator(address(appAdministrator));
        switchToAppAdministrator();
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(applicationCoinProxy));
    }

    function testERC20_ApplicationERC20UMin_ERC20Upgrade() public endWithStopPrank {
        vm.startPrank(proxyOwner);
        minimalUCoin2 = new ApplicationERC20UMinUpgAdminMint();
        applicationCoinProxy.upgradeTo(address(minimalUCoin2));
    }

    /// INTERNAL HELPER FUNCTIONS

    function _accountMinMaxTokenBalanceRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// mint some tokens to appAdministrator for transfer
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 1000);

        /// set up a non admin user with tokens
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100);

        ///Add Tag to account
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "Gordon"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "Gordon"));
        applicationAppManager.addTag(user2, "Gordon"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Gordon"));
        applicationAppManager.addTag(user3, "Gordon"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Gordon"));
        ///perform transfer that checks rule
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 50);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 50);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 50);

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Gordon"), createUint256Array(50), createUint256Array(100));
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandlerUMin), ruleId);
    }

    function _accountDenyOracleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// mint some tokens to appAdministrator for transfer
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 1000);

        /// set up a non admin user with tokens
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerUMin), ruleId);
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);

        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 10);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 10);
    }

    function _accountApproveOracleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// mint some tokens to appAdministrator for transfer
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 1000);

        /// set up a non admin user with tokens
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationCoinHandlerUMin), ruleId);
        // add an approved address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleApproved.addToApprovedList(goodBoys);
        vm.startPrank(user1);
        // This one should pass
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(address(59), 2);
    }

    function _pauseRulesViaAppManagerSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user with tokens
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user1, 100);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100);

        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);
    }

    function _accountMaxTransactionValueByRiskScoreSetup() public endWithStopPrank {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(10, 40, 80, 99);
        ///Mint coins (user1,2,3)
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user1, 100 * ATTO);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100 * ATTO);

        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user2, 100 * ATTO);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 100 * ATTO);

        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(1, 1, 1, 1));
        setAccountMaxTxValueByRiskRule(ruleId);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for coin proxy
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoinProxy), 1 * (10 ** 18));

        ///Transfer coins
        ///Positive cases
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 1);

        vm.startPrank(user3);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 1);

        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
    }

    function _accountDenyForNoAccessLevelInCoinSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user some coins
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user1, 100 * ATTO);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 100 * ATTO);

        // apply the rule to the handler
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(createActionTypeArrayAll(), true);
    }

    function _accountMinMaxTokenBalanceSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// Mint coins for users 1, 2, 3
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user1, 1000);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user2, 1000);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(user3, 1000);

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("MIN1", "MIN2", "MIN3");
        uint256[] memory minAmounts = createUint256Array(100, 200, 300); /// Represent min number of tokens held by user for Collection address
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationCoinHandlerUMin), ruleId);
        /// Add Tags to users
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "MIN1"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MIN1"));
        applicationAppManager.addTag(user2, "MIN2"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MIN2"));
        applicationAppManager.addTag(user3, "MIN3"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "MIN3"));

        /// Transfers passing (above min value limit)
        vm.startPrank(user1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user1), 998);

        vm.startPrank(user2);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user3, 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user2), 999);

        vm.startPrank(user3);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user2, 1);
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user1, 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user3), 1000);
    }

    function _upgradeAppManagerERC20UMinSetup() public endWithStopPrank {
        switchToAppAdministrator();
        address newAdmin = address(75);
        /// create a new app manager
        applicationAppManager2 = new ApplicationAppManager(newAdmin, "Frankensteins Lab", false);
        /// propose a new AppManager
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).proposeAppManagerAddress(address(applicationAppManager2));
        switchToNewAdmin();
        applicationAppManager2.addAppAdministrator(address(appAdministrator));

        /// confirm the app manager
        switchToAppAdministrator();
        applicationAppManager2.confirmAppManager(address(applicationCoinProxy));
        /// test to ensure it still works
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).mint(appAdministrator, 100);
        switchToAppAdministrator();
        ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).transfer(user, 1);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(appAdministrator), 99);
        assertEq(ApplicationERC20UMinUpgAdminMint(address(applicationCoinProxy)).balanceOf(user), 1);
    }
}

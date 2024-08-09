// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

contract ApplicationERC721UTest is TestCommonFoundry, ERC721Util {
    function setUp() public {
        vm.warp(Blocktime);
        setUpProtocolAndAppManagerAndTokensUpgradeable();
        vm.warp(Blocktime); // set block.timestamp
    }

    function testERC721_ApplicationERC721U_Mint() public endWithStopPrank {
        switchToAppAdministrator();
        /// Owner Mints new tokenId
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        console.log(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        console.log(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator));
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 2);
    }

    function testERC721_ApplicationERC721U_AdminMintOnly() public endWithStopPrank {
        ApplicationERC721UpgAdminMint nft = ApplicationERC721UpgAdminMint(address(applicationNFTProxy));
        /// since this is the default implementation, we only need to test the negative case
        switchToUser();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        nft.safeMint(appAdministrator);

        switchToAccessLevelAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        nft.safeMint(appAdministrator);

        switchToRuleAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        nft.safeMint(appAdministrator);

        switchToRiskAdmin();
        vm.expectRevert(abi.encodeWithSignature("NotAppAdministrator()"));
        nft.safeMint(appAdministrator);
    }

    function testERC721_ApplicationERC721U_Transfer() public endWithStopPrank {
        switchToAppAdministrator();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user), 1);
    }

    function testERC721_ApplicationERC721U_Burn_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(1);
        ///Switch to app administrator account for burn
        switchToAppAdministrator();
        /// Burn appAdministrator token
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(0);
        ///Return to app admin account
        switchToAppAdministrator();
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
    }

    function testERC721_ApplicationERC721U_Burn_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user);
        switchToUser();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user, appAdministrator, 0);
        ///attempt to burn token that user does not own
        vm.expectRevert("ERC721: caller is not token owner or approved");
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(0);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalanceRule_Minimum() public endWithStopPrank {
        /// make sure the minimum rules fail results in revert
        _accountMinMaxTokenBalanceRuleSetup();
        vm.startPrank(user1, user1);
        vm.expectRevert(abi.encodeWithSignature("UnderMinBalance()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user3, 5);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalanceRule_Maximum() public endWithStopPrank {
        _accountMinMaxTokenBalanceRuleSetup();
        ///make sure the maximum rule fail results in revert
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); /// Id 6
        }

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2);
        // transfer to user1 to exceed limit
        vm.startPrank(user2, user2);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalanceRule_Upgrade() public endWithStopPrank {
        // upgrade the NFT and make sure it still works
        _accountMinMaxTokenBalanceRuleSetup();
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); /// Id 6
        }
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2);
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user2, user2);
        // transfer should still fail
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
    }

    function testERC721_ApplicationERC721U_AccountDenyOracle_Negative() public endWithStopPrank {
        _accountDenyOracleSetup();
        vm.startPrank(user1, user1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(69), 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(address(69)), 0);
    }

    function testERC721_ApplicationERC721U_AccountApproveOracle_Negative() public endWithStopPrank {
        _accountApproveOracleSetup();
        vm.startPrank(user1, user1);
        // This one should fail
        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(88), 3);
    }

    function testERC721_ApplicationERC721U_AccountApproveDenyOracle_Invalid() public endWithStopPrank {
        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC721_ApplicationERC721U_PauseRulesViaAppManager_Negative() public endWithStopPrank {
        _pauseRulesViaAppManagerSetup();
        vm.startPrank(user1, user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
    }

    function testERC721_ApplicationERC721U_PauseRulesViaAppManager_Upgrade() public endWithStopPrank {
        // upgrade the NFT and make sure it still works
        _pauseRulesViaAppManagerSetup();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user1, user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
    }

    function testERC721_ApplicationERC721U_TokenMaxDailyTrades_OneTagFail() public endWithStopPrank {
        _tokenMaxDailyTradesSetup(false);
        vm.startPrank(user2, user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
    }

    function testERC721_ApplicationERC721U_TokenMaxDailyTrades_Period() public endWithStopPrank {
        _tokenMaxDailyTradesSetup(false);
        vm.startPrank(user2, user2);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 0);
    }

    function testERC721_ApplicationERC721U_TokenMaxDailyTrades_AdditionalTagFail() public endWithStopPrank {
        _tokenMaxDailyTradesSetup(true);
        vm.startPrank(user2, user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
    }

    function testERC721_ApplicationERC721U_TokenMaxDailyTrades_Upgrade() public endWithStopPrank {
        // upgrade the NFT and make sure it still fails
        _tokenMaxDailyTradesSetup(true);
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user2, user2);
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
    }

    function testERC721_ApplicationERC721U_AccountMaxTransactionValueByRiskScore_Negative() public endWithStopPrank {
        ///Fail cases
        _accountMaxTransactionValueByRiskScoreSetup();
        vm.startPrank(user2, user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 12000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.startPrank(user2, user2);
        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 12000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);
    }

    function testERC721_ApplicationERC721U_AccountMaxTransactionValueByRiskScore_PriceChange() public endWithStopPrank {
        _accountMaxTransactionValueByRiskScoreSetup();
        ///simulate price changes
        switchToAppAdministrator();

        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);
    }

    function testERC721_ApplicationERC721U_AccountMaxTransactionValueByRiskScore_Upgrade() public endWithStopPrank {
        /// upgrade the NFT and make sure it still fails
        _accountMaxTransactionValueByRiskScoreSetup();
        ///simulate price changes
        switchToAppAdministrator();

        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user2, user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);
    }

    function testERC721_ApplicationERC721U_AccountDenyForNoAccessLevelInNFT_Negative() public endWithStopPrank {
        // transfers should not work for addresses without AccessLevel
        _accountDenyForNoAccessLevelInNFTSetup();
        vm.startPrank(user1, user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
    }

    function testERC721_ApplicationERC721U_AccountDenyForNoAccessLevelInNFT_Upgrade() public endWithStopPrank {
        // upgrade the NFT and make sure it still fails
        _accountDenyForNoAccessLevelInNFTSetup();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user1, user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
    }

    function testERC721_ApplicationERC721U_AccountDenyForNoAccessLevelInNFT_AccessLevelFail() public endWithStopPrank {
        // set AccessLevel and try again
        _accountDenyForNoAccessLevelInNFTSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.startPrank(user1, user1);
        vm.expectRevert(0x3fac082d); /// user 1 accessLevel is still 0 so tx reverts
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
    }

    function testERC721_ApplicationERC721U_AccountDenyForNoAccessLevelInNFT_AccessLevelPass() public endWithStopPrank {
        _accountDenyForNoAccessLevelInNFTSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        applicationAppManager.addAccessLevel(user2, 1);
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalance_Negative() public endWithStopPrank {
        /// Transfers failing (below min value limit)
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.startPrank(user3, user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalance_Upgrade() public endWithStopPrank {
        // upgrade the NFT and make sure it still fails
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.startPrank(user3, user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);
    }

    function testERC721_ApplicationERC721U_AccountMinMaxTokenBalance_Period() public endWithStopPrank {
        _accountMinMaxTokenBalanceSetup();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);

        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);

        vm.startPrank(user3, user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6);
    }

    function testERC721_ApplicationERC721U_UpgradeAppManager721u_FailZeroAddress() public endWithStopPrank {
        _upgradeAppManager721uSetup();
        /// Test fail scenarios
        switchToAppAdministrator();
        // zero address
        vm.expectRevert(0xd92e233d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(0));
    }

    function testERC721_ApplicationERC721U_UpgradeAppManager721u_FailNoProposedAddress() public endWithStopPrank {
        _upgradeAppManager721uSetup();
        switchToAppAdministrator();
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        applicationAppManager2.confirmAppManager(address(applicationNFT));
    }

    function testERC721_ApplicationERC721U_UpgradeAppManager721u_NonProposerConfirm() public endWithStopPrank {
        _upgradeAppManager721uSetup();
        switchToAppAdministrator();
        // non proposer tries to confirm
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        switchToNewAdmin();
        applicationAppManager3.addAppAdministrator(address(appAdministrator));
        switchToAppAdministrator();
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(applicationNFTProxy));
    }

    function testERC721_ApplicationERC721U_ERC721Upgrade() public endWithStopPrank {
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).upgradeTo(address(applicationNFT2));
        // applicationNFTProxy.upgradeTo(address(applicationNFT2));
    }

    /// INTERNAL HELPER FUNCTIONS

    function _accountMinMaxTokenBalanceRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// mint 6 NFTs to appAdministrator for transfer
        for (uint i = 0; i < 6; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        }

        /// set up a non admin user with tokens
        ///transfer tokenId 1 and 2 to rich_user
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, rich_user, 1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, rich_user, 2);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user1, 4);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user1, 5);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 2);

        ///Add Tag to account
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        applicationAppManager.addTag(user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
        applicationAppManager.addTag(user3, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Oscar"));
        ///perform transfer that checks rule
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 4);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(6));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
    }

    function _accountDenyOracleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);

        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
    }

    function _accountApproveOracleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        // add an approved address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        goodBoys.push(user1);
        oracleApproved.addToApprovedList(goodBoys);
        vm.startPrank(user1, user1);
        // This one should pass
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
    }

    function _pauseRulesViaAppManagerSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);
    }

    /**
     * @dev Test the TokenMaxDailyTrades rule
     */
    function _tokenMaxDailyTradesSetup(bool additionalTag) public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        // apply the rule
        uint32 ruleId = createTokenMaxDailyTradesRule("BoredGrape", "DiscoPunk", 1, 5);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        applicationAppManager.addTag(address(applicationNFTProxy), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);

        if (additionalTag) {
            // add the other tag and check to make sure that it still only allows 1 trade
            switchToAppAdministrator();
            applicationAppManager.addTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
            vm.startPrank(user1, user1);
            // first one should pass
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 2);
        }
    }

    function _accountMaxTransactionValueByRiskScoreSetup() public endWithStopPrank {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        ///Mint NFT's (user1,2,3)
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 6
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 7
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 3);

        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11));
        setAccountMaxTxValueByRiskRule(ruleId);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for (uint i = 0; i < 8; i++) {
            erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), i, (10 + i) * ATTO);
        }

        ///Transfer NFT's
        ///Positive cases
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 0);

        vm.startPrank(user3, user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 0);

        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 4);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 1);
    }

    function _accountDenyForNoAccessLevelInNFTSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i = 0; i < 5; i++) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(createActionTypeArrayAll(), true);
    }

    function _accountMinMaxTokenBalanceSetup() public endWithStopPrank {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 3
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 4
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user3); // tokenId = 6
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user3); // tokenId = 7
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user3); // tokenId = 8

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("MIN1", "MIN2", "MIN3");
        uint256[] memory minAmounts = createUint256Array(1, 2, 3); /// Represent min number of tokens held by user for Collection address
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// Add Tags to users
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "MIN1"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MIN1"));
        applicationAppManager.addTag(user2, "MIN2"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MIN2"));
        applicationAppManager.addTag(user3, "MIN3"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "MIN3"));

        /// Transfers passing (above min value limit)
        vm.startPrank(user1, user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.startPrank(user2, user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 3);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.startPrank(user3, user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);
    }

    function _upgradeAppManager721uSetup() public endWithStopPrank {
        switchToAppAdministrator();
        address newAdmin = address(75);
        /// create a new app manager
        applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(applicationAppManager2));
        switchToNewAdmin();
        applicationAppManager2.addAppAdministrator(address(appAdministrator));

        /// confirm the app manager
        switchToAppAdministrator();
        applicationAppManager2.confirmAppManager(address(applicationNFTProxy));
        /// test to ensure it still works
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        switchToAppAdministrator();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user), 1);
    }
}

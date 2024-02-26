// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

contract ApplicationERC721UTest is TestCommonFoundry, ERC721Util {

    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokensUpgradeable();
        switchToAppAdministrator();
        vm.warp(Blocktime); // set block.timestamp
    }

    function testERC721U_MintUpgradeable() public {
        /// Owner Mints new tokenId
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        console.log(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        console.log(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator));
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 2);
    }

    function testERC721U_AdminMintOnlyUpgradeable() public {
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
 
    function testERC721U_TransferUpgradeable() public {
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user), 1);
    }

    function testERC721U_BurnUpgradeable() public {
        ///Mint and transfer tokenId 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(1);
        ///Switch to app administrator account for burn
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// Burn appAdministrator token
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(0);
        ///Return to app admin account
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
    }

    function testFailBurnUpgradeable() public {
        ///Mint and transfer tokenId 0
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user, appAdministrator, 0);
        ///attempt to burn token that user does not own
        switchToUser();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).burn(0);
    }
 
    function testERC721U_AccountMinMaxTokenBalanceRuleUpgradeable() public {
        /// mint 6 NFTs to appAdministrator for transfer
        for(uint i=0;i < 6;i++){
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        }


        /// set up a non admin user with tokens
        switchToAppAdministrator();
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
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 4);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        uint32 ruleId = createAccountMinMaxTokenBalanceRuleRule("Oscar", 1, 6);
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user3, 5);

        ///make sure the maximum rule fail results in revert
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        for(uint i=0;i < 5;i++){
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1); /// Id 6
        }

        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x1da56a44);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
        // upgrade the NFT and make sure it still works
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        // transfer should still fail
        vm.expectRevert(0x1da56a44);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
    
    }

    function testERC721U_AccountApproveDenyOracleUpgradeable() public {
        /// set up a non admin user an nft
        for(uint i=0;i < 5;i++){
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
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(69), 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(address(69)), 0);
        // check the allowed list type
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        // add an approved address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC721U_PauseRulesViaAppManager() public {
        /// set up a non admin user an nft
        for(uint i=0;i < 5;i++){
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
        // upgrade the NFT and make sure it still works
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
    }

    /**
     * @dev Test the TokenMaxDailyTrades rule
     */
    function testERC721U_TokenMaxDailyTrades() public {
        /// set up a non admin user an nft
        for(uint i=0;i < 5;i++){
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
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        applicationAppManager.addTag(address(applicationNFTProxy), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x09a92f2d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
    }

    function testERC721U_AccountMaxTransactionValueByRiskScore() public {
        switchToAppAdministrator();
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

        uint32 ruleId = createAccountMaxTxValueByRiskRule(0, 10, 40, 80, 17, 15, 12, 11);
        setAccountMaxTxValueByRiskRule(ruleId);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, 0);
        applicationAppManager.addRiskScore(user2, 10);
        applicationAppManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for(uint i=0;i < 8;i++){
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), i, (10 + i) * ATTO);
        }

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 4);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();

        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);
    }

    function testERC721U_AccountDenyForNoAccessLevelInNFTUpgradeable() public {
        /// set up a non admin user an nft
        for(uint i=0;i < 5;i++){
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(user1);
        }

        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(true);

        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);

        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// user 1 accessLevel is still 0 so tx reverts
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 1);
    }

    function testERC721U_AccountMinMaxTokenBalanceUpgradeable() public {
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
        uint32 ruleId = createAccountMinMaxTokenBalanceRuleRule(accs, minAmounts, maxAmounts, periods);
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
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 3);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 1);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);

        /// Transfers failing (below min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user3), 3);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6);
    }

    function testERC721U_AdminMinTokenBalanceUpgradeable() public {
        /// Mint TokenId 0-6 to admin
        for (uint i; i < 7; i++ ) {
            ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(ruleBypassAccount);
        }
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        uint32 ruleId = createAdminMinTokenBalanceRule(5, uint64(block.timestamp + 365 days));
        setAdminMinTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// Set the rule in the handler
        switchToRuleAdmin();

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);
        switchToRuleBypassAccount();
        /// These transfers should pass
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(ruleBypassAccount, user1, 0);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(ruleBypassAccount, user1, 1);
        /// This one fails
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(ruleBypassAccount, user1, 2);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        switchToRuleBypassAccount();
        vm.expectRevert();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(ruleBypassAccount, user1, 2);

        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeTransferFrom(ruleBypassAccount, user1, 2);
        switchToRuleAdmin();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);
    }

    function testERC721U_UpgradeAppManager721u() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager _applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(_applicationAppManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        _applicationAppManager2.confirmAppManager(address(applicationNFTProxy));
        /// test to ensure it still works
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).safeMint(appAdministrator);
        switchToAppAdministrator();
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).transferFrom(appAdministrator, user, 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
        assertEq(ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).balanceOf(user), 1);

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        _applicationAppManager2.confirmAppManager(address(applicationNFT));
        // non proposer tries to confirm
        ApplicationERC721UpgAdminMint(address(applicationNFTProxy)).proposeAppManagerAddress(address(_applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(applicationNFTProxy));
    }

    function testERC721U_ERC721Upgrade() public {
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721UpgAdminMint();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
    }
}

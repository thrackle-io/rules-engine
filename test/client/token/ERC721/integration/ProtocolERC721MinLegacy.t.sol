// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";
/**
 * @dev This test is to confirm that the pass through logic created for legacy implementations does in fact work. 
 */
contract ProtocolERC721MinLegacyTest is TestCommonFoundry, DummyNFTAMM, ERC721Util {

    uint256 erc721Liq = 10_000;
     uint256 erc20Liq = 100_000 * ATTO;

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC721MinLegacyAndDiamondHandler();
    }

    function testERC721Legacy_ProtocolERC721Min_HandlerVersions() public view {
        string memory version = VersionFacet(address(applicationNFTHandler)).version();
        assertEq(version, "1.2.0");
    }

    function testERC721Legacy_ProtocolERC721Min_AlreadyInitialized() public endWithStopPrank(){
        vm.stopPrank();
        vm.startPrank(address(minimalNFTLegacy));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(user1, user2, user3);
    }

    function testERC721Legacy_ProtocolERC721Min_ERC721OnlyTokenCanCallCheckAllRules() public{
        address handler = minimalNFTLegacy.getHandlerAddress();
        assertEq(handler, address(applicationNFTHandler));
        address owner = ERC173Facet(address(applicationNFTHandler)).owner();
        assertEq(owner, address(minimalNFTLegacy));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC721Legacy_ProtocolERC721Min_Mint() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Owner Mints new tokenId
        minimalNFTLegacy.safeMint(appAdministrator);
        console.log(minimalNFTLegacy.balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        minimalNFTLegacy.safeMint(appAdministrator);
        console.log(minimalNFTLegacy.balanceOf(appAdministrator));
        assertEq(minimalNFTLegacy.balanceOf(appAdministrator), 2);
    }

    function testERC721Legacy_ProtocolERC721Min_Transfer() public endWithStopPrank() {
        switchToAppAdministrator();
        minimalNFTLegacy.safeMint(appAdministrator);
        minimalNFTLegacy.transferFrom(appAdministrator, user, 0);
        assertEq(minimalNFTLegacy.balanceOf(appAdministrator), 0);
        assertEq(minimalNFTLegacy.balanceOf(user), 1);
    }

    function testERC721Legacy_ProtocolERC721Min_BurnERC721_Positive() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        minimalNFTLegacy.safeMint(appAdministrator);
        minimalNFTLegacy.transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        minimalNFTLegacy.safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        minimalNFTLegacy.burn(1);

        /// Burn appAdministrator token
        minimalNFTLegacy.burn(0);
        assertEq(minimalNFTLegacy.balanceOf(appAdministrator), 0);
        assertEq(minimalNFTLegacy.balanceOf(appAdministrator), 0);
    }

    function testERC721Legacy_ProtocolERC721Min_BurnERC721_Negative() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        minimalNFTLegacy.safeMint(appAdministrator);
        switchToUser();
        ///attempt to burn token that user does not own
        vm.expectRevert("ERC721: caller is not token owner or approved");
        minimalNFTLegacy.burn(0);
    }

    function testERC721Legacy_ProtocolERC721Min_ZeroAddressChecksERC721() public {
        vm.expectRevert();
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert();
        minimalNFTLegacy.connectHandlerToToken(address(0));

        /// test both address checks in constructor
        applicationNFTHandler = _createERC721HandlerDiamond();
       
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(0x0), address(applicationAppManager), address(minimalNFTLegacy));
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(0x0), address(minimalNFTLegacy));
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(0x0));

        vm.expectRevert();
        applicationHandler.setNFTPricingAddress(address(0x00));
    }

    function testERC721Legacy_ProtocolERC721Min_AccountMinMaxTokenBalanceRule() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint 6 NFTs to appAdministrator for transfer
        for (uint i; i < 6; i++) {
        minimalNFTLegacy.safeMint(appAdministrator);
        }


        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 0);
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 1);
        assertEq(minimalNFTLegacy.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        minimalNFTLegacy.transferFrom(appAdministrator, user1, 3);
        minimalNFTLegacy.transferFrom(appAdministrator, user1, 4);
        assertEq(minimalNFTLegacy.balanceOf(user1), 2);

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
        minimalNFTLegacy.transferFrom(user1, user2, 3);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        assertEq(minimalNFTLegacy.balanceOf(user1), 1);
        switchToRuleAdmin();
        ///update ruleId in application NFT handler
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(6)); 
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        minimalNFTLegacy.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        for (uint i; i < 5; i++) {
            minimalNFTLegacy.safeMint(user1); 
        }

        vm.stopPrank();
        switchToAppAdministrator();
        minimalNFTLegacy.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x1da56a44);
        minimalNFTLegacy.transferFrom(user2, user1, 3);

        /// test that burn works with rule
        minimalNFTLegacy.burn(3);
        vm.expectRevert(0x3e237976);
        minimalNFTLegacy.burn(11);
    }

    function testERC721Legacy_ProtocolERC721Min_AccountMinMaxTokenBalanceBlankTag2() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint 6 NFTs to appAdministrator for transfer
        for (uint i; i < 10; i++) {
            minimalNFTLegacy.safeMint(appAdministrator);
        }

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 0);
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 1);
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 5);
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 6);
        minimalNFTLegacy.transferFrom(appAdministrator, rich_user, 7);
        assertEq(minimalNFTLegacy.balanceOf(rich_user), 5);

        ///transfer tokenId 3 and 4 to user1
        minimalNFTLegacy.transferFrom(appAdministrator, user1, 3);
        minimalNFTLegacy.transferFrom(appAdministrator, user1, 4);
        assertEq(minimalNFTLegacy.balanceOf(user1), 2);

        ///update ruleId in application NFT handler
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(3));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 3);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        assertEq(minimalNFTLegacy.balanceOf(user1), 1);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        minimalNFTLegacy.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        minimalNFTLegacy.transferFrom(rich_user, user1, 5);
        assertEq(minimalNFTLegacy.balanceOf(user1), 2);
        minimalNFTLegacy.transferFrom(rich_user, user1, 6);
        assertEq(minimalNFTLegacy.balanceOf(user1), 3);
        // one more should revert for max
        vm.expectRevert(0x1da56a44);
        minimalNFTLegacy.transferFrom(rich_user, user1, 7);
    }

    function testERC721Legacy_ProtocolERC721Min_AccountApproveDenyOracle2() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            minimalNFTLegacy.safeMint(user1);
        }

        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

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
        minimalNFTLegacy.transferFrom(user1, user2, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        minimalNFTLegacy.transferFrom(user1, address(69), 1);
        assertEq(minimalNFTLegacy.balanceOf(address(69)), 0);
        // check the allowed list type
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        minimalNFTLegacy.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        minimalNFTLegacy.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
        /// test burning while oracle rule is active (allow list active)
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);

        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
       ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2767bda4);
        minimalNFTLegacy.burn(3);
    }

    function testERC721Legacy_ProtocolERC721Min_PauseRulesViaAppManager() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        minimalNFTLegacy.safeMint(user1);
        minimalNFTLegacy.safeMint(user1);
        minimalNFTLegacy.safeMint(user1);
        minimalNFTLegacy.safeMint(user1);
        minimalNFTLegacy.safeMint(user1);

        assertEq(minimalNFTLegacy.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        minimalNFTLegacy.transferFrom(user1, address(59), 2);
    }

    function testERC721Legacy_ProtocolERC721Min_TokenMaxDailyTrades() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2
        minimalNFTLegacy.safeMint(user1); // tokenId = 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 4

        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createTokenMaxDailyTradesRule("BoredGrape", "DiscoPunk", 1, 5);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(minimalNFTLegacy), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.transferFrom(user2, user1, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(minimalNFTLegacy), "DiscoPunk"); ///add tag
        applicationAppManager.addTag(address(minimalNFTLegacy), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 1);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        minimalNFTLegacy.transferFrom(user2, user1, 1);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        minimalNFTLegacy.transferFrom(user2, user1, 1);
        assertEq(minimalNFTLegacy.balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addTag(address(minimalNFTLegacy), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        minimalNFTLegacy.transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        minimalNFTLegacy.transferFrom(user2, user1, 2);
    }
 
    function testERC721Legacy_ProtocolERC721Min_TokenMaxDailyTradesBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2
        minimalNFTLegacy.safeMint(user1); // tokenId = 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 4

        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createTokenMaxDailyTradesRule("", 1);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(minimalNFTLegacy), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        minimalNFTLegacy.transferFrom(user2, user1, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        minimalNFTLegacy.transferFrom(user2, user1, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 0);
    }

    function testERC721Legacy_ProtocolERC721Min_AccountMaxTransactionValueByRiskScore() public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        ///Mint NFT's (user1,2,3)
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2
        minimalNFTLegacy.safeMint(user1); // tokenId = 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 4
        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

        minimalNFTLegacy.safeMint(user2); // tokenId = 5
        minimalNFTLegacy.safeMint(user2); // tokenId = 6
        minimalNFTLegacy.safeMint(user2); // tokenId = 7
        assertEq(minimalNFTLegacy.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11));
        setAccountMaxTxValueByRiskRule(ruleId); 
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for (uint i; i < 8; i++ ) {
            erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), i, (10 + i) * ATTO);
        }

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        minimalNFTLegacy.safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 4);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 7, 9 * ATTO); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 7);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 4);

        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.burn(5);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
        minimalNFTLegacy.burn(4);
        vm.expectRevert();
        minimalNFTLegacy.burn(6);
    }

    function testERC721Legacy_ProtocolERC721Min_AccountMaxTransactionValueByRiskScoreWithPeriod() public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        ///Mint NFT's (user1,2,3)
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2
        minimalNFTLegacy.safeMint(user1); // tokenId = 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 4
        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

        minimalNFTLegacy.safeMint(user2); // tokenId = 5
        minimalNFTLegacy.safeMint(user2); // tokenId = 6
        minimalNFTLegacy.safeMint(user2); // tokenId = 7
        assertEq(minimalNFTLegacy.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
        switchToRuleAdmin();
        uint8 period = 24; 
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11), period);
        setAccountMaxTxValueByRiskRule(ruleId);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for (uint i; i < 8; i++ ) {
            erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), i, (10 + i) * ATTO);
        }

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user3, 0);

        vm.warp(block.timestamp + 25 hours);
        vm.stopPrank();
        vm.startPrank(user3);
        minimalNFTLegacy.safeTransferFrom(user3, user1, 0);

        vm.warp(block.timestamp + 25 hours * 2);
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 4);
        vm.warp(block.timestamp + 25 hours * 3);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);

        vm.warp(block.timestamp + 25 hours * 4);
        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 4, 1050 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 5, 1550 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 7, 9 * ATTO); // in dollars

        vm.warp(block.timestamp + 25 hours * 5);
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 7);
        vm.warp(block.timestamp + 25 hours * 6);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user2, user3, 5);

        vm.warp(block.timestamp + 25 hours * 7);
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user3, 4);

        vm.warp(block.timestamp + 25 hours * 8);
        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.burn(5);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
        minimalNFTLegacy.burn(4);
        vm.expectRevert();
        minimalNFTLegacy.burn(6);

        /// negative cases in multiple steps
        vm.warp(block.timestamp + 25 hours * 9);
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        vm.expectRevert();
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);
    }
    
    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testERC721Legacy_ProtocolERC721Min_AccountDenyForNoAccessLevelInNFT() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2
        minimalNFTLegacy.safeMint(user1); // tokenId = 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 4

        assertEq(minimalNFTLegacy.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        createAccountDenyForNoAccessLevelRule();
        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        minimalNFTLegacy.transferFrom(user1, user2, 0);
        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// still fails since user 1 is accessLevel0
        minimalNFTLegacy.transferFrom(user1, user2, 0);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 0);
        assertEq(minimalNFTLegacy.balanceOf(user2), 1);
    }

    function testERC721Legacy_ProtocolERC721Min_AccountMinMaxTokenBalance() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1
        minimalNFTLegacy.safeMint(user1); // tokenId = 2

        minimalNFTLegacy.safeMint(user2); // tokenId = 3
        minimalNFTLegacy.safeMint(user2); // tokenId = 4
        minimalNFTLegacy.safeMint(user2); // tokenId = 5

        minimalNFTLegacy.safeMint(user3); // tokenId = 6
        minimalNFTLegacy.safeMint(user3); // tokenId = 7
        minimalNFTLegacy.safeMint(user3); // tokenId = 8

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
        /// Add Tags to users
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "MIN1"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MIN1"));
        applicationAppManager.addTag(user2, "MIN2"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MIN2"));
        applicationAppManager.addTag(user3, "MIN3"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "MIN3"));
        /// Set rule bool to active
        switchToRuleAdmin();
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// Transfers passing (above min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        minimalNFTLegacy.safeTransferFrom(user1, user3, 1);
        assertEq(minimalNFTLegacy.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        minimalNFTLegacy.safeTransferFrom(user2, user3, 3);
        assertEq(minimalNFTLegacy.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        minimalNFTLegacy.safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        minimalNFTLegacy.safeTransferFrom(user3, user1, 1);
        assertEq(minimalNFTLegacy.balanceOf(user3), 3);

        /// Transfers failing (below min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        minimalNFTLegacy.safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        minimalNFTLegacy.safeTransferFrom(user1, rich_user, 2);
        assertEq(minimalNFTLegacy.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        minimalNFTLegacy.safeTransferFrom(user2, rich_user, 4);
        assertEq(minimalNFTLegacy.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        minimalNFTLegacy.safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(minimalNFTLegacy.balanceOf(user3), 3);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, rich_user, 2);

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, rich_user, 4);

        vm.stopPrank();
        vm.startPrank(user3);
        minimalNFTLegacy.safeTransferFrom(user3, rich_user, 6);
    }
    
    function testERC721Legacy_ProtocolERC721Min_AccountMinMaxTokenBalanceBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        minimalNFTLegacy.safeMint(user1); // tokenId = 0
        minimalNFTLegacy.safeMint(user1); // tokenId = 1

        minimalNFTLegacy.safeMint(user2); // tokenId = 2
        minimalNFTLegacy.safeMint(user2); // tokenId = 3

        minimalNFTLegacy.safeMint(user3); // tokenId = 4
        minimalNFTLegacy.safeMint(user3); // tokenId = 5
        minimalNFTLegacy.safeMint(user3); // tokenId = 6

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000), createUint16Array(720));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// Transfers passing (above min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        // should fail since it puts user1 below min of 1
        vm.expectRevert(0xa7fb7b4b); 
        minimalNFTLegacy.safeTransferFrom(user1, user3, 1);
    }

    function testERC721Legacy_ProtocolERC721Min_TransferVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            minimalNFTLegacy.safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        // transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 3);
    }

    function testERC721Legacy_ProtocolERC721Min_TransferVolumeRuleWithSupplySet() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            minimalNFTLegacy.safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        //transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        // assertFalse(isWithinPeriod2(Blocktime, 2, Blocktime));
        minimalNFTLegacy.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 3);
    }

    function testERC721Legacy_ProtocolERC721Min_TokenMinHoldTime() public endWithStopPrank() {
        /// set the rule for 24 hours
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(24); 
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        minimalNFTLegacy.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer should fail
        vm.expectRevert(0x5f98112f);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 1 days;
        vm.warp(Blocktime);
        minimalNFTLegacy.safeTransferFrom(user1, user2, 0);
        // the original owner was able to transfer but the new owner should not be able to because the time resets
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x5f98112f);
        minimalNFTLegacy.safeTransferFrom(user2, user1, 0);
        // move forward under the threshold and ensure it fails
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);
        vm.expectRevert(0x5f98112f);
        minimalNFTLegacy.safeTransferFrom(user2, user1, 0);
        // now change the rule hold hours to 2 and it should pass
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(2); 
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.safeTransferFrom(user2, user1, 0);
    }

    function testERC721Legacy_ProtocolERC721Min_NFTValuationOrig() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            minimalNFTLegacy.safeMint(user1);
            erc721Pricer.setSingleNFTPrice(address(minimalNFTLegacy), i, 1 * ATTO);
        }
        uint256 testPrice = erc721Pricer.getNFTPrice(address(minimalNFTLegacy), 1);
        assertEq(testPrice, 1 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(minimalNFTLegacy), 1 * ATTO);
        /// set the nftHandler nftValuationLimit variable
        switchToRuleAdmin();
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(20);
        /// activate rule that calls valuation
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, 1, 10, 50, 100);
        setAccountMaxValueByAccessLevelRule(ruleId);
        /// calc expected valuation based on tokenId's
        /**
         total valuation for user1 should be $10 USD
         10 tokens * 1 USD for each token 
         */

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 2);
        applicationAppManager.addAccessLevel(user2, 1);

        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 1);

        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.transferFrom(user2, user1, 1);

        /// switch to rule admin to deactive rule for set up 
        switchToRuleAdmin();
        applicationHandler.activateAccountMaxValueByAccessLevel(createActionTypeArrayAll(), false);

        switchToAppAdministrator();
        /// create new collection and mint enough tokens to exceed the nftValuationLimit set in handler
        ApplicationERC721 _applicationNFT2 = new ApplicationERC721("ToughTurtles", "THTR", address(applicationAppManager), "https://SampleApp.io");
        console.log("applicationNFT2", address(_applicationNFT2));
        HandlerDiamond _applicationNFTHandler2 = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(_applicationNFTHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(_applicationNFT2));
        _applicationNFT2.connectHandlerToToken(address(_applicationNFTHandler2));
        /// register the token
        applicationAppManager.registerToken("THTR", address(_applicationNFT2));

        for (uint i = 0; i < 40; i++) {
            _applicationNFT2.safeMint(appAdministrator);
            _applicationNFT2.transferFrom(appAdministrator, user1, i);
            erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), i, 1 * ATTO);
        }
        uint256 testPrice2 = erc721Pricer.getNFTPrice(address(_applicationNFT2), 35);
        assertEq(testPrice2, 1 * ATTO);
        /// set the nftHandler nftValuationLimit variable
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(_applicationNFTHandler2)).setNFTValuationLimit(20);
        /// set specific tokens in NFT 2 to higher prices. Expect this value to be ignored by rule check as it is checking collection price.
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 36, 100 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 37, 50 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 40, 25 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(_applicationNFT2), 1 * ATTO);

        ///reactivate rule 
        switchToRuleAdmin();
        applicationHandler.activateAccountMaxValueByAccessLevel(createActionTypeArrayAll(), true); 
        /// calc expected valuation for user based on tokens * collection price
        /** 
        expected calculated total should be $50 USD since we take total number of tokens owned * collection price 
        10 PuddgyPenguins 
        40 ToughTurtles 
        50 total * collection prices of $1 usd each 
        */

        /// retest rule to ensure proper valuation totals
        /// user 2 has access level 1 and can hold balance of 1
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 1);
        /// user 1 has access level of 2 and can hold balance of 10 (currently above this after admin transfers)
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        minimalNFTLegacy.transferFrom(user2, user1, 1);
        /// increase user 1 access level to allow for balance of $50 USD
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 3);
        /**
        This passes because: 
        Handler Valuation limits are set at 20 
        Valuation will check collection price (Floor or ceiling) * tokens held by address 
        Actual valuation of user 1 is:
        9 PudgeyPenguins ($9USD) + 40 ToughTurtles ((37 * $1USD) + (1 * $100USD) + (1 * $50USD) + (1 * $25USD) = $221USD)
         */
        vm.stopPrank();
        vm.startPrank(user2);
        minimalNFTLegacy.transferFrom(user2, user1, 1);

        /// adjust nft valuation limit to ensure we revert back to individual pricing
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(50);

        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        minimalNFTLegacy.transferFrom(user2, user1, 1);

        /// test burn with rule active user 2
        minimalNFTLegacy.burn(1);
        /// test burns with user 1
        vm.stopPrank();
        vm.startPrank(user1);
        minimalNFTLegacy.burn(3);
        _applicationNFT2.burn(36);
    }


    /// INTERNAL HELPER FUNCTIONS
    function _approveTokens(DummyNFTAMM amm, uint256 amountERC20, bool _isApprovalERC721) internal {
        applicationCoin.approve(address(amm), amountERC20);
        minimalNFTLegacy.setApprovalForAll(address(amm), _isApprovalERC721);
    }

    function _safeMintERC721(uint256 amount) internal {
        for(uint256 i; i < amount; i++){
            minimalNFTLegacy.safeMint(appAdministrator);
        }
    }

    function _addLiquidityInBatchERC721(DummyNFTAMM amm, uint256 amount) private {
        for(uint256 i; i < amount; i++){
            minimalNFTLegacy.safeTransferFrom(appAdministrator, address(amm), i);
        }
    }

    function _testBuyNFT(uint256 _tokenId, DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(minimalNFTLegacy), 10, _tokenId, true);
    }

    function _testSellNFT(uint256 _tokenId,  DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(minimalNFTLegacy), 10, _tokenId, false);
    }

    function _fundThreeAccounts() internal endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user, 1000 * ATTO);
        applicationCoin.transfer(user2, 1000 * ATTO);
        applicationCoin.transfer(user1, 1000 * ATTO);
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + 50; i++){
            minimalNFTLegacy.safeTransferFrom(appAdministrator, user, i);
        }
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 150; i++){
            minimalNFTLegacy.safeTransferFrom(appAdministrator, user1, i);
        }
        for(uint i = erc721Liq / 2 + 200; i < erc721Liq / 2 + 250; i++){
            minimalNFTLegacy.safeTransferFrom(appAdministrator, user2, i);
        }
    }
    

}


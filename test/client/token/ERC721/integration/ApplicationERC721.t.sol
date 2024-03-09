// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

contract ApplicationERC721Test is TestCommonFoundry, DummyNFTAMM, ERC721Util {

    uint256 erc721Liq = 10_000;
     uint256 erc20Liq = 100_000 * ATTO;

    function setUp() public {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
    }

    function testERC721_ApplicationERC721_HandlerVersions() public {
        string memory version = VersionFacet(address(applicationNFTHandler)).version();
        assertEq(version, "1.1.0");
    }

    function testERC721_ApplicationERC721_AlreadyInitialized() public endWithStopPrank(){
        vm.startPrank(address(applicationNFT));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(user1, user2, user3);
    }

    function testERC721_ApplicationERC721_SimpleActionEventEmission() public endWithStopPrank() {
        switchToRuleAdmin();
        vm.expectEmit(true,true,true,false);
        emit AD1467_ApplicationHandlerSimpleActionApplied(TOKEN_MIN_HOLD_TIME, ActionTypes.P2P_TRANSFER, 24);
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMinHoldTime(_createActionsArray(), 24);
    }

    function testERC721_ApplicationERC721_NFTEvaluationLimitEventEmission() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectEmit(true,true,true,false);
        emit AD1467_NFTValuationLimitUpdated(20);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(20);
    }

    function testERC721_ApplicationERC721_ERC721OnlyTokenCanCallCheckAllRules() public endWithStopPrank(){
        address handler = applicationNFT.getHandlerAddress();
        assertEq(handler, address(applicationNFTHandler));
        address owner = ERC173Facet(address(applicationNFTHandler)).owner();
        assertEq(owner, address(applicationNFT));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC721_ApplicationERC721_Mint() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Owner Mints new tokenId
        applicationNFT.safeMint(appAdministrator);
        console.log(applicationNFT.balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        applicationNFT.safeMint(appAdministrator);
        console.log(applicationNFT.balanceOf(appAdministrator));
        assertEq(applicationNFT.balanceOf(appAdministrator), 2);
    }

    function testERC721_ApplicationERC721_Transfer() public endWithStopPrank() {
        switchToAppAdministrator();
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
        assertEq(applicationNFT.balanceOf(user), 1);

    }

    function testERC721_ApplicationERC721_BurnERC721_Positive() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        applicationNFT.safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        applicationNFT.burn(1);
        ///Switch to app administrator account for burn

        /// Burn appAdministrator token
        applicationNFT.burn(0);
        ///Return to app admin account
        switchToAppAdministrator();
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
    }

    function testERC721_ApplicationERC721_BurnERC721_Negative() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(appAdministrator);
        switchToUser();
        ///attempt to burn token that user does not own
        vm.expectRevert("ERC721: caller is not token owner or approved");
        applicationNFT.burn(0);
    }

    function testERC721_ApplicationERC721_ZeroAddressChecksERC721() public {
        vm.expectRevert();
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert();
        applicationNFT.connectHandlerToToken(address(0));

        /// test both address checks in constructor
        applicationNFTHandler = _createERC721HandlerDiamond();
       
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(0x0), address(applicationAppManager), address(applicationNFT));
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(0x0), address(applicationNFT));
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(0x0));

        vm.expectRevert();
        applicationHandler.setNFTPricingAddress(address(0x00));
    }

    function testERC721_ApplicationERC721_AccountMinMaxTokenBalanceRule() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint 6 NFTs to appAdministrator for transfer
        for (uint i; i < 6; i++) {
            applicationNFT.safeMint(appAdministrator);
        }

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        applicationNFT.transferFrom(appAdministrator, rich_user, 0);
        applicationNFT.transferFrom(appAdministrator, rich_user, 1);
        assertEq(applicationNFT.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(appAdministrator, user1, 3);
        applicationNFT.transferFrom(appAdministrator, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);

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
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        switchToRuleAdmin();

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(6)); 
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        applicationNFT.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        for (uint i; i < 5; i++) {
            applicationNFT.safeMint(user1);
        }

        vm.stopPrank();
        switchToAppAdministrator();
        applicationNFT.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x1da56a44);
        applicationNFT.transferFrom(user2, user1, 3);

        /// test that burn works with rule
        applicationNFT.burn(3);
        vm.expectRevert(0x3e237976);
        applicationNFT.burn(11);
    }

    function testERC721_ApplicationERC721_AccountMinMaxTokenBalanceBlankTag2() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint NFTs to appAdministrator for transfer
        for (uint i; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        applicationNFT.transferFrom(appAdministrator, rich_user, 0);
        applicationNFT.transferFrom(appAdministrator, rich_user, 1);
        applicationNFT.transferFrom(appAdministrator, rich_user, 5);
        applicationNFT.transferFrom(appAdministrator, rich_user, 6);
        applicationNFT.transferFrom(appAdministrator, rich_user, 7);
        assertEq(applicationNFT.balanceOf(rich_user), 5);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(appAdministrator, user1, 3);
        applicationNFT.transferFrom(appAdministrator, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(3));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        applicationNFT.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(rich_user);
        applicationNFT.transferFrom(rich_user, user1, 5);
        assertEq(applicationNFT.balanceOf(user1), 2);
        applicationNFT.transferFrom(rich_user, user1, 6);
        assertEq(applicationNFT.balanceOf(user1), 3);
        // one more should revert for max
        vm.expectRevert(0x1da56a44);
        applicationNFT.transferFrom(rich_user, user1, 7);
    }

    function testERC721_ApplicationERC721_AccountApproveDenyOracle2() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            applicationNFT.safeMint(user1);
        }
        assertEq(applicationNFT.balanceOf(user1), 5);

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
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationNFT.transferFrom(user1, address(69), 1);
        assertEq(applicationNFT.balanceOf(address(69)), 0);
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
        applicationNFT.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        applicationNFT.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
        /// test burning while oracle rule is active (allow list active)
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2767bda4);
        applicationNFT.burn(3);
    }

    function testERC721_ApplicationERC721_PauseRulesViaAppManager() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFT.transferFrom(user1, address(59), 2);
    }

function testERC721_ApplicationERC721_TokenMaxDailyTrades() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createTokenMaxDailyTradesRule("BoredGrape", "DiscoPunk", 1, 5);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.transferFrom(user2, user1, 0);
        assertEq(applicationNFT.balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(applicationNFT), "DiscoPunk"); ///add tag
        applicationAppManager.addTag(address(applicationNFT), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        applicationNFT.transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        applicationNFT.transferFrom(user2, user1, 2);
    }
 
    function testERC721_ApplicationERC721_TokenMaxDailyTradesBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        uint32 ruleId = createTokenMaxDailyTradesRule("", 1);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        applicationNFT.transferFrom(user2, user1, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFT.transferFrom(user2, user1, 0);
        assertEq(applicationNFT.balanceOf(user2), 0);
    }

    function testERC721_ApplicationERC721_AccountMaxTransactionValueByRiskScore() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint NFT's (user1,2,3)
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4
        assertEq(applicationNFT.balanceOf(user1), 5);

        applicationNFT.safeMint(user2); // tokenId = 5
        applicationNFT.safeMint(user2); // tokenId = 6
        applicationNFT.safeMint(user2); // tokenId = 7
        assertEq(applicationNFT.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
        uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11));
        switchToRuleAdmin();
        setAccountMaxTxValueByRiskRule(ruleId); 
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for (uint i; i < 8; i++ ) {
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (10 + i) * ATTO);
        }
       
        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFT.safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 4);
        applicationNFT.safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * ATTO); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 7);
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 4);

        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.burn(5);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
        applicationNFT.burn(4);
        vm.expectRevert();
        applicationNFT.burn(6);
    }

    function testERC721_ApplicationERC721_AccountMaxTransactionValueByRiskScoreWithPeriod() public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        ///Mint NFT's (user1,2,3)
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4
        assertEq(applicationNFT.balanceOf(user1), 5);

        applicationNFT.safeMint(user2); // tokenId = 5
        applicationNFT.safeMint(user2); // tokenId = 6
        applicationNFT.safeMint(user2); // tokenId = 7
        assertEq(applicationNFT.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
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
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (10 + i) * ATTO);
        }

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user3, 0);

        vm.warp(block.timestamp + 25 hours);
        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFT.safeTransferFrom(user3, user1, 0);

        vm.warp(block.timestamp + 25 hours * 2);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 4);
        vm.warp(block.timestamp + 25 hours * 3);
        applicationNFT.safeTransferFrom(user1, user2, 1);

        vm.warp(block.timestamp + 25 hours * 4);
        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 1050 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 1550 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * ATTO); // in dollars

        vm.warp(block.timestamp + 25 hours * 5);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 7);
        vm.warp(block.timestamp + 25 hours * 6);
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.warp(block.timestamp + 25 hours * 7);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 4);

        vm.warp(block.timestamp + 25 hours * 8);
        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.burn(5);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert();
        applicationNFT.burn(4);
        vm.expectRevert();
        applicationNFT.burn(6);

        /// negative cases in multiple steps
        vm.warp(block.timestamp + 25 hours * 9);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }
    
    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testERC721_ApplicationERC721_AccountDenyForNoAccessLevelInNFT() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        createAccountDenyForNoAccessLevelRule();
        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        applicationNFT.transferFrom(user1, user2, 0);
        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// still fails since user 1 is accessLevel0
        applicationNFT.transferFrom(user1, user2, 0);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
    }

    function testERC721_ApplicationERC721_AccountMinMaxTokenBalance() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2

        applicationNFT.safeMint(user2); // tokenId = 3
        applicationNFT.safeMint(user2); // tokenId = 4
        applicationNFT.safeMint(user2); // tokenId = 5

        applicationNFT.safeMint(user3); // tokenId = 6
        applicationNFT.safeMint(user3); // tokenId = 7
        applicationNFT.safeMint(user3); // tokenId = 8

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
        applicationNFT.safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        applicationNFT.safeTransferFrom(user1, user3, 1);
        assertEq(applicationNFT.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        applicationNFT.safeTransferFrom(user2, user3, 3);
        assertEq(applicationNFT.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFT.safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        applicationNFT.safeTransferFrom(user3, user1, 1);
        assertEq(applicationNFT.balanceOf(user3), 3);

        /// Transfers failing (below min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        applicationNFT.safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFT.safeTransferFrom(user1, rich_user, 2);
        assertEq(applicationNFT.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        applicationNFT.safeTransferFrom(user2, rich_user, 4);
        assertEq(applicationNFT.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFT.safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(applicationNFT.balanceOf(user3), 3);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, rich_user, 2);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, rich_user, 4);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFT.safeTransferFrom(user3, rich_user, 6);
    }
    
    function testERC721_ApplicationERC721_AccountMinMaxTokenBalanceBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1

        applicationNFT.safeMint(user2); // tokenId = 2
        applicationNFT.safeMint(user2); // tokenId = 3

        applicationNFT.safeMint(user3); // tokenId = 4
        applicationNFT.safeMint(user3); // tokenId = 5
        applicationNFT.safeMint(user3); // tokenId = 6

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000), createUint16Array(720));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// Transfers passing (above min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // should fail since it puts user1 below min of 1
        vm.expectRevert(0xa7fb7b4b); 
        applicationNFT.safeTransferFrom(user1, user3, 1);
    }

    function testERC721_ApplicationERC721_AdminMinTokenBalance() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint TokenId 0-6 to super admin
        for (uint i; i < 7; i++ ) {
            applicationNFT.safeMint(ruleBypassAccount);
        }
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        switchToRuleAdmin();
        uint32 ruleId = createAdminMinTokenBalanceRule(5, uint64(block.timestamp + 365 days));
        setAdminMinTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        vm.expectRevert();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);
        switchToRuleBypassAccount();
        /// These transfers should pass
        applicationNFT.safeTransferFrom(ruleBypassAccount, user1, 0);
        applicationNFT.safeTransferFrom(ruleBypassAccount, user1, 1);
        /// This one fails
        vm.expectRevert();
        applicationNFT.safeTransferFrom(ruleBypassAccount, user1, 2);

        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        applicationNFT.safeTransferFrom(ruleBypassAccount, user1, 2);
        switchToRuleAdmin();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);
    }

    function testERC721_ApplicationERC721_TransferVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 3);
    }

    function testERC721_ApplicationERC721_TransferVolumeRuleWithSupplySet() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFT.safeTransferFrom(user1, user2, 0);
        //transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        // assertFalse(isWithinPeriod2(Blocktime, 2, Blocktime));
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        applicationNFT.safeTransferFrom(user1, user2, 3);
    }

    function testERC721_ApplicationERC721_TokenMinHoldTime() public endWithStopPrank() {
        /// set the rule for 24 hours
        setTokenMinHoldTimeRule(24); 
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        applicationNFT.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer should fail
        vm.expectRevert(0x5f98112f);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 1 days;
        vm.warp(Blocktime);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // the original owner was able to transfer but the new owner should not be able to because the time resets
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x5f98112f);
        applicationNFT.safeTransferFrom(user2, user1, 0);
        // move forward under the threshold and ensure it fails
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);
        vm.expectRevert(0x5f98112f);
        applicationNFT.safeTransferFrom(user2, user1, 0);
        // now change the rule hold hours to 2 and it should pass
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(2);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);
    }

    function testERC721_ApplicationERC721_CollectionTokenMaxSupplyVolatility() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint tokens to specific supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }
        /// create rule 
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(2000, 24, Blocktime, 0);
        setTokenMaxSupplyVolatilityRule(address(applicationNFTHandler), ruleId);
        /// set blocktime to within rule period
        vm.warp(Blocktime + 13 hours);
        /// mint tokens under supply limit
        vm.stopPrank();
        switchToAppAdministrator();
        applicationNFT.safeMint(user1);
        /// mint tokens to the cap
        applicationNFT.safeMint(user1);
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert();
        applicationNFT.safeMint(user1);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(10);
        /// move out of rule period
        vm.warp(Blocktime + 36 hours);
        /// burn tokens (should pass)
        applicationNFT.burn(11);
        /// mint
        vm.stopPrank();
        switchToAppAdministrator();
        applicationNFT.safeMint(user1);
    }

    function testERC721_ApplicationERC721_NFTValuationOrig() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * ATTO);
        }
        uint256 testPrice = erc721Pricer.getNFTPrice(address(applicationNFT), 1);
        assertEq(testPrice, 1 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * ATTO);
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
        applicationNFT.transferFrom(user1, user2, 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.transferFrom(user2, user1, 1);

        /// switch to rule admin to deactive rule for set up 
        switchToRuleAdmin();
        applicationHandler.activateAccountMaxValueByAccessLevel(false);

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
        applicationHandler.activateAccountMaxValueByAccessLevel(true); 
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
        applicationNFT.transferFrom(user1, user2, 1);
        /// user 1 has access level of 2 and can hold balance of 10 (currently above this after admin transfers)
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        applicationNFT.transferFrom(user2, user1, 1);
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
        applicationNFT.transferFrom(user2, user1, 1);

        /// adjust nft valuation limit to ensure we revert back to individual pricing
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(50);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        applicationNFT.transferFrom(user2, user1, 1);

        /// test burn with rule active user 2
        applicationNFT.burn(1);
        /// test burns with user 1
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(3);
        _applicationNFT2.burn(36);
    }

    function testERC721_ApplicationERC721_UpgradeAppManager721() public endWithStopPrank() {
        switchToAppAdministrator();
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager _applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        applicationNFT.proposeAppManagerAddress(address(_applicationAppManager2));
        /// give new admin app administator role 
        switchToNewAdmin();
        _applicationAppManager2.addAppAdministrator(address(appAdministrator));
        /// confirm the app manager
        switchToAppAdministrator();
        _applicationAppManager2.confirmAppManager(address(applicationNFT));
        /// test to ensure it still works
        applicationNFT.safeMint(appAdministrator);
        vm.stopPrank();
        switchToAppAdministrator();
        applicationNFT.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
        assertEq(applicationNFT.balanceOf(user), 1);

        /// Test fail scenarios
        switchToAppAdministrator();
        // zero address
        vm.expectRevert(0xd92e233d);
        applicationNFT.proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        _applicationAppManager2.confirmAppManager(address(applicationNFT));
        // non proposer tries to confirm
        applicationNFT.proposeAppManagerAddress(address(_applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        switchToNewAdmin();
        applicationAppManager3.addAppAdministrator(address(appAdministrator));
        switchToAppAdministrator();
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(applicationNFT));
    }
 
    function setupTradingRuleTests() internal returns(DummyNFTAMM) {
        DummyNFTAMM amm = new DummyNFTAMM();
        _safeMintERC721(erc721Liq);
        _approveTokens(amm, erc20Liq, true);
        _addLiquidityInBatchERC721(amm, erc721Liq / 2); /// half of total supply
        applicationCoin.mint(appAdministrator, 1_000_000 * ATTO);
        applicationCoin.transfer(address(amm), erc20Liq);
        return amm;
    }

    function testERC721_ApplicationERC721_TokenMaxBuyVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set up rule
        uint16 tokenPercentage = 10; /// .1% 
        uint32 ruleId = createTokenMaxBuyVolumeRule(10, 24, 0, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationNFTHandler), ruleId);
        /// we make sure we are in a new period
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i; i < (erc721Liq * tokenPercentage) / 10000 - 1; i++){
            _testBuyNFT(i, amm);
        }
        vm.expectRevert(0x6a46d1f4);
        _testBuyNFT(tokenPercentage, amm);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x6a46d1f4);
        _testBuyNFT(tokenPercentage + 1, amm);
        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testBuyNFT(tokenPercentage + 1, amm);
        /// with another user
        vm.stopPrank();
        vm.startPrank(user1);
        /// we have to do this manually since the _testBuyNFT uses the *user* acccount
        _testBuyNFT(tokenPercentage + 2, amm);
    }

    function testERC721_ApplicationERC721_TokenMaxSellVolumeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// now we setup the sell percentage rule
        uint16 tokenPercentageSell = 30; /// 0.30%
        uint32 ruleId = createTokenMaxSellVolumeRule(30, 24, 0, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationNFTHandler), ruleId);
        vm.warp(Blocktime + 36 hours);
        /// now we test
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test selling the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++){
            _testSellNFT(i,  amm);
        }
        /// If try to sell one more, it should fail in this period.
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + tokenPercentageSell, amm);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
         _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + 100 + 1, amm);
        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testSellNFT(erc721Liq / 2 + tokenPercentageSell + 1, amm);
        /// with another user
         vm.stopPrank();
        vm.startPrank(user1);
        _testSellNFT(erc721Liq / 2 + 100 + 2, amm);
    }

    function testERC721_ApplicationERC721_AccountMaxSellSize() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        uint32 ruleId = createAccountMaxSellSizeRule("AccountMaxSellSize", 1, 36); /// tag, maxNFtsPerPeriod, period
        setAccountMaxSellSizeRule(address(applicationNFTHandler), ruleId);
        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "AccountMaxSellSize");
        /// Swap that passes rule check
        switchToUser();
        applicationNFT.setApprovalForAll(address(amm), true);
        _testSellNFT(erc721Liq / 2 + 1, amm);
        /// Swap that fails
        vm.expectRevert(0x91985774);
        _testSellNFT(erc721Liq / 2 + 2, amm);
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_ApplicationERC721_AccountMaxSellSizeBlankTag() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        uint32 ruleId = createAccountMaxSellSizeRule("", 1, 36); /// tag, maxNFtsPerPeriod, period
        setAccountMaxSellSizeRule(address(applicationNFTHandler), ruleId);
        /// Swap that passes rule check
        switchToUser();
        applicationNFT.setApprovalForAll(address(amm), true);
        _testSellNFT(erc721Liq / 2 + 1, amm);
        /// Swap that fails
        vm.expectRevert(0x91985774);
        _testSellNFT(erc721Liq / 2 + 2, amm);
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_ApplicationERC721_AccountMaxBuySizeRule() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        uint32 ruleId = createAccountMaxBuySizeRule("MaxBuySize", 1, 36); /// tag, maxNFtsPerPeriod, period
        setAccountMaxBuySizeRule(address(applicationNFTHandler), ruleId);
        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "MaxBuySize");
        applicationNFT.setApprovalForAll(address(amm), true);
        // _addLiquidityInBatchERC721(amm,1);
        /// Swap that passes rule check
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        _testBuyNFT(0, amm);
        /// Swap that fails
        vm.expectRevert(0xa7fb7b4b);
        _testBuyNFT(1, amm);
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testBuyNFT(1, amm);
    }

    function testERC721_ApplicationERC721_TokenMaxSellVolumeRuleByPasserRule() public endWithStopPrank() {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        switchToAppAdministrator();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user, true);

        /// SELL PERCENTAGE RULE
        uint16 tokenPercentageSell = 30; /// 0.30%
        uint32 ruleId = createTokenMaxSellVolumeRule(30, 24, 0, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationNFTHandler), ruleId);
        vm.warp(Blocktime + 36 hours);
        /// ALLOWLISTED USER
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going above rule percentage in the period is ok for user (... + 1)
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 + 1; i++){
            _testSellNFT(i,  amm);
        }
        /// NOT ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going right below the rule percentage in the period (... - 1)
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++){
            _testSellNFT(i,  amm);
        }
        /// and now we test the actual rule with a non-allowlisted address to check it will fail
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000,  amm);

        //BUY PERCENTAGE RULE
        uint16 tokenPercentage = 10; /// .1% 
        ruleId = createTokenMaxBuyVolumeRule(10, 24, 0, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationNFTHandler), ruleId);
        /// we make sure we are in a new period
        vm.warp(Blocktime + 72 hours);
        /// ALLOWLISTED USER
        switchToUser();
        /// we test buying the *tokenPercentage* of the NFTs total supply + 1 to prove that *user* can break the rules with no consequences
        for(uint i = erc721Liq / 2 ; i < erc721Liq / 2 + (erc721Liq * tokenPercentage) / 10000 + 1; i++){
            _testBuyNFT(i, amm);
        }
        /// NOT ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentage) / 10000 - 1; i++){
            _testBuyNFT(i, amm);
        }
        /// now we check that user1 cannot break the rule
        vm.expectRevert(0x6a46d1f4);
        _testBuyNFT(erc721Liq / 2 + 100 + tokenPercentage, amm);

        /// SELL RULE
        uint32 ruleIdSell = createAccountMaxSellSizeRule("AccountMaxSellSize", 1, 36); /// tag, maxNFtsPerPeriod, period
        setAccountMaxSellSizeRule(address(applicationNFTHandler), ruleIdSell);
        vm.warp(Blocktime + 108 hours);
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "AccountMaxSellSize");
        applicationAppManager.addTag(user1, "AccountMaxSellSize");
        /// ALLOWLISTED USER
        switchToUser();
        /// user can break the rules
        _testSellNFT(erc721Liq / 2, amm);
        _testSellNFT(erc721Liq / 2 + 1, amm);
        /// NOT ALLOWLISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        /// user1 cannot break the rules
        _testSellNFT(erc721Liq / 2 + 100, amm);
        vm.expectRevert(0x91985774);
        _testSellNFT(erc721Liq / 2 + 100 + 1, amm);
    }

    /* TokenMaxDailyTrades */
    function testApplicationERC721_TokenMaxDailyTradesAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape1", "DiscoPunk", 1, 5);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape2", "DiscoPunk", 1, 15);
        ruleIds[2] = createTokenMaxDailyTradesRule("BoredGrape3", "DiscoPunk", 1, 25);
        ruleIds[3] = createTokenMaxDailyTradesRule("BoredGrape4", "DiscoPunk", 1, 35);
        ruleIds[4] = createTokenMaxDailyTradesRule("BoredGrape5", "DiscoPunk", 1, 45);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxDailyTradesRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BURN));
    }

    function testApplicationERC20_TokenMaxDailyTradesAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape1", "DiscoPunk", 1, 5);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape2", "DiscoPunk", 1, 15);
        ruleIds[2] = createTokenMaxDailyTradesRule("BoredGrape3", "DiscoPunk", 1, 25);
        ruleIds[3] = createTokenMaxDailyTradesRule("BoredGrape4", "DiscoPunk", 1, 35);
        ruleIds[4] = createTokenMaxDailyTradesRule("BoredGrape5", "DiscoPunk", 1, 45);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape6", "DiscoPunk", 1, 65);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape7", "DiscoPunk", 1, 75);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxDailyTradesRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.MINT),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BURN));
    }

    /* TokenMaxSupplyVolatility */
    function testApplicationERC721_TokenMaxSupplyVolatilityAtomicFullSet() public {
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
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    function testApplicationERC721_TokenMaxSupplyVolatilityAtomicFullReSet() public {
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
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    /* TokenMaxTradingVolume */
    function testApplicationERC721_TokenMaxTradingVolumeAtomicFullSet() public {
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
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL),ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY),ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT),ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN),ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

    function testApplicationERC721_TokenMaxTradingVolumeAtomicFullReSet() public {
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
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL),ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY),ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

    /* TokenMinHoldTime */
    function testApplicationERC721_TokenMinHoldTimeAtomicFullSet() public {
        uint32[] memory periods = new uint32[](5);
        // Set up rule
        periods[0] = 1;
        periods[1] = 2;
        periods[2] = 3;
        periods[3] = 4;
        periods[4] = 5;
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER),periods[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.SELL),periods[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BUY),periods[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.MINT),periods[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BURN),periods[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BURN));
    }

    function testApplicationERC721_TokenMinHoldTimeAtomicFullReSet() public {
        uint32[] memory periods = new uint32[](5);
        // Set up rule
        periods[0] = 1;
        periods[1] = 2;
        periods[2] = 3;
        periods[3] = 4;
        periods[4] = 5;        
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        periods = new uint32[](2);
        periods[0] = 6;
        periods[1] = 7;
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.SELL),periods[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BUY),periods[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.MINT),0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BURN),0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BURN));
    }


    /* AccountApproveDenyOracle */
    function testApplicationERC721_AccountApproveDenyOracleAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountApproveDenyOracleRule(0);
        ruleIds[1] = createAccountApproveDenyOracleRule(0);
        ruleIds[2] = createAccountApproveDenyOracleRule(0);
        ruleIds[3] = createAccountApproveDenyOracleRule(0);
        ruleIds[4] = createAccountApproveDenyOracleRule(0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.P2P_TRANSFER)[0],ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.SELL)[0],ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BUY)[0],ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.MINT)[0],ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BURN)[0],ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.P2P_TRANSFER,ruleIds[0]));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.SELL,ruleIds[1]));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BUY,ruleIds[2]));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.MINT,ruleIds[3]));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BURN,ruleIds[4]));
    }

    function testApplicationERC721_AccountApproveDenyOracleAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountApproveDenyOracleRule(0);
        ruleIds[1] = createAccountApproveDenyOracleRule(0);
        ruleIds[2] = createAccountApproveDenyOracleRule(0);
        ruleIds[3] = createAccountApproveDenyOracleRule(0);
        ruleIds[4] = createAccountApproveDenyOracleRule(0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        uint32[] memory ruleIds2 = new uint32[](2);
        ruleIds2[0] = createAccountApproveDenyOracleRule(0);
        ruleIds2[1] = createAccountApproveDenyOracleRule(0);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds2);
        // Verify that all the rule id's were set correctly 
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.SELL)[0],ruleIds2[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BUY)[0],ruleIds2[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.MINT).length,0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(ActionTypes.BURN).length,0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.SELL,ruleIds2[0]));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BUY,ruleIds2[1]));
        // // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.MINT,ruleIds[3]));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(ActionTypes.BURN,ruleIds[4]));
    }

    /// INTERNAL HELPER FUNCTIONS
    function _approveTokens(DummyNFTAMM amm, uint256 amountERC20, bool _isApprovalERC721) internal {
        applicationCoin.approve(address(amm), amountERC20);
        applicationNFT.setApprovalForAll(address(amm), _isApprovalERC721);
    }

    function _safeMintERC721(uint256 amount) internal {
        for(uint256 i; i < amount; i++){
            applicationNFT.safeMint(appAdministrator);
        }
    }

    function _addLiquidityInBatchERC721(DummyNFTAMM amm, uint256 amount) private {
        for(uint256 i; i < amount; i++){
            applicationNFT.safeTransferFrom(appAdministrator, address(amm), i);
        }
    }

    function _testBuyNFT(uint256 _tokenId, DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(applicationNFT), 10, _tokenId, true);
    }

    function _testSellNFT(uint256 _tokenId,  DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(applicationNFT), 10, _tokenId, false);
    }

    function _fundThreeAccounts() internal endWithStopPrank() {
        switchToAppAdministrator();
        applicationCoin.transfer(user, 1000 * ATTO);
        applicationCoin.transfer(user2, 1000 * ATTO);
        applicationCoin.transfer(user1, 1000 * ATTO);
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + 50; i++){
            applicationNFT.safeTransferFrom(appAdministrator, user, i);
        }
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 150; i++){
            applicationNFT.safeTransferFrom(appAdministrator, user1, i);
        }
        for(uint i = erc721Liq / 2 + 200; i < erc721Liq / 2 + 250; i++){
            applicationNFT.safeTransferFrom(appAdministrator, user2, i);
        }
    }
}
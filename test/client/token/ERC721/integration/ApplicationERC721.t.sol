// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";

contract ApplicationERC721Test is TestCommonFoundry, DummyNFTAMM {

    uint256 erc721Liq = 10_000;
     uint256 erc20Liq = 100_000 * ATTO;

    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
    }

    function testERC721_HandlerVersions() public {
        string memory version = applicationNFTHandler.version();
        assertEq(version, "1.1.0");
    }

    function testERC721_Mint() public {
        /// Owner Mints new tokenId
        applicationNFT.safeMint(appAdministrator);
        console.log(applicationNFT.balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        applicationNFT.safeMint(appAdministrator);
        console.log(applicationNFT.balanceOf(appAdministrator));
        assertEq(applicationNFT.balanceOf(appAdministrator), 2);
    }

    function testERC721_Transfer() public {
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
        assertEq(applicationNFT.balanceOf(user), 1);
    }

    function testERC721_Burn() public {
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

    function testERC721_BurnERC721_Negative() public {
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(appAdministrator);
        switchToUser();
        ///attempt to burn token that user does not own
        vm.expectRevert("ERC721: caller is not token owner or approved");
        applicationNFT.burn(0);
    }

    function testERC721_ZeroAddressChecksERC721() public {
        vm.expectRevert();
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert();
        applicationNFT.connectHandlerToToken(address(0));

        /// test both address checks in constructor
        vm.expectRevert();
        new ApplicationERC721Handler(address(0x0), address(applicationAppManager), address(applicationNFT), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), address(0x0), address(applicationNFT), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), address(0x0), address(0x0), false);

        vm.expectRevert();
        applicationHandler.setNFTPricingAddress(address(0x00));
    }

    function testERC721_PassMinMaxAccountBalanceRule() public {
        /// mint 6 NFTs to appAdministrator for transfer
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);

        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(1);
        uint256[] memory max = createUint256Array(6);

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

        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
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
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        switchToRuleAdmin();
        ///update ruleId in application NFT handler
        ActionTypes[] memory actionTypes = new ActionTypes[](3);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.MINT;
        actionTypes[2] = ActionTypes.BURN;
        applicationNFTHandler.setMinMaxBalanceRuleId(actionTypes, ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        applicationNFT.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        // user1 mints to 6 total (limit)
        applicationNFT.safeMint(user1); /// Id 6
        applicationNFT.safeMint(user1); /// Id 7
        applicationNFT.safeMint(user1); /// Id 8
        applicationNFT.safeMint(user1); /// Id 9
        applicationNFT.safeMint(user1); /// Id 10

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFT.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x24691f6b);
        applicationNFT.transferFrom(user2, user1, 3);

        /// test that burn works with rule
        applicationNFT.burn(3);
        vm.expectRevert(0xf1737570);
        applicationNFT.burn(11);
    }

    /**
     * @dev Test the oracle rule, both allow and denied types
     */
    function testERC721_NFTOracle() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = new ActionTypes[](3);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.MINT;
        actionTypes[2] = ActionTypes.BURN;
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
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
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationNFT.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationNFT.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));

        /// set oracle back to allow and attempt to burn token
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2767bda4);
        applicationNFT.burn(3);
    }

    function testERC721_PauseRulesViaAppManager() public {
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

    /**
     * @dev Test the NFT Trade rule
     */
    function testERC721_NFTTradeRuleInNFT() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        // apply the rule to the ApplicationERC721Handler
        applicationNFTHandler.setTradeCounterRuleId(_createActionsArray(), _index);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag

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
        applicationAppManager.removeGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        applicationAppManager.addGeneralTag(address(applicationNFT), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        applicationNFT.transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFT.transferFrom(user2, user1, 2);
    }

    function testERC721_TransactionLimitByRiskScoreNFT() public {
        ///Set transaction limit rule params
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80, 99);
        uint48[] memory txnLimits = createUint48Array(17, 15, 12, 11, 10);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addMaxTxSizePerPeriodByRiskRule(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        switchToAppAdministrator();
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
        switchToRuleAdmin();
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(index);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, 10 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, 11 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 12 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 13 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 20 * (10 ** 18));

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
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * (10 ** 18)); // in dollars

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
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 14 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 25 * (10 ** 18));
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

    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testERC721_AccessLevel0InNFT() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        applicationHandler.activateAccessLevel0Rule(true);
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

    function testERC721_MinAccountBalanceByDate() public {
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
        uint256[] memory holdAmounts = createUint256Array(1, 2, 3); /// Represent min number of tokens held by user for Collection address
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory holdPeriods = createUint16Array(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        /// Add Tags to users
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user1, "MIN1"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MIN1"));
        applicationAppManager.addGeneralTag(user2, "MIN2"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MIN2"));
        applicationAppManager.addGeneralTag(user3, "MIN3"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "MIN3"));
        /// Set rule bool to active
        switchToRuleAdmin();
        applicationNFTHandler.setMinBalByDateRuleId(_createActionsArray(), _index);
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

    function testERC721_AdminWithdrawal() public {
        /// Mint TokenId 0-6 to super admin
        for (uint i; i < 7; i++ ) {
            applicationNFT.safeMint(ruleBypassAccount);
        }
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);

        /// Set the rule in the handler
        applicationNFTHandler.setAdminWithdrawalRuleId(_createActionsArray(), _index);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTHandler.activateAdminWithdrawalRule(_createActionsArray(), false);
        vm.expectRevert();
        applicationNFTHandler.setAdminWithdrawalRuleId(_createActionsArray(), _index);
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
        applicationNFTHandler.activateAdminWithdrawalRule(_createActionsArray(), false);
        applicationNFTHandler.setAdminWithdrawalRuleId(_createActionsArray(), _index);
    }

    /// test the transfer volume rule in erc721
    function testERC721_TransferVolumeRuleNFT() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 2000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTHandler.setTokenTransferVolumeRuleId(_createActionsArray(), _index);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // transfer one that hits the percentage
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 3);
    }

    /// test the transfer volume rule in erc721
    function testERC721_NFTTransferVolumeRuleWithSupplySet() public {
        /// set the rule for 2% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 200, 2, Blocktime, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 200);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTHandler.setTokenTransferVolumeRuleId(_createActionsArray(), _index);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFT.safeTransferFrom(user1, user2, 0);
        //transfer one that hits the percentage
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        // assertFalse(isWithinPeriod2(Blocktime, 2, Blocktime));
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationNFT.safeTransferFrom(user1, user2, 3);
    }

    /// test the minimum hold time rule in erc721
    function testERC721_NFTMinimumHoldTime() public {
        /// set the rule for 24 hours
        switchToRuleAdmin();
        applicationNFTHandler.setMinimumHoldTimeHours(_createActionsArray(), 24);
        assertEq(applicationNFTHandler.getMinimumHoldTimeHours(ActionTypes.P2P_TRANSFER), 24);
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        applicationNFT.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer should fail
        vm.expectRevert(0x6d12e45a);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 1 days;
        vm.warp(Blocktime);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // the original owner was able to transfer but the new owner should not be able to because the time resets
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x6d12e45a);
        applicationNFT.safeTransferFrom(user2, user1, 0);
        // move forward under the threshold and ensure it fails
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);
        vm.expectRevert(0x6d12e45a);
        applicationNFT.safeTransferFrom(user2, user1, 0);
        // now change the rule hold hours to 2 and it should pass
        switchToRuleAdmin();
        applicationNFTHandler.setMinimumHoldTimeHours(_createActionsArray(), 2);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);
    }

    /// test supply volatility rule
    function testERC721_CollectionSupplyVolatilityRule() public {
        /// Mint tokens to specific supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }
        /// create rule params
        // create rule params
        uint16 volatilityLimit = 2000; /// 10%
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startingTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token

        /// set rule id and activate
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), volatilityLimit, rulePeriod, startingTime, tokenSupply);
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.MINT;
        actionTypes[1] = ActionTypes.BURN;
        applicationNFTHandler.setTotalSupplyVolatilityRuleId(actionTypes, _index);
        /// set blocktime to within rule period
        vm.warp(Blocktime + 13 hours);
        /// mint tokens under supply limit
        vm.stopPrank();
        vm.startPrank(appAdministrator);
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
        vm.startPrank(appAdministrator);
        applicationNFT.safeMint(user1);
    }

    function testERC721_NFTValuationOrig() public {
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * (10 ** 18));
        }
        uint256 testPrice = erc721Pricer.getNFTPrice(address(applicationNFT), 1);
        assertEq(testPrice, 1 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        switchToRuleAdmin();
        switchToAppAdministrator();
        applicationNFTHandler.setNFTValuationLimit(20);
        /// activate rule that calls valuation
        uint48[] memory balanceAmounts = createUint48Array(0, 1, 10, 50, 100);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);
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
        applicationHandler.activateAccountBalanceByAccessLevelRule(false);

        switchToAppAdministrator();
        /// create new collection and mint enough tokens to exceed the nftValuationLimit set in handler
        ApplicationERC721 _applicationNFT2 = new ApplicationERC721("ToughTurtles", "THTR", address(applicationAppManager), "https://SampleApp.io");
        console.log("applicationNFT2", address(_applicationNFT2));
        ApplicationERC721Handler _applicationNFTHandler2 = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(_applicationNFT2), false);
        _applicationNFT2.connectHandlerToToken(address(_applicationNFTHandler2));
        /// register the token
        applicationAppManager.registerToken("THTR", address(_applicationNFT2));

        for (uint i = 0; i < 40; i++) {
            _applicationNFT2.safeMint(appAdministrator);
            _applicationNFT2.transferFrom(appAdministrator, user1, i);
            erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), i, 1 * (10 ** 18));
        }
        uint256 testPrice2 = erc721Pricer.getNFTPrice(address(_applicationNFT2), 35);
        assertEq(testPrice2, 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        switchToAppAdministrator();
        _applicationNFTHandler2.setNFTValuationLimit(20);
        /// set specific tokens in NFT 2 to higher prices. Expect this value to be ignored by rule check as it is checking collection price.
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 36, 100 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 37, 50 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(_applicationNFT2), 40, 25 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(_applicationNFT2), 1 * (10 ** 18));

        ///reactivate rule 
        switchToRuleAdmin();
        applicationHandler.activateAccountBalanceByAccessLevelRule(true); 
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
        vm.expectRevert(0xdd76c810);
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
        applicationNFTHandler.setNFTValuationLimit(50);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xdd76c810);
        applicationNFT.transferFrom(user2, user1, 1);

        /// test burn with rule active user 2
        applicationNFT.burn(1);
        /// test burns with user 1
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(3);
        _applicationNFT2.burn(36);
    }

    function testERC721_UpgradingHandlersERC721() public {
        ///deploy new modified appliction asset handler contract
        ApplicationERC721HandlerMod _AssetHandler = new ApplicationERC721HandlerMod(address(ruleProcessor), address(applicationAppManager), address(applicationNFT), true);
        ///connect to apptoken
        applicationNFT.connectHandlerToToken(address(_AssetHandler));
        /// in order to handle upgrades and handler registrations, deregister and re-register with new
        applicationAppManager.deregisterToken("FRANKENSTEIN");
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFT));

        ///Set transaction limit rule params
        uint8[] memory riskScores = createUint8Array(1, 10, 40, 80, 99);
        uint48[] memory txnLimits = createUint48Array(17, 15, 12, 11, 10);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addMaxTxSizePerPeriodByRiskRule(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        switchToAppAdministrator();
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
        switchToRuleAdmin();
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(index);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, 11 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, 10 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 12 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 13 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 20 * (10 ** 18));

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
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 7);
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 4);

        address testAddress = _AssetHandler.newTestFunction();
        console.log(_AssetHandler.newTestFunction(), testAddress);
    }

    function testERC721_UpgradeAppManager721() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager _applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        applicationNFT.proposeAppManagerAddress(address(_applicationAppManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        _applicationAppManager2.confirmAppManager(address(applicationNFT));
        /// test to ensure it still works
        applicationNFT.safeMint(appAdministrator);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFT.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
        assertEq(applicationNFT.balanceOf(user), 1);

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        applicationNFT.proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        _applicationAppManager2.confirmAppManager(address(applicationNFT));
        // non proposer tries to confirm
        applicationNFT.proposeAppManagerAddress(address(_applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
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

    function testERC721_PurchasePercentageRule() public {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set up rule
        uint16 tokenPercentage = 10; /// 1% 
        _setPurchasePercentageRule(tokenPercentage, 24); /// 24 hour periods
        /// we make sure we are in a new period
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i; i < (erc721Liq * tokenPercentage) / 10000 - 1; i++){
            _testBuyNFT(i, amm);
        }
        vm.expectRevert(0xb634aad9);
        _testBuyNFT(tokenPercentage, amm);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0xb634aad9);
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

    function testERC721_SellPercentageRule() public {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// now we setup the sell percentage rule
        uint16 tokenPercentageSell = 30; /// 0.30%
        _setSellPercentageRule(tokenPercentageSell, 24); ///  24 hour periods
        vm.warp(Blocktime + 36 hours);
        /// now we test
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test selling the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++){
            _testSellNFT(i,  amm);
        }
        /// If try to sell one more, it should fail in this period.
        vm.expectRevert(0xb17ff693);
        _testSellNFT(erc721Liq / 2 + tokenPercentageSell, amm);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
         _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0xb17ff693);
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

    function testERC721_SellRule() public {
        switchToAppAdministrator();
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        _setSellRule("SellRule", 1, 36); /// tag, maxNFtsPerPeriod, period
        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user, "SellRule");
        /// Swap that passes rule check
        switchToUser();
        applicationNFT.setApprovalForAll(address(amm), true);
        _testSellNFT(erc721Liq / 2 + 1, amm);
        /// Swap that fails
        vm.expectRevert(0xc11d5f20);
        _testSellNFT(erc721Liq / 2 + 2, amm);
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_TradeRuleByPasserRule() public {
        DummyNFTAMM amm = setupTradingRuleTests();
        _fundThreeAccounts();
        applicationAppManager.approveAddressToTradingRuleWhitelist(user, true);

        /// SELL PERCENTAGE RULE
        uint16 tokenPercentageSell = 30; /// 0.30%
        _setSellPercentageRule(tokenPercentageSell, 24); ///  24 hour periods
        vm.warp(Blocktime + 36 hours);
        /// WHITELISTED USER
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going above rule percentage in the period is ok for user (... + 1)
        for(uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 + 1; i++){
            _testSellNFT(i,  amm);
        }
        /// NOT WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going right below the rule percentage in the period (... - 1)
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++){
            _testSellNFT(i,  amm);
        }
        /// and now we test the actual rule with a non-whitelisted address to check it will fail
        vm.expectRevert(0xb17ff693);
        _testSellNFT(erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000,  amm);

        //PURCHASE PERCENTAGE RULE
        uint16 tokenPercentage = 10; /// 1% 
        _setPurchasePercentageRule(tokenPercentage, 24); /// 24 hour periods
        /// we make sure we are in a new period
        vm.warp(Blocktime + 72 hours);
        /// WHITELISTED USER
        switchToUser();
        /// we test buying the *tokenPercentage* of the NFTs total supply + 1 to prove that *user* can break the rules with no consequences
        for(uint i = erc721Liq / 2 ; i < erc721Liq / 2 + (erc721Liq * tokenPercentage) / 10000 + 1; i++){
            _testBuyNFT(i, amm);
        }
        /// NOT WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentage) / 10000 - 1; i++){
            _testBuyNFT(i, amm);
        }
        /// now we check that user1 cannot break the rule
        vm.expectRevert(0xb634aad9);
        _testBuyNFT(erc721Liq / 2 + 100 + tokenPercentage, amm);

        /// SELL RULE
        _setSellRule("SellRule", 1, 36); /// tag, maxNFtsPerPeriod, period
        vm.warp(Blocktime + 108 hours);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user, "SellRule");
        applicationAppManager.addGeneralTag(user1, "SellRule");
        /// WHITELISTED USER
        switchToUser();
        /// user can break the rules
        _testSellNFT(erc721Liq / 2, amm);
        _testSellNFT(erc721Liq / 2 + 1, amm);
        /// NOT WHITELISTED USER
        vm.stopPrank();
        vm.startPrank(user1);
        /// user1 cannot break the rules
        _testSellNFT(erc721Liq / 2 + 100, amm);
        vm.expectRevert(0xc11d5f20);
        _testSellNFT(erc721Liq / 2 + 100 + 1, amm);
    }

    /// HELPER INTERNAL FUNCTIONS

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

    function _setSellRule(bytes32 _tag, uint192 _sellAmount,  uint16 _sellPeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        accs[0] = bytes32(_tag);
        sellAmounts[0] = _sellAmount; ///Amount to trigger Sell freeze rules
        sellPeriod[0] = _sellPeriod; ///Hours
        ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, uint64(Blocktime));
        applicationNFTHandler.setSellLimitRuleId(ruleId);
    }


    function _setSanctionOracleRule() internal returns(uint32 ruleId){
        switchToRuleAdmin();
        ruleId = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(ruleId);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        applicationNFTHandler.setOracleRuleId(_createActionsArray(), ruleId);
    }

    function _setAllowedOracleRule() internal returns(uint32 ruleId){
        switchToRuleAdmin();
        ruleId = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(ruleId);
        assertEq(rule.oracleType, 1);
        assertEq(rule.oracleAddress, address(oracleAllowed));
        applicationNFTHandler.setOracleRuleId(_createActionsArray(), ruleId);
    }

    function _setPurchasePercentageRule(uint16 _tokenPercentage, uint16  _purchasePeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        uint16 tokenPercentage = _tokenPercentage; 
        uint16 purchasePeriod = _purchasePeriod; 
        uint256 _totalSupply = 0;
        uint64 ruleStartTime = Blocktime;
        ruleId = RuleDataFacet(address(ruleProcessor)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, _totalSupply, ruleStartTime);
        applicationNFTHandler.setPurchasePercentageRuleId(ruleId);
    }

    function _setSellPercentageRule(uint16 _tokenPercentageSell, uint16  _sellPeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        uint16 tokenPercentageSell = _tokenPercentageSell; 
        uint16 sellPeriod = _sellPeriod;
        uint256 _totalSupply = 0;
        uint64 ruleStartTime = Blocktime;
        ruleId = RuleDataFacet(address(ruleProcessor)).addPercentageSellRule(address(applicationAppManager), tokenPercentageSell, sellPeriod, _totalSupply, ruleStartTime);
        applicationNFTHandler.setSellPercentageRuleId(ruleId);
    }

    function _fundThreeAccounts() internal {
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


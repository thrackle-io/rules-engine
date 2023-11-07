// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {TaggedRuleDataFacet} from "src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/economic/ruleStorage/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/economic/ruleStorage/AppRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules} from "src/economic/ruleStorage/RuleDataInterfaces.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import {ApplicationERC721HandlerMod} from "../helpers/ApplicationERC721HandlerMod.sol";
import "test/helpers/ApplicationERC721WithBatchMintBurn.sol";
import "test/helpers/TestCommonFoundry.sol";
import "@limitbreak/creator-token-contracts/contracts/utils/CreatorTokenTransferValidator.sol";

contract ApplicationERC721Test is TestCommonFoundry {
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC721HandlerMod newAssetHandler;
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address accessTier = address(3);
    address ac;
    address[] badBoys;
    address[] goodBoys;

    function setUp() public {
        vm.warp(Blocktime);

        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndERC721CTokens();
        switchToAppAdministrator();
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }


    function testERC721AndHandlerVersions() public {
        string memory version = applicationNFTCHandler.version();
        assertEq(version, "1.1.0");
    }

    function testMint() public {
        /// Owner Mints new tokenId
        applicationNFTC.safeMint(appAdministrator);
        console.log(applicationNFTC.balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        applicationNFTC.safeMint(appAdministrator);
        console.log(applicationNFTC.balanceOf(appAdministrator));
        assertEq(applicationNFTC.balanceOf(appAdministrator), 2);
    }


    function testTransfer() public {
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
        assertEq(applicationNFTC.balanceOf(user), 1);
    }

    function testBurn() public {
        ///Mint and transfer tokenId 0
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        applicationNFTC.safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        applicationNFTC.burn(1);
        ///Switch to app administrator account for burn

        /// Burn appAdministrator token
        applicationNFTC.burn(0);
        ///Return to app admin account
        switchToAppAdministrator();
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
    }

    function testFailBurnERC721() public {
        ///Mint and transfer tokenId 0
        applicationNFTC.safeMint(appAdministrator);
        switchToUser();
        ///attempt to burn token that user does not own
        applicationNFTC.burn(0);
    }

    function testZeroAddressChecksERC721() public {
        vm.expectRevert();
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert();
        applicationNFTC.connectHandlerToToken(address(0));

        /// test both address checks in constructor
        vm.expectRevert();
        new ApplicationERC721Handler(address(0x0), ac, address(applicationNFTC), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), ac, address(applicationNFTC), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), address(0x0), address(0x0), false);

        vm.expectRevert();
        applicationNFTCHandler.setNFTPricingAddress(address(0x00));
        vm.expectRevert();
        applicationNFTCHandler.setERC20PricingAddress(address(0x00));
    }

    function testPassMinMaxAccountBalanceRule() public {
        /// mint 6 NFTs to appAdministrator for transfer
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);

        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(1);
        max[0] = uint256(6);

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        applicationNFTC.transferFrom(appAdministrator, rich_user, 0);
        applicationNFTC.transferFrom(appAdministrator, rich_user, 1);
        assertEq(applicationNFTC.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFTC.transferFrom(appAdministrator, user1, 3);
        applicationNFTC.transferFrom(appAdministrator, user1, 4);
        assertEq(applicationNFTC.balanceOf(user1), 2);

        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
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
        applicationNFTC.transferFrom(user1, user2, 3);
        assertEq(applicationNFTC.balanceOf(user2), 1);
        assertEq(applicationNFTC.balanceOf(user1), 1);
        switchToRuleAdmin();
        ///update ruleId in application NFT handler
        applicationNFTCHandler.setMinMaxBalanceRuleId(ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        applicationNFTC.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        // user1 mints to 6 total (limit)
        applicationNFTC.safeMint(user1); /// Id 6
        applicationNFTC.safeMint(user1); /// Id 7
        applicationNFTC.safeMint(user1); /// Id 8
        applicationNFTC.safeMint(user1); /// Id 9
        applicationNFTC.safeMint(user1); /// Id 10

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFTC.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x24691f6b);
        applicationNFTC.transferFrom(user2, user1, 3);

        /// test that burn works with rule
        applicationNFTC.burn(3);
        vm.expectRevert(0xf1737570);
        applicationNFTC.burn(11);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testNFTOracle() public {
        /// set up a non admin user an nft
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);

        assertEq(applicationNFTC.balanceOf(user1), 5);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        applicationNFTCHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.transferFrom(user1, user2, 0);
        assertEq(applicationNFTC.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationNFTC.transferFrom(user1, address(69), 1);
        assertEq(applicationNFTC.balanceOf(address(69)), 0);
        // check the allowed list type
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTCHandler.setOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationNFTC.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationNFTC.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));

        /// set oracle back to allow and attempt to burn token
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        applicationNFTCHandler.setOracleRuleId(_index);
        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        applicationNFTCHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleRestricted.addToSanctionsList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x6bdfffc0);
        applicationNFTC.burn(3);
    }

    function testPauseRulesViaAppManager() public {
        /// set up a non admin user an nft
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);
        applicationNFTC.safeMint(user1);

        assertEq(applicationNFTC.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFTC.transferFrom(user1, address(59), 2);
    }

    /**
     * @dev Test the NFT Trade rule
     */
    function testNFTTradeRuleInNFT() public {
        /// set up a non admin user an nft
        applicationNFTC.safeMint(user1); // tokenId = 0
        applicationNFTC.safeMint(user1); // tokenId = 1
        applicationNFTC.safeMint(user1); // tokenId = 2
        applicationNFTC.safeMint(user1); // tokenId = 3
        applicationNFTC.safeMint(user1); // tokenId = 4

        assertEq(applicationNFTC.balanceOf(user1), 5);

        // add the rule.
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.NFTTradeCounterRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        // apply the rule to the ApplicationERC721Handler
        applicationNFTCHandler.setTradeCounterRuleId(_index);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFTC), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.transferFrom(user1, user2, 0);
        assertEq(applicationNFTC.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.transferFrom(user2, user1, 0);
        assertEq(applicationNFTC.balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeGeneralTag(address(applicationNFTC), "DiscoPunk"); ///add tag
        applicationAppManager.addGeneralTag(address(applicationNFTC), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.transferFrom(user1, user2, 1);
        assertEq(applicationNFTC.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFTC.transferFrom(user2, user1, 1);
        assertEq(applicationNFTC.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFTC.transferFrom(user2, user1, 1);
        assertEq(applicationNFTC.balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFTC), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        applicationNFTC.transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFTC.transferFrom(user2, user1, 2);
    }

    function testTransactionLimitByRiskScoreNFT() public {
        ///Set transaction limit rule params
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory txnLimits = new uint48[](5);
        riskScores[0] = 1;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;

        txnLimits[0] = 17;
        txnLimits[1] = 15;
        txnLimits[2] = 12;
        txnLimits[3] = 11;
        txnLimits[4] = 10;
        switchToRuleAdmin();
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        switchToAppAdministrator();
        ///Mint NFT's (user1,2,3)
        applicationNFTC.safeMint(user1); // tokenId = 0
        applicationNFTC.safeMint(user1); // tokenId = 1
        applicationNFTC.safeMint(user1); // tokenId = 2
        applicationNFTC.safeMint(user1); // tokenId = 3
        applicationNFTC.safeMint(user1); // tokenId = 4
        assertEq(applicationNFTC.balanceOf(user1), 5);

        applicationNFTC.safeMint(user2); // tokenId = 5
        applicationNFTC.safeMint(user2); // tokenId = 6
        applicationNFTC.safeMint(user2); // tokenId = 7
        assertEq(applicationNFTC.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
        switchToRuleAdmin();
        applicationNFTCHandler.setTransactionLimitByRiskRuleId(index);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 0, 10 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 1, 11 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 2, 12 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 3, 13 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 4, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 5, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 6, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 7, 20 * (10 ** 18));

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFTC.safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user2, 4);
        applicationNFTC.safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user3, 7);
        applicationNFTC.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user3, 4);

        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 5, 14 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 4, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 6, 25 * (10 ** 18));
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.burn(5);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0x9fe6aeac);
        applicationNFTC.burn(4);
        vm.expectRevert(0x9fe6aeac);
        applicationNFTC.burn(6);
    }

    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testAccessLevel0InNFT() public {
        /// set up a non admin user an nft
        applicationNFTC.safeMint(user1); // tokenId = 0
        applicationNFTC.safeMint(user1); // tokenId = 1
        applicationNFTC.safeMint(user1); // tokenId = 2
        applicationNFTC.safeMint(user1); // tokenId = 3
        applicationNFTC.safeMint(user1); // tokenId = 4

        assertEq(applicationNFTC.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        applicationHandler.activateAccessLevel0Rule(true);
        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        applicationNFTC.transferFrom(user1, user2, 0);
        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// still fails since user 1 is accessLevel0
        applicationNFTC.transferFrom(user1, user2, 0);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.transferFrom(user1, user2, 0);
        assertEq(applicationNFTC.balanceOf(user2), 1);
    }

    function testMinAccountBalanceByDate() public {
        /// Mint NFTs for users 1, 2, 3
        applicationNFTC.safeMint(user1); // tokenId = 0
        applicationNFTC.safeMint(user1); // tokenId = 1
        applicationNFTC.safeMint(user1); // tokenId = 2

        applicationNFTC.safeMint(user2); // tokenId = 3
        applicationNFTC.safeMint(user2); // tokenId = 4
        applicationNFTC.safeMint(user2); // tokenId = 5

        applicationNFTC.safeMint(user3); // tokenId = 6
        applicationNFTC.safeMint(user3); // tokenId = 7
        applicationNFTC.safeMint(user3); // tokenId = 8

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("MIN1");
        accs[1] = bytes32("MIN2");
        accs[2] = bytes32("MIN3");
        uint256[] memory holdAmounts = new uint256[](3); /// Represent min number of tokens held by user for Collection address
        holdAmounts[0] = uint256(1);
        holdAmounts[1] = uint256(2);
        holdAmounts[2] = uint256(3);
        uint16[] memory holdPeriods = new uint16[](3);
        holdPeriods[0] = uint16(720); // one month
        holdPeriods[1] = uint16(4380); // six months
        holdPeriods[2] = uint16(17520); // two years
        uint64[] memory holdTimestamps = new uint64[](3); /// StartTime of hold period
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, holdTimestamps);
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
        applicationNFTCHandler.setMinBalByDateRuleId(_index);
        /// Transfers passing (above min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        applicationNFTC.safeTransferFrom(user1, user3, 1);
        assertEq(applicationNFTC.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        applicationNFTC.safeTransferFrom(user2, user3, 3);
        assertEq(applicationNFTC.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFTC.safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        applicationNFTC.safeTransferFrom(user3, user1, 1);
        assertEq(applicationNFTC.balanceOf(user3), 3);

        /// Transfers failing (below min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        applicationNFTC.safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFTC.safeTransferFrom(user1, rich_user, 2);
        assertEq(applicationNFTC.balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        applicationNFTC.safeTransferFrom(user2, rich_user, 4);
        assertEq(applicationNFTC.balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFTC.safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(applicationNFTC.balanceOf(user3), 3);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, rich_user, 2);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, rich_user, 4);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFTC.safeTransferFrom(user3, rich_user, 6);
    }

    function testAdminWithdrawal() public {
        /// Mint TokenId 0-6 to super admin
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.safeMint(appAdministrator);
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);

        /// Set the rule in the handler
        applicationNFTCHandler.setAdminWithdrawalRuleId(_index);
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTCHandler.activateAdminWithdrawalRule(false);
        vm.expectRevert();
        applicationNFTCHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator();
        /// These transfers should pass
        applicationNFTC.safeTransferFrom(appAdministrator, user1, 0);
        applicationNFTC.safeTransferFrom(appAdministrator, user1, 1);
        /// This one fails
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(appAdministrator, user1, 2);

        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        applicationNFTC.safeTransferFrom(appAdministrator, user1, 2);
        switchToRuleAdmin();
        applicationNFTCHandler.activateAdminWithdrawalRule(false);
        applicationNFTCHandler.setAdminWithdrawalRuleId(_index);
    }

    /// test the transfer volume rule in erc721
    function testTransferVolumeRuleNFT() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(applicationAppManager), 2000, 2, Blocktime, 10);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFTC.safeMint(user1);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTCHandler.setTokenTransferVolumeRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        // transfer one that hits the percentage
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        applicationNFTC.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFTC.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 3);
    }

    /// test the transfer volume rule in erc721
    function testNFTTransferVolumeRuleWithSupplySet() public {
        /// set the rule for 2% in 2 hours, starting at midnight
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(applicationAppManager), 200, 2, Blocktime, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 200);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFTC.safeMint(user1);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTCHandler.setTokenTransferVolumeRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer under the threshold
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        //transfer one that hits the percentage
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        // assertFalse(isWithinPeriod2(Blocktime, 2, Blocktime));
        applicationNFTC.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        applicationNFTC.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x3627495d);
        applicationNFTC.safeTransferFrom(user1, user2, 3);
    }

    /// test the minimum hold time rule in erc721
    function testNFTMinimumHoldTime() public {
        /// set the rule for 24 hours
        switchToRuleAdmin();
        applicationNFTCHandler.setMinimumHoldTimeHours(24);
        assertEq(applicationNFTCHandler.getMinimumHoldTimeHours(), 24);
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        // transfer should fail
        vm.expectRevert(0x6d12e45a);
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 1 days;
        vm.warp(Blocktime);
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        // the original owner was able to transfer but the new owner should not be able to because the time resets
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x6d12e45a);
        applicationNFTC.safeTransferFrom(user2, user1, 0);
        // move forward under the threshold and ensure it fails
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);
        vm.expectRevert(0x6d12e45a);
        applicationNFTC.safeTransferFrom(user2, user1, 0);
        // now change the rule hold hours to 2 and it should pass
        switchToRuleAdmin();
        applicationNFTCHandler.setMinimumHoldTimeHours(2);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user1, 0);
    }

    /// test supply volatility rule
    function testCollectionSupplyVolatilityRule() public {
        /// Mint tokens to specific supply
        for (uint i = 0; i < 10; i++) {
            applicationNFTC.safeMint(appAdministrator);
        }
        /// create rule params
        // create rule params
        uint16 volatilityLimit = 2000; /// 10%
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startingTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 10; /// calls totalSupply() for the token

        /// set rule id and activate
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(applicationAppManager), volatilityLimit, rulePeriod, startingTime, tokenSupply);
        applicationNFTCHandler.setTotalSupplyVolatilityRuleId(_index);
        /// set blocktime to within rule period
        vm.warp(Blocktime + 13 hours);
        /// mint tokens under supply limit
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFTC.safeMint(user1);
        /// mint tokens to the cap
        applicationNFTC.safeMint(user1);
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert();
        applicationNFTC.safeMint(user1);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.burn(10);
        /// move out of rule period
        vm.warp(Blocktime + 36 hours);
        /// burn tokens (should pass)
        applicationNFTC.burn(11);
        /// mint
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFTC.safeMint(user1);
    }

    function testNFTValuationOrig() public {
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            applicationNFTC.safeMint(user1);
            erc721Pricer.setSingleNFTPrice(address(applicationNFTC), i, 1 * (10 ** 18));
        }
        uint256 testPrice = erc721Pricer.getNFTPrice(address(applicationNFTC), 1);
        assertEq(testPrice, 1 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(applicationNFTC), 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        switchToRuleAdmin();
        switchToAppAdministrator();
        applicationNFTCHandler.setNFTValuationLimit(20);
        /// activate rule that calls valuation
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 0;
        balanceAmounts[1] = 1;
        balanceAmounts[2] = 10;
        balanceAmounts[3] = 50;
        balanceAmounts[4] = 100;
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
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
        applicationNFTC.transferFrom(user1, user2, 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.transferFrom(user2, user1, 1);

        switchToAppAdministrator();
        /// create new collection and mint enough tokens to exceed the nftValuationLimit set in handler
        ApplicationERC721 applicationNFT2 = new ApplicationERC721("ToughTurtles", "THTR", address(applicationAppManager), "https://SampleApp.io");
        console.log("applicationNFT2", address(applicationNFT2));
        ApplicationERC721Handler applicationNFTCHandler2 = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFT2), false);
        applicationNFT2.connectHandlerToToken(address(applicationNFTCHandler2));
        /// register the token
        applicationAppManager.registerToken("THTR", address(applicationNFT2));
        ///Pricing Contracts
        applicationNFTCHandler2.setNFTPricingAddress(address(erc721Pricer));
        applicationNFTCHandler2.setERC20PricingAddress(address(erc20Pricer));
        for (uint i = 0; i < 40; i++) {
            applicationNFT2.safeMint(appAdministrator);
            applicationNFT2.transferFrom(appAdministrator, user1, i);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT2), i, 1 * (10 ** 18));
        }
        uint256 testPrice2 = erc721Pricer.getNFTPrice(address(applicationNFT2), 35);
        assertEq(testPrice2, 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        switchToAppAdministrator();
        applicationNFTCHandler2.setNFTValuationLimit(20);
        /// set specific tokens in NFT 2 to higher prices. Expect this value to be ignored by rule check as it is checking collection price.
        erc721Pricer.setSingleNFTPrice(address(applicationNFT2), 36, 100 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT2), 37, 50 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT2), 40, 25 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT2), 1 * (10 ** 18));
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
        applicationNFTC.transferFrom(user1, user2, 1);
        /// user 1 has access level of 2 and can hold balance of 10 (currently above this after admin transfers)
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xdd76c810);
        applicationNFTC.transferFrom(user2, user1, 1);
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
        applicationNFTC.transferFrom(user2, user1, 1);

        /// adjust nft valuation limit to ensure we revert back to individual pricing
        switchToAppAdministrator();
        applicationNFTCHandler.setNFTValuationLimit(50);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xdd76c810);
        applicationNFTC.transferFrom(user2, user1, 1);

        /// test burn with rule active user 2
        //applicationNFTC.burn(1);
        /// test burns with user 1
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.burn(3);
        applicationNFT2.burn(36);
    }

    /// test batch mint and burn
    function testBatchMintAndBurn() public {
        /// create the batch capable NFT
        ApplicationERC721WithBatchMintBurn nftBurner = new ApplicationERC721WithBatchMintBurn("BeanBabyBurner", "THRK", address(applicationAppManager), "https://SampleApp.io");
        applicationNFTCHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(nftBurner), false);
        nftBurner.connectHandlerToToken(address(applicationNFTCHandler));
        /// cannot batch burn
        /// non admins cannot batch mint
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x46b2bfeb);
        nftBurner.mint(10);
        assertEq(nftBurner.balanceOf(user1), 0);
        vm.expectRevert(0x46b2bfeb);
        nftBurner.burn(10);
    }

    function testUpgradingHandlersERC721() public {
        ///deploy new modified appliction asset handler contract
        ApplicationERC721HandlerMod assetHandler = new ApplicationERC721HandlerMod(address(ruleProcessor), address(applicationAppManager), address(applicationNFTC), true);
        ///connect to apptoken
        applicationNFTC.connectHandlerToToken(address(assetHandler));
        /// in order to handle upgrades and handler registrations, deregister and re-register with new
        applicationAppManager.deregisterToken("FRANKENSTEIN");
        applicationAppManager.registerToken("FRANKENSTEIN", address(applicationNFTC));
        assetHandler.setNFTPricingAddress(address(erc721Pricer));
        assetHandler.setERC20PricingAddress(address(erc20Pricer));

        ///Set transaction limit rule params
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory txnLimits = new uint48[](5);
        riskScores[0] = 1;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        txnLimits[0] = 17;
        txnLimits[1] = 15;
        txnLimits[2] = 12;
        txnLimits[3] = 11;
        txnLimits[4] = 10;
        switchToRuleAdmin();
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        switchToAppAdministrator();
        ///Mint NFT's (user1,2,3)
        applicationNFTC.safeMint(user1); // tokenId = 0
        applicationNFTC.safeMint(user1); // tokenId = 1
        applicationNFTC.safeMint(user1); // tokenId = 2
        applicationNFTC.safeMint(user1); // tokenId = 3
        applicationNFTC.safeMint(user1); // tokenId = 4
        assertEq(applicationNFTC.balanceOf(user1), 5);

        applicationNFTC.safeMint(user2); // tokenId = 5
        applicationNFTC.safeMint(user2); // tokenId = 6
        applicationNFTC.safeMint(user2); // tokenId = 7
        assertEq(applicationNFTC.balanceOf(user2), 3);

        ///Set Rule in NFTHandler
        switchToRuleAdmin();
        assetHandler.setTransactionLimitByRiskRuleId(index);
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 1, 11 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 0, 10 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 2, 12 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 3, 13 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 4, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 5, 15 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 6, 17 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 7, 20 * (10 ** 18));

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        applicationNFTC.safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user2, 4);
        applicationNFTC.safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        switchToAppAdministrator();

        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 6, 11 * (10 ** 18)); // in dollars
        erc721Pricer.setSingleNFTPrice(address(applicationNFTC), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user3, 7);
        applicationNFTC.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user3, 4);

        address testAddress = assetHandler.newTestFunction();
        console.log(assetHandler.newTestFunction(), testAddress);
    }

    function testUpgradeAppManager721() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        applicationNFTC.proposeAppManagerAddress(address(applicationAppManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        applicationAppManager2.confirmAppManager(address(applicationNFTC));
        /// test to ensure it still works
        applicationNFTC.safeMint(appAdministrator);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFTC.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
        assertEq(applicationNFTC.balanceOf(user), 1);

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        applicationNFTC.proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        applicationAppManager2.confirmAppManager(address(applicationNFTC));
        // non proposer tries to confirm
        applicationNFTC.proposeAppManagerAddress(address(applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(applicationNFTC));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC721.sol";
import {ApplicationAppManager} from "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import {ApplicationERC721HandlerMod} from "./helpers/ApplicationERC721HandlerMod.sol";
import "test/helpers/ApplicationERC721WithBatchMintBurn.sol";

contract ApplicationERC721Test is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC721 applicationNFT;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    ApplicationERC721HandlerMod newAssetHandler;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address accessTier = address(3);
    address ac;
    address[] badBoys;
    address[] goodBoys;
    uint64 Blocktime = 1769924800;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        /// add the AccessLevelAdmin address as a AccessLevel admin
        appManager.addAccessTier(accessTier);
        appManager.addAccessTier(AccessTier);
        /// add Risk Admin
        appManager.addRiskAdmin(riskAdmin);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));

        applicationNFT = new ApplicationERC721("PudgyParakeet", "THRK", address(appManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(applicationNFT), false);
        applicationNFT.connectHandlerToToken(address(applicationNFTHandler));

        /// register the token
        appManager.registerToken("THRK", address(applicationNFT));

        ///Pricing Contracts
        nftPricer = new ApplicationERC721Pricing();
        applicationNFTHandler.setNFTPricingAddress(address(nftPricer));
        erc20Pricer = new ApplicationERC20Pricing();
        applicationNFTHandler.setERC20PricingAddress(address(erc20Pricer));
        /// create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
        vm.warp(Blocktime); // set block.timestamp
    }

    function testMint() public {
        /// Owner Mints new tokenId
        applicationNFT.safeMint(defaultAdmin);
        console.log(applicationNFT.balanceOf(defaultAdmin));
        /// Owner Mints a second new tokenId
        applicationNFT.safeMint(defaultAdmin);
        console.log(applicationNFT.balanceOf(defaultAdmin));
        assertEq(applicationNFT.balanceOf(defaultAdmin), 2);
    }

    function testTransfer() public {
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.transferFrom(defaultAdmin, appAdministrator, 0);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 1);
    }

    function testBurn() public {
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.transferFrom(defaultAdmin, appAdministrator, 0);
        ///Mint tokenId 1
        applicationNFT.safeMint(defaultAdmin);
        ///Test token burn of token 0 and token 1
        applicationNFT.burn(1);
        ///Switch to app administrator account for burn
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// Burn appAdministrator token
        applicationNFT.burn(0);
        ///Return to default admin account
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 0);
    }

    function testFailBurn() public {
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.transferFrom(defaultAdmin, appAdministrator, 0);
        ///Mint tokenId 1
        applicationNFT.safeMint(defaultAdmin);
        ///attempt to burn token that user does not own
        applicationNFT.burn(0);
    }

    function testZeroAddressChecksERC721() public {
        vm.expectRevert();
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert();
        applicationNFT.connectHandlerToToken(address(0));

        /// test both address checks in constructor
        vm.expectRevert();
        new ApplicationERC721Handler(address(0x0), ac, address(applicationNFT), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), ac, address(applicationNFT), false);
        vm.expectRevert();
        new ApplicationERC721Handler(address(ruleProcessor), address(0x0), address(0x0), false);

        vm.expectRevert();
        applicationNFTHandler.setNFTPricingAddress(address(0x00));
        vm.expectRevert();
        applicationNFTHandler.setERC20PricingAddress(address(0x00));
    }

    function testPassMinMaxAccountBalanceRule() public {
        /// mint 6 NFTs to defaultAdmin for transfer
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);

        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(1);
        max[0] = uint256(6);

        /// set up a non admin user with tokens
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        ///transfer tokenId 1 and 2 to rich_user
        applicationNFT.transferFrom(appAdministrator, rich_user, 0);
        applicationNFT.transferFrom(appAdministrator, rich_user, 1);
        assertEq(applicationNFT.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(appAdministrator, user1, 3);
        applicationNFT.transferFrom(appAdministrator, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);

        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);

        ///Add GeneralTag to account
        appManager.addGeneralTag(user1, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user1, "Oscar"));
        appManager.addGeneralTag(user2, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user2, "Oscar"));
        appManager.addGeneralTag(user3, "Oscar"); ///add tag
        assertTrue(appManager.hasTag(user3, "Oscar"));
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        ///update ruleId in application NFT handler
        applicationNFTHandler.setMinMaxBalanceRuleId(ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        applicationNFT.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        // user1 mints to 6 total (limit)
        applicationNFT.safeMint(user1); /// Id 6
        applicationNFT.safeMint(user1); /// Id 7
        applicationNFT.safeMint(user1); /// Id 8
        applicationNFT.safeMint(user1); /// Id 9
        applicationNFT.safeMint(user1); /// Id 10

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.expectRevert(0x24691f6b);
        applicationNFT.transferFrom(user2, user1, 3);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testNFTOracle() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(address(69));
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(_index);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        applicationNFT.transferFrom(user1, address(69), 1);
        assertEq(applicationNFT.balanceOf(address(69)), 0);
        // check the allowed list type
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(_index);
        // add an allowed address
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 2, address(oracleAllowed));
    }

    function testPauseRulesViaAppManager() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFT.transferFrom(user1, address(59), 2);
    }

    /**
     * @dev Test the NFT Trade rule
     */
    function testNFTTradeRuleInNFT() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(address(appManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        NonTaggedRules.NFTTradeCounterRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        // tag the NFT collection
        appManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        // apply the rule to the ApplicationERC721Handler
        applicationNFTHandler.setTradeCounterRuleId(_index);

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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        appManager.removeGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        appManager.addGeneralTag(address(applicationNFT), "BoredGrape"); ///add tag
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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        appManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
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

    function testTransactionLimitByRiskScoreNFT() public {
        ///Set transaction limit rule params
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory txnLimits = new uint48[](6);
        riskScores[0] = 1;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        txnLimits[0] = 20;
        txnLimits[1] = 17;
        txnLimits[2] = 15;
        txnLimits[3] = 12;
        txnLimits[4] = 11;
        txnLimits[5] = 10;
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), riskScores, txnLimits);

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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationNFTHandler.setTransactionLimitByRiskRuleId(index);
        ///Set Risk Scores for users
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, riskScores[0]);
        appManager.addRiskScore(user2, riskScores[1]);
        appManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        nftPricer.setSingleNFTPrice(address(applicationNFT), 1, 11 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 0, 10 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 2, 12 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 3, 13 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 4, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 5, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 6, 17 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 7, 20 * (10 ** 18));

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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        nftPricer.setSingleNFTPrice(address(applicationNFT), 4, 1050 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFT), 5, 1550 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * (10 ** 18)); // in dollars
        nftPricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 7);
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 4);
    }

    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testAccessLevel0InNFT() public {
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        applicationHandler.activateAccessLevel0Rule(true);

        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        applicationNFT.transferFrom(user1, user2, 0);
        // set AccessLevel and try again
        vm.stopPrank();
        vm.startPrank(AccessTier);
        appManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// still fails since user 1 is accessLevel0
        applicationNFT.transferFrom(user1, user2, 0);

        vm.stopPrank();
        vm.startPrank(AccessTier);
        appManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
    }

    function testMinAccountBalanceByDate() public {
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
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(appManager), accs, holdAmounts, holdPeriods, holdTimestamps);
        assertEq(_index, 0);
        /// Add Tags to users
        appManager.addGeneralTag(user1, "MIN1"); ///add tag
        assertTrue(appManager.hasTag(user1, "MIN1"));
        appManager.addGeneralTag(user2, "MIN2"); ///add tag
        assertTrue(appManager.hasTag(user2, "MIN2"));
        appManager.addGeneralTag(user3, "MIN3"); ///add tag
        assertTrue(appManager.hasTag(user3, "MIN3"));
        /// Set rule bool to active
        applicationNFTHandler.setMinBalByDateRuleId(_index);
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

    function testAdminWithdrawal() public {
        /// Mint TokenId 0-6 to default admin
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        applicationNFT.safeMint(defaultAdmin);
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(appManager), 5, block.timestamp + 365 days);

        /// Set the rule in the handler
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(appManager), 5, block.timestamp + 365 days);

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        vm.expectRevert();
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);

        /// These transfers should pass
        applicationNFT.safeTransferFrom(defaultAdmin, user1, 0);
        applicationNFT.safeTransferFrom(defaultAdmin, user1, 1);
        /// This one fails
        vm.expectRevert();
        applicationNFT.safeTransferFrom(defaultAdmin, user1, 2);

        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        applicationNFT.safeTransferFrom(defaultAdmin, user1, 2);
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
    }

    /// test the transfer volume rule in erc721
    function testTransferVolumeRuleNFT() public {
        /// set the rule for 40% in 2 hours, starting at midnight
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(appManager), 2000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        applicationNFTHandler.setTokenTransferVolumeRuleId(_index);
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
    function testNFTTransferVolumeRuleWithSupplySet() public {
        /// set the rule for 2% in 2 hours, starting at midnight
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(appManager), 200, 2, Blocktime, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 200);
        assertEq(rule.period, 2);
        assertEq(rule.startTime, Blocktime);
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
        }
        // apply the rule
        applicationNFTHandler.setTokenTransferVolumeRuleId(_index);
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
    function testNFTMinimumHoldTime() public {
        /// set the rule for 24 hours
        applicationNFTHandler.setMinimumHoldTimeHours(24);
        assertEq(applicationNFTHandler.getMinimumHoldTimeHours(), 24);
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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationNFTHandler.setMinimumHoldTimeHours(2);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);
    }

    /// test supply volatility rule
    function testCollectionSupplyVolatilityRule() public {
        /// Mint tokens to specific supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(defaultAdmin);
        }
        /// create rule params
        // create rule params
        uint16 volatilityLimit = 2000; /// 10%
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startingTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token

        /// set rule id and activate
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(appManager), volatilityLimit, rulePeriod, startingTime, tokenSupply);
        applicationNFTHandler.setTotalSupplyVolatilityRuleId(_index);
        /// set blocktime to within rule period
        vm.warp(Blocktime + 13 hours);
        /// mint tokens under supply limit
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeMint(user1);
        /// mint tokens to the cap
        applicationNFT.safeMint(user1);
        /// fail transactions (mint and burn with passing transfers)
        vm.expectRevert();
        applicationNFT.safeMint(user1);

        applicationNFT.burn(10);
        /// move out of rule period
        vm.warp(Blocktime + 36 hours);
        /// burn tokens (should pass)
        applicationNFT.burn(11);
        /// mint
        applicationNFT.safeMint(user1);
    }

    function testNFTValuationOrig() public {
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(user1);
            nftPricer.setSingleNFTPrice(address(applicationNFT), i, 1 * (10 ** 18));
        }
        uint256 testPrice = nftPricer.getNFTPrice(address(applicationNFT), 1);
        assertEq(testPrice, 1 * (10 ** 18));
        nftPricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        applicationNFTHandler.setNFTValuationLimit(20);
        /// activate rule that calls valuation
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 0;
        balanceAmounts[1] = 1;
        balanceAmounts[2] = 10;
        balanceAmounts[3] = 50;
        balanceAmounts[4] = 100;

        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(appManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);
        /// calc expected valuation based on tokenId's
        /**
         total valuation for user1 should be $10 USD
         10 tokens * 1 USD for each token 
         */

        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(user1, 2);
        appManager.addAccessLevel(user2, 1);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.transferFrom(user2, user1, 1);

        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        /// create new collection and mint enough tokens to exceed the nftValuationLimit set in handler
        ApplicationERC721 applicationNFT2 = new ApplicationERC721("ToughTurtles", "THTR", address(appManager), "https://SampleApp.io");
        console.log("applicationNFT2", address(applicationNFT2));
        ApplicationERC721Handler applicationNFTHandler2 = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(applicationNFT2), false);
        applicationNFT2.connectHandlerToToken(address(applicationNFTHandler2));
        /// register the token
        appManager.registerToken("THTR", address(applicationNFT2));
        ///Pricing Contracts
        applicationNFTHandler2.setNFTPricingAddress(address(nftPricer));
        applicationNFTHandler2.setERC20PricingAddress(address(erc20Pricer));
        for (uint i = 0; i < 40; i++) {
            applicationNFT2.safeMint(defaultAdmin);
            applicationNFT2.transferFrom(defaultAdmin, user1, i);
            nftPricer.setSingleNFTPrice(address(applicationNFT2), i, 1 * (10 ** 18));
        }
        uint256 testPrice2 = nftPricer.getNFTPrice(address(applicationNFT2), 35);
        assertEq(testPrice2, 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        applicationNFTHandler2.setNFTValuationLimit(20);

        /// set specific tokens in NFT 2 to higher prices. Expect this value to be ignored by rule check as it is checking collection price.
        nftPricer.setSingleNFTPrice(address(applicationNFT2), 36, 100 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT2), 37, 50 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT2), 40, 25 * (10 ** 18));
        nftPricer.setNFTCollectionPrice(address(applicationNFT2), 1 * (10 ** 18));
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
        vm.stopPrank();
        vm.startPrank(accessTier);
        appManager.addAccessLevel(user1, 3);
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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationNFTHandler.setNFTValuationLimit(50);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0xdd76c810);
        applicationNFT.transferFrom(user2, user1, 1);
    }

    /// test batch mint and burn
    function testBatchMintAndBurn() public {
        /// create the batch capable NFT
        ApplicationERC721WithBatchMintBurn nftBurner = new ApplicationERC721WithBatchMintBurn("BeanBabyBurner", "THRK", address(appManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(nftBurner), false);
        nftBurner.connectHandlerToToken(address(applicationNFTHandler));
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
        ApplicationERC721HandlerMod assetHandler = new ApplicationERC721HandlerMod(address(ruleProcessor), address(appManager), address(applicationNFT), true);
        ///connect to apptoken
        applicationNFT.connectHandlerToToken(address(assetHandler));

        assetHandler.setNFTPricingAddress(address(nftPricer));
        assetHandler.setERC20PricingAddress(address(erc20Pricer));

        ///Set transaction limit rule params
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory txnLimits = new uint48[](6);
        riskScores[0] = 1;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        txnLimits[0] = 20;
        txnLimits[1] = 17;
        txnLimits[2] = 15;
        txnLimits[3] = 12;
        txnLimits[4] = 11;
        txnLimits[5] = 10;
        uint32 index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(appManager), riskScores, txnLimits);

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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        assetHandler.setTransactionLimitByRiskRuleId(index);
        ///Set Risk Scores for users
        vm.stopPrank();
        vm.startPrank(riskAdmin);
        appManager.addRiskScore(user1, riskScores[0]);
        appManager.addRiskScore(user2, riskScores[1]);
        appManager.addRiskScore(user3, 49);

        ///Set Pricing for NFTs 0-7
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        nftPricer.setSingleNFTPrice(address(applicationNFT), 1, 11 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 0, 10 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 2, 12 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 3, 13 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 4, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 5, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 6, 17 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFT), 7, 20 * (10 ** 18));

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
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        nftPricer.setSingleNFTPrice(address(applicationNFT), 4, 1050 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFT), 5, 1550 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFT), 6, 11 * (10 ** 18)); // in dollars
        nftPricer.setSingleNFTPrice(address(applicationNFT), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 7);
        applicationNFT.safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        applicationNFT.safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user3, 4);

        address testAddress = assetHandler.newTestFunction();
        console.log(assetHandler.newTestFunction(), testAddress);
    }

    function testUpgradeAppManager721() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager appManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        applicationNFT.proposeAppManagerAddress(address(appManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        appManager2.confirmAppManager(address(applicationNFT));
        /// test to ensure it still works
        applicationNFT.safeMint(defaultAdmin);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationNFT.transferFrom(defaultAdmin, appAdministrator, 0);
        assertEq(applicationNFT.balanceOf(defaultAdmin), 0);
        assertEq(applicationNFT.balanceOf(appAdministrator), 1);

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        applicationNFT.proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        appManager2.confirmAppManager(address(applicationNFT));
        // non proposer tries to confirm
        applicationNFT.proposeAppManagerAddress(address(appManager2));
        ApplicationAppManager appManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        vm.expectRevert(0x41284967);
        appManager3.confirmAppManager(address(applicationNFT));
    }

    /// ******************* OPTIONAL MINT FUNCTION TESTING ******************
    /// These functions should remain commented out unless implementing overriding safeMint function inside of ApplicationERC721
    /**
     * Test the Mint Function with a set mint price
     */
    // function testOptionalMintFunctions() public {
    //     /// test admin setting mint price
    //     applicationNFT.setMintPrice(1 ether);
    //     /// test treasury not set error fires
    //     vm.deal(defaultAdmin, 5 ether);
    //     vm.expectRevert(0xf726ee2d);
    //     applicationNFT.safeMint{value: 1 ether}(user1);
    //     /// set treasury address
    //     address payable treasuryAddress = payable(defaultAdmin);
    //     applicationNFT.setTreasuryAddress(treasuryAddress);
    //     /// test mint without ether
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(user1);
    //     /// give user 1 ether to mint
    //     vm.deal(user1, 5 ether);
    //     /// mint with msg.value
    //     applicationNFT.safeMint{value: 1 ether}(user1);
    //     /// send mint fee to treasury address
    //     uint256 treasuryBalance = address(defaultAdmin).balance;
    //     assertEq(treasuryBalance, (6 * 10**18)); /// Balance is 6 as we gave 5 ETH for testing above plus the 1 ETH mint fee

    // }

    /**
     * Test the Mint Function with Application Administrator Only Modifier
     */
    // function testAppAdminOnlyMinting() public {
    //     /// Owner Mints new tokenId
    //     applicationNFT.safeMint(defaultAdmin);
    //     console.log(applicationNFT.balanceOf(defaultAdmin));
    //     /// Owner Mints a second new tokenId
    //     applicationNFT.safeMint(defaultAdmin);
    //     console.log(applicationNFT.balanceOf(defaultAdmin));
    //     assertEq(applicationNFT.balanceOf(defaultAdmin), 2);
    //     /// try to mint as non admin
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(user1);
    // }

    /**
     * Test the Mint Function with Only Owner Minting
     */
    // function testOnlyOwnerMinting() public {
    //     /// Owner Mints new tokenId
    //     applicationNFT.safeMint(defaultAdmin);
    //     console.log(applicationNFT.balanceOf(defaultAdmin));
    //     /// Owner Mints a second new tokenId
    //     applicationNFT.safeMint(defaultAdmin);
    //     console.log(applicationNFT.balanceOf(defaultAdmin));
    //     assertEq(applicationNFT.balanceOf(defaultAdmin), 2);
    //     /// try to mint as non admin
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(user1);

    //     /// Try to mint as admins but not owner
    //     vm.stopPrank();
    //     vm.startPrank(accessTier);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(accessTier);

    //     vm.stopPrank();
    //     vm.startPrank(riskAdmin);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(riskAdmin);

    //     vm.stopPrank();
    //     vm.startPrank(appAdministrator);
    //     vm.expectRevert();
    //     applicationNFT.safeMint(appAdministrator);
    // }
}

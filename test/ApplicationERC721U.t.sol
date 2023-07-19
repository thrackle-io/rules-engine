// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC721U.sol";
import "../src/example/ApplicationERC721UProxy.sol";
import {ApplicationAppManager} from "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import {ApplicationERC721HandlerMod} from "./helpers/ApplicationERC721HandlerMod.sol";

contract ApplicationERC721UTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationERC721U applicationNFT;
    ApplicationERC721U applicationNFT2;
    ApplicationERC721UProxy applicationNFTProxy;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationERC721Handler applicationNFTHandler2;
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
    address proxyOwner = address(787);

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

        applicationNFT = new ApplicationERC721U();
        applicationNFTProxy = new ApplicationERC721UProxy(address(applicationNFT), proxyOwner, "");
        ApplicationERC721U(address(applicationNFTProxy)).initialize("Prime Eternal", "CHAMP", address(appManager));
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(applicationNFTProxy), false);
        ApplicationERC721U(address(applicationNFTProxy)).connectHandlerToToken(address(applicationNFTHandler));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        /// register the token
        appManager.registerToken("THRK", address(applicationNFTProxy));

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

    function testMintUpgradeable() public {
        /// Owner Mints new tokenId
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        console.log(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin));
        /// Owner Mints a second new tokenId
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        console.log(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin));
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin), 2);
    }

    function testTransferUpgradeable() public {
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin), 1);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(defaultAdmin, appAdministrator, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin), 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(appAdministrator), 1);
    }

    function testBurnUpgradeable() public {
        ///Mint and transfer tokenId 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(defaultAdmin, appAdministrator, 0);
        ///Mint tokenId 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ///Test token burn of token 0 and token 1
        ApplicationERC721U(address(applicationNFTProxy)).burn(1);
        ///Switch to app administrator account for burn
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// Burn appAdministrator token
        ApplicationERC721U(address(applicationNFTProxy)).burn(0);
        ///Return to default admin account
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin), 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(appAdministrator), 0);
    }

    function testFailBurnUpgradeable() public {
        ///Mint and transfer tokenId 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(defaultAdmin, appAdministrator, 0);
        ///Mint tokenId 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ///attempt to burn token that user does not own
        ApplicationERC721U(address(applicationNFTProxy)).burn(0);
    }

    function testPassMinMaxAccountBalanceRuleUpgradeable() public {
        /// mint 6 NFTs to defaultAdmin for transfer
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(appAdministrator);

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
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(appAdministrator, rich_user, 1);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(appAdministrator, rich_user, 2);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(appAdministrator, user1, 4);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(appAdministrator, user1, 5);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 2);

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
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 4);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 1);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        ///update ruleId in application NFT handler
        applicationNFTHandler.setMinMaxBalanceRuleId(ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user3, 5);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        // user1 mints to 6 total (limit)
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); /// Id 6
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); /// Id 7
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); /// Id 8
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); /// Id 9
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); /// Id 10

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2);
        // transfer to user1 to exceed limit
        vm.expectRevert(0x24691f6b);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
        // upgrade the NFT and make sure it still works
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        // transfer should still fail
        vm.expectRevert(0x24691f6b);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 4);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testNFTOracleUpgradeable() public {
        /// set up a non admin user an nft
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);

        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

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
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(69), 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(address(69)), 0);
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
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 2, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2a15491e);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(88), 3);
        // upgrade the NFT and make sure it still works
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2a15491e);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(88), 3);
    }

    function testPauseRulesViaAppManagerERC721U() public {
        /// set up a non admin user an nft
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1);

        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
        // upgrade the NFT and make sure it still works
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, address(59), 2);
    }

    /**
     * @dev Test the NFT Trade rule
     */
    function testNFTTradeRuleInNFTUpgradeable() public {
        /// set up a non admin user an nft
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4

        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

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
        assertEq(rule.startTs, Blocktime);
        // tag the NFT collection
        appManager.addGeneralTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        // apply the rule to the ApplicationERC721Handler
        applicationNFTHandler.setTradeCounterRuleId(_index);

        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        appManager.removeGeneralTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        appManager.addGeneralTag(address(applicationNFTProxy), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        appManager.addGeneralTag(address(applicationNFTProxy), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x00b223e3);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user2, user1, 2);
    }

    function testTransactionLimitByRiskScoreNFTUpgradeable() public {
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
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 6
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 7
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 3);

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
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 1, 11 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 0, 10 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 2, 12 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 3, 13 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 17 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 20 * (10 ** 18));

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 4);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);
    }

    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testAccessLevel0InNFTUpgradeable() public {
        /// set up a non admin user an nft
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4

        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        applicationHandler.activateAccessLevel0Rule(true);

        // transfers should not work for addresses without AccessLevel
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);

        // set AccessLevel and try again
        vm.stopPrank();
        vm.startPrank(AccessTier);
        appManager.addAccessLevel(user2, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// user 1 accessLevel is still 0 so tx reverts 
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);


        vm.stopPrank();
        vm.startPrank(AccessTier);
        appManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(user1, user2, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 1);
    }

    function testMinAccountBalanceByDateUpgradeable() public {
        /// Mint NFTs for users 1, 2, 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2

        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 4
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5

        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user3); // tokenId = 6
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user3); // tokenId = 7
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user3); // tokenId = 8

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
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 3);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 1);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user3), 3);

        /// Transfers failing (below min value limit)
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 1);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 2);

        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user3), 3);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user3), 3);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, rich_user, 2);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, rich_user, 4);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, rich_user, 6);
    }

    function testAdminWithdrawalUpgradeable() public {
        /// Mint TokenId 0-6 to default admin
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(appManager), 5, block.timestamp + 365 days);

        /// Set the rule in the handler
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);

        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        vm.expectRevert();
        applicationNFTHandler.setAdminWithdrawalRuleId(1);

        /// These transfers should pass
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(defaultAdmin, user1, 0);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(defaultAdmin, user1, 1);
        /// This one fails
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(defaultAdmin, user1, 2);

        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(defaultAdmin, user1, 2);

        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(defaultAdmin, user1, 2);
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        applicationNFTHandler.setAdminWithdrawalRuleId(1);
    }

    function testUpgradeAppManager721u() public {
        address newAdmin = address(75);
        /// create a new app manager
        ApplicationAppManager appManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        ApplicationERC721U(address(applicationNFTProxy)).proposeAppManagerAddress(address(appManager2));
        /// confirm the app manager
        vm.stopPrank();
        vm.startPrank(newAdmin);
        appManager2.confirmAppManager(address(applicationNFTProxy));
        /// test to ensure it still works
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(defaultAdmin);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        ApplicationERC721U(address(applicationNFTProxy)).transferFrom(defaultAdmin, appAdministrator, 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(defaultAdmin), 0);
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(appAdministrator), 1);

        /// Test fail scenarios
        vm.stopPrank();
        vm.startPrank(newAdmin);
        // zero address
        vm.expectRevert(0xd92e233d);
        ApplicationERC721U(address(applicationNFTProxy)).proposeAppManagerAddress(address(0));
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        appManager2.confirmAppManager(address(applicationNFT));
        // non proposer tries to confirm
        ApplicationERC721U(address(applicationNFTProxy)).proposeAppManagerAddress(address(appManager2));
        ApplicationAppManager appManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        vm.expectRevert(0x41284967);
        appManager3.confirmAppManager(address(applicationNFTProxy));
    }

    function testUpgradingHandlersUpgradeable() public {
        ///deploy new modified appliction asset handler contract
        ApplicationERC721HandlerMod assetHandler = new ApplicationERC721HandlerMod(address(ruleProcessor), address(appManager), address(applicationNFTProxy), true);
        ///connect to apptoken
        ApplicationERC721U(address(applicationNFTProxy)).connectHandlerToToken(address(assetHandler));

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
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 6
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 7
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 3);

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
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 1, 11 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 0, 10 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 2, 12 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 3, 13 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 17 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 20 * (10 ** 18));

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 4);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        address testAddress = assetHandler.newTestFunction();
        console.log(assetHandler.newTestFunction(), testAddress);
    }

    function testUpgradingHandlersPostUpgrades() public {
        // upgrade the NFT and make sure it still fails
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
        // make it a double
        applicationNFT = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        ///deploy new modified appliction asset handler contract
        ApplicationERC721HandlerMod assetHandler = new ApplicationERC721HandlerMod(address(ruleProcessor), address(appManager), address(applicationNFTProxy), true);
        ///connect to apptoken
        ApplicationERC721U(address(applicationNFTProxy)).connectHandlerToToken(address(assetHandler));

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
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 0
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 1
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 2
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 3
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user1); // tokenId = 4
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user1), 5);

        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 5
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 6
        ApplicationERC721U(address(applicationNFTProxy)).safeMint(user2); // tokenId = 7
        assertEq(ApplicationERC721U(address(applicationNFTProxy)).balanceOf(user2), 3);

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
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 1, 11 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 0, 10 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 2, 12 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 3, 13 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 15 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 17 * (10 ** 18));
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 20 * (10 ** 18));

        ///Transfer NFT's
        ///Positive cases
        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user3, 0);

        vm.stopPrank();
        vm.startPrank(user3);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user3, user1, 0);

        vm.stopPrank();
        vm.startPrank(user1);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 4);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user1, user2, 1);

        ///Fail cases
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        ///simulate price changes
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 4, 1050 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 5, 1550 * (10 ** 16)); // in cents
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 6, 11 * (10 ** 18)); // in dollars
        nftPricer.setSingleNFTPrice(address(applicationNFTProxy), 7, 9 * (10 ** 18)); // in dollars

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 7);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 6);

        vm.expectRevert();
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 5);

        vm.stopPrank();
        vm.startPrank(user2);
        ApplicationERC721U(address(applicationNFTProxy)).safeTransferFrom(user2, user3, 4);

        address testAddress = assetHandler.newTestFunction();
        console.log(assetHandler.newTestFunction(), testAddress);
    }

    function testERC721Upgrade() public {
        vm.stopPrank();
        vm.startPrank(proxyOwner);
        applicationNFT2 = new ApplicationERC721U();
        applicationNFTProxy.upgradeTo(address(applicationNFT2));
    }
}

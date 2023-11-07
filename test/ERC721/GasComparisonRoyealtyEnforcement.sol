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
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

/**
* @dev a dummy contract to test the receiver whitelist functionality
 */
contract NFTDummyReceiver is IERC721Receiver{
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return this.onERC721Received.selector;
    }
}

/**
* @dev this test implements 3 different styles of royalty enforcement:
* 1. ERC721C integrated into our protocol.
* 2. ApplicationERC721 with the same functionality of ERC721C through the transfer function hook: TronC.
* 3. ApplicationERC721 with the same functionality of ERC721C splitted in the approve, setApprovalForAll, and transfer function hooks: TronD.
* The tests demonstrate how using these different approaches impact the gas consumption of trades and transfers.
*/

contract ERC721GasComparisonRoyaltyEnforcementTest is TestCommonFoundry {
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    OracleAllowed receiversAllowed;
    ApplicationERC721HandlerMod newAssetHandler;
    CreatorTokenTransferValidator transferValidator;
    NFTDummyReceiver receiver;
    NFTDummyReceiver badReceiver;
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address accessTier = address(3);
    address ac;
    address[] badBoys;
    address[] goodBoys;
    address[] goodReceivers;
    address openPond = address(0x74ADE);
    uint120 whitelistId;

    function setUp() public {
        vm.warp(Blocktime);

        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndERC721CTokens();

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        // we deploy the transfer validator for ERC721C
        transferValidator = new CreatorTokenTransferValidator(address(superAdmin));
        // we apply the transfer validator to the ERC721C token
        applicationNFTC.setTransferValidator(address(transferValidator));
        // we create a whitelist in the transfer validator
        whitelistId = transferValidator.createOperatorWhitelist("ThrackleWhitelist");
        // we set a security level of 1 (whitelist of operators) 
        transferValidator.setTransferSecurityLevelOfCollection(address(applicationNFTC), TransferSecurityLevels.One);
        // we set the whitelist for the token
        transferValidator.setOperatorWhitelistOfCollection(address(applicationNFTC), whitelistId);
        // we add our NFT marketplace to the whitelist 
        transferValidator.addOperatorToWhitelist(whitelistId, address(openPond));

        // let's create a receiver contract 
        receiver = new NFTDummyReceiver();
        //let's deploy our malicious contract receiver
        badReceiver = new NFTDummyReceiver();
        // we create a receiver whitelist in the transfer validator (this is not enabled yet since it requires at least 
        // level 3 to take effect)
        receiversWhitelistId = transferValidator.createPermittedContractReceiverAllowlist("ThrackleWhitelist");
        // we set the receiver whitelist for the token 
        transferValidator.setPermittedContractReceiverAllowlistOfCollection(address(applicationNFTC), receiversWhitelistId);
        // we add our good receiver to the whitelist 
        transferValidator.addPermittedContractReceiverToAllowlist(receiversWhitelistId, address(receiver));

        switchToAppAdministrator();
        // create the oracles
        oracleAllowed = new OracleAllowed();
        receiversAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }


    function testERC721AndHandlerVersions() public {
        string memory version = applicationNFTHandler.version();
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

    /// SIMPLE TRADES WITH WHITELIST OPERATORS
    function testNFTCOperatorWhitelistTrade() public{
        applicationNFTC.safeMint(user1);
        //negative case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.approve(address(0xBAAAAAAD), 0);
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.approve(openPond, 0);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user1, 0);

    }

    
    function testNFTTronCOperatorWhitelistTrade() public{
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
        assertEq(rule.oracleAddress, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setSenderOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(openPond);
        oracleAllowed.addToAllowList(goodBoys);
        // now comes the real action
        //negative case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.approve(address(0xBAAAAAAD), 0);
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 0);
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.approve(openPond, 0);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);


    }

   
    function testNFTTronDOperatorWhitelistTradeApproved() public{
         /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
        assertEq(rule.oracleAddress, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOperatorOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(openPond);
        oracleAllowed.addToAllowList(goodBoys);
        // now comes the real action
        vm.stopPrank();
        vm.startPrank(user1);
        // this address shouldn't be allowed to be approved
        vm.expectRevert();
        applicationNFT.approve(address(0xBAAAAAAD), 0);
        // but this one should
        applicationNFT.approve(openPond, 0);
        // now, 0xBAAAAAAD shouldn't be able to transfer tokens
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // but OpenPond should be able to carry out the trade
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);


    }

    function testNFTTronDOperatorWhitelistTradeOperator() public{
         /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
        assertEq(rule.oracleAddress, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOperatorOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(openPond);
        oracleAllowed.addToAllowList(goodBoys);
        // now comes the real action
        vm.stopPrank();
        vm.startPrank(user1);
        // this address shouldn't be allowed to be approved
        vm.expectRevert();
        applicationNFT.setApprovalForAll(address(0xBAAAAAAD), true);
        // but this one should
        applicationNFT.setApprovalForAll(openPond, true);
        // now, 0xBAAAAAAD shouldn't be able to transfer tokens
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // but OpenPond should be able to carry out the trade
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);


    }


    /// TRADES WITH WHITELIST OPERATORS AND WHITELIST CONTRACT REVEIVERS
    function testNFTCOperatorWhitelistTradeWhitelistContractReceiver() public{
        
        vm.stopPrank();
        vm.startPrank(appAdministrator);
    
        // we set a security level of 3 (whitelist of operators and no contract can receive NFTs except for whitelisted ones) 
        transferValidator.setTransferSecurityLevelOfCollection(address(applicationNFTC), TransferSecurityLevels.Three);
        
        // positive case
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFTC.safeTransferFrom(user1, receiver, 0);
        // negative case
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.stopPrank();
        vm.startPrank(openPond);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, badReceiver, 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user1, user2, 1);

    }
    
    function testNFTTronCOperatorWhitelistTradeWhitelistContractReceiver() public{
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        assertEq(applicationNFT.balanceOf(user1), 2);

        // add the rule for operators.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setSenderOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(openPond);
        oracleAllowed.addToAllowList(goodBoys);

         // add the rule for receiver contracts.
         switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(receiversAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setRecipientOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodReceivers.push(receiver);
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, receiver, 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, badReceiver, 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }

    function testNFTTronDOperatorWhitelistTradeWhitelistContractReceiver() public{
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        assertEq(applicationNFT.balanceOf(user1), 2);

        // add the rule for operators.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOperatorOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(openPond);
        oracleAllowed.addToAllowList(goodBoys);

         // add the rule for receiver contracts.
         switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(receiversAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setRecipientOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodReceivers.push(receiver);
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, receiver, 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, badReceiver, 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }


    function testTransfer() public {
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
        assertEq(applicationNFTC.balanceOf(user), 1);
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
        applicationNFTHandler.setNFTPricingAddress(address(0x00));
        vm.expectRevert();
        applicationNFTHandler.setERC20PricingAddress(address(0x00));
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
        applicationNFTHandler.setOracleRuleId(_index);
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
        applicationNFTHandler.setOracleRuleId(_index);
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
        applicationNFTHandler.setOracleRuleId(_index);
        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        applicationNFTHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleRestricted.addToSanctionsList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x6bdfffc0);
        applicationNFTC.burn(3);
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
        applicationNFTHandler.setTradeCounterRuleId(_index);
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
        applicationNFTHandler.setTransactionLimitByRiskRuleId(index);
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
        applicationNFTHandler.setNFTValuationLimit(20);
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
        ApplicationERC721Handler applicationNFTHandler2 = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(applicationNFT2), false);
        applicationNFT2.connectHandlerToToken(address(applicationNFTHandler2));
        /// register the token
        applicationAppManager.registerToken("THTR", address(applicationNFT2));
        ///Pricing Contracts
        applicationNFTHandler2.setNFTPricingAddress(address(erc721Pricer));
        applicationNFTHandler2.setERC20PricingAddress(address(erc20Pricer));
        for (uint i = 0; i < 40; i++) {
            applicationNFT2.safeMint(appAdministrator);
            applicationNFT2.transferFrom(appAdministrator, user1, i);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT2), i, 1 * (10 ** 18));
        }
        uint256 testPrice2 = erc721Pricer.getNFTPrice(address(applicationNFT2), 35);
        assertEq(testPrice2, 1 * (10 ** 18));
        /// set the nftHandler nftValuationLimit variable
        switchToAppAdministrator();
        applicationNFTHandler2.setNFTValuationLimit(20);
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
        applicationNFTHandler.setNFTValuationLimit(50);

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


}

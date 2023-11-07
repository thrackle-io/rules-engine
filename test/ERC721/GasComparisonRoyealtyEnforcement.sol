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
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

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

        switchToAppAdministrator();
        setUpProtocolAndAppManagerAndERC721CTokens();
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
    function testERC721CLevel1() public{
        applicationNFTC.safeMint(user1);
        //negative case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.setApprovalForAll(address(0xBAAAAAAD), true);
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFTC.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFTC.safeTransferFrom(user2, user1, 0);

    }

    
    function testTronCLevel1() public{
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
        applicationNFT.setApprovalForAll(address(0xBAAAAAAD), true);
        vm.stopPrank();
        vm.startPrank(address(0xBAAAAAAD));
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 0);
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, user2, 0);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.safeTransferFrom(user2, user1, 0);


    }

   
    function testTronDLevelApprove1() public{
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

    function testTronDLevelOperator1() public{
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
        goodBoys.push(address(0xABCDE));
        oracleAllowed.addToAllowList(goodBoys);
        // now comes the real action
        vm.stopPrank();
        vm.startPrank(user1);
        // this address shouldn't be allowed to be approved
        vm.expectRevert();
        applicationNFT.setApprovalForAll(address(0xBAAAAAAD), true);
        // this first approval is to get a more accurate gas number since the first approval is always more expensive
        applicationNFT.setApprovalForAll(address(0xABCDE), true);
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
    function testERC721CLevel3() public{
        
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
        applicationNFTC.safeTransferFrom(user1, address(receiver), 0);
        // negative case
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.stopPrank();
        vm.startPrank(openPond);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.safeTransferFrom(user1, user2, 1);

    }
    
    function testTronCLevel3() public{
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
        goodReceivers.push(address(receiver));
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, address(receiver), 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }

    function testTronDLevel3() public{
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
         goodBoys.push(address(0xABCDE));
        oracleAllowed.addToAllowList(goodBoys);

         // add the rule for receiver contracts.
         switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(receiversAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setRecipientOracleRuleId(_index);
        // add an allowed address
        switchToAppAdministrator();
        goodReceivers.push(address(receiver));
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        // this first approval is to get a more accurate gas number since the first approval is always more expensive
        applicationNFT.setApprovalForAll(address(0xABCDE), true);
        // now the real one
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, address(receiver), 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }


    /// TRADES WITH WHITELIST OPERATORS, WHITELIST CONTRACT REVEIVERS AND NO OTC TRANSFERS
    function testERC721CLevel5() public{
        
        vm.stopPrank();
        vm.startPrank(appAdministrator);
    
        // we set a security level of 3 (whitelist of operators and no contract can receive NFTs except for whitelisted ones) 
        transferValidator.setTransferSecurityLevelOfCollection(address(applicationNFTC), TransferSecurityLevels.Five);
        
        // positive case
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFTC.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFTC.safeTransferFrom(user1, address(receiver), 0);
        // negative case
        applicationNFTC.safeMint(user1);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.stopPrank();
        vm.startPrank(openPond);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFTC.safeTransferFrom(user1, user2, 1);

    }
    
    function testTronCLevel5() public{
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
        // enable Only Trades allowed rule
        applicationNFTHandler.activateRestrictedToTradesOnlyRule(true);
        // add an allowed address
        switchToAppAdministrator();
        goodReceivers.push(address(receiver));
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, address(receiver), 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }

    function testTronDLevel5() public{
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
        goodBoys.push(address(0xABCDE));
        oracleAllowed.addToAllowList(goodBoys);

         // add the rule for receiver contracts.
         switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(receiversAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setRecipientOracleRuleId(_index);
        // enable Only Trades allowed rule
        applicationNFTHandler.activateRestrictedToTradesOnlyRule(true);
        // add an allowed address
        switchToAppAdministrator();
        goodReceivers.push(address(receiver));
        receiversAllowed.addToAllowList(goodReceivers);


        // now comes the real action
        //positive case
        vm.stopPrank();
        vm.startPrank(user1);
        // this first approval is to get a more accurate gas number since the first approval is always more expensive
        applicationNFT.setApprovalForAll(address(0xABCDE), true);
        // now the real one
        applicationNFT.setApprovalForAll(openPond, true);
        vm.stopPrank();
        vm.startPrank(openPond);
        applicationNFT.safeTransferFrom(user1, address(receiver), 0);
        //negative case
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, address(badReceiver), 1);
        // let's see how a regular transfer uses gas
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(user1, user2, 1);
    }



    function testTransfer() public {
        applicationNFTC.safeMint(appAdministrator);
        applicationNFTC.transferFrom(appAdministrator, user, 0);
        assertEq(applicationNFTC.balanceOf(appAdministrator), 0);
        assertEq(applicationNFTC.balanceOf(user), 1);
    }


   
}

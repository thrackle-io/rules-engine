// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {TaggedRuleDataFacet} from "src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/economic/ruleStorage/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/economic/ruleStorage/AppRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "src/economic/ruleStorage/RuleDataInterfaces.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import {ApplicationERC721HandlerMod} from "../helpers/ApplicationERC721HandlerMod.sol";
import "test/helpers/ApplicationERC721WithBatchMintBurn.sol";
import "test/helpers/TestCommonFoundry.sol";
import "src/example/ERC721/NonProtocolERC721.sol";
import "src/example/StakingWrapper.sol";

contract ApplicationERC721Test is TestCommonFoundry {
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC721HandlerMod newAssetHandler;
    StakingWrapper stakingWrapper;
    NonProtocolERC721 nonProtoNFT; 
    ApplicationERC721Handler nonProtoNFTHandler;
    address nonProtoNFTAddress;
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
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();

        /// deploy nonProtocol Collection and mint 
        nonProtoNFT = new NonProtocolERC721("NonProto","NPRT"); 
        nonProtoNFTAddress = address(nonProtoNFT);
        /// deploy wrapper contract with nonProtocol NFT set as collection to wrap 
        uint96 royaltyFee = uint96(100); //.01% of sale price
        vm.deal(appAdministrator, 10 ether);  
        stakingWrapper = new StakingWrapper(nonProtoNFTAddress, "wrappedToken", "WTKN", address(appAdministrator), royaltyFee); 
        /// set wrapped tokens as applicationNFT + set tokenHandler and appManager addresses in wrapper contract 
        nonProtoNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(applicationAppManager), address(stakingWrapper), false); 
        applicationNFTHandler = nonProtoNFTHandler;
        stakingWrapper.connectHandlerToToken(address(applicationNFTHandler));
        stakingWrapper.setAppManagerAddress(address(applicationAppManager));
        applicationAppManager.registerToken("wrappedToken", address(stakingWrapper));
        /// mint 50 non protocol rule tokens 
        for (uint i = 0; i < 50; i++) {
                nonProtoNFT.safeMint(appAdministrator);
                nonProtoNFT.approve(address(stakingWrapper), i); 
            }
        // stake the non protocol tokens into contract and receive wrapped tokens with protocol checkAllRules() hook 
        for (uint i = 0; i < 50; i++) {
                stakingWrapper.stake(i);
            }
    }

    function testERC721AndHandlerVersions() public {
        string memory version = applicationNFTHandler.version();
        assertEq(version, "1.1.0");
    }


    function testTransfer() public {
        stakingWrapper.transferFrom(appAdministrator, user, 0);
        assertEq(stakingWrapper.balanceOf(appAdministrator), 49);
        assertEq(stakingWrapper.balanceOf(user), 1);
    }


    function testPassMinMaxAccountBalanceRule() public {
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(1);
        max[0] = uint256(6);

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 6 and 7 to rich_user
        stakingWrapper.transferFrom(appAdministrator, rich_user, 1);
        stakingWrapper.transferFrom(appAdministrator, rich_user, 2);
        assertEq(stakingWrapper.balanceOf(rich_user), 2);

        ///transfer tokenId 8 and 9 to user1
        stakingWrapper.transferFrom(appAdministrator, user1, 3);
        stakingWrapper.transferFrom(appAdministrator, user1, 4);
        assertEq(stakingWrapper.balanceOf(user1), 2);

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
        stakingWrapper.transferFrom(user1, user2, 3);
        assertEq(stakingWrapper.balanceOf(user2), 1);
        assertEq(stakingWrapper.balanceOf(user1), 1);
        switchToRuleAdmin();
        ///update ruleId in application NFT handler
        applicationNFTHandler.setMinMaxBalanceRuleId(ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        stakingWrapper.transferFrom(user1, user3, 4);

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        stakingWrapper.transferFrom(appAdministrator, user1, 6);
        stakingWrapper.transferFrom(appAdministrator, user1, 7);
        stakingWrapper.transferFrom(appAdministrator, user1, 8);
        stakingWrapper.transferFrom(appAdministrator, user1, 9);
        stakingWrapper.transferFrom(appAdministrator, user1, 10);

        stakingWrapper.safeTransferFrom(appAdministrator, user2, 11);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x24691f6b);
        stakingWrapper.transferFrom(user2, user1, 3);

    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testNFTOracle() public {
        /// set up a non admin user an nft
        stakingWrapper.transferFrom(appAdministrator, user1, 0);
        stakingWrapper.transferFrom(appAdministrator, user1, 1);
        stakingWrapper.transferFrom(appAdministrator, user1, 2);
        stakingWrapper.transferFrom(appAdministrator, user1, 3);
        stakingWrapper.transferFrom(appAdministrator, user1, 4);

        assertEq(stakingWrapper.balanceOf(user1), 5);

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
        stakingWrapper.transferFrom(user1, user2, 0);
        assertEq(stakingWrapper.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x6bdfffc0);
        stakingWrapper.transferFrom(user1, address(69), 1);
        assertEq(stakingWrapper.balanceOf(address(69)), 0);
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
        stakingWrapper.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        stakingWrapper.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));

        /// set oracle back to allow and attempt to burn token
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        applicationNFTHandler.setOracleRuleId(_index);
       
    }

    function testPauseRulesViaAppManager() public {
        /// set up a non admin user an nft
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 0);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 1);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 2);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 3);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 4);

        assertEq(stakingWrapper.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        stakingWrapper.transferFrom(user1, address(59), 2);
    }

    function testPeerToPeerTransfersWithValue() public {
        /// this is to test royalty payments in a peer to peer transaction 
        vm.deal(user1, 10 ether); 
        assertEq(user1.balance, 10 ether); 
        assertEq(appAdministrator.balance, 10 ether); 
        /// set up a non admin user an nft
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 0);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 1);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 2);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 3);
        stakingWrapper.safeTransferFrom(appAdministrator, user1, 4);

        vm.stopPrank();
        vm.startPrank(user1);
        /// user 1 sends tokens to user 2 with value 
        /// we expect the balance of app admin to increase 
        stakingWrapper._safeTransferFrom{value: 1 ether}(user1, user2, 0); 
        console.log("Royalty Recipient Balance", appAdministrator.balance);
        console.log("Wrapping Contract Balance",address(stakingWrapper).balance);
        assertGt(appAdministrator.balance, 10 ether);
        assertEq(user2.balance, 0); 
        assertGt(address(stakingWrapper).balance, 1); 
        stakingWrapper._safeTransferFrom{value: 1 ether}(user1, user2, 1);
        console.log("Royalty Recipient Balance", appAdministrator.balance);
        console.log("Wrapping Contract Balance",address(stakingWrapper).balance);
        stakingWrapper._safeTransferFrom{value: 1 ether}(user1, user2, 2);
        console.log("Royalty Recipient Balance", appAdministrator.balance);
        console.log("Wrapping Contract Balance",address(stakingWrapper).balance);
        stakingWrapper._safeTransferFrom{value: 1 ether}(user1, user2, 3);
        console.log("Royalty Recipient Balance", appAdministrator.balance);
        console.log("Wrapping Contract Balance",address(stakingWrapper).balance);
        stakingWrapper._safeTransferFrom{value: 1 ether}(user1, user2, 4);
        assertEq(appAdministrator.balance, 10.05 ether);
        assertEq(user2.balance, 0);
        console.log("Wrapping Contract Balance",address(stakingWrapper).balance); 
        console.log("Royalty Recipient Balance", appAdministrator.balance); 

        /// attempt to send tokens without value 
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert("Msg.Value must be greater than 0");
        stakingWrapper._safeTransferFrom(user2, user1, 3);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ApplicationERC20} from "../src/example/ApplicationERC20.sol";
import {ApplicationERC721} from "src/example/ApplicationERC721.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import {ApplicationERC721Handler} from "../src/example/ApplicationERC721Handler.sol";
import {ApplicationERC20Handler} from "../src/example/ApplicationERC20Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import {RuleDataFacet} from "src/economic/ruleStorage/RuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "src/economic/ruleStorage/RuleDataInterfaces.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import "test/helpers/TestCommon.sol";

contract ApplicationERC721FuzzTest is TestCommon {
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    address[] badBoys;
    address[] goodBoys;
    event Log(string eventString, bytes32[] tag);

    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();

        //activateBalanceByAccessLevelRule
        applicationCoin.mint(appAdministrator, type(uint256).max);
    }

    function testMintFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 1);
        address randomUser = addressList[0];
        /// Owner Mints new tokenId
        applicationNFT.safeMint(randomUser);
        console.log(applicationNFT.balanceOf(randomUser));
        /// Owner Mints a second new tokenId
        applicationNFT.safeMint(randomUser);
        console.log(applicationNFT.balanceOf(randomUser));
        assertEq(applicationNFT.balanceOf(randomUser), 2);
    }

    function testTransferFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address randomUser = addressList[0];
        address randomUser2 = addressList[1];
        applicationNFT.safeMint(randomUser);
        vm.stopPrank();
        vm.startPrank(randomUser);
        applicationNFT.transferFrom(randomUser, randomUser2, 0);
        assertEq(applicationNFT.balanceOf(randomUser), 0);
        assertEq(applicationNFT.balanceOf(randomUser2), 1);
    }

    function testBurnFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address randomUser = addressList[0];
        address randomUser2 = addressList[1];
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(randomUser);
        vm.stopPrank();
        vm.startPrank(randomUser);
        applicationNFT.transferFrom(randomUser, randomUser2, 0);
        ///Mint tokenId 1
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFT.safeMint(randomUser);
        ///Test token burn of token 0 and token 1
        vm.stopPrank();
        vm.startPrank(randomUser);
        applicationNFT.burn(1);
        ///Switch to app administrator account for burn
        vm.stopPrank();
        vm.startPrank(randomUser2);
        // Burn appAdministrator token
        applicationNFT.burn(0);
        ///Return to default admin account
        assertEq(applicationNFT.balanceOf(randomUser), 0);
        assertEq(applicationNFT.balanceOf(randomUser2), 0);
    }

    function testFailBurnFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address randomUser = addressList[0];
        address randomUser2 = addressList[1];
        ///Mint and transfer tokenId 0
        applicationNFT.safeMint(randomUser);
        applicationNFT.transferFrom(randomUser, randomUser2, 0);
        ///Mint tokenId 1
        applicationNFT.safeMint(randomUser);
        ///attempt to burn token that user does not own
        applicationNFT.burn(0);
    }

    function testPassMinMaxAccountBalanceRuleFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address randomUser = addressList[0];
        address richGuy = addressList[1];
        address user1 = addressList[2];
        address user2 = addressList[3];
        address user3 = addressList[4];
        /// mint 6 NFTs to appAdministrator for transfer
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);

        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("Oscar");
        min[0] = uint256(1);
        max[0] = uint256(6);

        /// set up a non admin user with tokens
        vm.stopPrank();
        vm.startPrank(randomUser);
        ///transfer tokenId 1 and 2 to richGuy
        applicationNFT.transferFrom(randomUser, richGuy, 0);
        applicationNFT.transferFrom(randomUser, richGuy, 1);
        assertEq(applicationNFT.balanceOf(richGuy), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(randomUser, user1, 3);
        applicationNFT.transferFrom(randomUser, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);
        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);

        ///Add GeneralTag to account
        switchToAppAdministrator();
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
        applicationNFTHandler.setMinMaxBalanceRuleId(ruleId);
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

        applicationNFT.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x24691f6b);
        applicationNFT.transferFrom(user2, user1, 3);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testNFTOracleFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address randomUser = addressList[0];
        address richGuy = addressList[1];
        address user1 = addressList[2];
        address user2 = addressList[3];
        address user3 = addressList[4];
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        switchToAppAdministrator();
        // add a blacklist address
        badBoys.push(user3);
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
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
        applicationNFT.transferFrom(user1, user3, 1);
        assertEq(applicationNFT.balanceOf(user3), 0);
        // check the allowed list type
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(randomUser);
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationNFT.transferFrom(user1, randomUser, 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationNFT.transferFrom(user1, richGuy, 3);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));
    }

    /**
     * @dev Test the NFT Trade rule
     */
    function testNFTTradeRuleInNFTFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address user1 = addressList[0];
        address user2 = addressList[1];
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        NonTaggedRules.NFTTradeCounterRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        assertEq(rule.startTs, Blocktime);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
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

    /**
     * @dev Test the NFT TransactionSizeByRiskRule
     */
    function testTransactionSizeByRiskRuleNFT(uint8 _addressIndex, uint8 _risk) public {
        for (uint i; i < 30; ) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * (10 ** 18)); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * (10 ** 18));
            unchecked {
                ++i;
            }
        }
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 0);
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 2);
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 3);
        assertEq(applicationNFT.balanceOf(_user1), 4);
        applicationNFT.safeTransferFrom(appAdministrator, _user2, 5);
        applicationNFT.safeTransferFrom(appAdministrator, _user2, 6);
        assertEq(applicationNFT.balanceOf(_user2), 2);
        applicationNFT.safeTransferFrom(appAdministrator, _user3, 7);
        applicationNFT.safeTransferFrom(appAdministrator, _user3, 19);
        assertEq(applicationNFT.balanceOf(_user3), 2);

        uint48[] memory _maxSize = new uint48[](6);
        uint8[] memory _riskLevel = new uint8[](5);
        uint8 risk = uint8((uint16(_risk) * 100) / 256);

        _maxSize[0] = 120;
        _maxSize[1] = 70;
        _maxSize[2] = 50;
        _maxSize[3] = 40;
        _maxSize[4] = 30;
        _maxSize[5] = 20;
        _riskLevel[0] = 20;
        _riskLevel[1] = 40;
        _riskLevel[2] = 60;
        _riskLevel[3] = 80;
        _riskLevel[4] = 99;

        ///Register rule with ERC721Handler
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(applicationAppManager), _riskLevel, _maxSize);
        applicationNFTHandler.setTransactionLimitByRiskRuleId(ruleId);
        /// we set a risk score for user1 and user 2
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(_user1, risk);
        applicationAppManager.addRiskScore(_user2, risk);
        applicationAppManager.addRiskScore(_user3, risk);
        applicationAppManager.addRiskScore(_user4, risk);

        vm.stopPrank();
        vm.startPrank(_user1);
        ///Should always pass
        applicationNFT.safeTransferFrom(_user1, _user2, 0); // a 10-dollar NFT
        applicationNFT.safeTransferFrom(_user1, _user2, 1); // a 20-dollar NFT

        if (risk >= 99) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 2); // a 30-dollar NFT

        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.safeTransferFrom(_user2, _user1, 0); // a 10-dollar NFT

        if (risk >= 40) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user2, _user1, 5); // a 60-dollar NFT

        vm.stopPrank();
        vm.startPrank(_user3);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user3, _user4, 19); // a 200-dollar NFT
    }

    /**
     * @dev Test the Balance By AccessLevel rule
     */
    function testNFTBalanceByAccessLevelRulePassesFuzz(uint8 _addressIndex, uint8 _amountSeed) public {
        for (uint i; i < 30; ) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * (10 ** 18)); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * (10 ** 18));
            unchecked {
                ++i;
            }
        }
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 0); // a 10-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user3, 19); // an 200-dollar NFT
        assertEq(applicationNFT.balanceOf(_user3), 1);
        // we make sure that _amountSeed is between 10 and 255
        if (_amountSeed < 245) _amountSeed += 10;

        // add the rule.
        uint48[] memory balanceAmounts = new uint48[](5);
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = uint48(_amountSeed) + 50;
        uint48 accessBalance3 = uint48(_amountSeed) + 100;
        uint48 accessBalance4 = uint48(_amountSeed) + 200;

        balanceAmounts[0] = 0;
        balanceAmounts[1] = accessBalance1;
        balanceAmounts[2] = accessBalance2;
        balanceAmounts[3] = accessBalance3;
        balanceAmounts[4] = accessBalance4;
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);

        ///perform transfer that checks rule when account does not have AccessLevel fails
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        vm.stopPrank();
        vm.startPrank(_user2);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user2, _user4, 0);
        vm.stopPrank();
        vm.startPrank(_user4);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user4, _user1, 0);
        /// this should revert
        vm.stopPrank();
        vm.startPrank(_user3);
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user3, _user4, 19);

        /// Add access levellevel to _user3
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user3, 3);
        applicationAppManager.addAccessLevel(_user1, 1);

        /// if NFTs are woth more than accessBalance3, it should fail
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        if (accessBalance3 < 210) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user3, 0);
        if (accessBalance3 >= 210) {
            vm.stopPrank();
            vm.startPrank(_user3);
            applicationNFT.safeTransferFrom(_user3, _user1, 0);
        }

        /// let's give user2 a 100-dollar NFT
        switchToAppAdministrator();
        applicationNFT.safeTransferFrom(appAdministrator, _user2, 9); // a 100-dollar NFT
        assertEq(applicationNFT.balanceOf(_user2), 1);
        /// now let's assign him access=2 and let's check the rule again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user2, 2);
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        if (accessBalance2 < 110) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        if (accessBalance2 >= 110) {
            vm.stopPrank();
            vm.startPrank(_user2);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }

        /// create erc20 token, mint, and transfer to user
        switchToAppAdministrator();
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));
        // set the access levellevel for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user4, 4);

        /// let's give user1 a 150-dollar NFT
        switchToAppAdministrator();
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 14); // a 150-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 2);

        vm.stopPrank();
        vm.startPrank(_user1);
        /// let's send 150-dollar worth of dracs to user4. If accessBalance4 allows less than
        /// 300 (150 in NFTs and 150 in erc20s) it should fail when trying to send NFT
        applicationCoin.transfer(_user4, 150 * (10 ** 18));
        if (accessBalance4 < 300) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user4, 14);
        if (accessBalance3 >= 300) assertEq(applicationCoin.balanceOf(_user4), 150 * (10 ** 18));
        bytes4 erc20Id = type(IERC20).interfaceId;
        console.log(uint32(erc20Id));
        console.log(applicationCoin.supportsInterface(0x36372b07));
    }

    function testNFTValuationLimitFuzz(uint8 _addressIndex, uint8 _amountToMint) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];

        // we make sure that _amountToMint is between 10 and 255
        if (_amountToMint < 245) _amountToMint += 10;
        uint8 mintAmount = _amountToMint;
        /// mint and load user 1 with 10-255 NFTs
        for (uint i; i < mintAmount; ) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * (10 ** 18)); //setting at $1
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), 1 * (10 ** 18));
            applicationNFT.transferFrom(appAdministrator, _user1, i);
            unchecked {
                ++i;
            }
        }
        // add the rule.
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 0;
        balanceAmounts[1] = 10;
        balanceAmounts[2] = 50;
        balanceAmounts[3] = 100;
        balanceAmounts[4] = 300;
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);
        switchToAppAdministrator();
        /// set the nftHandler nftValuationLimit variable
        applicationNFTHandler.setNFTValuationLimit(20);
        /// set 2 tokens above the $1 USD amount of other tokens (tokens 0-9 will always be minted)
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 50 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 25 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18));
        /// set access levels for user 1 and user 2
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user1, 2);
        applicationAppManager.addAccessLevel(_user2, 2);
        applicationAppManager.addAccessLevel(_user3, 1);
        applicationAppManager.addAccessLevel(_user4, 4);
        /// transfer tokens to user 2
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 9);
        /// transfer back to user 1
        /**
        Tx fails if the balance of user1 is over the access level of $50USD 
        or 
        if the balance of user 1 is less than the nftValuation limit (will calc the token prices increase above)
        */
        vm.stopPrank();
        vm.startPrank(_user2);
        if (!applicationAppManager.isAppAdministrator(_user1) && !applicationAppManager.isAppAdministrator(_user2)) {
            if (_amountToMint < 10 || mintAmount > 51) {
                vm.expectRevert(0xdd76c810);
                applicationNFT.transferFrom(_user2, _user1, 9);
            }
        }

        vm.stopPrank();
        vm.startPrank(_user1);
        /// check token valuation works with increased value tokens
        vm.expectRevert(0xdd76c810);
        applicationNFT.transferFrom(_user1, _user3, 2);

        applicationNFT.transferFrom(_user1, _user4, 2);
    }

    function testNFTValuationVariableLimitFuzz(uint8 _addressIndex, uint256 _valuationLimit) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];

        /// mint and load user 1 with 50 NFTs
        for (uint i; i < 50; ) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * (10 ** 18)); //setting at $1
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), 1 * (10 ** 18));
            applicationNFT.transferFrom(appAdministrator, _user1, i);
            unchecked {
                ++i;
            }
        }
        // add account balance rule to check valuations
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 0;
        balanceAmounts[1] = 10;
        balanceAmounts[2] = 50;
        balanceAmounts[3] = 100;
        balanceAmounts[4] = 300;
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);
        switchToAppAdministrator();
        /// set the nftHandler nftValuationLimit variable
        applicationNFTHandler.setNFTValuationLimit(_valuationLimit);
        /// set 2 tokens above the $1 USD amount of other tokens (tokens 0-9 will always be minted)
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 50 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 25 * (10 ** 18));
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * (10 ** 18));
        /// set access levels for user 1 and user 2
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user1, 2);
        applicationAppManager.addAccessLevel(_user2, 2);
        applicationAppManager.addAccessLevel(_user3, 1);
        applicationAppManager.addAccessLevel(_user4, 4);
        /// transfer tokens to user 2
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 9);
        /// transfer back to user 1
        /**
        Tx fails if the balance of user1 is over the access level of $50USD 
        or 
        if the balance of user 1 is less than the nftValuation limit (will calc the token prices increase above)
        */
        vm.stopPrank();
        vm.startPrank(_user2);
        if (!applicationAppManager.isAppAdministrator(_user1) && !applicationAppManager.isAppAdministrator(_user2)) {
            if (_valuationLimit > 49) {
                vm.expectRevert(0xdd76c810);
                applicationNFT.transferFrom(_user2, _user1, 9);
            }
        }
    }

    function testPassesMinBalByDateNFTFuzz(uint8 _addressIndex, bytes32 tag1, bytes32 tag2, bytes32 tag3) public {
        /// Set up test variables
        vm.assume(tag1 != "" && tag2 != "" && tag3 != "");
        vm.assume(tag1 != tag2 && tag1 != tag3 && tag2 != tag3);

        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];

        applicationNFT.safeMint(_user1); /// TokenId 0
        applicationNFT.safeMint(_user1); /// TokenId 1
        applicationNFT.safeMint(_user1); /// TokenId 2

        applicationNFT.safeMint(_user2); /// TokenId 3
        applicationNFT.safeMint(_user2); /// TokenId 4
        applicationNFT.safeMint(_user2); /// TokenId 5

        applicationNFT.safeMint(_user3); /// TokenId 6
        applicationNFT.safeMint(_user3); /// TokenId 7
        applicationNFT.safeMint(_user3); /// TokenId 8
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = tag1;
        accs[1] = tag2;
        accs[2] = tag3;
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = 1;
        holdAmounts[1] = 2;
        holdAmounts[2] = 3;
        uint16[] memory holdPeriods = new uint16[](3);
        holdPeriods[0] = uint16(720); // one month
        holdPeriods[1] = uint16(4380); // six months
        holdPeriods[2] = uint16(17520); // two years
        uint64[] memory holdTimestamps = new uint64[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, holdTimestamps);
        assertEq(_index, 0);
        /// Set rule
        applicationNFTHandler.setMinBalByDateRuleId(_index);
        switchToAppAdministrator();
        /// Tag accounts
        applicationAppManager.addGeneralTag(_user1, tag1); ///add tag
        applicationAppManager.addGeneralTag(_user2, tag2); ///add tag
        applicationAppManager.addGeneralTag(_user3, tag3); ///add tag
        /// Transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.safeTransferFrom(_user1, _user4, 0);
        applicationNFT.safeTransferFrom(_user1, _user4, 2);
        assertEq(applicationNFT.balanceOf(_user1), 1);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFT.safeTransferFrom(_user1, _user4, 1); /// Fails because User1 cannot have balanceOf less than 1

        vm.stopPrank();
        vm.startPrank(_user2);
        assertEq(applicationNFT.balanceOf(_user2), 3);
        applicationNFT.safeTransferFrom(_user2, _user4, 4); /// Send token4 to user 4
        assertEq(applicationNFT.balanceOf(_user2), 2);
        vm.expectRevert(0xa7fb7b4b);
        applicationNFT.safeTransferFrom(_user2, _user4, 3); /// Fails because User2 cannot have balanceOf less than 2

        /// warp to allow user 1 to transfer
        vm.warp(Blocktime + 725 hours);
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.safeTransferFrom(_user1, _user4, 1);

        /// warp to allow user 2 to transfer
        vm.warp(Blocktime + 4385 hours);
        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.safeTransferFrom(_user2, _user4, 3);

        /// warp to allow user 3 to transfer
        vm.warp(Blocktime + 17525 hours);
        vm.stopPrank();
        vm.startPrank(_user3);
        applicationNFT.safeTransferFrom(_user3, _user4, 6);
    }

    function testMaxTxSizePerPeriodByRiskRuleNFT(uint8 _risk, uint8 _period, uint8 _hourOfDay) public {
        vm.warp(100_000_000);
        /// we create the rule
        uint48[] memory _maxSize = new uint48[](4);
        uint8[] memory _riskLevel = new uint8[](3);
        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
        uint8 hourOfDay = _hourOfDay < 235 ? _hourOfDay / 10 : 2;
        uint8 risk = uint8((uint16(_risk) * 100) / 256);

        address user1 = address(0xaa);
        address user2 = address(0x22);

        _maxSize[0] = 1_000_000_000_000;
        _maxSize[1] = 100_000_000;
        _maxSize[2] = 10_000;
        _maxSize[3] = 1;
        _riskLevel[0] = 25;
        _riskLevel[1] = 50;
        _riskLevel[2] = 75;

        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 10_000 * (10 ** 18) - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 100_000_000 * (10 ** 18) - 10_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 1_000_000_000_000 * (10 ** 18) - 100_000_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 1 * (10 ** 18));
        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(user2);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 8, 90_000 * (10 ** 18) - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 9, 900_000_000 * (10 ** 18) - 90_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 10, 9_000_000_000_000 * (10 ** 18) - 900_000_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 11, 1 * (10 ** 18));

        /// we register the rule in the protocol
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addMaxTxSizePerPeriodByRiskRule(address(applicationAppManager), _maxSize, _riskLevel, period, hourOfDay);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(ruleId);

        /// we set a risk score for user1
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, risk);

        /// we start the prank exactly at the time when the rule starts taking effect + 1 full period + 1 second
        uint256 startTestAt = (block.timestamp - (block.timestamp % (1 days))) + ((uint256(hourOfDay) * (1 hours)) + (uint256(period) * (1 hours))) + 1 - 1 days;
        vm.warp(startTestAt);

        /// TEST RULE ON SENDER
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(user1);
        /// first we send only 1 token which shouldn't trigger any risk check
        applicationNFT.safeTransferFrom(user1, user2, 0);
        /// 1
        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskLevel[2]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user1, user2, 1);
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskLevel[1]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user1, user2, 2);
        /// 10_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskLevel[0]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user1, user2, 3);
        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
        /// even if the user's risk profile is 0, this transfer should revert according to how the rule was built
        vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user1, user2, 4);
        /// if passed: 1_000_000_000_000 - 100_000_000 + 100_000_001 = 1_000_000_000_000 + 1 = 1_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        applicationNFT.safeTransferFrom(user1, user2, 5);

        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (9 * (uint256(period) * 1 hours)) / 2);

        /// TEST RULE ON RECIPIENT
        _maxSize[0] = 9_000_000_000_000;
        _maxSize[1] = 900_000_000;
        _maxSize[2] = 90_000;
        _maxSize[3] = 1;
        _riskLevel[0] = 1;
        _riskLevel[1] = 40;
        _riskLevel[2] = 90;

        /// we give some trillions to user1 to spend
        switchToRuleAdmin();
        /// let's deactivate the rule before minting to avoid triggering the rule
        applicationHandler.activateMaxTxSizePerPeriodByRiskRule(false);
        /// we register the rule in the protocol
        ruleId = AppRuleDataFacet(address(ruleStorageDiamond)).addMaxTxSizePerPeriodByRiskRule(address(applicationAppManager), _maxSize, _riskLevel, period, hourOfDay);
        assertEq(ruleId, 1);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setMaxTxSizePerPeriodByRiskRuleId(ruleId);
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(user2);

        /// first we send only 1 token which shouldn't trigger any risk check
        applicationNFT.safeTransferFrom(user2, user1, 6);
        /// 1
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskLevel[2]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user2, user1, 7);
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskLevel[1]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user2, user1, 8);
        /// 90_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskLevel[0]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user2, user1, 9);
        /// 900_000_000 - 90_000 + 90_001 = 900_000_000 + 1 = 900_000_001
        /// even if the user's risk profile is 0, this transfer should revert according to how the rule was built
        vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(user2, user1, 10);
        /// if passed: 9_000_000_000_000 - 900_000_000 + 900_000_001  = 9_000_000_000_000 + 1 = 9_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours));
        applicationNFT.safeTransferFrom(user2, user1, 11);

        /// test burn while rule is active
        vm.stopPrank();
        vm.startPrank(user1);
        if (risk >= _riskLevel[2]) {
            vm.expectRevert();
            applicationNFT.burn(11);
            vm.warp(block.timestamp + (uint256(period) * 2 hours));
            applicationNFT.burn(11);
        }
    }

    function testNFTBalanceLimitByRiskScore(uint32 priceA, uint32 priceB, uint16 priceC, uint8 _riskScore) public {
        vm.assume(priceA > 0 && priceB > 0 && priceC > 0);
        uint8 riskScore = uint8((uint16(_riskScore) * 100) / 254);
        uint8[] memory riskScores = new uint8[](5);
        uint48[] memory balanceLimits = new uint48[](6);
        //address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = address(0xff11);
        address _user2 = address(0xaa22);
        riskScores[0] = 0;
        riskScores[1] = 10;
        riskScores[2] = 40;
        riskScores[3] = 80;
        riskScores[4] = 99;
        balanceLimits[0] = 1_000_000_000;
        balanceLimits[1] = 10_000_000;
        balanceLimits[2] = 100_000;
        balanceLimits[3] = 1_000;
        balanceLimits[4] = 500;
        balanceLimits[5] = 0;

        switchToAppAdministrator();
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, priceA);
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, priceB);
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, priceC);

        switchToRiskAdmin();
        // we apply random risk score to user2
        applicationAppManager.addRiskScore(_user2, riskScore);

        // we find the max balance user2
        uint32 maxBalanceForUser2;
        for (uint i; i < balanceLimits.length - 1; ) {
            if (riskScore < riskScores[i]) maxBalanceForUser2 = uint32(balanceLimits[i]);
            unchecked {
                ++i;
            }
        }

        ///Switch to Default admin and activate AccountBalanceByRiskScore Rule
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
        applicationHandler.setAccountBalanceByRiskRuleId(index);

        vm.stopPrank();
        vm.startPrank(_user1);
        if (priceA >= uint112(maxBalanceForUser2) * (10 ** 18)) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        if (priceA <= uint112(maxBalanceForUser2) * (10 ** 18)) {
            if (uint64(priceA) + uint64(priceB) >= uint112(maxBalanceForUser2) * (10 ** 18)) vm.expectRevert();
            applicationNFT.safeTransferFrom(_user1, _user2, 1);
            if (uint64(priceA) + uint64(priceB) < uint112(maxBalanceForUser2) * (10 ** 18)) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxBalanceForUser2) * (10 ** 18)) vm.expectRevert();
                applicationNFT.safeTransferFrom(_user1, _user2, 2);
            }
        }

        /// test if user can burn NFT with risk score assigned
        /// admin sets NFT price above highest risk limit to ensure burn is unaffected
        switchToAppAdministrator();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 0); // Reseting the default price to $0 to ensure mint is successful
        applicationNFT.safeMint(_user2);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 1_000_000_000_000);
        /// user 2 burns token
        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.burn(3);
    }

    function testWithdrawalLimitByAccessLevelFuzz(uint8 _addressIndex, uint8 accessLevel) public {
        for (uint i; i < 30; ) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * (10 ** 18)); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * (10 ** 18));
            unchecked {
                ++i;
            }
        }
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        address _user3 = addressList[2];
        address _user4 = addressList[3];
        /// set up a non admin user with tokens
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 0); // a 10-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user3, 1); // an 20-dollar NFT
        assertEq(applicationNFT.balanceOf(_user3), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user4, 4); // a 50-dollar NFT
        assertEq(applicationNFT.balanceOf(_user4), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user4, 19); // a 200-dollar NFT
        assertEq(applicationNFT.balanceOf(_user4), 2);

        /// ensure access level is between 0-4
        if (accessLevel > 4) {
            accessLevel = 4;
        }
        /// create rule params
        uint48[] memory withdrawalLimits = new uint48[](5);
        withdrawalLimits[0] = 0;
        withdrawalLimits[1] = 10;
        withdrawalLimits[2] = 20;
        withdrawalLimits[3] = 50;
        withdrawalLimits[4] = 250;
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelWithdrawalRule(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setWithdrawalLimitByAccessLevelRuleId(index);

        /// assign accessLevels to users
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user1, accessLevel);
        applicationAppManager.addAccessLevel(_user3, accessLevel);
        applicationAppManager.addAccessLevel(_user4, accessLevel);
        /// set token pricing
        switchToAppAdministrator();
        /// ERC20 tokens priced $1 USD
        applicationCoin.transfer(_user1, 1000 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user1), 1000 * (10 ** 18));
        applicationCoin.transfer(_user2, 25 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user2), 25 * (10 ** 18));
        applicationCoin.transfer(_user3, 10 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user3), 10 * (10 ** 18));
        applicationCoin.transfer(_user4, 50 * (10 ** 18));
        assertEq(applicationCoin.balanceOf(_user4), 50 * (10 ** 18));
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * (10 ** 18)); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * (10 ** 18));

        ///perform transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        if (accessLevel < 1) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);

        vm.stopPrank();
        vm.startPrank(_user3);
        if (accessLevel < 2) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user3, _user2, 1);

        vm.stopPrank();
        vm.startPrank(_user4);
        if (accessLevel < 3) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user4, _user2, 4);

        /// transfer erc20 tokens
        vm.stopPrank();
        vm.startPrank(_user4);
        if (accessLevel < 4) vm.expectRevert();
        applicationCoin.transfer(_user2, 50 * (10 ** 18));

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user2, accessLevel);

        /// reduce pricing
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 5 * (10 ** 17)); //setting at $.50
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 5 * (10 ** 17));

        vm.stopPrank();
        vm.startPrank(_user2);
        if (accessLevel < 2) vm.expectRevert();
        applicationCoin.transfer(_user4, 25 * (10 ** 18));
    }

    function testTotalSupplyVolatilityERC721Fuzz(uint8 _addressIndex, uint16 volLimit) public {
        /// test params
        vm.assume(volLimit < 9999 && volLimit > 0);
        if (volLimit < 100) volLimit = 100;
        vm.warp(Blocktime);
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startingTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address rich_user = addressList[0];
        /// mint initial supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }
        applicationNFT.safeTransferFrom(appAdministrator, rich_user, 9);
        /// create and activate rule
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(address(applicationAppManager), volLimit, rulePeriod, startingTime, tokenSupply);
        applicationNFTHandler.setTotalSupplyVolatilityRuleId(_index);

        /// determine the maximum burn/mint amount for inital test
        uint256 maxVol = uint256(volLimit) / 1000;
        console.logUint(maxVol);
        /// make sure that transfer under the threshold works
        switchToAppAdministrator();
        if (maxVol >= 1) {
            for (uint i = 0; i < maxVol - 1; i++) {
                applicationNFT.safeMint(rich_user);
            }
            assertEq(applicationNFT.balanceOf(rich_user), maxVol);
        }
        if (maxVol == 0) {
            vm.expectRevert();
            applicationNFT.safeMint(rich_user);
        }
        if (maxVol == 0) {
            vm.expectRevert();
            applicationNFT.safeMint(rich_user);
        }
        /// at vol limit
        vm.stopPrank();
        vm.startPrank(rich_user);
        if ((10000 / applicationNFT.totalSupply()) > volLimit) {
            vm.expectRevert();
            applicationNFT.burn(9);
        } else {
            applicationNFT.burn(9);
            vm.stopPrank();
            vm.startPrank(appAdministrator);
            applicationNFT.safeMint(rich_user); // token 10
            vm.stopPrank();
            vm.startPrank(rich_user);
            applicationNFT.burn(10);
            vm.stopPrank();
            vm.startPrank(appAdministrator);
            applicationNFT.safeMint(rich_user);
            vm.stopPrank();
            vm.startPrank(rich_user);
            applicationNFT.burn(11);
        }
    }

    function testTheWholeProtocolThroughNFT(uint32 priceA, uint32 priceB, uint16 priceC, uint8 riskScore, bytes32 tag1) public {
        vm.assume(priceA > 0 && priceB > 0 && priceC > 0);
        vm.assume(tag1 != "");
        riskScore = uint8((uint16(riskScore) * 100) / 254);
        address _user1 = address(0xff11);
        address _user2 = address(0xaa22);
        address _user3 = address(0xbb33);
        address _user4 = address(0xee44);

        uint32 maxBalanceForUser2;
        bool reached3;
        ///Add GeneralTag to account
        applicationAppManager.addGeneralTag(_user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user1, "Oscar"));
        applicationAppManager.addGeneralTag(_user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user2, "Oscar"));

        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1);
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, priceA);
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, priceB);
        applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, priceC);
        for (uint i; i < 5; i++) applicationNFT.safeMint(_user1);

        {
            if (priceA % 2 == 0) {
                badBoys.push(_user4);
                oracleRestricted.addToSanctionsList(badBoys);
                switchToRuleAdmin();
                uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
                applicationNFTHandler.setOracleRuleId(_index);
            } else {
                goodBoys.push(_user1);
                goodBoys.push(_user2);
                goodBoys.push(_user3);
                goodBoys.push(address(0xee55));
                oracleAllowed.addToAllowList(goodBoys);
                switchToRuleAdmin();
                uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
                applicationNFTHandler.setOracleRuleId(_index);
            }
            switchToAppAdministrator();
            uint8[] memory riskScores = new uint8[](5);
            uint48[] memory balanceLimits = new uint48[](6);
            riskScores[0] = 0;
            riskScores[1] = 10;
            riskScores[2] = 40;
            riskScores[3] = 80;
            riskScores[4] = 99;
            balanceLimits[0] = 1_000_000_000;
            balanceLimits[1] = 10_000_000;
            balanceLimits[2] = 100_000;
            balanceLimits[3] = 1_000;
            balanceLimits[4] = 500;
            balanceLimits[5] = 0;
            // we find the mas balance user2
            for (uint i; i < balanceLimits.length - 1; ) {
                if (riskScore < riskScores[i]) maxBalanceForUser2 = uint32(balanceLimits[i]);
                unchecked {
                    ++i;
                }
            }
            switchToRuleAdmin();
            uint32 balanceByRiskId = AppRuleDataFacet(address(ruleStorageDiamond)).addAccountBalanceByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
            applicationHandler.setAccountBalanceByRiskRuleId(balanceByRiskId);
        }
        {
            bytes32[] memory accs = new bytes32[](1);
            uint256[] memory min = new uint256[](1);
            uint256[] memory max = new uint256[](1);
            accs[0] = bytes32("Oscar");
            min[0] = uint256(1);
            max[0] = uint256(3);
            uint32 balanceLimitId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
            applicationNFTHandler.setMinMaxBalanceRuleId(balanceLimitId);
        }
        {
            bytes32[] memory accs = new bytes32[](1);
            accs[0] = tag1;
            uint256[] memory holdAmounts = new uint256[](1);
            holdAmounts[0] = 2;
            uint16[] memory holdPeriods = new uint16[](1);
            holdPeriods[0] = uint16(720); // one month
            uint64[] memory holdTimestamps = new uint64[](1);
            holdTimestamps[0] = Blocktime;
            switchToAppAdministrator();
            applicationAppManager.addGeneralTag(_user1, tag1); ///add tag
            switchToRuleAdmin();
            uint32 balanceByDateId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, holdTimestamps);
            /// Set rule
            applicationNFTHandler.setMinBalByDateRuleId(balanceByDateId);
        }
        {
            bytes32[] memory nftTags = new bytes32[](1);
            nftTags[0] = bytes32("BoredGrape");
            uint8[] memory tradesAllowed = new uint8[](1);
            tradesAllowed[0] = 3;
            uint32 tradeRuleId = RuleDataFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            switchToAppAdministrator();
            applicationAppManager.addGeneralTag(address(applicationNFT), "BoredGrape"); ///add tag
            switchToRuleAdmin();
            applicationNFTHandler.setTradeCounterRuleId(tradeRuleId);
        }
        {
            uint48[] memory _maxSize = new uint48[](6);
            uint8[] memory _riskLevel = new uint8[](5);

            _maxSize[0] = 750_000_000;
            _maxSize[1] = 7_500_000;
            _maxSize[2] = 75_000;
            _maxSize[3] = 750;
            _maxSize[4] = 350;
            _maxSize[5] = 0;
            _riskLevel[0] = 0;
            _riskLevel[1] = 10;
            _riskLevel[2] = 40;
            _riskLevel[3] = 80;
            _riskLevel[4] = 99;

            ///Register rule with ERC721Handler
            uint32 maxTxPerRiskId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addTransactionLimitByRiskScore(address(applicationAppManager), _riskLevel, _maxSize);
            applicationNFTHandler.setTransactionLimitByRiskRuleId(maxTxPerRiskId);
        }

        switchToRiskAdmin();
        // we apply random risk score to user2
        applicationAppManager.addRiskScore(_user2, riskScore);

        vm.stopPrank();
        vm.startPrank(_user1);
        /// test oracle rule
        vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user4, 7);

        /// test risk rules
        if (priceA > (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4 || priceA > uint112(maxBalanceForUser2) * (10 ** 18)) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);

        if (priceA <= (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4 && priceA <= uint112(maxBalanceForUser2) * (10 ** 18)) {
            if (uint64(priceA) + uint64(priceB) > uint112(maxBalanceForUser2) * (10 ** 18) || priceB > (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4) vm.expectRevert();
            applicationNFT.safeTransferFrom(_user1, _user2, 1);

            if (uint64(priceA) + uint64(priceB) <= uint112(maxBalanceForUser2) * (10 ** 18) && priceB <= (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxBalanceForUser2) * (10 ** 18) || priceC > (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4) vm.expectRevert();
                applicationNFT.safeTransferFrom(_user1, _user2, 2);

                if (uint64(priceA) + uint64(priceB) + uint64(priceC) <= uint112(maxBalanceForUser2) * (10 ** 18) && priceC <= (uint112(maxBalanceForUser2) * 3 * (10 ** 18)) / 4) {
                    /// balanceLimit rule should fail since _user2 now would have 4
                    vm.expectRevert(0x24691f6b);
                    applicationNFT.safeTransferFrom(_user1, _user2, 3);
                    /// now let's warp a day to make sure this won't be a problem
                    vm.warp(Blocktime + 40 hours);
                    for (uint i = 3; i < 6; i++) {
                        applicationNFT.safeTransferFrom(_user1, _user3, i);
                    }
                    reached3 = true;
                    /// balance by date test
                    vm.expectRevert(0xa7fb7b4b);
                    applicationNFT.safeTransferFrom(_user1, _user3, 6); /// Fails because User1 cannot have balanceOf less than 2
                    /// warp to allow user 1 to transfer NFT 6
                    vm.warp(Blocktime + 725 hours);
                    applicationNFT.safeTransferFrom(_user1, _user3, 6);
                    /// balanceLimit rule should fail since _user1 now would have 0
                    vm.expectRevert(0xf1737570);
                    applicationNFT.safeTransferFrom(_user1, _user3, 7);

                    /// let's give back the NFTs to _user1
                    /// we update the min max balance rule so it's not a problem testing our AccessLevel
                    bytes32[] memory accs1 = new bytes32[](1);
                    uint256[] memory min1 = new uint256[](1);
                    uint256[] memory max1 = new uint256[](1);
                    accs1[0] = bytes32("Oscar");
                    min1[0] = uint256(1);
                    max1[0] = uint256(5);
                    switchToRuleAdmin();
                    uint32 balanceLimitId1 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs1, min1, max1);
                    applicationNFTHandler.setMinMaxBalanceRuleId(balanceLimitId1);
                    assertEq(balanceLimitId1, 1);
                    console.log("balanceLimitId", balanceLimitId1);
                    vm.stopPrank();
                    vm.startPrank(_user3);

                    applicationNFT.safeTransferFrom(_user3, _user1, 3);
                    applicationNFT.safeTransferFrom(_user3, _user2, 4);
                    // for(uint i=3;i < 7;i++){

                    // }
                    vm.stopPrank();
                    vm.startPrank(_user2);
                    applicationNFT.safeTransferFrom(_user2, _user1, 2);
                }
                bytes32[] memory accs2 = new bytes32[](1);
                uint256[] memory min2 = new uint256[](1);
                uint256[] memory max2 = new uint256[](1);
                accs2[0] = bytes32("Oscar");
                min2[0] = uint256(1);
                max2[0] = uint256(8);
                switchToRuleAdmin();
                uint32 balanceLimitId2 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs2, min2, max2);
                applicationNFTHandler.setMinMaxBalanceRuleId(balanceLimitId2);
                vm.stopPrank();
                vm.startPrank(_user2);
                applicationNFT.safeTransferFrom(_user2, _user1, 1);
            }
            bytes32[] memory accs3 = new bytes32[](1);
            uint256[] memory min3 = new uint256[](1);
            uint256[] memory max3 = new uint256[](1);
            accs3[0] = bytes32("Oscar");
            min3[0] = uint256(1);
            max3[0] = uint256(8);
            switchToRuleAdmin();
            uint32 balanceLimitId3 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs3, min3, max3);
            applicationNFTHandler.setMinMaxBalanceRuleId(balanceLimitId3);
            vm.stopPrank();
            vm.startPrank(_user2);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }
        {
            bytes32[] memory accs4 = new bytes32[](1);
            uint256[] memory min4 = new uint256[](1);
            uint256[] memory max4 = new uint256[](1);
            accs4[0] = bytes32("Oscar");
            min4[0] = uint256(1);
            max4[0] = uint256(8);
            switchToRuleAdmin();
            uint32 balanceLimitId4 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs4, min4, max4);
            applicationNFTHandler.setMinMaxBalanceRuleId(balanceLimitId4);
        }
        {
            /// now let's try to give it to _user3, but this time it should fail since this would be more
            /// than 3 trades in less than 24 hrs
            vm.stopPrank();
            vm.startPrank(_user1);
            applicationNFT.safeTransferFrom(_user1, _user3, 3);

            vm.stopPrank();
            vm.startPrank(_user3);
            applicationNFT.safeTransferFrom(_user3, _user1, 3);

            vm.stopPrank();
            vm.startPrank(_user1);
            if (reached3) {
                vm.expectRevert(0x00b223e3);
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
                vm.warp(Blocktime + 1725 hours);
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
            } else {
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
                vm.stopPrank();
                vm.startPrank(_user3);
                vm.expectRevert(0x00b223e3);
                applicationNFT.safeTransferFrom(_user3, _user1, 3);
                vm.warp(Blocktime + 1725 hours);
                applicationNFT.safeTransferFrom(_user3, _user1, 3);
            }

            uint8 accessLevel = riskScore % 5;
            switchToAccessLevelAdmin();
            _user2 = address(0xee55);
            applicationAppManager.addAccessLevel(_user2, accessLevel);
            // add the rule.
            uint48[] memory balanceAmounts = new uint48[](5);
            balanceAmounts[0] = 0;
            balanceAmounts[1] = 500;
            balanceAmounts[2] = 10_000;
            balanceAmounts[3] = 800_000;
            balanceAmounts[4] = 200_000_000;
            {
                switchToRuleAdmin();
                uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
                /// connect the rule to this handler
                applicationHandler.setAccountBalanceByAccessLevelRuleId(_index);
            }
            {
                /// test access level rules
                vm.stopPrank();
                vm.startPrank(_user1);
                if (priceA > uint(balanceAmounts[accessLevel]) * (10 ** 18)) vm.expectRevert();
                applicationNFT.safeTransferFrom(_user1, _user2, 0);

                if (priceA <= uint120(balanceAmounts[accessLevel]) * (10 ** 18)) {
                    if (uint64(priceA) + uint64(priceB) > uint120(balanceAmounts[accessLevel]) * (10 ** 18)) vm.expectRevert();
                    applicationNFT.safeTransferFrom(_user1, _user2, 1);

                    if (uint64(priceA) + uint64(priceB) <= uint112(balanceAmounts[accessLevel]) * (10 ** 18)) {
                        if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(balanceAmounts[accessLevel]) * (10 ** 18)) vm.expectRevert();
                        applicationNFT.safeTransferFrom(_user1, _user2, 2);

                        if (uint(priceA) + uint(priceB) + uint(priceC) <= uint112(balanceAmounts[accessLevel]) * (10 ** 18)) {
                            /// balanceLimit rule should fail since _user2 now would have 4
                        }
                    }
                }
            }
        }
    }

    function testAdminWithdrawalFuzz(uint32 daysForward, uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address user1 = addressList[2];
        /// Mint TokenId 0-6 to default admin
        for (uint i; i < 7; i++) applicationNFT.safeMint(appAdministrator);
        /// we create a rule that sets the minimum amount to 5 tokens to be tranferable in 1 year
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);
        /// Set the rule in the handler
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(address(applicationAppManager), 5, block.timestamp + 365 days);
        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTHandler.activateAdminWithdrawalRule(false);
        vm.expectRevert();
        applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        switchToAppAdministrator();
        /// These transfers should pass
        applicationNFT.safeTransferFrom(appAdministrator, user1, 0);
        applicationNFT.safeTransferFrom(appAdministrator, user1, 1);
        /// This one fails
        vm.expectRevert();
        applicationNFT.safeTransferFrom(appAdministrator, user1, 2);

        vm.warp(Blocktime + daysForward);
        if (daysForward < 365 days) vm.expectRevert();
        applicationNFT.safeTransferFrom(appAdministrator, user1, 2);
        switchToRuleAdmin();
        if (daysForward >= 365 days) {
            applicationNFTHandler.activateAdminWithdrawalRule(false);
            applicationNFTHandler.setAdminWithdrawalRuleId(_index);
        }
    }

    /// test the token transfer volume rule in erc721
    function testTokenTransferVolumeRuleFuzzNFT(uint8 _addressIndex, uint8 _period, uint16 _maxPercent) public {
        if (_period == 0) _period = 1;
        //since NFT's take so long to mint, don't test for below 10% because the test pool will only be 10 NFT's
        if (_maxPercent < 100) _maxPercent = 100;
        if (_maxPercent > 9999) _maxPercent = 9999;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address rich_user = addressList[0];
        address _user1 = addressList[1];
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(applicationAppManager), _maxPercent, _period, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, _maxPercent);
        assertEq(rule.period, _period);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        /// load non admin users with nft's
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(rich_user);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTHandler.setTokenTransferVolumeRuleId(_index);
        /// determine the maximum transfer amount
        uint256 maxSize = uint256(_maxPercent) / 1000;
        console.logUint(maxSize);
        vm.stopPrank();
        vm.startPrank(rich_user);
        /// make sure that transfer under the threshold works
        if (maxSize > 1) {
            for (uint i = 0; i < maxSize - 1; i++) {
                applicationNFT.safeTransferFrom(rich_user, _user1, i);
            }
            assertEq(applicationNFT.balanceOf(_user1), maxSize - 1);
        }
        /// Now break the rule
        if (maxSize == 0) {
            vm.expectRevert(0x3627495d);
            applicationNFT.safeTransferFrom(rich_user, _user1, 0);
        } else {
            /// account for decimal percentages
            if (uint256(_maxPercent) % 1000 == 0) {
                vm.expectRevert(0x3627495d);
                applicationNFT.safeTransferFrom(rich_user, _user1, maxSize - 1);
            } else {
                applicationNFT.safeTransferFrom(rich_user, _user1, maxSize - 1);
                vm.expectRevert(0x3627495d);
                applicationNFT.safeTransferFrom(rich_user, _user1, maxSize);
            }
        }
    }

    /// test the minimum hold time rule in erc721
    function testNFTMinimumHoldTimeFuzz(uint8 _addressIndex, uint32 _hours) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        switchToRuleAdmin();
        // hold time range must be between 1 hour and 5 years
        if (_hours == 0 || _hours > 43830) {
            vm.expectRevert();
            applicationNFTHandler.setMinimumHoldTimeHours(_hours);
        } else {
            /// set the rule for x hours
            applicationNFTHandler.setMinimumHoldTimeHours(_hours);
            assertEq(applicationNFTHandler.getMinimumHoldTimeHours(), _hours);
            // mint 1 nft to non admin user(this should set their ownership start time)
            switchToAppAdministrator();
            applicationNFT.safeMint(_user1);
            vm.stopPrank();
            vm.startPrank(_user1);
            // transfer should fail
            vm.expectRevert(0x6d12e45a);
            applicationNFT.safeTransferFrom(_user1, _user2, 0);
            // move forward in time x hours and it should pass
            Blocktime = Blocktime + (_hours * 1 hours);
            vm.warp(Blocktime);
            applicationNFT.safeTransferFrom(_user1, _user2, 0);
            // the original owner was able to transfer but the new owner should not be able to because the time resets
            vm.stopPrank();
            vm.startPrank(_user2);
            vm.expectRevert(0x6d12e45a);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
            // move forward in time x hours and it should pass
            Blocktime = Blocktime + (_hours * 1 hours);
            vm.warp(Blocktime);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }
    }
}

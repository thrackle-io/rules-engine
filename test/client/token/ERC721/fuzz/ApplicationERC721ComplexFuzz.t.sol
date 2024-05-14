// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

contract ApplicationERC721ComplexFuzzTest is TestCommonFoundry, ERC721Util {
    event Log(string eventString, bytes32[] tag);

    uint8[] riskScoresRuleA = createUint8Array(20, 40, 60, 80, 99);
    uint48[] maxBalancesRiskRule = createUint48Array(70, 50, 40, 30, 20);
    uint8[] riskScoresRuleB = createUint8Array(25, 50, 75);
    uint48[] maxSizeRiskRule = createUint48Array(100_000_000, 10_000, 1);

    function setUp() public endWithStopPrank {
        vm.warp(Blocktime);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, type(uint256).max);
    }

    function testERC721_ApplicationERC721Fuzz_AccountMinMaxTokenBalanceRule_Complex(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address randomUser = addressList[0];
        address richGuy = addressList[1];
        address _user1 = addressList[2];
        address _user2 = addressList[3];
        address _user3 = addressList[4];
        /// mint 6 NFTs to appAdministrator for transfer
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);
        applicationNFT.safeMint(randomUser);

        /// set up a non admin user with tokens
        vm.stopPrank();
        vm.startPrank(randomUser);
        ///transfer tokenId 1 and 2 to richGuy
        applicationNFT.transferFrom(randomUser, richGuy, 0);
        applicationNFT.transferFrom(randomUser, richGuy, 1);
        assertEq(applicationNFT.balanceOf(richGuy), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(randomUser, _user1, 3);
        applicationNFT.transferFrom(randomUser, _user1, 4);
        assertEq(applicationNFT.balanceOf(_user1), 2);

        ///Add Tag to account
        switchToAppAdministrator();
        applicationAppManager.addTag(_user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user1, "Oscar"));
        applicationAppManager.addTag(_user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user2, "Oscar"));
        applicationAppManager.addTag(_user3, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user3, "Oscar"));
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 3);
        assertEq(applicationNFT.balanceOf(_user2), 1);
        assertEq(applicationNFT.balanceOf(_user1), 1);
        switchToRuleAdmin();
        /// Apply Rule
        uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(6));
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(0x3e237976);
        applicationNFT.transferFrom(_user1, _user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        switchToAppAdministrator();
        // user1 mints to 6 total (limit)
        applicationNFT.safeMint(_user1); /// Id 6
        applicationNFT.safeMint(_user1); /// Id 7
        applicationNFT.safeMint(_user1); /// Id 8
        applicationNFT.safeMint(_user1); /// Id 9
        applicationNFT.safeMint(_user1); /// Id 10

        applicationNFT.safeMint(_user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(_user2);
        vm.expectRevert(0x1da56a44);
        applicationNFT.transferFrom(_user2, _user1, 3);
    }

    function testERC721_ApplicationERC721Fuzz_AccountApproveDenyOracle_Complex(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address randomUser = addressList[0];
        address richGuy = addressList[1];
        address _user1 = addressList[2];
        address _user2 = addressList[3];
        address _user3 = addressList[4];
        /// set up a non admin user an nft
        applicationNFT.safeMint(_user1);
        applicationNFT.safeMint(_user1);
        applicationNFT.safeMint(_user1);
        applicationNFT.safeMint(_user1);
        applicationNFT.safeMint(_user1);

        assertEq(applicationNFT.balanceOf(_user1), 5);

        switchToAppAdministrator();
        // add a blacklist address
        badBoys.push(_user3);
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 0);
        assertEq(applicationNFT.balanceOf(_user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationNFT.transferFrom(_user1, _user3, 1);
        assertEq(applicationNFT.balanceOf(_user3), 0);
        // check the allowed list type
        ruleId = createAccountApproveDenyOracleRule(1);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(randomUser);
        oracleApproved.addToApprovedList(goodBoys);
        vm.stopPrank();
        vm.startPrank(_user1);
        // This one should pass
        applicationNFT.transferFrom(_user1, randomUser, 2);
        // This one should fail
        vm.expectRevert(0xcafd3316);
        applicationNFT.transferFrom(_user1, richGuy, 3);

        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    /**
     * @dev Test the TokenMaxDailyTrades rule
     */
    function testERC721_ApplicationERC721Fuzz_TokenMaxDailyTrades_Complex(uint8 _addressIndex) public endWithStopPrank {
        switchToAppAdministrator();
        (address _user1, address _user2) = _get2RandomAddresses(_addressIndex);
        /// set up a non admin user an nft
        applicationNFT.safeMint(_user1); // tokenId = 0
        applicationNFT.safeMint(_user1); // tokenId = 1
        applicationNFT.safeMint(_user1); // tokenId = 2
        applicationNFT.safeMint(_user1); // tokenId = 3
        applicationNFT.safeMint(_user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(_user1), 5);

        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag
        // apply the rule to the ApplicationERC721Handler
        uint32 ruleId = createTokenMaxDailyTradesRule("BoredGrape", "DiscoPunk", 1, 5);
        setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 0);
        assertEq(applicationNFT.balanceOf(_user2), 1);
        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.transferFrom(_user2, _user1, 0);
        assertEq(applicationNFT.balanceOf(_user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(applicationNFT), "DiscoPunk"); ///add tag
        applicationAppManager.addTag(address(applicationNFT), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(_user1);
        applicationNFT.transferFrom(_user1, _user2, 1);
        assertEq(applicationNFT.balanceOf(_user2), 1);
        vm.stopPrank();
        vm.startPrank(_user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        applicationNFT.transferFrom(_user2, _user1, 1);
        assertEq(applicationNFT.balanceOf(_user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFT.transferFrom(_user2, _user1, 1);
        assertEq(applicationNFT.balanceOf(_user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(_user1);
        // first one should pass
        applicationNFT.transferFrom(_user1, _user2, 2);
        vm.stopPrank();
        vm.startPrank(_user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x09a92f2d);
        applicationNFT.transferFrom(_user2, _user1, 2);
    }

    function testERC721_ApplicationERC721Fuzz_AccountMaxTransactionValueByRiskScoreRuleNFT_Complex(uint8 _addressIndex, uint8 _risk) public endWithStopPrank {
        switchToAppAdministrator();
        for (uint i; i < 30; ++i) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * ATTO); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * ATTO);
        }
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);
        uint8[] memory riskScores = createUint8Array(20, 40, 60, 80, 99);
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

        uint8 risk = _parameterizeRisk(_risk);
        ///Create rule

        uint32 ruleId = createAccountMaxTxValueByRiskRule(createUint8Array(20, 40, 60, 80, 99), createUint48Array(70, 50, 40, 30, 20));
        setAccountMaxTxValueByRiskRule(ruleId);
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

        if (risk >= riskScores[4]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 20000000000000000000));
        }
        applicationNFT.safeTransferFrom(_user1, _user2, 2); // a 30-dollar NFT

        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.safeTransferFrom(_user2, _user1, 0); // a 10-dollar NFT

        if (risk >= riskScores[4]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 20000000000000000000));
        } else if (risk >= riskScores[3]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 30000000000000000000));
        } else if (risk >= riskScores[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 40000000000000000000));
        } else if (risk >= riskScores[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 50000000000000000000));
        }
        applicationNFT.safeTransferFrom(_user2, _user1, 5); // a 60-dollar NFT

        vm.stopPrank();
        vm.startPrank(_user3);
        if (risk >= riskScores[4]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 20000000000000000000));
        } else if (risk >= riskScores[3]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 30000000000000000000));
        } else if (risk >= riskScores[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 40000000000000000000));
        } else if (risk >= riskScores[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 50000000000000000000));
        } else if (risk >= riskScores[0]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 70000000000000000000));
        }
        applicationNFT.safeTransferFrom(_user3, _user4, 19); // a 200-dollar NFT
    }

    function testERC721_ApplicationERC721Fuzz_AccountMaxValueByAccessLevel(uint8 _addressIndex, uint8 _amountSeed) public endWithStopPrank {
        switchToAppAdministrator();
        for (uint i; i < 30; ++i) {
            applicationNFT.safeMint(treasuryAccount);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * ATTO); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * ATTO);
        }
        applicationCoin.transfer(treasuryAccount, type(uint256).max);
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);
        /// set up a non admin user with tokens
        switchToTreasuryAccount();
        applicationNFT.safeTransferFrom(treasuryAccount, _user1, 0); // a 10-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 1);
        applicationNFT.safeTransferFrom(treasuryAccount, _user3, 19); // an 200-dollar NFT
        assertEq(applicationNFT.balanceOf(_user3), 1);
        // we make sure that _amountSeed is between 10 and 255
        if (_amountSeed < 245) _amountSeed += 10;
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = uint48(_amountSeed) + 50;
        uint48 accessBalance3 = uint48(_amountSeed) + 100;
        uint48 accessBalance4 = uint48(_amountSeed) + 200;
        // add the rule.
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
        setAccountMaxValueByAccessLevelRule(ruleId);
        switchToTreasuryAccount();
        ///perform transfer that checks rule when account does not have AccessLevel fails
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        vm.stopPrank();
        vm.startPrank(_user2);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        applicationNFT.safeTransferFrom(_user2, _user4, 0);
        vm.stopPrank();
        vm.startPrank(_user4);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        applicationNFT.safeTransferFrom(_user4, _user1, 0);
        /// this should revert
        vm.stopPrank();
        vm.startPrank(_user3);
        vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user3, _user4, 19);

        /// Add access level to _user3
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user3, 3);
        applicationAppManager.addAccessLevel(_user1, 1);

        /// if NFTs are woth more than accessBalance3, it should fail
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        if (accessBalance3 < 210) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user1, _user3, 0);
        if (accessBalance3 >= 210) {
            vm.stopPrank();
            vm.startPrank(_user3);
            applicationNFT.safeTransferFrom(_user3, _user1, 0);
        }

        /// let's give user2 a 100-dollar NFT
        switchToTreasuryAccount();
        applicationNFT.safeTransferFrom(treasuryAccount, _user2, 9); // a 100-dollar NFT
        assertEq(applicationNFT.balanceOf(_user2), 1);
        /// now let's assign him access=2 and let's check the rule again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user2, 2);
        vm.stopPrank();
        vm.startPrank(_user1);
        /// this one is over the limit and should fail
        if (accessBalance2 < 110) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        if (accessBalance2 >= 110) {
            vm.stopPrank();
            vm.startPrank(_user2);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }

        /// create erc20 token, mint, and transfer to user
        switchToTreasuryAccount();
        applicationCoin.transfer(_user1, type(uint256).max);
        assertEq(applicationCoin.balanceOf(_user1), type(uint256).max);
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * ATTO);
        // set the access level for the user4
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user4, 4);

        /// let's give user1 a 150-dollar NFT
        switchToTreasuryAccount();
        applicationNFT.safeTransferFrom(treasuryAccount, _user1, 14); // a 150-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 2);

        vm.stopPrank();
        vm.startPrank(_user1);
        /// let's send 150-dollar worth of dracs to user4. If accessBalance4 allows less than
        /// 300 (150 in NFTs and 150 in erc20s) it should fail when trying to send NFT
        applicationCoin.transfer(_user4, 150 * ATTO);
        if (accessBalance4 < 300) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user1, _user4, 14);
        if (accessBalance3 >= 300) assertEq(applicationCoin.balanceOf(_user4), 150 * ATTO);
        bytes4 erc20Id = type(IERC20).interfaceId;
        console.log(uint32(erc20Id));
        console.log(applicationCoin.supportsInterface(0x36372b07));
    }

    function testERC721_ApplicationERC721Fuzz_NFTValuationLimit_Complex(uint8 _addressIndex, uint8 _amountToMint) public endWithStopPrank {
        switchToAppAdministrator();
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);

        // we make sure that _amountToMint is between 10 and 255
        if (_amountToMint < 245) _amountToMint += 10;
        uint8 mintAmount = _amountToMint;
        /// mint and load user 1 with 10-255 NFTs
        for (uint i; i < mintAmount; ++i) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * ATTO); //setting at $1
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), 1 * ATTO);
            applicationNFT.transferFrom(appAdministrator, _user1, i);
        }

        switchToAppAdministrator();
        /// set the nftHandler nftValuationLimit variable
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(20);
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 300);
        setAccountMaxValueByAccessLevelRule(ruleId);
        switchToAppAdministrator();
        /// set 2 tokens above the $1 USD amount of other tokens (tokens 0-9 will always be minted)
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 50 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 25 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * ATTO);
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
                vm.expectRevert(0xaee8b993);
                applicationNFT.transferFrom(_user2, _user1, 9);
            }
        }

        vm.stopPrank();
        vm.startPrank(_user1);
        /// check token valuation works with increased value tokens
        vm.expectRevert(0xaee8b993);
        applicationNFT.transferFrom(_user1, _user3, 2);
        applicationNFT.transferFrom(_user1, _user4, 2);
    }

    /// Test Account Max Value By Access Level Rule
    function testERC721_ApplicationERC721Fuzz_AccountMaxValueByAccessLevel_Complex(uint8 _addressIndex, uint16 _valuationLimit) public endWithStopPrank {
        switchToAppAdministrator();
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);

        /// mint and load user 1 with 50 NFTs
        for (uint i; i < 50; ++i) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, 1 * ATTO); //setting at $1
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), 1 * ATTO);
            applicationNFT.transferFrom(appAdministrator, _user1, i);
        }

        switchToAppAdministrator();
        /// set the nftHandler nftValuationLimit variable
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(_valuationLimit);
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, 10, 50, 100, 300);
        setAccountMaxValueByAccessLevelRule(ruleId);
        switchToAppAdministrator();
        /// set 2 tokens above the $1 USD amount of other tokens (tokens 0-9 will always be minted)
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 50 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 25 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 1 * ATTO);
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
                vm.expectRevert(0xaee8b993);
                applicationNFT.transferFrom(_user2, _user1, 9);
            }
        }
    }

    function testERC721_ApplicationERC721Fuzz_AccountMinMaxTokenBalance_Complex(uint8 _addressIndex, bytes32 tag1, bytes32 tag2, bytes32 tag3) public endWithStopPrank {
        switchToAppAdministrator();
        /// Set up test variables
        vm.assume(tag1 != "" && tag2 != "" && tag3 != "");
        vm.assume(tag1 != tag2 && tag1 != tag3 && tag2 != tag3);

        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);

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
        bytes32[] memory accs = createBytes32Array(tag1, tag2, tag3);
        uint256[] memory minAmounts = createUint256Array(1, 2, 3);
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);

        uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
        setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        /// Tag accounts
        applicationAppManager.addTag(_user1, tag1); ///add tag
        applicationAppManager.addTag(_user2, tag2); ///add tag
        applicationAppManager.addTag(_user3, tag3); ///add tag
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

    function testERC721_ApplicationERC721Fuzz_AccountMaxTransactionValueByRiskScoreRuleNFT2_Complex(uint8 _risk, uint8 _period) public endWithStopPrank {
        switchToAppAdministrator();
        vm.warp(Blocktime);
        /// we create the rule
        uint48[] memory _maxSize = createUint48Array(100_000_000, 10_000, 1);
        uint8[] memory _riskScore = createUint8Array(25, 50, 75);
        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
        uint8 risk = _parameterizeRisk(_risk);
        address _user1 = address(0xaa);
        address _user2 = address(0x22);
        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, 1 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 10_000 * ATTO - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 100_000_000 * ATTO - 10_000 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 1_000_000_000_000 * ATTO - 100_000_000 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 1 * ATTO);
        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(_user2);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 1 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 1 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 8, 90_000 * ATTO - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 9, 900_000_000 * ATTO - 90_000 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 10, 9_000_000_000_000 * ATTO - 900_000_000 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 11, 1 * ATTO);

        uint32 ruleId = createAccountMaxTxValueByRiskRule(_riskScore, createUint48Array(100_000_000, 10_000, 1), period);
        setAccountMaxTxValueByRiskRule(ruleId);
        /// we set a risk score for user1
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(_user1, risk);

        /// we start the prank exactly at the time when the rule starts taking effect + 1 full period + 1 minute
        uint256 startTestAt = (block.timestamp + (uint256(period) * (1 hours)) + 1 minutes);
        vm.warp(startTestAt);

        /// TEST RULE ON SENDER
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        /// first we send only 1 token which shouldn't trigger any risk check
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        /// 1
        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        /// now, if the user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 1);
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 10000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 2);
        /// 10_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 10000000000000000000000));
        } else if (risk >= _riskScore[0]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 100000000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 3);
        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 10000000000000000000000));
        } else if (risk >= _riskScore[0]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 100000000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 4);
        /// if passed: 1_000_000_000_000 - 100_000_000 + 100_000_001 = 1_000_000_000_000 + 1 = 1_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours) / 2);
        applicationNFT.safeTransferFrom(_user1, _user2, 5);

        /// let's go to the future in the middle of the period
        vm.warp(block.timestamp + (9 * (uint256(period) * 1 hours)) / 2);

        /// TEST RULE ON RECIPIENT
        _maxSize[0] = 900_000_000;
        _maxSize[1] = 90_000;
        _maxSize[2] = 1;
        _riskScore[0] = 1;
        _riskScore[1] = 40;
        _riskScore[2] = 90;

        /// we give some trillions to _user1 to spend
        switchToRuleAdmin();
        /// let's deactivate the rule before minting to avoid triggering the rule
        applicationHandler.activateAccountMaxTxValueByRiskScore(createActionTypeArrayAll(), false);

        ruleId = createAccountMaxTxValueByRiskRule(createUint8Array(1, 40, 90), createUint48Array(900_000_000, 90_000, 1), period);
        setAccountMaxTxValueByRiskRule(ruleId);
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(_user2);

        /// first we send only 1 token which shouldn't trigger any risk check
        applicationNFT.safeTransferFrom(_user2, _user1, 6);
        /// 1
        /// now, if the _user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 7);
        /// 2
        /// if the _user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 90000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 8);
        /// 90_001
        /// if the _user's risk profile is in the lowest range, this transfer should revert
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 90000000000000000000000));
        } else if (risk >= _riskScore[0]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 900000000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 9);
        /// 900_000_000 - 90_000 + 90_001 = 900_000_000 + 1 = 900_000_001
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
        } else if (risk >= _riskScore[1]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 90000000000000000000000));
        } else if (risk >= _riskScore[0]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 900000000000000000000000000));
        }
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 10);
        /// if passed: 9_000_000_000_000 - 900_000_000 + 900_000_001  = 9_000_000_000_000 + 1 = 9_000_000_000_001

        /// we jump to the next period and make sure it still works.
        vm.warp(block.timestamp + (uint256(period) * 1 hours));
        applicationNFT.safeTransferFrom(_user2, _user1, 11);

        /// test burn while rule is active
        vm.stopPrank();
        vm.startPrank(_user1);
        if (risk >= _riskScore[2]) {
            bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
            vm.expectRevert(abi.encodeWithSelector(selector, risk, 1000000000000000000));
            applicationNFT.burn(11);
            vm.warp(block.timestamp + (uint256(period) * 2 hours));
            applicationNFT.burn(11);
        }
    }

    function testERC721_ApplicationERC721Fuzz_AccountMaxValueByRiskScoreNFT_Complex(uint32 priceA, uint32 priceB, uint16 priceC, uint8 _riskScore) public endWithStopPrank {
        vm.assume(priceA > 0 && priceB > 0 && priceC > 0);
        uint8 riskScore = uint8((uint16(_riskScore) * 100) / 254);
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80, 99);
        uint48[] memory balanceLimits = createUint48Array(10_000_000, 100_000, 1_000, 500, 10);
        //address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 4);
        address _user1 = address(0xff11);
        address _user2 = address(0xaa22);
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
        uint32 maxValueForUser2;
        for (uint i; i < balanceLimits.length - 1; ++i) {
            if (riskScore < riskScores[i]) {
                maxValueForUser2 = uint32(balanceLimits[i]);
            } else {
                maxValueForUser2 = uint32(balanceLimits[3]);
            }
        }

        uint32 ruleId = createAccountMaxValueByRiskRule(riskScores, createUint48Array(10_000_000, 100_000, 1_000, 500, 10));
        setAccountMaxValueByRiskRule(ruleId);
        vm.stopPrank();
        vm.startPrank(_user1);
        if (priceA >= uint112(maxValueForUser2) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxAccValueByRiskScore()"));
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        if (priceA <= uint112(maxValueForUser2) * ATTO) {
            if (uint64(priceA) + uint64(priceB) >= uint112(maxValueForUser2) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxAccValueByRiskScore()"));
            applicationNFT.safeTransferFrom(_user1, _user2, 1);
            if (uint64(priceA) + uint64(priceB) < uint112(maxValueForUser2) * ATTO) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxValueForUser2) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxAccValueByRiskScore()"));
                applicationNFT.safeTransferFrom(_user1, _user2, 2);
            }
        }

        /// test if user can burn NFT with risk score assigned
        /// admin sets NFT price above highest risk limit to ensure burn is unaffected
        switchToAppAdministrator();
        erc721Pricer.setNFTCollectionPrice(address(applicationNFT), 0); // Resetting the default price to $0 to ensure mint is successful
        applicationNFT.safeMint(_user2);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 1_000_000_000_000);
        /// user 2 burns token
        vm.stopPrank();
        vm.startPrank(_user2);
        applicationNFT.burn(3);
    }

    function testERC721_ApplicationERC721Fuzz_AccountMaxValueOutByAccessLevel(uint8 _addressIndex, uint8 accessLevel) public endWithStopPrank {
        switchToAppAdministrator();
        for (uint i; i < 30; ++i) {
            applicationNFT.safeMint(appAdministrator);
            erc721Pricer.setSingleNFTPrice(address(applicationNFT), i, (i + 1) * 10 * ATTO); //setting at $10 * (ID + 1)
            assertEq(erc721Pricer.getNFTPrice(address(applicationNFT), i), (i + 1) * 10 * ATTO);
        }
        (address _user1, address _user2, address _user3, address _user4) = _get4RandomAddresses(_addressIndex);
        /// set up a non admin user with tokens
        applicationNFT.safeTransferFrom(appAdministrator, _user1, 0); // a 10-dollar NFT
        assertEq(applicationNFT.balanceOf(_user1), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user3, 1); // an 20-dollar NFT
        assertEq(applicationNFT.balanceOf(_user3), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user4, 4); // a 50-dollar NFT
        assertEq(applicationNFT.balanceOf(_user4), 1);
        applicationNFT.safeTransferFrom(appAdministrator, _user4, 19); // a 200-dollar NFT
        assertEq(applicationNFT.balanceOf(_user4), 2);

        /// ERC20 tokens priced $1 USD
        applicationCoin.transfer(_user1, 1000 * ATTO);
        assertEq(applicationCoin.balanceOf(_user1), 1000 * ATTO);
        applicationCoin.transfer(_user2, 25 * ATTO);
        assertEq(applicationCoin.balanceOf(_user2), 25 * ATTO);
        applicationCoin.transfer(_user3, 10 * ATTO);
        assertEq(applicationCoin.balanceOf(_user3), 10 * ATTO);
        applicationCoin.transfer(_user4, 50 * ATTO);
        assertEq(applicationCoin.balanceOf(_user4), 50 * ATTO);
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 1 * ATTO); //setting at $1
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 1 * ATTO);

        /// ensure access level is between 0-4
        if (accessLevel > 4) {
            accessLevel = 4;
        }
        /// create rule params
        uint32 ruleId = createAccountMaxValueOutByAccessLevelRule(0, 10, 20, 50, 250);
        setAccountMaxValueOutByAccessLevelRule(ruleId);
        switchToTreasuryAccount();
        /// assign accessLevels to users
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user1, accessLevel);
        applicationAppManager.addAccessLevel(_user3, accessLevel);
        applicationAppManager.addAccessLevel(_user4, accessLevel);
        /// set token pricing

        ///perform transfers
        vm.stopPrank();
        vm.startPrank(_user1);
        if (accessLevel < 1) vm.expectRevert(abi.encodeWithSignature("OverMaxValueOutByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user1, _user2, 0);

        vm.stopPrank();
        vm.startPrank(_user3);
        if (accessLevel < 2) vm.expectRevert(abi.encodeWithSignature("OverMaxValueOutByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user3, _user2, 1);

        vm.stopPrank();
        vm.startPrank(_user4);
        if (accessLevel < 3) vm.expectRevert(abi.encodeWithSignature("OverMaxValueOutByAccessLevel()"));
        applicationNFT.safeTransferFrom(_user4, _user2, 4);

        /// transfer erc20 tokens
        vm.stopPrank();
        vm.startPrank(_user4);
        if (accessLevel < 4) vm.expectRevert(abi.encodeWithSignature("OverMaxValueOutByAccessLevel()"));
        applicationCoin.transfer(_user2, 50 * ATTO);

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(_user2, accessLevel);

        /// reduce pricing
        switchToAppAdministrator();
        erc20Pricer.setSingleTokenPrice(address(applicationCoin), 5 * (10 ** 17)); //setting at $.50
        assertEq(erc20Pricer.getTokenPrice(address(applicationCoin)), 5 * (10 ** 17));

        vm.stopPrank();
        vm.startPrank(_user2);
        if (accessLevel < 2) vm.expectRevert(abi.encodeWithSignature("OverMaxValueOutByAccessLevel()"));
        applicationCoin.transfer(_user4, 25 * ATTO);
    }

    function testERC721_ApplicationERC721Fuzz_TokenMaxSupplyVolatility_Complex(uint8 _addressIndex, uint16 volLimit) public endWithStopPrank {
        switchToAppAdministrator();
        /// test params
        vm.assume(volLimit < 9999 && volLimit > 0);
        if (volLimit < 100) volLimit = 100;
        vm.warp(Blocktime);
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _rich_user = addressList[0];
        /// mint initial supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }
        applicationNFT.safeTransferFrom(appAdministrator, _rich_user, 9);
        /// create and activate rule
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(volLimit, 24, Blocktime, 0);
        setTokenMaxSupplyVolatilityRule(address(applicationNFTHandler), ruleId);
        /// determine the maximum burn/mint amount for inital test
        uint256 maxVol = uint256(volLimit) / 1000;
        console.logUint(maxVol);
        /// make sure that transfer under the threshold works
        switchToAppAdministrator();
        if (maxVol >= 1) {
            for (uint i = 0; i < maxVol - 1; i++) {
                applicationNFT.safeMint(_rich_user);
            }
            assertEq(applicationNFT.balanceOf(_rich_user), maxVol);
        }
        if (maxVol == 0) {
            vm.expectRevert(abi.encodeWithSignature("OverMaxSupplyVolatility()"));
            applicationNFT.safeMint(_rich_user);
        }
        if (maxVol == 0) {
            vm.expectRevert(abi.encodeWithSignature("OverMaxSupplyVolatility()"));
            applicationNFT.safeMint(_rich_user);
        }
        /// at vol limit
        vm.stopPrank();
        vm.startPrank(_rich_user);
        if ((10000 / applicationNFT.totalSupply()) > volLimit) {
            vm.expectRevert(abi.encodeWithSignature("OverMaxSupplyVolatility()"));
            applicationNFT.burn(9);
        } else {
            applicationNFT.burn(9);
            vm.stopPrank();
            switchToAppAdministrator();
            applicationNFT.safeMint(_rich_user); // token 10
            vm.stopPrank();
            vm.startPrank(_rich_user);
            applicationNFT.burn(10);
            vm.stopPrank();
            switchToAppAdministrator();
            applicationNFT.safeMint(_rich_user);
            vm.stopPrank();
            vm.startPrank(_rich_user);
            applicationNFT.burn(11);
        }
    }

    /// Test Whole Protocol with Non Fungible Token
    function testERC721_ApplicationERC721Fuzz_TheWholeProtocolThroughNFT_Complex(uint32 priceA, uint32 priceB, uint16 priceC, uint8 riskScore, bytes32 tag1) public endWithStopPrank {
        switchToAppAdministrator();
        vm.assume(priceA > 0 && priceB > 0 && priceC > 0);
        vm.assume(tag1 != "");
        riskScore = uint8((uint16(riskScore) * 100) / 254);
        address _user1 = address(0xff11);
        address _user2 = address(0xaa22);
        address _user3 = address(0xbb33);
        address _user4 = address(0xee44);

        uint32 maxValueForUser2;
        bool reached3;
        ///Add Tag to account
        applicationAppManager.addTag(_user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(_user1, "Oscar"));
        applicationAppManager.addTag(_user2, "Oscar"); ///add tag
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
                switchToAppAdministrator();
                oracleDenied.addToDeniedList(badBoys);
                switchToRuleAdmin();
                uint32 ruleId = createAccountApproveDenyOracleRule(0);
                setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
            } else {
                goodBoys.push(_user1);
                goodBoys.push(_user2);
                goodBoys.push(_user3);
                goodBoys.push(address(0xee55));
                switchToAppAdministrator();
                oracleApproved.addToApprovedList(goodBoys);
                switchToRuleAdmin();
                uint32 ruleId = createAccountApproveDenyOracleRule(1);
                setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
            }
            switchToAppAdministrator();
            uint8[] memory riskScores = createUint8Array(0, 10, 40, 80, 99);
            uint48[] memory balanceLimits = createUint48Array(10_000_000, 100_000, 1_000, 500, 10);
            // we find the max balance user2
            for (uint i; i < balanceLimits.length - 1; ++i) {
                if (riskScore < riskScores[i]) {
                    maxValueForUser2 = uint32(balanceLimits[i]);
                } else {
                    maxValueForUser2 = uint32(balanceLimits[4]);
                }
            }
            uint32 ruleIdRisk = createAccountMaxValueByRiskRule(createUint8Array(0, 10, 40, 80, 99), createUint48Array(10_000_000, 100_000, 1_000, 500, 10));
            setAccountMaxValueByRiskRule(ruleIdRisk);
        }
        {
            uint32 ruleIdMinMax = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(3));
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleIdMinMax);
        }

        {
            switchToAppAdministrator();
            applicationAppManager.addTag(address(applicationNFT), "BoredGrape"); ///add tag
            uint32 ruleIdDailyTrades = createTokenMaxDailyTradesRule("BoredGrape", 3);
            setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleIdDailyTrades);
        }
        {
            uint32 ruleIdMaxTxRisk = createAccountMaxTxValueByRiskRule(createUint8Array(0, 10, 40, 80, 99), createUint48Array(7_500_000, 75_000, 750, 350, 10));
            setAccountMaxTxValueByRiskRule(ruleIdMaxTxRisk);
        }

        switchToRiskAdmin();
        // we apply random risk score to user2
        applicationAppManager.addRiskScore(_user2, riskScore);

        vm.stopPrank();
        vm.startPrank(_user1);
        /// test oracle rule
        if (priceA % 2 == 0) {
            vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        } else {
            vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
        }
        applicationNFT.safeTransferFrom(_user1, _user4, 7);

        /// test risk rules
        if (priceA > uint112(maxValueForUser2) * ATTO) {
            if (priceA % 2 == 0) {
                vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
            } else {
                vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
            }
        }
        applicationNFT.safeTransferFrom(_user1, _user2, 0);

        if (priceA <= (uint112(maxValueForUser2) * 3 * ATTO) / 4 && priceA <= uint112(maxValueForUser2) * ATTO) {
            if (uint64(priceA) + uint64(priceB) > uint112(maxValueForUser2) * ATTO || priceB > (uint112(maxValueForUser2) * 3 * ATTO) / 4) {
                if (priceA % 2 == 0) {
                    vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
                } else {
                    vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
                }
            }
            applicationNFT.safeTransferFrom(_user1, _user2, 1);

            if (uint64(priceA) + uint64(priceB) <= uint112(maxValueForUser2) * ATTO && priceB <= (uint112(maxValueForUser2) * 3 * ATTO) / 4) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxValueForUser2) * ATTO || priceC > (uint112(maxValueForUser2) * 3 * ATTO) / 4) {
                    if (priceA % 2 == 0) {
                        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
                    } else {
                        vm.expectRevert(abi.encodeWithSignature("AddressNotApproved()"));
                    }
                }
                applicationNFT.safeTransferFrom(_user1, _user2, 2);

                if (uint64(priceA) + uint64(priceB) + uint64(priceC) <= uint112(maxValueForUser2) * ATTO && priceC <= (uint112(maxValueForUser2) * 3 * ATTO) / 4) {
                    /// balanceLimit rule should fail since _user2 now would have 4
                    vm.expectRevert(0x1da56a44);
                    applicationNFT.safeTransferFrom(_user1, _user2, 3);
                    /// now let's warp a day to make sure this won't be a problem
                    vm.warp(Blocktime + 40 hours);
                    for (uint i = 3; i < 6; i++) {
                        applicationNFT.safeTransferFrom(_user1, _user3, i);
                    }
                    reached3 = true;

                    /// warp to allow user 1 to transfer NFT 6
                    vm.warp(Blocktime + 725 hours);
                    applicationNFT.safeTransferFrom(_user1, _user3, 6);
                    /// balanceLimit rule should fail since _user1 now would have 0
                    vm.expectRevert(0x3e237976);
                    applicationNFT.safeTransferFrom(_user1, _user3, 7);

                    /// let's give back the NFTs to _user1
                    /// we update the min max balance rule so it's not a problem testing our AccessLevel
                    uint32 minMaxRuleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(5));
                    setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), minMaxRuleId);
                    vm.stopPrank();
                    vm.startPrank(_user3);

                    applicationNFT.safeTransferFrom(_user3, _user1, 3);
                    applicationNFT.safeTransferFrom(_user3, _user2, 4);

                    vm.stopPrank();
                    vm.startPrank(_user2);
                    applicationNFT.safeTransferFrom(_user2, _user1, 2);
                }
                uint32 _index = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(8));
                setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), _index);
                vm.stopPrank();
                vm.startPrank(_user2);
                applicationNFT.safeTransferFrom(_user2, _user1, 1);
            }
            uint32 index = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(8));
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), index);
            vm.stopPrank();
            vm.startPrank(_user2);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }
        {
            uint32 indexTwo = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(8));
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), indexTwo);
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
                vm.expectRevert(0x09a92f2d);
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
                vm.warp(Blocktime + 1725 hours);
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
            } else {
                applicationNFT.safeTransferFrom(_user1, _user3, 3);
                vm.stopPrank();
                vm.startPrank(_user3);
                vm.expectRevert(0x09a92f2d);
                applicationNFT.safeTransferFrom(_user3, _user1, 3);
                vm.warp(Blocktime + 1725 hours);
                applicationNFT.safeTransferFrom(_user3, _user1, 3);
            }

            uint8 accessLevel = riskScore % 5;
            switchToAccessLevelAdmin();
            _user2 = address(0xee55);
            applicationAppManager.addAccessLevel(_user2, accessLevel);
            // add the rule.
            uint48[] memory balanceAmounts = createUint48Array(0, 500, 10_000, 800_000, 200_000_000);
            {
                uint32 ruleIdAccessLevel = createAccountMaxValueByAccessLevelRule(0, 500, 10_000, 800_000, 200_000_000);
                setAccountMaxValueByAccessLevelRule(ruleIdAccessLevel);
            }
            {
                /// test access level rules
                vm.stopPrank();
                vm.startPrank(_user1);
                if (priceA > uint(balanceAmounts[accessLevel]) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
                applicationNFT.safeTransferFrom(_user1, _user2, 0);

                if (priceA <= uint120(balanceAmounts[accessLevel]) * ATTO) {
                    if (uint64(priceA) + uint64(priceB) > uint120(balanceAmounts[accessLevel]) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
                    applicationNFT.safeTransferFrom(_user1, _user2, 1);

                    if (uint64(priceA) + uint64(priceB) <= uint112(balanceAmounts[accessLevel]) * ATTO) {
                        if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(balanceAmounts[accessLevel]) * ATTO) vm.expectRevert(abi.encodeWithSignature("OverMaxValueByAccessLevel()"));
                        applicationNFT.safeTransferFrom(_user1, _user2, 2);

                        if (uint(priceA) + uint(priceB) + uint(priceC) <= uint112(balanceAmounts[accessLevel]) * ATTO) {
                            /// balanceLimit rule should fail since _user2 now would have 4
                        }
                    }
                }
            }
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract ApplicationERC721FuzzTest is TestCommonFoundry {

    event Log(string eventString, bytes32[] tag);

    function setUp() public {
        vm.warp(Blocktime);
        vm.startPrank(appAdministrator);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        applicationCoin.mint(appAdministrator, type(uint256).max);
    }

    function testERC721_MintFuzz(uint8 _addressIndex) public {
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

    function testERC721_TransferFuzz(uint8 _addressIndex) public {
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
    
    function testERC721_BurnFuzz(uint8 _addressIndex) public {
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
        ///Return to super admin account
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

    function testERC721_AccountMinMaxTokenBalanceRuleFuzz(uint8 _addressIndex) public {
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

        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(1);
        uint256[] memory max = createUint256Array(6);
        uint16[] memory empty;
        /// set up a non admin user with tokens
        vm.stopPrank();
        vm.startPrank(randomUser);
        ///transfer tokenId 1 and 2 to richGuy
        applicationNFT.transferFrom(randomUser, richGuy, 0);
        applicationNFT.transferFrom(randomUser, richGuy, 1);
        assertEq(applicationNFT.balanceOf(richGuy), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(randomUser,_user1, 3);
        applicationNFT.transferFrom(randomUser,_user1, 4);
        assertEq(applicationNFT.balanceOf(_user1), 2);
        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));

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
        ///update ruleId in application NFT handler
        applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(_user1);
        vm.expectRevert(0x3e237976);
        applicationNFT.transferFrom(_user1, _user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(appAdministrator);
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

    function testERC721_AccountApproveDenyOracleFuzz(uint8 _addressIndex) public {
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

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        switchToAppAdministrator();
        // add a blacklist address
        badBoys.push(_user3);
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        applicationNFTHandler.setAccountApproveDenyOracleId(_createActionsArray(), _index);
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
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
        /// connect the rule to this handler
        applicationNFTHandler.setAccountApproveDenyOracleId(_createActionsArray(), _index);
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
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 2, address(oracleApproved));
    }

    function testERC721_TokenMaxDailyTradesFuzz(uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        /// set up a non admin user an nft
        applicationNFT.safeMint(_user1); // tokenId = 0
        applicationNFT.safeMint(_user1); // tokenId = 1
        applicationNFT.safeMint(_user1); // tokenId = 2
        applicationNFT.safeMint(_user1); // tokenId = 3
        applicationNFT.safeMint(_user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(_user1), 5);

        // add the rule.
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        assertEq(rule.startTime, Blocktime);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(applicationNFT), "DiscoPunk"); ///add tag
        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        applicationNFTHandler.setTokenMaxDailyTradesId(_createActionsArray(), _index);

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

    function testERC721_AccountMaxTransactionValueByRiskScoreRuleNFT(uint8 _addressIndex, uint8 _risk) public {
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

        uint48[] memory _maxSize = createUint48Array(70, 50, 40, 30, 20);
        uint8[] memory _riskScore = createUint8Array(20, 40, 60, 80, 99);
        uint8 risk = uint8((uint16(_risk) * 100) / 256);
        ///Register rule with ERC721Handler
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), _maxSize, _riskScore, 0, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(ruleId);
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
        if (risk >= _riskScore[0]) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user3, _user4, 19); // a 200-dollar NFT
    }

    function testERC721_AccountMaxValueByAccessLevelFuzz(uint8 _addressIndex, uint8 _amountSeed) public {
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
        uint48 accessBalance1 = _amountSeed;
        uint48 accessBalance2 = uint48(_amountSeed) + 50;
        uint48 accessBalance3 = uint48(_amountSeed) + 100;
        uint48 accessBalance4 = uint48(_amountSeed) + 200;
        // add the rule.
        uint48[] memory balanceAmounts = createUint48Array(0, accessBalance1, accessBalance2, accessBalance3, accessBalance4);
 
        applicationAppManager.addRuleBypassAccount(appAdministrator);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountMaxValueByAccessLevelId(_index);

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

        /// Add access level to _user3
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
        // set the access level for the user4
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

    function testERC721_NFTValuationLimitFuzz(uint8 _addressIndex, uint8 _amountToMint) public {
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
        uint48[] memory balanceAmounts = createUint48Array(0, 10, 50, 100, 300);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountMaxValueByAccessLevelId(_index);
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
    function testERC721_AccountMaxValueByAccessLevelFuzz(uint8 _addressIndex, uint16 _valuationLimit) public {
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
        uint48[] memory balanceAmounts = createUint48Array(0, 10, 50, 100, 300);
        switchToRuleAdmin();
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        /// connect the rule to this handler
        applicationHandler.setAccountMaxValueByAccessLevelId(_index);
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
                vm.expectRevert(0xaee8b993);
                applicationNFT.transferFrom(_user2, _user1, 9);
            }
        }
    }

    function testERC721_AccountMinMaxTokenBalanceFuzz(uint8 _addressIndex, bytes32 tag1, bytes32 tag2, bytes32 tag3) public {
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
        bytes32[] memory accs = createBytes32Array(tag1, tag2, tag3);
        uint256[] memory minAmounts = createUint256Array(1, 2, 3);
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
        assertEq(_index, 0);
        /// Set rule
        applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), _index);
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

    function testERC721_AccountMaxTransactionValueByRiskScoreRuleNFT2(uint8 _risk, uint8 _period) public {
        vm.warp(Blocktime);
        /// we create the rule
        uint48[] memory _maxSize = createUint48Array(100_000_000, 10_000, 1);
        uint8[] memory _riskScore = createUint8Array(25, 50, 75);
        uint8 period = _period > 6 ? _period / 6 + 1 : 1;
        uint8 risk = uint8((uint16(_risk) * 100) / 256);
        address _user1 = address(0xaa);
        address _user2 = address(0x22);
        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(_user1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 0, 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 1, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 2, 10_000 * (10 ** 18) - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 3, 100_000_000 * (10 ** 18) - 10_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 4, 1_000_000_000_000 * (10 ** 18) - 100_000_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 5, 1 * (10 ** 18));
        /// we mint some NFTs for user 1 and give them a price
        for (uint i; i < 6; i++) applicationNFT.safeMint(_user2);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 6, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 7, 1 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 8, 90_000 * (10 ** 18) - 1);
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 9, 900_000_000 * (10 ** 18) - 90_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 10, 9_000_000_000_000 * (10 ** 18) - 900_000_000 * (10 ** 18));
        erc721Pricer.setSingleNFTPrice(address(applicationNFT), 11, 1 * (10 ** 18));

        /// we register the rule in the protocol
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), _maxSize, _riskScore, period, Blocktime);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setAccountMaxTxValueByRiskScoreId(ruleId);

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
        if (risk >= _riskScore[2]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 1);
        /// 2
        /// if the user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskScore[1]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 2);
        /// 10_001
        /// if the user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskScore[0]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user1, _user2, 3);
        /// 100_000_000 - 10_000 + 10_001 = 100_000_000 + 1 = 100_000_001
        if (risk >= _riskScore[0]) vm.expectRevert();
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
        applicationHandler.activateAccountMaxTxValueByRiskScore(false);
        /// we register the rule in the protocol
        ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), _maxSize, _riskScore, period, Blocktime);
        assertEq(ruleId, 1);
        /// now we set the rule in the applicationHandler for the applicationCoin only
        applicationHandler.setAccountMaxTxValueByRiskScoreId(ruleId);
        /// we start making transfers
        vm.stopPrank();
        vm.startPrank(_user2);

        /// first we send only 1 token which shouldn't trigger any risk check
        applicationNFT.safeTransferFrom(_user2, _user1, 6);
        /// 1
        /// now, if the _user's risk profile is in the highest range, this transfer should revert
        if (risk >= _riskScore[2]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 7);
        /// 2
        /// if the _user's risk profile is in the second to the highest range, this transfer should revert
        if (risk >= _riskScore[1]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 8);
        /// 90_001
        /// if the _user's risk profile is in the second to the lowest range, this transfer should revert
        if (risk >= _riskScore[0]) vm.expectRevert();
        console.log(risk);
        applicationNFT.safeTransferFrom(_user2, _user1, 9);
        /// 900_000_000 - 90_000 + 90_001 = 900_000_000 + 1 = 900_000_001
        if (risk >= _riskScore[0]) vm.expectRevert();
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
            vm.expectRevert();
            applicationNFT.burn(11);
            vm.warp(block.timestamp + (uint256(period) * 2 hours));
            applicationNFT.burn(11);
        }
    }

    function testERC721_AccountMaxValueByRiskScoreNFT(uint32 priceA, uint32 priceB, uint16 priceC, uint8 _riskScore) public {
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
        for (uint i; i < balanceLimits.length - 1; ) {
            if (riskScore < riskScores[i]) {
                maxValueForUser2 = uint32(balanceLimits[i]);
            } else {
                maxValueForUser2 = uint32(balanceLimits[3]);
            }
            unchecked {
                ++i;
            }

        }

        ///Switch to Rule admin and activate AccountBalanceByRiskScore Rule
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
        applicationHandler.setAccountMaxValueByRiskScoreId(index);

        vm.stopPrank();
        vm.startPrank(_user1);
        if (priceA >= uint112(maxValueForUser2) * (10 ** 18)) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);
        if (priceA <= uint112(maxValueForUser2) * (10 ** 18)) {
            if (uint64(priceA) + uint64(priceB) >= uint112(maxValueForUser2) * (10 ** 18)) vm.expectRevert();
            applicationNFT.safeTransferFrom(_user1, _user2, 1);
            if (uint64(priceA) + uint64(priceB) < uint112(maxValueForUser2) * (10 ** 18)) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxValueForUser2) * (10 ** 18)) vm.expectRevert();
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

    function testERC721_AccountMaxValueOutByAccessLevelFuzz(uint8 _addressIndex, uint8 accessLevel) public {
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
        uint48[] memory withdrawalLimits = createUint48Array(0, 10, 20, 50, 250); 
        applicationAppManager.addRuleBypassAccount(appAdministrator);
        switchToRuleAdmin();
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setAccountMaxValueOutByAccessLevelId(index);

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

    function testERC721_TokenMaxSupplyVolatilityFuzz(uint8 _addressIndex, uint16 volLimit) public {
        /// test params
        vm.assume(volLimit < 9999 && volLimit > 0);
        if (volLimit < 100) volLimit = 100;
        vm.warp(Blocktime);
        uint8 rulePeriod = 24; /// 24 hours
        uint64 startTime = Blocktime; /// default timestamp
        uint256 tokenSupply = 0; /// calls totalSupply() for the token
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _rich_user = addressList[0];
        /// mint initial supply
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(appAdministrator);
        }
        applicationNFT.safeTransferFrom(appAdministrator, _rich_user, 9);
        /// create and activate rule
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), volLimit, rulePeriod, startTime, tokenSupply);
        ActionTypes[] memory actionTypes = new ActionTypes[](2);
        actionTypes[0] = ActionTypes.MINT;
        actionTypes[1] = ActionTypes.BURN;
        applicationNFTHandler.setTokenMaxSupplyVolatilityId(actionTypes, _index);

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
            vm.expectRevert();
            applicationNFT.safeMint(_rich_user);
        }
        if (maxVol == 0) {
            vm.expectRevert();
            applicationNFT.safeMint(_rich_user);
        }
        /// at vol limit
        vm.stopPrank();
        vm.startPrank(_rich_user);
        if ((10000 / applicationNFT.totalSupply()) > volLimit) {
            vm.expectRevert();
            applicationNFT.burn(9);
        } else {
            applicationNFT.burn(9);
            vm.stopPrank();
            vm.startPrank(appAdministrator);
            applicationNFT.safeMint(_rich_user); // token 10
            vm.stopPrank();
            vm.startPrank(_rich_user);
            applicationNFT.burn(10);
            vm.stopPrank();
            vm.startPrank(appAdministrator);
            applicationNFT.safeMint(_rich_user);
            vm.stopPrank();
            vm.startPrank(_rich_user);
            applicationNFT.burn(11);
        }
    }

    /// Test Whole Protocol with Non Fungible Token 
    function testERC721_TheWholeProtocolThroughNFT(uint32 priceA, uint32 priceB, uint16 priceC, uint8 riskScore, bytes32 tag1) public {
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
                oracleDenied.addToDeniedList(badBoys);
                switchToRuleAdmin();
                uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
                applicationNFTHandler.setAccountApproveDenyOracleId(_createActionsArray(), _index);
            } else {
                goodBoys.push(_user1);
                goodBoys.push(_user2);
                goodBoys.push(_user3);
                goodBoys.push(address(0xee55));
                oracleApproved.addToApprovedList(goodBoys);
                switchToRuleAdmin();
                uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
                applicationNFTHandler.setAccountApproveDenyOracleId(_createActionsArray(), _index);
            }
            switchToAppAdministrator();
            uint8[] memory riskScores = createUint8Array(0, 10, 40, 80, 99);
            uint48[] memory balanceLimits = createUint48Array(10_000_000, 100_000, 1_000, 500, 10);
            // we find the max balance user2
            for (uint i; i < balanceLimits.length - 1; ) {
                if (riskScore < riskScores[i]) { 
                    maxValueForUser2 = uint32(balanceLimits[i]); 
                } else { 
                    maxValueForUser2 = uint32(balanceLimits[4]); 
                }
                unchecked {
                    ++i;
                }
            }
            switchToRuleAdmin();
            uint32 balanceByRiskId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, balanceLimits);
            applicationHandler.setAccountMaxValueByRiskScoreId(balanceByRiskId);
        }
        {
            bytes32[] memory accs = createBytes32Array("Oscar");
            uint256[] memory min = createUint256Array(1);
            uint256[] memory max = createUint256Array(3);
            uint16[] memory empty;
            uint32 balanceLimitId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
            applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), balanceLimitId);
        }
        {
            bytes32[] memory nftTags =createBytes32Array("BoredGrape");
            uint8[] memory tradesAllowed = createUint8Array(3);
            uint32 tradeRuleId = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            switchToAppAdministrator();
            applicationAppManager.addTag(address(applicationNFT), "BoredGrape"); ///add tag
            switchToRuleAdmin();
            applicationNFTHandler.setTokenMaxDailyTradesId(_createActionsArray(), tradeRuleId);
        }
        {
            uint48[] memory _maxSize = createUint48Array(7_500_000, 75_000, 750, 350, 10);
            uint8[] memory _riskScore = createUint8Array(0, 10, 40, 80, 99);
            ///Register rule with ERC721Handler
            uint32 maxTxPerRiskId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), _maxSize, _riskScore, 0, uint64(block.timestamp));
            applicationHandler.setAccountMaxTxValueByRiskScoreId(maxTxPerRiskId);
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
        if (priceA > uint112(maxValueForUser2) * (10 ** 18)) vm.expectRevert();
        applicationNFT.safeTransferFrom(_user1, _user2, 0);

        if (priceA <= (uint112(maxValueForUser2) * 3 * (10 ** 18)) / 4 && priceA <= uint112(maxValueForUser2) * (10 ** 18)) {
            if (uint64(priceA) + uint64(priceB) > uint112(maxValueForUser2) * (10 ** 18) || priceB > (uint112(maxValueForUser2) * 3 * (10 ** 18)) / 4) vm.expectRevert();
            applicationNFT.safeTransferFrom(_user1, _user2, 1);

            if (uint64(priceA) + uint64(priceB) <= uint112(maxValueForUser2) * (10 ** 18) && priceB <= (uint112(maxValueForUser2) * 3 * (10 ** 18)) / 4) {
                if (uint64(priceA) + uint64(priceB) + uint64(priceC) > uint112(maxValueForUser2) * (10 ** 18) || priceC > (uint112(maxValueForUser2) * 3 * (10 ** 18)) / 4) vm.expectRevert();
                applicationNFT.safeTransferFrom(_user1, _user2, 2);

                if (uint64(priceA) + uint64(priceB) + uint64(priceC) <= uint112(maxValueForUser2) * (10 ** 18) && priceC <= (uint112(maxValueForUser2) * 3 * (10 ** 18)) / 4) {
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
                    bytes32[] memory accs1 = createBytes32Array("Oscar");
                    uint256[] memory min1 = createUint256Array(1);
                    uint256[] memory max1 = createUint256Array(5);
                    uint16[] memory empty1;
                    switchToRuleAdmin();
                    uint32 balanceLimitId1 = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs1, min1, max1, empty1, uint64(Blocktime));
                    applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), balanceLimitId1);
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
                bytes32[] memory accs2 = createBytes32Array("Oscar");
                uint256[] memory min2 = createUint256Array(1);
                uint256[] memory max2 = createUint256Array(8);
                uint16[] memory empty2;
                switchToRuleAdmin();
                uint32 balanceLimitId2 = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs2, min2, max2, empty2, uint64(Blocktime));
                applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), balanceLimitId2);
                vm.stopPrank();
                vm.startPrank(_user2);
                applicationNFT.safeTransferFrom(_user2, _user1, 1);
            }
            bytes32[] memory accs3 = createBytes32Array("Oscar");
            uint256[] memory min3 = createUint256Array(1);
            uint256[] memory max3 = createUint256Array(8);
            uint16[] memory empty3;
            switchToRuleAdmin();
            uint32 balanceLimitId3 = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs3, min3, max3, empty3, uint64(Blocktime));
            applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), balanceLimitId3);
            vm.stopPrank();
            vm.startPrank(_user2);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }
        {
            bytes32[] memory accs4 = createBytes32Array("Oscar");
            uint256[] memory min4 = createUint256Array(1);
            uint256[] memory max4 = createUint256Array(8);
            uint16[] memory empty4;
            switchToRuleAdmin();
            uint32 balanceLimitId4 = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs4, min4, max4, empty4, uint64(Blocktime));
            applicationNFTHandler.setAccountMinMaxTokenBalanceId(_createActionsArray(), balanceLimitId4);
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
                switchToRuleAdmin();
                uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
                /// connect the rule to this handler
                applicationHandler.setAccountMaxValueByAccessLevelId(_index);
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

    function testERC721_AdminMinTokenBalanceFuzz(uint32 daysForward, uint8 _addressIndex) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 5);
        address _user1 = addressList[2];
        /// Mint TokenId 0-6 to ruleBypassAccount
        for (uint i; i < 7; i++) applicationNFT.safeMint(ruleBypassAccount);
        /// we create a rule that sets the minimum amount to 5 tokens to be tranferable in 1 year
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 5, block.timestamp + 365 days);
        /// Set the rule in the handler
        applicationNFTHandler.setAdminMinTokenBalanceId(_createActionsArray(), _index);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 5, block.timestamp + 365 days);
        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert();
        applicationNFTHandler.activateAdminMinTokenBalance(_createActionsArray(), false);
        vm.expectRevert();
        applicationNFTHandler.setAdminMinTokenBalanceId(_createActionsArray(), _index);

        switchToRuleBypassAccount();
        /// These transfers should pass
        applicationNFT.safeTransferFrom(ruleBypassAccount, _user1, 0);
        applicationNFT.safeTransferFrom(ruleBypassAccount, _user1, 1);
        /// This one fails
        vm.expectRevert();
        applicationNFT.safeTransferFrom(ruleBypassAccount, _user1, 2);

        vm.warp(Blocktime + daysForward);
        if (daysForward < 365 days) vm.expectRevert();
        applicationNFT.safeTransferFrom(ruleBypassAccount, _user1, 2);
        switchToRuleAdmin();
        if (daysForward >= 365 days) {
            applicationNFTHandler.activateAdminMinTokenBalance(_createActionsArray(), false);
            applicationNFTHandler.setAdminMinTokenBalanceId(_createActionsArray(), _index);
        }
    }

    function testERC721_TokenMaxTradingVolumeFuzzNFT(uint8 _addressIndex, uint8 _period, uint16 _maxPercent) public {
        if (_period == 0) _period = 1;
        //since NFT's take so long to mint, don't test for below 10% because the test pool will only be 10 NFT's
        if (_maxPercent < 100) _maxPercent = 100;
        if (_maxPercent > 9999) _maxPercent = 9999;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _rich_user = addressList[0];
        address _user1 = addressList[1];
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), _maxPercent, _period, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
        assertEq(rule.max, _maxPercent);
        assertEq(rule.period, _period);
        assertEq(rule.startTime, Blocktime);
        switchToAppAdministrator();
        /// load non admin users with nft's
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            applicationNFT.safeMint(_rich_user);
        }
        // apply the rule
        switchToRuleAdmin();
        applicationNFTHandler.setTokenMaxTradingVolumeId(_createActionsArray(), _index);
        /// determine the maximum transfer amount
        uint256 maxSize = uint256(_maxPercent) / 1000;
        console.logUint(maxSize);
        vm.stopPrank();
        vm.startPrank(_rich_user);
        /// make sure that transfer under the threshold works
        if (maxSize > 1) {
            for (uint i = 0; i < maxSize - 1; i++) {
                applicationNFT.safeTransferFrom(_rich_user, _user1, i);
            }
            assertEq(applicationNFT.balanceOf(_user1), maxSize - 1);
        }
        /// Now break the rule
        if (maxSize == 0) {
            vm.expectRevert(0x009da0ce);
            applicationNFT.safeTransferFrom(_rich_user, _user1, 0);
        } else {
            /// account for decimal percentages
            if (uint256(_maxPercent) % 1000 == 0) {
                vm.expectRevert(0x009da0ce);
                applicationNFT.safeTransferFrom(_rich_user, _user1, maxSize - 1);
            } else {
                applicationNFT.safeTransferFrom(_rich_user, _user1, maxSize - 1);
                vm.expectRevert(0x009da0ce);
                applicationNFT.safeTransferFrom(_rich_user, _user1, maxSize);
            }
        }
    }

    function testERC721_TokenMinHoldTimeFuzz(uint8 _addressIndex, uint32 _hours) public {
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address _user1 = addressList[0];
        address _user2 = addressList[1];
        switchToRuleAdmin();
        // hold time range must be between 1 hour and 5 years
        if (_hours == 0 || _hours > 43830) {
            vm.expectRevert();
            applicationNFTHandler.setTokenMinHoldTime(_createActionsArray(), _hours);
        } else {
            /// set the rule for x hours
            applicationNFTHandler.setTokenMinHoldTime(_createActionsArray(), _hours);
            assertEq(applicationNFTHandler.getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), _hours);
            // mint 1 nft to non admin user(this should set their ownership start time)
            switchToAppAdministrator();
            applicationNFT.safeMint(_user1);
            vm.stopPrank();
            vm.startPrank(_user1);
            // transfer should fail
            vm.expectRevert(0x5f98112f);
            applicationNFT.safeTransferFrom(_user1, _user2, 0);
            // move forward in time x hours and it should pass
            Blocktime = Blocktime + (_hours * 1 hours);
            vm.warp(Blocktime);
            applicationNFT.safeTransferFrom(_user1, _user2, 0);
            // the original owner was able to transfer but the new owner should not be able to because the time resets
            vm.stopPrank();
            vm.startPrank(_user2);
            vm.expectRevert(0x5f98112f);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
            // move forward in time x hours and it should pass
            Blocktime = Blocktime + (_hours * 1 hours);
            vm.warp(Blocktime);
            applicationNFT.safeTransferFrom(_user2, _user1, 0);
        }
    }
}

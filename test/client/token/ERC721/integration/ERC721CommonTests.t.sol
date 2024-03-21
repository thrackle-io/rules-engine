// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "../../TestTokenCommon.sol";
import "test/client/token/ERC721/util/ERC721Util.sol";

abstract contract ERC721CommonTests is TestCommonFoundry, ERC721Util {
    IERC721 testCaseNFT;
    uint256 erc721Liq = 10_000;
    uint256 erc20Liq = 100_000 * ATTO;
    DummyNFTAMM amm;
    
    function testERC721_ERC721CommonTests_HandlerVersions() public {
        string memory version = VersionFacet(address(applicationNFTHandler)).version();
        assertEq(version, "1.1.0");
    }

    function testERC721_ERC721CommonTests_AlreadyInitialized() public endWithStopPrank {
        vm.startPrank(address(testCaseNFT));
        vm.expectRevert(abi.encodeWithSignature("AlreadyInitialized()"));
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(user1, user2, user3);
    }

    function testERC721_ERC721CommonTests_NFTEvaluationLimitEventEmission() public endWithStopPrank {
        switchToAppAdministrator();
        vm.expectEmit(true, true, true, false);
        emit AD1467_NFTValuationLimitUpdated(20);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(20);
    }

    function testERC721_ERC721CommonTests_ERC721OnlyTokenCanCallCheckAllRules() public {
        address handler = IProtocolTokenMin(address(testCaseNFT)).getHandlerAddress();
        assertEq(handler, address(applicationNFTHandler));
        address owner = ERC173Facet(address(applicationNFTHandler)).owner();
        assertEq(owner, address(testCaseNFT));
        vm.expectRevert("UNAUTHORIZED");
        ERC20HandlerMainFacet(handler).checkAllRules(0, 0, user1, user2, user3, 0);
    }

    function testERC721_ERC721CommonTests_Mint() public endWithStopPrank {
        switchToAppAdministrator();
        /// Owner Mints new tokenId
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        console.log(testCaseNFT.balanceOf(appAdministrator));
        /// Owner Mints a second new tokenId
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        console.log(testCaseNFT.balanceOf(appAdministrator));
        assertEq(testCaseNFT.balanceOf(appAdministrator), 2);
    }

    function testERC721_ERC721CommonTests_Transfer_Positive() public endWithStopPrank {
        switchToAppAdministrator();
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        testCaseNFT.transferFrom(appAdministrator, user, 0);
        assertEq(testCaseNFT.balanceOf(appAdministrator), 0);
        assertEq(testCaseNFT.balanceOf(user), 1);
    }

    function testERC721_ERC721CommonTests_Transfer_Negative() public endWithStopPrank() {
        switchToAppAdministrator();
        vm.expectRevert("ERC721: invalid token ID");
        testCaseNFT.transferFrom(appAdministrator, user, 0);
    }

        function testERC721_ERC721CommonTests_BurnERC721_Positive() public endWithStopPrank() {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        testCaseNFT.transferFrom(appAdministrator, appAdministrator, 0);
        ///Mint tokenId 1
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        ///Test token burn of token 0 and token 1
        ERC721Burnable(address(testCaseNFT)).burn(1);

        /// Burn appAdministrator token
        ERC721Burnable(address(testCaseNFT)).burn(0);
        assertEq(testCaseNFT.balanceOf(appAdministrator), 0);
    }

    function testERC721_ERC721CommonTests_BurnERC721_Negative() public endWithStopPrank {
        switchToAppAdministrator();
        ///Mint and transfer tokenId 0
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        switchToUser();
        ///attempt to burn token that user does not own
        vm.expectRevert("ERC721: caller is not token owner or approved");
        ERC721Burnable(address(testCaseNFT)).burn(0);
    }

    function testERC721_ERC721CommonTests_ZeroAddressChecksERC721() public {
        vm.expectRevert(0xd92e233d);
        new ApplicationERC721("FRANK", "FRANK", address(0x0), "https://SampleApp.io");
        vm.expectRevert(0xba80c9e5);
        IProtocolTokenMin(address(testCaseNFT)).connectHandlerToToken(address(0));

        /// test both address checks in constructor
        applicationNFTHandler = _createERC721HandlerDiamond();

        vm.expectRevert(0xd92e233d);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(0x0), address(applicationAppManager), address(testCaseNFT));
        vm.expectRevert(0xd92e233d);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(0x0), address(testCaseNFT));
        vm.expectRevert(0xd92e233d);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).initialize(address(ruleProcessor), address(applicationAppManager), address(0x0));

        vm.expectRevert(0xd66c3008);
        applicationHandler.setNFTPricingAddress(address(0x00));
    }

    /// Account Min/Max Token Balance Tests
    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceRule_Minimum_Fail() public endWithStopPrank() {
        /// make sure the minimum rules fail results in revert
        _accountMinMaxTokenBalanceRuleSetup(true);
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        testCaseNFT.transferFrom(user1, user3, 4);
    }
    
    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceRule_Maximum_Fail() public endWithStopPrank() {
        ///make sure the maximum rule fail results in revert
        _accountMinMaxTokenBalanceRuleSetup(true);
        switchToAppAdministrator();
        testCaseNFT.transferFrom(appAdministrator, user2, 2);
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        // transfer to user1 to exceed limit
        vm.startPrank(user2);
        vm.expectRevert(abi.encodeWithSignature("OverMaxBalance()"));
        testCaseNFT.transferFrom(user2, user1, 3);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceRule_Burning() public endWithStopPrank() {
        /// test that burn works with rule
        _accountMinMaxTokenBalanceRuleSetup(true);
        vm.startPrank(rich_user);
        ERC721Burnable(address(testCaseNFT)).burn(1);
        vm.startPrank(user1);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        ERC721Burnable(address(testCaseNFT)).burn(5);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceBlankTag_Pass() public endWithStopPrank() {
        ///perform transfer that checks rule
        _accountMinMaxTokenBalanceRuleSetup(false);
        vm.startPrank(user1);
        assertEq(testCaseNFT.balanceOf(user2), 1);
        assertEq(testCaseNFT.balanceOf(user1), 1);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceBlankTag_Minimum_Fail() public endWithStopPrank() {
        /// make sure the minimum rules fail results in revert
        _accountMinMaxTokenBalanceRuleSetup(false);
        vm.startPrank(user1);
        vm.expectRevert(0x3e237976);
        testCaseNFT.transferFrom(user1, user3, 4);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceBlankTag_Maximum_Fail() public endWithStopPrank() {
        ///make sure the maximum rule fail results in revert
        _accountMinMaxTokenBalanceRuleSetup(false);
        switchToAppAdministrator();
        testCaseNFT.transferFrom(appAdministrator, rich_user, 5);
        testCaseNFT.transferFrom(appAdministrator, user2, 2);
        vm.startPrank(rich_user);
        testCaseNFT.transferFrom(rich_user, user1, 0);
        assertEq(testCaseNFT.balanceOf(user1), 2);
        testCaseNFT.transferFrom(rich_user, user1, 1);
        assertEq(testCaseNFT.balanceOf(user1), 3);
        // one more should revert for max
        vm.startPrank(user2);
        vm.expectRevert(0x1da56a44);
        testCaseNFT.transferFrom(user2, user1, 2);
    }

    /// Account Approve Deny Oracle Tests
    function testERC721_ERC721CommonTests_AccountApproveDenyOracle_Deny_Fail() public endWithStopPrank() {
        ///perform transfer that checks rule
        // This one should fail
        _accountApproveDenyOracleSetup(true);
        vm.startPrank(user1);
        vm.expectRevert(0x2767bda4);
        testCaseNFT.transferFrom(user1, address(69), 1);
        assertEq(testCaseNFT.balanceOf(address(69)), 0);
    }

    function testERC721_ERC721CommonTests_AccountApproveDenyOracle_Approve_Fail() public endWithStopPrank() {
        _accountApproveDenyOracleSetup(false);
        // This one should fail
        vm.startPrank(user1);
        vm.expectRevert(0xcafd3316);
        testCaseNFT.transferFrom(user1, address(88), 3);
    }

    function testERC721_ERC721CommonTests_AccountApproveDenyOracle_Invalid() public endWithStopPrank() {
        // Finally, check the invalid type
        vm.expectRevert("Oracle Type Invalid");
        createAccountApproveDenyOracleRule(2);
    }

    function testERC721_ERC721CommonTests_AccountApproveDenyOracle_Burning() public endWithStopPrank() {
        _accountApproveDenyOracleSetup(false);
        /// swap to user and burn
        vm.startPrank(user1);
        ERC721Burnable(address(testCaseNFT)).burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
        uint32 ruleId = createAccountApproveDenyOracleRule(0);
        setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// user attempts burn
        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSignature("AddressIsDenied()"));
        ERC721Burnable(address(testCaseNFT)).burn(3);
    }

    function testERC721_ERC721CommonTests_PauseRulesViaAppManager() public endWithStopPrank {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        assertEq(testCaseNFT.balanceOf(user1), 5);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);
        vm.startPrank(user1);
        bytes4 selector = bytes4(keccak256("ApplicationPaused(uint256,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, Blocktime + 1000, Blocktime + 1500));
        testCaseNFT.transferFrom(user1, address(59), 2);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_FlexibleTag() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(true);
        switchToAppAdministrator();
        applicationAppManager.removeTag(address(testCaseNFT), "BoredGrape"); ///add tag
        applicationAppManager.addTag(address(testCaseNFT), "DiscoPunk"); ///add tag
        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 0);
        assertEq(testCaseNFT.balanceOf(user2), 2);
        vm.startPrank(user2);
        testCaseNFT.transferFrom(user2, user1, 0);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_StrictTag_Fail() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(true);
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        testCaseNFT.transferFrom(user2, user1, 1);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_Period() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(true);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        vm.startPrank(user2);
        testCaseNFT.transferFrom(user2, user1, 1);
        assertEq(testCaseNFT.balanceOf(user2), 0);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_MultipleTag() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(true);
        // add the other tag and check to make sure that it still only allows 1 trade
        vm.startPrank(user1);
        // first one should pass
        testCaseNFT.transferFrom(user1, user2, 2);
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        testCaseNFT.transferFrom(user2, user1, 2);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_BlankTag_Fail() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(false);
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(abi.encodeWithSignature("OverMaxDailyTrades()"));
        testCaseNFT.transferFrom(user2, user1, 1);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTrades_BlankTag_Period() public endWithStopPrank() {
        _tokenMaxDailyTradesSetup(false);
        // add a day to the time and it should pass
        vm.startPrank(user2);
        vm.warp(block.timestamp + 1 days);
        testCaseNFT.transferFrom(user2, user1, 1);
        assertEq(testCaseNFT.balanceOf(user2), 0);
    }


    /// Account Max Transaction Value By Risk Score Tests
    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Pass() public endWithStopPrank() {
        ///Transfer NFT's
        ///Positive cases
        _accountMaxTransactionValueByRiskScoreSetup(false); 
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user3, 0);
        vm.startPrank(user3);
        testCaseNFT.safeTransferFrom(user3, user1, 0);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 4);
        testCaseNFT.safeTransferFrom(user1, user2, 1);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Fail() public endWithStopPrank() {
        ///Fail cases
        _accountMaxTransactionValueByRiskScoreSetup(false); 
        vm.startPrank(user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 7);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 6);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 12000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 5);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_PriceChange() public endWithStopPrank() {
        _accountMaxTransactionValueByRiskScoreSetup(false);
        ///simulate price changes
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 4, 1050 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 5, 1550 * (10 ** 16)); // in cents
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 7, 9 * ATTO); // in dollars

        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 4);
        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user3, 7);
        testCaseNFT.safeTransferFrom(user2, user3, 6);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 5);
        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user3, 4);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Burning() public endWithStopPrank() {
        _accountMaxTransactionValueByRiskScoreSetup(false);
        /// set price of token 5 below limit of user 2
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.startPrank(user2);
        ERC721Burnable(address(testCaseNFT)).burn(5);
        
        vm.startPrank(user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ERC721Burnable(address(testCaseNFT)).burn(6);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Period_Pass() public endWithStopPrank() {
        ///Transfer NFT's
        ///Positive cases
        _accountMaxTransactionValueByRiskScoreSetup(true);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user3, 0);
        vm.warp(block.timestamp + 25 hours);
        vm.startPrank(user3);
        testCaseNFT.safeTransferFrom(user3, user1, 0);

        vm.warp(block.timestamp + 25 hours * 2);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 4);
        vm.warp(block.timestamp + 25 hours * 3);
        testCaseNFT.safeTransferFrom(user1, user2, 1);
    }
    
    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Period_Fail() public endWithStopPrank() {
        ///Fail cases
        _accountMaxTransactionValueByRiskScoreSetup(true);
        vm.startPrank(user2);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 7);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 6);

        selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 40, 12000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 5);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Period_Combination() public endWithStopPrank() {
        ///simulate price changes
        _accountMaxTransactionValueByRiskScoreSetup(true);
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 4, 1050 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 5, 1550 * (ATTO / 100)); // in cents
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 6, 11 * ATTO); // in dollars
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 7, 9 * ATTO); // in dollars

        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 4);

        vm.warp(block.timestamp + 25 hours * 5);
        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user3, 7);
        vm.warp(block.timestamp + 25 hours * 6);
        testCaseNFT.safeTransferFrom(user2, user3, 6);

        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        testCaseNFT.safeTransferFrom(user2, user3, 5);

        vm.warp(block.timestamp + 25 hours * 7);
        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user3, 4);
    }

    function testERC721_ERC721CommonTests_AccountMaxTransactionValueByRiskScore_Period_Burning() public endWithStopPrank() {
        /// set price of token 5 below limit of user 2
        _accountMaxTransactionValueByRiskScoreSetup(true);
        switchToAppAdministrator();
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 5, 14 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 4, 17 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(testCaseNFT), 6, 25 * ATTO);
        /// test burning with this rule active
        /// transaction valuation must remain within risk limit for sender
        vm.startPrank(user2);
        ERC721Burnable(address(testCaseNFT)).burn(5);
        bytes4 selector = bytes4(keccak256("OverMaxTxValueByRiskScore(uint8,uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10, 15000000000000000000));
        ERC721Burnable(address(testCaseNFT)).burn(6);
    }

    /**
     * @dev Test the AccessLevel = 0 rule
     */
     function testERC721_ERC721CommonTests_AccountDenyForNoAccessLevelInNFT_Fail() public endWithStopPrank() {
        // transfers should not work for addresses without AccessLevel
        _accountDenyForNoAccessLevelInNFTSetup();
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d);
        testCaseNFT.transferFrom(user1, user2, 0);
        // set AccessLevel and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        vm.startPrank(user1);
        vm.expectRevert(0x3fac082d); /// still fails since user 1 is accessLevel0
        testCaseNFT.transferFrom(user1, user2, 0);
    }

    function testERC721_ERC721CommonTests_AccountDenyForNoAccessLevelInNFT_Pass() public endWithStopPrank() {
        _accountDenyForNoAccessLevelInNFTSetup();
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user2, 1);
        applicationAppManager.addAccessLevel(user1, 1);
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 0);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalance_Pass() public endWithStopPrank() {
        /// Transfers passing (above min value limit)
        _accountMinMaxTokenBalanceSetup(true);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        testCaseNFT.safeTransferFrom(user1, user3, 1);
        assertEq(testCaseNFT.balanceOf(user1), 1);

        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        testCaseNFT.safeTransferFrom(user2, user3, 3);
        assertEq(testCaseNFT.balanceOf(user2), 2);

        vm.startPrank(user3);
        testCaseNFT.safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        testCaseNFT.safeTransferFrom(user3, user1, 1);
        assertEq(testCaseNFT.balanceOf(user3), 3);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalance_Fail() public endWithStopPrank() {
        _accountMinMaxTokenBalanceSetup(true);
        /// Transfers failing (below min value limit)
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, rich_user, 0); ///User 1 has min limit of 1
        testCaseNFT.safeTransferFrom(user1, rich_user, 1);
        vm.expectRevert(0xa7fb7b4b);
        testCaseNFT.safeTransferFrom(user1, rich_user, 2);
        assertEq(testCaseNFT.balanceOf(user1), 1);

        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, rich_user, 3); ///User 2 has min limit of 2
        vm.expectRevert(0xa7fb7b4b);
        testCaseNFT.safeTransferFrom(user2, rich_user, 4);
        assertEq(testCaseNFT.balanceOf(user2), 2);

        vm.startPrank(user3);
        vm.expectRevert(0xa7fb7b4b);
        testCaseNFT.safeTransferFrom(user3, rich_user, 6); ///User 3 has min limit of 3
        assertEq(testCaseNFT.balanceOf(user3), 3);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalance_Period() public endWithStopPrank() {
        _accountMinMaxTokenBalanceSetup(true);

        /// Expire time restrictions for users and transfer below rule
        vm.warp(Blocktime + 17525 hours);

        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, rich_user, 2);

        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, rich_user, 4);

        vm.startPrank(user3);
        testCaseNFT.safeTransferFrom(user3, rich_user, 6);
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalance_BlankTag_Pass() public endWithStopPrank() {
        _accountMinMaxTokenBalanceSetup(false);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
    }
    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalance_BlankTag_Fail() public endWithStopPrank() {
        // should fail since it puts user1 below min of 1
        _accountMinMaxTokenBalanceSetup(false);
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
        testCaseNFT.safeTransferFrom(user1, user3, 1);
        vm.expectRevert(0xa7fb7b4b); 
        testCaseNFT.safeTransferFrom(user1, user3, 2);
    }

    function testERC721_ERC721CommonTests_AdminMinTokenBalance_Fail() public endWithStopPrank() {
        _adminMinTokenBalanceSetup();
        switchToRuleBypassAccount();
        /// This one fails
        bytes4 selector = bytes4(keccak256("UnderMinBalance()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        testCaseNFT.safeTransferFrom(ruleBypassAccount, user1, 2);
    }

    function testERC721_ERC721CommonTests_AdminMinTokenBalance_Period() public endWithStopPrank() {
        _adminMinTokenBalanceSetup();
        switchToRuleBypassAccount();
        /// Move Time forward 366 days
        vm.warp(Blocktime + 366 days);

        /// Transfers and updating rules should now pass
        testCaseNFT.safeTransferFrom(ruleBypassAccount, user1, 2);  
    }  

    function testERC721_ERC721CommonTests_TransferVolumeRule_Fail() public endWithStopPrank() {
        _transferVolumeRuleSetup();
        vm.startPrank(user1);
        // transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 1);
    }

    function testERC721_ERC721CommonTests_TransferVolumeRule_Period() public endWithStopPrank() {
        _transferVolumeRuleSetup();
        vm.startPrank(user1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        testCaseNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        testCaseNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 3);
    }


    function testERC721_ERC721CommonTests_TransferVolumeRuleWithSupplySet_Fail() public endWithStopPrank() {
        _transferVolumeRuleWithSupplySet();
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
        //transfer one that hits the percentage
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 1);
    }

    function testERC721_ERC721CommonTests_TransferVolumeRuleWithSupplySet_Period() public endWithStopPrank() {
        _transferVolumeRuleWithSupplySet();
        vm.startPrank(user1);
        /// now move a little over 2 hours into the future to make sure the next block will work
        vm.warp(Blocktime + 121 minutes);
        // assertFalse(isWithinPeriod2(Blocktime, 2, Blocktime));
        testCaseNFT.safeTransferFrom(user1, user2, 1);
        /// now violate the rule in this block and ensure revert
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 2);
        /// now move 1 day into the future and try again
        vm.warp(Blocktime + 1 days);
        testCaseNFT.safeTransferFrom(user1, user2, 2);
        /// once again, break the rule
        vm.expectRevert(0x009da0ce);
        testCaseNFT.safeTransferFrom(user1, user2, 3);
    }

    function testERC721_ERC721CommonTests_TokenMinHoldTime_Fail() public endWithStopPrank() {
        /// set the rule for 24 hours
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(24);
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        vm.startPrank(user1);
        // transfer should fail
        vm.expectRevert(0x5f98112f);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
    }

    function testERC721_ERC721CommonTests_TokenMinHoldTime_Period() public endWithStopPrank() {
        /// set the rule for 24 hours
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(24); 
        switchToAppAdministrator();
        // mint 1 nft to non admin user(this should set their ownership start time)
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        vm.startPrank(user1);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 1 days;
        vm.warp(Blocktime);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
        // the original owner was able to transfer but the new owner should not be able to because the time resets
        vm.startPrank(user2);
        vm.expectRevert(0x5f98112f);
        testCaseNFT.safeTransferFrom(user2, user1, 0);
        // move forward under the threshold and ensure it fails
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);
        vm.expectRevert(0x5f98112f);
        testCaseNFT.safeTransferFrom(user2, user1, 0);
    }

    function testERC721_ERC721CommonTests_TokenMinHoldTime_UpdatedRule() public endWithStopPrank() {
        // now change the rule hold hours to 2 and it should pass
        switchToRuleAdmin();
        setTokenMinHoldTimeRule(2); 
        switchToAppAdministrator();
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        // move forward in time 1 day and it should pass
        Blocktime = Blocktime + 2 hours;
        vm.warp(Blocktime);

        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0);
    }

    function testERC721_ERC721CommonTests_CollectionTokenMaxSupplyVolatility_Fail() public endWithStopPrank() {
        _collectionTokenMaxSupplyVolatilitySetup();
        switchToAppAdministrator();
        /// fail transactions (mint and burn with passing transfers)
        bytes4 selector = bytes4(keccak256("OverMaxSupplyVolatility()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
    }

    function testERC721_ERC721CommonTests_CollectionTokenMaxSupplyVolatility_Burning() public endWithStopPrank() {
        _collectionTokenMaxSupplyVolatilitySetup();
        vm.startPrank(user1);
        ERC721Burnable(address(testCaseNFT)).burn(10);
        /// move out of rule period
        vm.warp(Blocktime + 36 hours);
        /// burn tokens (should pass)
        ERC721Burnable(address(testCaseNFT)).burn(11);
        /// mint
        switchToAppAdministrator();
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
    }

    function testERC721_ERC721CommonTests_NFTValuationOrig_Fails() public endWithStopPrank() {
        /// retest rule to ensure proper valuation totals
        /// user 2 has access level 1 and can hold balance of 1
        _NFTValuationOrigSetup();
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);
        /// user 1 has access level of 2 and can hold balance of 10 (currently above this after admin transfers)
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        testCaseNFT.transferFrom(user2, user1, 1);
    } 

    function testERC721_ERC721CommonTests_NFTValuationOrig_IncreaseAccessLevel() public endWithStopPrank() {
        _NFTValuationOrigSetup();
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);
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
        vm.startPrank(user2);
        testCaseNFT.transferFrom(user2, user1, 1);
    }

    function testERC721_ERC721CommonTests_NFTValuationOrig_AdjustValuation() public endWithStopPrank() {
        _NFTValuationOrigSetup();
        /// adjust nft valuation limit to ensure we revert back to individual pricing
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(50);
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);
        /// fails because valuation now prices each individual token so user 1 has $221USD account value
        vm.startPrank(user2);
        vm.expectRevert(0xaee8b993);
        testCaseNFT.transferFrom(user2, user1, 1);
    }

    function testERC721_ERC721CommonTests_NFTValuationOrig_Burning() public endWithStopPrank() {
        _NFTValuationOrigSetup();
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);
        vm.startPrank(user2);
        /// test burn with rule active user 2
        ERC721Burnable(address(testCaseNFT)).burn(1);
        /// test burns with user 1
        vm.startPrank(user1);
        ERC721Burnable(address(testCaseNFT)).burn(3);
        applicationNFTv2.burn(36);
    }

    function testERC721_ERC721CommonTests_UpgradeAppManager721_ZeroAddress() public endWithStopPrank() {
        _upgradeAppManager721Setup();
        switchToAppAdministrator();
        // zero address
        vm.expectRevert(0xd92e233d);
        ProtocolTokenCommon(address(testCaseNFT)).proposeAppManagerAddress(address(0));
    }

    function testERC721_ERC721CommonTests_UpgradeAppManager721_NoProposedAddress() public endWithStopPrank() {
        _upgradeAppManager721Setup();
        switchToAppAdministrator();
        // no proposed address
        vm.expectRevert(0x821e0eeb);
        applicationAppManager2.confirmAppManager(address(testCaseNFT));
    }

    function testERC721_ERC721CommonTests_UpgradeAppManager721_NonProposerConfirms() public endWithStopPrank() {
        _upgradeAppManager721Setup();
        switchToAppAdministrator();
        // non proposer tries to confirm
        ProtocolTokenCommon(address(testCaseNFT)).proposeAppManagerAddress(address(applicationAppManager2));
        ApplicationAppManager applicationAppManager3 = new ApplicationAppManager(newAdmin, "Castlevania3", false);
        switchToNewAdmin();
        applicationAppManager3.addAppAdministrator(address(appAdministrator));
        switchToAppAdministrator();
        vm.expectRevert(0x41284967);
        applicationAppManager3.confirmAppManager(address(testCaseNFT));
    }

    function testERC721_ERC721CommonTests_TokenMaxBuyVolumeRule_Fail() public endWithStopPrank {
        _tokenMaxBuyVolumeRuleSetup();
        uint16 tokenPercentage = 10; /// 1%
        vm.startPrank(user);
        vm.expectRevert(0x6a46d1f4);
        _testBuyNFT(tokenPercentage, amm);
        /// switch users and test rule still fails
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x6a46d1f4);
        _testBuyNFT(tokenPercentage + 1, amm);
    } 

    function testERC721_ERC721CommonTests_TokenMaxBuyVolumeRule_Period() public endWithStopPrank {
        _tokenMaxBuyVolumeRuleSetup();
        uint16 tokenPercentage = 10; /// 1%

        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testBuyNFT(tokenPercentage + 1, amm);
        /// with another user
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we have to do this manually since the _testBuyNFT uses the *user* acccount
        _testBuyNFT(tokenPercentage + 2, amm);
    }

    function testERC721_ERC721CommonTests_TokenMaxSellVolumeRule_Fail() public endWithStopPrank {
        _tokenMaxSellVolumeRuleSetup();
        uint16 tokenPercentageSell = 30; /// 0.30%
        /// If try to sell one more, it should fail in this period.
        vm.startPrank(user);
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + tokenPercentageSell, amm);
        /// switch users and test rule still fails
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + 100 + 1, amm);
    }

    function testERC721_ERC721CommonTests_TokenMaxSellVolumeRule_Period() public endWithStopPrank {
        _tokenMaxSellVolumeRuleSetup();
        uint16 tokenPercentageSell = 30; /// 0.30%
        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testSellNFT(erc721Liq / 2 + tokenPercentageSell + 1, amm);
        /// with another user
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        _testSellNFT(erc721Liq / 2 + 100 + 2, amm);
    }

    function testERC721_ERC721CommonTests_AccountMaxSellSize_Fail() public endWithStopPrank {
        _accountMaxSellSizeSetup(true);
        switchToUser();
        /// Swap that fails
        vm.expectRevert(0x91985774);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

   function testERC721_ERC721CommonTests_AccountMaxSellSize_Period() public endWithStopPrank {
        _accountMaxSellSizeSetup(true);
        switchToUser();
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_ERC721CommonTests_AccountMaxSellSize_BlankTag_Fail() public endWithStopPrank {
        _accountMaxSellSizeSetup(false);
        switchToUser();
        /// Swap that fails
        vm.expectRevert(0x91985774);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_ERC721CommonTests_AccountMaxSellSize_BlankTag_Period() public endWithStopPrank {
        _accountMaxSellSizeSetup(false);
        switchToUser();
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testSellNFT(erc721Liq / 2 + 2, amm);
    }

    function testERC721_ERC721CommonTests_AccountMaxBuySizeRule_Fail() public endWithStopPrank {
        _accountMaxBuySizeRuleSetup();
        switchToUser();
        /// Swap that fails
        vm.expectRevert(0xa7fb7b4b);
        _testBuyNFT(1, amm);
    }

    function testERC721_ERC721CommonTests_AccountMaxBuySizeRule_Period() public endWithStopPrank {
        _accountMaxBuySizeRuleSetup();
        switchToUser();
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _testBuyNFT(1, amm);
    }

    function testERC721_ERC721CommonTests_TokenMaxSellVolumeRuleByPasserRule_AllowListPass() public endWithStopPrank {
        uint16 tokenPercentageSell = 30; /// 0.30%
        _tokenMaxSellVolumeRuleByPasserRuleSetup();
        /// ALLOWLISTED USER
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going above rule percentage in the period is ok for user (... + 1)
        for (uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 + 1; i++) {
            _testSellNFT(i, amm);
        }
    }

    function testERC721_ERC721CommonTests_TokenMaxSellVolumeRuleByPasserRule_NotAllowListPass() public endWithStopPrank {
        uint16 tokenPercentageSell = 30; /// 0.30%
        _tokenMaxSellVolumeRuleByPasserRuleSetup();
        /// NOT ALLOWLISTED USER
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going right below the rule percentage in the period (... - 1)
        for (uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++) {
            _testSellNFT(i, amm);
        }
    }

    function testERC721_ERC721CommonTests_TokenMaxSellVolumeRuleByPasserRule_Fail() public endWithStopPrank {
        uint16 tokenPercentageSell = 30; /// 0.30%
        _tokenMaxSellVolumeRuleByPasserRuleSetup();
        vm.startPrank(user1);
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        /// we test going right below the rule percentage in the period (... - 1)
        for (uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++) {
            _testSellNFT(i, amm);
        }
        /// and now we test the actual rule with a non-allowlisted address to check it will fail
        vm.expectRevert(0x806a3391);
        _testSellNFT(erc721Liq / 2 + 100 + (erc721Liq * tokenPercentageSell) / 10000, amm);
    }

    /* TokenMaxDailyTrades */
    function testERC721_ERC721CommonTests_TokenMaxDailyTradesAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape1", "DiscoPunk", 1, 5);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape2", "DiscoPunk", 1, 15);
        ruleIds[2] = createTokenMaxDailyTradesRule("BoredGrape3", "DiscoPunk", 1, 25);
        ruleIds[3] = createTokenMaxDailyTradesRule("BoredGrape4", "DiscoPunk", 1, 35);
        ruleIds[4] = createTokenMaxDailyTradesRule("BoredGrape5", "DiscoPunk", 1, 45);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxDailyTradesRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BURN));
    }

    function testERC721_ERC721CommonTests_TokenMaxDailyTradesAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape1", "DiscoPunk", 1, 5);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape2", "DiscoPunk", 1, 15);
        ruleIds[2] = createTokenMaxDailyTradesRule("BoredGrape3", "DiscoPunk", 1, 25);
        ruleIds[3] = createTokenMaxDailyTradesRule("BoredGrape4", "DiscoPunk", 1, 35);
        ruleIds[4] = createTokenMaxDailyTradesRule("BoredGrape5", "DiscoPunk", 1, 45);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions

        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxDailyTradesRule("BoredGrape6", "DiscoPunk", 1, 65);
        ruleIds[1] = createTokenMaxDailyTradesRule("BoredGrape7", "DiscoPunk", 1, 75);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxDailyTradesRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.MINT), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxDailyTradesId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxDailyTradesActive(ActionTypes.BURN));
    }

    /* TokenMaxSupplyVolatility */
    function testERC721_ERC721CommonTests_TokenMaxSupplyVolatilityAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2000, 4, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(3000, 5, Blocktime, 0);
        ruleIds[2] = createTokenMaxSupplyVolatilityRule(4000, 6, Blocktime, 0);
        ruleIds[3] = createTokenMaxSupplyVolatilityRule(5000, 7, Blocktime, 0);
        ruleIds[4] = createTokenMaxSupplyVolatilityRule(6000, 8, Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    function testERC721_ERC721CommonTests_TokenMaxSupplyVolatilityAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2000, 4, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(3000, 5, Blocktime, 0);
        ruleIds[2] = createTokenMaxSupplyVolatilityRule(4000, 6, Blocktime, 0);
        ruleIds[3] = createTokenMaxSupplyVolatilityRule(5000, 7, Blocktime, 0);
        ruleIds[4] = createTokenMaxSupplyVolatilityRule(6000, 8, Blocktime, 0);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions

        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxSupplyVolatilityRule(2011, 6, Blocktime, 0);
        ruleIds[1] = createTokenMaxSupplyVolatilityRule(2022, 7, Blocktime, 0);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxSupplyVolatilityRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.MINT), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxSupplyVolatilityId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxSupplyVolatilityActive(ActionTypes.BURN));
    }

    /* TokenMaxTradingVolume */
    function testERC721_ERC721CommonTests_TokenMaxTradingVolumeAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxTradingVolumeRule(1000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(2000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[2] = createTokenMaxTradingVolumeRule(3000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[3] = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[4] = createTokenMaxTradingVolumeRule(5000, 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

    function testERC721_ERC721CommonTests_TokenMaxTradingVolumeAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMaxTradingVolumeRule(1000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(2000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[2] = createTokenMaxTradingVolumeRule(3000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[3] = createTokenMaxTradingVolumeRule(4000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[4] = createTokenMaxTradingVolumeRule(5000, 2, Blocktime, 100_000 * ATTO);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMaxTradingVolumeRule(6000, 2, Blocktime, 100_000 * ATTO);
        ruleIds[1] = createTokenMaxTradingVolumeRule(7000, 2, Blocktime, 100_000 * ATTO);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMaxTradingVolumeRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.MINT), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMaxTradingVolumeId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMaxTradingVolumeActive(ActionTypes.BURN));
    }

    /* TokenMinHoldTime */
    function testERC721_ERC721CommonTests_TokenMinHoldTimeAtomicFullSet() public {
        uint32[] memory periods = new uint32[](5);
        // Set up rule
        periods[0] = 1;
        periods[1] = 2;
        periods[2] = 3;
        periods[3] = 4;
        periods[4] = 5;
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), periods[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.SELL), periods[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BUY), periods[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.MINT), periods[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BURN), periods[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BURN));
    }

    function ttestERC721_ERC721CommonTests_TokenMinHoldTimeAtomicFullReSet() public {
        uint32[] memory periods = new uint32[](5);
        // Set up rule
        periods[0] = 1;
        periods[1] = 2;
        periods[2] = 3;
        periods[3] = 4;
        periods[4] = 5;
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        periods = new uint32[](2);
        periods[0] = 6;
        periods[1] = 7;
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMinHoldTimeRuleFull(address(applicationNFTHandler), actions, periods);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.SELL), periods[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BUY), periods[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.MINT), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinHoldTimePeriod(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinHoldTimeActive(ActionTypes.BURN));
    }

    /* AccountApproveDenyOracle */
    function testERC721_ERC721CommonTests_AccountApproveDenyOracleAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for (uint i; i < 5; i++) {
            for (uint j; j < 5; j++) {
                actions[mainIndex] = ActionTypes(actionIndex);
                ruleIds[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }

        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly and are active(Had to go old school with control break logic)
        mainIndex = 0;
        uint256 internalIndex;
        ActionTypes lastAction;
        for (uint i; i < 5; i++) {
            if (actions[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 5; j++) {
                assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex])[internalIndex], ruleIds[mainIndex]);
                assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex], ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
    }

    function testERC721_ERC721CommonTests_AccountApproveDenyOracleAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](25);
        ActionTypes[] memory actions = new ActionTypes[](25);
        // Set up rule
        uint256 actionIndex;
        uint256 mainIndex;
        for (uint i; i < 5; i++) {
            for (uint j; j < 5; j++) {
                actions[mainIndex] = ActionTypes(actionIndex);
                ruleIds[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }

        // Apply the rules to all actions
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        uint32[] memory ruleIds2 = new uint32[](24);
        ActionTypes[] memory actions2 = new ActionTypes[](24);
        actionIndex = 0;
        mainIndex = 0;
        for (uint i; i < 3; i++) {
            for (uint j; j < 8; j++) {
                actions2[mainIndex] = ActionTypes(actionIndex);
                ruleIds2[mainIndex] = createAccountApproveDenyOracleRule(0);
                mainIndex++;
            }
            actionIndex++;
        }
        // Apply the new set of rules
        setAccountApproveDenyOracleRuleFull(address(applicationNFTHandler), actions2, ruleIds2);
        // Verify that all the rule id's were set correctly and are active(Had to go old school with control break logic)
        mainIndex = 0;
        uint256 internalIndex;
        ActionTypes lastAction;
        for (uint i; i < 3; i++) {
            if (actions2[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 8; j++) {
                assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions2[mainIndex])[internalIndex], ruleIds2[mainIndex]);
                assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions2[mainIndex], ruleIds2[mainIndex]));
                lastAction = actions2[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }

        // Verify that all the rule id's were cleared for the previous set of rules(Had to go old school with control break logic)
        mainIndex = 0;
        internalIndex = 0;
        lastAction = ActionTypes(0);
        for (uint i; i < 5; i++) {
            if (actions[mainIndex] != lastAction) {
                internalIndex = 0;
            }
            for (uint j; j < 5; j++) {
                uint32[] memory ruleIds3 = ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).getAccountApproveDenyOracleIds(actions[mainIndex]);
                // If a value was returned it must not match a previous rule
                if (ruleIds3.length > 0) {
                    assertFalse(ruleIds3[internalIndex] == ruleIds[mainIndex]);
                }
                assertFalse(ERC20NonTaggedRuleFacet(address(applicationNFTHandler)).isAccountApproveDenyOracleActive(actions[mainIndex], ruleIds[mainIndex]));
                lastAction = actions[mainIndex];
                internalIndex++;
                mainIndex++;
            }
        }
    }

    /* TokenMinimumTransaction */
    function testERC721_ERC721CommonTests_TokenMinimumTransactionAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMinimumTransactionRule(1);
        ruleIds[1] = createTokenMinimumTransactionRule(2);
        ruleIds[2] = createTokenMinimumTransactionRule(3);
        ruleIds[3] = createTokenMinimumTransactionRule(4);
        ruleIds[4] = createTokenMinimumTransactionRule(5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BUY));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.MINT));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BURN));
    }

    function testERC721_ERC721CommonTests_TokenMinimumTransactionAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createTokenMinimumTransactionRule(1);
        ruleIds[1] = createTokenMinimumTransactionRule(2);
        ruleIds[2] = createTokenMinimumTransactionRule(3);
        ruleIds[3] = createTokenMinimumTransactionRule(4);
        ruleIds[4] = createTokenMinimumTransactionRule(5);
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createTokenMinimumTransactionRule(6);
        ruleIds[1] = createTokenMinimumTransactionRule(7);
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setTokenMinimumTransactionRuleFull(address(applicationNFTHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.MINT), 0);
        assertEq(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).getTokenMinTxSizeId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.SELL));
        assertTrue(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.MINT));
        assertFalse(ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).isTokenMinTxSizeActive(ActionTypes.BURN));
    }

    /* MinMaxTokenBalance */
    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceAtomicFullSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(1000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(2), createUint256Array(2000));
        ruleIds[2] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Tayler"), createUint256Array(3), createUint256Array(3000));
        ruleIds[3] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(4), createUint256Array(4000));
        ruleIds[4] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Shane"), createUint256Array(5), createUint256Array(5000));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER), ruleIds[0]);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL), ruleIds[1]);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY), ruleIds[2]);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT), ruleIds[3]);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN), ruleIds[4]);
        // Verify that all the rules were activated
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BUY));
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.MINT));
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BURN));
    }

    function testERC721_ERC721CommonTests_AccountMinMaxTokenBalanceAtomicFullReSet() public {
        uint32[] memory ruleIds = new uint32[](5);
        // Set up rule
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(1000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(2), createUint256Array(2000));
        ruleIds[2] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Tayler"), createUint256Array(3), createUint256Array(3000));
        ruleIds[3] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(4), createUint256Array(4000));
        ruleIds[4] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Michael"), createUint256Array(5), createUint256Array(5000));
        ActionTypes[] memory actions = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.BUY, ActionTypes.MINT, ActionTypes.BURN);
        // Apply the rules to all actions
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);

        // Reset with a partial list of rules and insure that the changes are saved correctly
        ruleIds = new uint32[](2);
        ruleIds[0] = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(10000));
        ruleIds[1] = createAccountMinMaxTokenBalanceRule(createBytes32Array("RJ"), createUint256Array(1), createUint256Array(20000));
        actions = createActionTypeArray(ActionTypes.SELL, ActionTypes.BUY);
        // Apply the new set of rules
        setAccountMinMaxTokenBalanceRuleFull(address(applicationCoinHandler), actions, ruleIds);
        // Verify that all the rule id's were set correctly
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.SELL), ruleIds[0]);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BUY), ruleIds[1]);
        // Verify that the old ones were cleared
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.P2P_TRANSFER), 0);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.MINT), 0);
        assertEq(ERC721TaggedRuleFacet(address(applicationCoinHandler)).getAccountMinMaxTokenBalanceId(ActionTypes.BURN), 0);
        // Verify that the new rules were activated
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.SELL));
        assertTrue(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BUY));
        // Verify that the old rules are not activated
        assertFalse(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        assertFalse(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.MINT));
        assertFalse(ERC721TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.BURN));
    }

    /// INTERNAL HELPER FUNCTIONS
    function _approveTokens(DummyNFTAMM amm, uint256 amountERC20, bool _isApprovalERC721) internal {
        applicationCoin.approve(address(amm), amountERC20);
        testCaseNFT.setApprovalForAll(address(amm), _isApprovalERC721);
    }

    function _safeMintERC721(uint256 amount) internal {
        for (uint256 i; i < amount; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        }
    }

    function _addLiquidityInBatchERC721(DummyNFTAMM amm, uint256 amount) private {
        for (uint256 i; i < amount; i++) {
            testCaseNFT.safeTransferFrom(appAdministrator, address(amm), i);
        }
    }

    function _testBuyNFT(uint256 _tokenId, DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(testCaseNFT), 10, _tokenId, true);
    }

    function _testSellNFT(uint256 _tokenId, DummyNFTAMM amm) internal {
        amm.dummyTrade(address(applicationCoin), address(testCaseNFT), 10, _tokenId, false);
    }

    function _fundThreeAccounts() internal endWithStopPrank {
        switchToAppAdministrator();
        applicationCoin.transfer(user, 1000 * ATTO);
        applicationCoin.transfer(user2, 1000 * ATTO);
        applicationCoin.transfer(user1, 1000 * ATTO);
        for (uint i = erc721Liq / 2; i < erc721Liq / 2 + 50; i++) {
            testCaseNFT.safeTransferFrom(appAdministrator, user, i);
        }
        for (uint i = erc721Liq / 2 + 100; i < erc721Liq / 2 + 150; i++) {
            testCaseNFT.safeTransferFrom(appAdministrator, user1, i);
        }
        for (uint i = erc721Liq / 2 + 200; i < erc721Liq / 2 + 250; i++) {
            testCaseNFT.safeTransferFrom(appAdministrator, user2, i);
        }
    }

    function _accountMinMaxTokenBalanceRuleSetup(bool tag) public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint 6 NFTs to appAdministrator for transfer
        for (uint i; i < 7; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        }

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        testCaseNFT.transferFrom(appAdministrator, rich_user, 0);
        testCaseNFT.transferFrom(appAdministrator, rich_user, 1);
        assertEq(testCaseNFT.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        testCaseNFT.transferFrom(appAdministrator, user1, 3);
        testCaseNFT.transferFrom(appAdministrator, user1, 4);
        assertEq(testCaseNFT.balanceOf(user1), 2);

        switchToAppAdministrator();
        if(tag) {
            ///Add Tag to account
            applicationAppManager.addTag(user1, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
            applicationAppManager.addTag(user2, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
            applicationAppManager.addTag(user3, "Oscar"); ///add tag
            assertTrue(applicationAppManager.hasTag(user3, "Oscar"));
            switchToRuleAdmin();
            ///update ruleId in application NFT handler
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array("Oscar"), createUint256Array(1), createUint256Array(6)); 
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        } else {
            switchToRuleAdmin();
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(3));
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        }

        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 3);
        assertEq(testCaseNFT.balanceOf(user2), 1);
        assertEq(testCaseNFT.balanceOf(user1), 1);
    }

    function _accountApproveDenyOracleSetup(bool deny) public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        assertEq(testCaseNFT.balanceOf(user1), 5);

        if(deny) {
            // add the rule.
            uint32 ruleId = createAccountApproveDenyOracleRule(0);
            setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
            // add a blocked address
            switchToAppAdministrator();
            badBoys.push(address(69));
            oracleDenied.addToDeniedList(badBoys);
        } else {
            uint32 ruleId = createAccountApproveDenyOracleRule(1);
            setAccountApproveDenyOracleRule(address(applicationNFTHandler), ruleId);
            // add an allowed address
            switchToAppAdministrator();
            goodBoys.push(address(user2));
            oracleApproved.addToApprovedList(goodBoys);
        }

        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 0);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function _tokenMaxDailyTradesSetup(bool tag) public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        assertEq(testCaseNFT.balanceOf(user1), 5);
        // add the rule.
        switchToRuleAdmin();
        if(tag) {
            uint32 ruleId = createTokenMaxDailyTradesRule("BoredGrape", "DiscoPunk", 1, 5);
            setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        } else {
            uint32 ruleId = createTokenMaxDailyTradesRule("", 1);
            setTokenMaxDailyTradesRule(address(applicationNFTHandler), ruleId);
        }
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addTag(address(testCaseNFT), "BoredGrape"); ///add tag

        // perform 1 transfer
        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);
        assertEq(testCaseNFT.balanceOf(user2), 1);
    }

    function _accountMaxTransactionValueByRiskScoreSetup(bool period) public endWithStopPrank() {
        switchToAppAdministrator();
        uint8[] memory riskScores = createUint8Array(0, 10, 40, 80);
        ///Mint NFT's (user1,2,3)
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }
        assertEq(testCaseNFT.balanceOf(user1), 5);

        for (uint i; i < 3; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user2);
        }
        assertEq(testCaseNFT.balanceOf(user2), 3);

        switchToRuleAdmin();
        if(period) {
            ///Set Rule in NFTHandler
            uint8 period = 24; 
            uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11), period);
            setAccountMaxTxValueByRiskRule(ruleId);
        } else {
            ///Set Rule in NFTHandler
            uint32 ruleId = createAccountMaxTxValueByRiskRule(riskScores, createUint48Array(17, 15, 12, 11));
            setAccountMaxTxValueByRiskRule(ruleId); 
        }
        ///Set Risk Scores for users
        switchToRiskAdmin();
        applicationAppManager.addRiskScore(user1, riskScores[0]);
        applicationAppManager.addRiskScore(user2, riskScores[1]);
        applicationAppManager.addRiskScore(user3, riskScores[2]);

        ///Set Pricing for NFTs 0-7
        switchToAppAdministrator();
        for (uint i; i < 8; i++ ) {
            erc721Pricer.setSingleNFTPrice(address(testCaseNFT), i, (10 + i) * ATTO);
        }
    }

    function _accountDenyForNoAccessLevelInNFTSetup() public endWithStopPrank() {
        switchToAppAdministrator();
        /// set up a non admin user an nft
        for (uint i; i < 5; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        assertEq(testCaseNFT.balanceOf(user1), 5);

        // apply the rule to the ApplicationERC721Handler
        switchToRuleAdmin();
        createAccountDenyForNoAccessLevelRule();
    }

    function _accountMinMaxTokenBalanceSetup(bool tag) public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint NFTs for users 1, 2, 3
        for (uint i; i < 3; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }

        for (uint i; i < 3; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user2);
        }

        for (uint i; i < 3; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user3);
        }

        /// Create Rule Params and create rule
        // Set up the rule conditions
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("MIN1", "MIN2", "MIN3");
        uint256[] memory minAmounts = createUint256Array(1, 2, 3); /// Represent min number of tokens held by user for Collection address
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        // 720 = one month 4380 = six months 17520 = two years
        uint16[] memory periods = createUint16Array(720, 4380, 17520);
        /// Add Tags to users
        switchToAppAdministrator();
        applicationAppManager.addTag(user1, "MIN1"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MIN1"));
        applicationAppManager.addTag(user2, "MIN2"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MIN2"));
        applicationAppManager.addTag(user3, "MIN3"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "MIN3"));
        /// Set rule bool to active
        switchToRuleAdmin();
        if(tag) {
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(accs, minAmounts, maxAmounts, periods);
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        } else {
            uint32 ruleId = createAccountMinMaxTokenBalanceRule(createBytes32Array(""), createUint256Array(1), createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000), createUint16Array(720));
            setAccountMinMaxTokenBalanceRule(address(applicationNFTHandler), ruleId);
        }

        /// Transfers passing (above min value limit)
        vm.startPrank(user1);
        testCaseNFT.safeTransferFrom(user1, user2, 0); ///User 1 has min limit of 1
        testCaseNFT.safeTransferFrom(user1, user3, 1);
        assertEq(testCaseNFT.balanceOf(user1), 1);

        vm.startPrank(user2);
        testCaseNFT.safeTransferFrom(user2, user1, 0); ///User 2 has min limit of 2
        testCaseNFT.safeTransferFrom(user2, user3, 3);
        assertEq(testCaseNFT.balanceOf(user2), 2);

        vm.startPrank(user3);
        testCaseNFT.safeTransferFrom(user3, user2, 3); ///User 3 has min limit of 3
        testCaseNFT.safeTransferFrom(user3, user1, 1);
        assertEq(testCaseNFT.balanceOf(user3), 3);
    } 

    function _adminMinTokenBalanceSetup() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint TokenId 0-6 to super admin
        for (uint i; i < 7; i++ ) {
            ProtocolERC721(address(testCaseNFT)).safeMint(ruleBypassAccount);
        }
        /// we create a rule that sets the minimum amount to 5 tokens to be transferable in 1 year
        switchToRuleAdmin();
        uint32 ruleId = createAdminMinTokenBalanceRule(5, uint64(block.timestamp + 365 days));
        setAdminMinTokenBalanceRule(address(applicationNFTHandler), ruleId);
        /// check that we cannot change the rule or turn it off while the current rule is still active
        vm.expectRevert(0xd66c3008);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).activateAdminMinTokenBalance(_createActionsArray(), false);
        vm.expectRevert(0xd66c3008);
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setAdminMinTokenBalanceId(_createActionsArray(), ruleId);

        switchToRuleBypassAccount();
        /// These transfers should pass
        testCaseNFT.safeTransferFrom(ruleBypassAccount, user1, 0);
        testCaseNFT.safeTransferFrom(ruleBypassAccount, user1, 1);
    }

    function _transferVolumeRuleSetup() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        vm.startPrank(user1);
        // transfer under the threshold
        testCaseNFT.safeTransferFrom(user1, user2, 0);
    }

    function _transferVolumeRuleWithSupplySet() public endWithStopPrank() {
        switchToAppAdministrator();
        // mint 10 nft's to non admin user
        for (uint i = 0; i < 10; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        }
        // apply the rule
        uint32 ruleId = createTokenMaxTradingVolumeRule(200, 2, Blocktime, 100);
        setTokenMaxTradingVolumeRule(address(applicationNFTHandler), ruleId);
        
    }

    function _collectionTokenMaxSupplyVolatilitySetup() public endWithStopPrank() {
        switchToAppAdministrator();
        /// Mint tokens to specific supply
        for (uint i = 0; i < 10; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        }

        /// set rule id and activate
        switchToRuleAdmin();
        uint32 ruleId = createTokenMaxSupplyVolatilityRule(2000, 24, Blocktime, 0);
        setTokenMaxSupplyVolatilityRule(address(applicationNFTHandler), ruleId);
        /// set blocktime to within rule period
        vm.warp(Blocktime + 13 hours);
        
        switchToAppAdministrator();
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
        /// mint tokens to the cap
        ProtocolERC721(address(testCaseNFT)).safeMint(user1);
    }

    function _NFTValuationOrigSetup() public endWithStopPrank() {
        switchToAppAdministrator();
        /// mint NFTs and set price to $1USD for each token
        for (uint i = 0; i < 10; i++) {
            ProtocolERC721(address(testCaseNFT)).safeMint(user1);
            erc721Pricer.setSingleNFTPrice(address(testCaseNFT), i, 1 * ATTO);
        }
        uint256 testPrice = erc721Pricer.getNFTPrice(address(testCaseNFT), 1);
        assertEq(testPrice, 1 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(testCaseNFT), 1 * ATTO);
        /// set the nftHandler nftValuationLimit variable
        switchToRuleAdmin();
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler)).setNFTValuationLimit(20);
        /// activate rule that calls valuation
        uint32 ruleId = createAccountMaxValueByAccessLevelRule(0, 1, 10, 50, 100);
        setAccountMaxValueByAccessLevelRule(ruleId);
        /// calc expected valuation based on tokenId's
        /**
         total valuation for user1 should be $10 USD
         10 tokens * 1 USD for each token 
         */

        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 2);
        applicationAppManager.addAccessLevel(user2, 1);

        vm.startPrank(user1);
        testCaseNFT.transferFrom(user1, user2, 1);

        vm.startPrank(user2);
        testCaseNFT.transferFrom(user2, user1, 1);

        /// switch to rule admin to deactive rule for set up
        switchToRuleAdmin();
        applicationHandler.activateAccountMaxValueByAccessLevel(false);

        switchToAppAdministrator();
        /// create new collection and mint enough tokens to exceed the nftValuationLimit set in handler
        applicationNFTv2 = new ApplicationERC721("ToughTurtles", "THTR", address(applicationAppManager), "https://SampleApp.io");
        console.log("applicationNFTv2", address(applicationNFTv2));
        applicationNFTHandler2 = _createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(applicationNFTHandler2)).initialize(address(ruleProcessor), address(applicationAppManager), address(applicationNFTv2));
        applicationNFTv2.connectHandlerToToken(address(applicationNFTHandler2));
        /// register the token
        applicationAppManager.registerToken("THTR", address(applicationNFTv2));

        for (uint i = 0; i < 40; i++) {
            applicationNFTv2.safeMint(appAdministrator);
            applicationNFTv2.transferFrom(appAdministrator, user1, i);
            erc721Pricer.setSingleNFTPrice(address(applicationNFTv2), i, 1 * ATTO);
        }
        uint256 testPrice2 = erc721Pricer.getNFTPrice(address(applicationNFTv2), 35);
        assertEq(testPrice2, 1 * ATTO);
        /// set the nftHandler nftValuationLimit variable
        switchToAppAdministrator();
        ERC721HandlerMainFacet(address(applicationNFTHandler2)).setNFTValuationLimit(20);
        /// set specific tokens in NFT 2 to higher prices. Expect this value to be ignored by rule check as it is checking collection price.
        erc721Pricer.setSingleNFTPrice(address(applicationNFTv2), 36, 100 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFTv2), 37, 50 * ATTO);
        erc721Pricer.setSingleNFTPrice(address(applicationNFTv2), 40, 25 * ATTO);
        erc721Pricer.setNFTCollectionPrice(address(applicationNFTv2), 1 * ATTO);

        ///reactivate rule
        switchToRuleAdmin();
        applicationHandler.activateAccountMaxValueByAccessLevel(true);
        /// calc expected valuation for user based on tokens * collection price
        /** 
        expected calculated total should be $50 USD since we take total number of tokens owned * collection price 
        10 PuddgyPenguins 
        40 ToughTurtles 
        50 total * collection prices of $1 usd each 
        */
    }

    function _upgradeAppManager721Setup() public endWithStopPrank() {
        switchToAppAdministrator();
        address newAdmin = address(75);
        /// create a new app manager
        applicationAppManager2 = new ApplicationAppManager(newAdmin, "Castlevania2", false);
        /// propose a new AppManager
        ProtocolTokenCommon(address(testCaseNFT)).proposeAppManagerAddress(address(applicationAppManager2));
        switchToNewAdmin();
        applicationAppManager2.addAppAdministrator(address(appAdministrator));
        
        /// confirm the app manager
        switchToAppAdministrator();
        applicationAppManager2.confirmAppManager(address(testCaseNFT));
        /// test to ensure it still works
        ProtocolERC721(address(testCaseNFT)).safeMint(appAdministrator);
        switchToAppAdministrator();
        testCaseNFT.transferFrom(appAdministrator, user, 0);
        assertEq(testCaseNFT.balanceOf(appAdministrator), 0);
        assertEq(testCaseNFT.balanceOf(user), 1);
    }

    function setupTradingRuleTests() internal returns (DummyNFTAMM) {
        amm = new DummyNFTAMM();
        _safeMintERC721(erc721Liq);
        _approveTokens(amm, erc20Liq, true);
        _addLiquidityInBatchERC721(amm, erc721Liq / 2); /// half of total supply
        applicationCoin.mint(appAdministrator, 1_000_000 * ATTO);
        applicationCoin.transfer(address(amm), erc20Liq);
        return amm;
    }

    function _tokenMaxSellVolumeRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// now we setup the sell percentage rule
        uint32 ruleId = createTokenMaxSellVolumeRule(30, 24, 0, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationNFTHandler), ruleId);
        vm.warp(Blocktime + 36 hours);
        /// now we test
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);

        uint16 tokenPercentageSell = 30; /// 0.30%
        /// we test selling the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for (uint i = erc721Liq / 2; i < erc721Liq / 2 + (erc721Liq * tokenPercentageSell) / 10000 - 1; i++) {
            _testSellNFT(i, amm);
        }
    }

    function _accountMaxSellSizeSetup(bool tag) public endWithStopPrank {
        switchToAppAdministrator();
        amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        if(tag) {
            uint32 ruleId = createAccountMaxSellSizeRule("AccountMaxSellSize", 1, 36); /// tag, maxNFtsPerPeriod, period
            setAccountMaxSellSizeRule(address(applicationNFTHandler), ruleId);
        } else {
            uint32 ruleId = createAccountMaxSellSizeRule("", 1, 36); /// tag, maxNFtsPerPeriod, period
            setAccountMaxSellSizeRule(address(applicationNFTHandler), ruleId);
        }

        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "AccountMaxSellSize");

        /// Swap that passes rule check
        switchToUser();
        testCaseNFT.setApprovalForAll(address(amm), true);
        _testSellNFT(erc721Liq / 2 + 1, amm);
    }

    function _tokenMaxSellVolumeRuleByPasserRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        amm = setupTradingRuleTests();
        _fundThreeAccounts();
        switchToAppAdministrator();
        applicationAppManager.approveAddressToTradingRuleAllowlist(user, true);

        /// SELL PERCENTAGE RULE
        uint32 ruleId = createTokenMaxSellVolumeRule(30, 24, 0, Blocktime);
        setTokenMaxSellVolumeRule(address(applicationNFTHandler), ruleId);
        vm.warp(Blocktime + 36 hours);
    }

    function _tokenMaxBuyVolumeRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set up rule
        uint32 ruleId = createTokenMaxBuyVolumeRule(10, 24, 0, Blocktime);
        setTokenMaxBuyVolumeRule(address(applicationNFTHandler), ruleId);
        /// we make sure we are in a new period
        vm.warp(Blocktime + 36 hours);

        /// test swap below percentage
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);

        uint16 tokenPercentage = 10; /// 1%
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for (uint i; i < (erc721Liq * tokenPercentage) / 10000 - 1; i++) {
            _testBuyNFT(i, amm);
        }
    } 

    function _accountMaxBuySizeRuleSetup() public endWithStopPrank {
        switchToAppAdministrator();
        amm = setupTradingRuleTests();
        _fundThreeAccounts();
        /// set the rule
        uint32 ruleId = createAccountMaxBuySizeRule("MaxBuySize", 1, 36); /// tag, maxNFtsPerPeriod, period
        setAccountMaxBuySizeRule(address(applicationNFTHandler), ruleId);
        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addTag(user, "MaxBuySize");
        testCaseNFT.setApprovalForAll(address(amm), true);

        /// Swap that passes rule check
        switchToUser();
        _approveTokens(amm, 5 * 10 ** 8 * ATTO, true);
        _testBuyNFT(0, amm);
    }
}

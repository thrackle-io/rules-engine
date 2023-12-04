// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import {ApplicationAMMHandler} from "../../src/example/liquidity/ApplicationAMMHandler.sol";
import {ApplicationAMMHandlerMod} from "../helpers/ApplicationAMMHandlerMod.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LineInput} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolERC721AMMTest is TestCommonFoundry {
    ApplicationAMMHandler handler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationAMMHandler applicationAMMHandler;
    ApplicationAMMHandlerMod newAssetHandler;
    ProtocolAMMCalculatorFactory factory;

    address rich_user = address(44);
    address treasuryAddress = address(55);
    address user1 = address(0x111);
    address user2 = address(0x222);
    address user3 = address(0x333);
    address user4 = address(0x444);
    address[] badBoys;
    address[] goodBoys;
    address[] addresses = [user1, user2, user3, rich_user];
    uint256 erc20Liq = 1_000; // there will be no NFTs left outside the AMM. ERC20 liquidity should get filled by swaps. We only add some for tests (1 * 10 ** (-14)).
    uint256 erc721Liq = 10_000;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        /// we mint coins and nfts for the appAdmin
        applicationCoin.mint(appAdministrator, 1_000_000_000_000 * (ATTO));
        _safeMintERC721(10_000); 

        /// Set up the AMM
        protocolAMMFactory = createProtocolAMMFactory();
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        LineInput memory buy = LineInput(1 * 10 ** 6, 30 * ATTO); /// buy slope = 0.01; b = 30
        LineInput memory sell = LineInput(9 * 10 ** 5, 29 * ATTO); /// sell slope = 0.009; b = 29
        dualLinearERC271AMM = ProtocolERC721AMM(protocolAMMFactory.createDualLinearERC721AMM(address(applicationCoin), address(applicationNFT), buy, sell, address(applicationAppManager)));
        handler = new ApplicationAMMHandler(address(applicationAppManager), address(ruleProcessor), address(dualLinearERC271AMM));
        dualLinearERC271AMM.connectHandlerToAMM(address(handler));
        applicationAMMHandler = ApplicationAMMHandler(dualLinearERC271AMM.getHandlerAddress());
        applicationAppManager.registerAMM(address(dualLinearERC271AMM));
        dualLinearERC271AMM.setTreasuryAddress(treasuryAddress);
        applicationAppManager.registerTreasury(treasuryAddress);

        vm.warp(Blocktime);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }


    function testAMMERC721NegNotEnumerable() public{
        ERC721 notEnumNFT = new ERC721("NotEnum","NE");
        LineInput memory buy = LineInput(1 * 10 ** 6, 30 * ATTO); /// buy slope = 0.01; b = 30
        LineInput memory sell = LineInput(9 * 10 ** 5, 29 * ATTO); /// sell slope = 0.009; b = 29
        vm.expectRevert(abi.encodeWithSignature("NotEnumerable()"));
        dualLinearERC271AMM = ProtocolERC721AMM(protocolAMMFactory.createDualLinearERC721AMM(address(applicationCoin), address(notEnumNFT), buy, sell, address(applicationAppManager)));
    }


    function testAMMERC721DualLinearAddLiquidityBatch() public { 
        switchToAppAdministrator();
        /// Approve the transfer of tokens into AMM
        _approveTokens(erc20Liq, true);
        /// Transfer the tokens into the AMM
        _addLiquidityInBatchERC721(erc721Liq);
        dualLinearERC271AMM.addLiquidityERC20(erc20Liq);
        /// Make sure the tokens made it
        _checkLiquidity();
    }

    function testAMMERC721DualLinearAddLiquidityOneByOne() public {
        switchToAppAdministrator();
        /// Approve the transfer of tokens into AMM
        _approveTokens(erc20Liq, true);
        /// Transfer the tokens into the AMM
        _addAllLiquidityERC721OneByOne(erc721Liq);
        dualLinearERC271AMM.addLiquidityERC20(erc20Liq);
        /// Make sure the tokens made it
        _checkLiquidity();
    }

    
    function testAMMERC721DualLinearRemoveERC20sNegative() public {
        testAMMERC721DualLinearAddLiquidityBatch();
        /// try to remove more coins than what it has
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        dualLinearERC271AMM.removeERC20(erc20Liq + 1);
    }

    function testAMMERC721DualLinearRemoveERC20sPositive() public {
        testAMMERC721DualLinearAddLiquidityBatch();
        /// Get user's initial balance
        uint256 balanceAppAdmin = applicationCoin.balanceOf(appAdministrator);
        /// Remove some coins
        dualLinearERC271AMM.removeERC20(500 );
        /// Make sure they came back to admin
        assertEq(balanceAppAdmin + 500 , applicationCoin.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(erc20Liq - 500 , dualLinearERC271AMM.getERC20Reserves());
    }

    function testAMMERC721DualLinearRemoveERC721sPositive() public { 
        testAMMERC721DualLinearAddLiquidityBatch();
        /// Get user's initial balance
        uint256 balance = applicationNFT.balanceOf(appAdministrator);
        /// Remove some NFTs
        _removeLiquidityInBatchERC721(0, 500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationNFT.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(erc721Liq - 500, dualLinearERC271AMM.getERC721Reserves());
    }

    function testAMMERC721DualLinearSwapZeroAmountERC20() public { 
        testAMMERC721DualLinearAddLiquidityBatch();
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 500_000_000_000 * ATTO);
        switchToUser();
        /// Approve transfer
        applicationCoin.approve(address(dualLinearERC271AMM), 500_000_000_000 * ATTO);
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        dualLinearERC271AMM.swap(address(applicationCoin), 0, 123);
    }

    function testAMMERC721DualLinearSwapInvalidERC20Address() public { 
        testAMMERC721DualLinearAddLiquidityBatch();
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        switchToUser();
        ApplicationERC20 wrongCoin = new ApplicationERC20("WrongCoin", "WC", address(applicationAppManager));
        vm.expectRevert(abi.encodeWithSignature("TokenInvalid(address)", address(wrongCoin)));
        dualLinearERC271AMM.swap(address(wrongCoin), 100000, 123);
    }

    /// Test linear swaps
    function testAMMERC721DualLinearBuyNFT0() public { 
        testAMMERC721DualLinearSwapZeroAmountERC20();
        _testBuyNFT(0,  0);
    }

    function testAMMERC721DualLinearBuyNFT1() public {
        testAMMERC721DualLinearBuyNFT0();
        _testBuyNFT(1,  0);
    }

    function testAMMERC721DualLinearSellNFT0() public {
        // we cannot sell without having bought first since q can't be negative
        testAMMERC721DualLinearBuyNFT1(); // user buys NFTs 0 and 1
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        _testSellNFT(0,  0); // user sells back NFT 0
    }

    function testAMMERC721DualLinearSwapZeroAmountERC721() public { 
        testAMMERC721DualLinearBuyNFT0(); // user buys NFT with Id 0
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        dualLinearERC271AMM.swap(address(applicationNFT), 0, 123);
    }

     function testAMMERC721DualLinearRemoveERC721InvalidId() public { 
        testAMMERC721DualLinearBuyNFT0(); // user buys NFT with Id 0
        /// try to remove an NFT that the pool doesn't own
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("NotTheOwnerOfNFT(uint256)", 0));
        dualLinearERC271AMM.removeERC721(0);
    }

    function testAMMERC721DualLinearBuyAllNFTs() public{
         testAMMERC721DualLinearSwapZeroAmountERC20();
         uint256 balanceBefore = applicationCoin.balanceOf(user);
         for(uint i; i < erc721Liq; i++){
            _testBuyNFT(i,  0);
         }
         console.log("Spent buying all NFTs", balanceBefore - applicationCoin.balanceOf(user));
    }

    function testAMMERC721DualLinearSellAllNFTs() public{
         testAMMERC721DualLinearBuyAllNFTs();
         applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
         uint256 balanceBefore = applicationCoin.balanceOf(user);
         for(uint i; i < erc721Liq; i++){
            _testSellNFT(i,  0);
         }
         console.log("Made selling all NFTs", applicationCoin.balanceOf(user) - balanceBefore);
    }

    function testAMMERC721DualLinearSellRule() public {
         /// we pick up from this test
        testAMMERC721DualLinearBuyAllNFTs();
        /// set the rule
        _setSellRule("SellRule", 1, 36); /// tag, maxNFtsPerPeriod, period
        /// apply tag to user
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user, "SellRule");
        /// Swap that passes rule check
        switchToUser();
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        _sell(123);
        /// Swap that fails
        vm.expectRevert(0xc11d5f20);
        _sell(124);
        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _sell(124);
    }

    function testAMMERC721DualLinearFeeRule() public {
        uint256 testFees = 300;
        /// we pick up from this test
        testAMMERC721DualLinearAddLiquidityBatch();
        /// we add the rule.
        _setFeeRule(testFees);
        /// set the treasury address
        switchToAppAdministrator();
        dualLinearERC271AMM.setTreasuryAddress(treasuryAddress);
        applicationCoin.transfer(user, 500_000_000_000 * ATTO);
        /// we test
        switchToUser();
        /// Approve transfer
        _approveTokens(5 * 10 ** 9 * ATTO, true);
        /// we test buying all the NFTs with the testFees
        for(uint i; i < erc721Liq; i++){
            _testBuyNFT(i, testFees);
        }
        /// we test selling all the NFTs with the testFees
        for(uint i; i < erc721Liq; i++){
            _testSellNFT(i, testFees);
        }
    }
    
    function testAMMERC721DualLinearOracleRule() public {
        /// we pick up from this test
        testAMMERC721DualLinearAddLiquidityBatch();
        _fundThreeAccounts();
        // add a blocked address
        badBoys.push(user2);
        oracleRestricted.addToSanctionsList(badBoys);
        // add an allowed address
        goodBoys.push(user1);
        oracleAllowed.addToAllowList(goodBoys);

        /// SANCTION ORACLE
        /// we set the rule
        _setSanctionOracleRule();
        /// get the price
        (uint256 priceA, uint256 feesA) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFeesA = priceA + feesA;
        /// we test that bad boys can't trade
        vm.stopPrank();
        vm.startPrank(user2);
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x6bdfffc0);
        _buy(pricePlusFeesA, 345);
        /// this should go through since user is not a bad boy
        switchToUser();
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        _buy(pricePlusFeesA, 345);

        /// ALLOWLIST ORACLE
        /// we set the rule
        _setAllowedOracleRule();
        /// get the price
        (uint256 priceB, uint256 feesB) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFeesB = priceB + feesB;
        /// we test that not good boys can't trade
        switchToUser();
        vm.expectRevert(0x7304e213);
        _buy(pricePlusFeesB, 456);
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        _buy(pricePlusFeesB, 456);
    }


    function testAMMERC721DualLinearUpgradeHandler() public {
        /// Deploy the modified AMM Handler contract
        ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(applicationAppManager), address(ruleProcessor), address(dualLinearERC271AMM));
       
        /// connect AMM to new Handler
        dualLinearERC271AMM.connectHandlerToAMM(address(assetHandler));
        /// must deregister and reregister AMM
        applicationAppManager.deRegisterAMM(address(dualLinearERC271AMM));
        applicationAppManager.registerAMM(address(dualLinearERC271AMM));
        testAMMERC721DualLinearBuyAllNFTs();

        switchToSuperAdmin();
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        uint64[] memory startTime = new uint64[](1);
        accs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(1); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint16(36); ///Hours
        startTime[0] = uint64(Blocktime);

        /// Set the rule data
        applicationAppManager.addGeneralTag(user, "SellRule");
        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, startTime);
        ///update ruleId in application AMM rule handler
        assetHandler.setSellLimitRuleId(ruleId);
        /// Swap that passes rule check
        switchToUser();
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        _sell(123);

        /// Swap that fails
        vm.expectRevert(0xc11d5f20);
        _sell(124);

        /// we wait until the next period so user can swap again
        vm.warp(block.timestamp + 36 hours);
        _sell(124);
    }

    function testAMMERC721DualLinearPurchasePercentageRule() public {
        /// we pick up from this test
        testAMMERC721DualLinearAddLiquidityBatch();
        switchToAppAdministrator();
        _fundThreeAccounts();
        /// set up rule
        uint16 tokenPercentage = 100; /// 1% 
        _setPurchasePercentageRule(tokenPercentage, 24); /// 24 hour periods
        /// we make sure we are in a new period
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        switchToUser();
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        /// we test buying the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i; i < (erc721Liq * tokenPercentage) / 10000 - 1; i++){
            _testBuyNFT(i,  0);
        }
        /// we get the price manually since we will test reverts on buys
        (uint256 price, uint256 fees) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFees = price + fees;
        /// If try to buy one more, it should fail in this period.
        vm.expectRevert(0xb634aad9);
        _buy(pricePlusFees, 100);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0xb634aad9);
        _buy(pricePlusFees, 100);
        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testBuyNFT(100,  0);
        /// with another user
        vm.stopPrank();
        vm.startPrank(user1);
        /// we have to do this manually since the _testBuyNFT uses the *user* acccount
        (price, fees) = dualLinearERC271AMM.getBuyPrice();
        pricePlusFees = price + fees;
        _buy(pricePlusFees, 222);

    }

    function testAMMERC721DualLinearSellPercentageRule() public {
        /// We start the test by running the testAMMERC721DualLinearPurchasePercentageRule so we can have some 
        /// NFTs already bought by the users
        testAMMERC721DualLinearPurchasePercentageRule();
        switchToRuleAdmin();
        /// we turn off the purchase percentage rule
        applicationAMMHandler.activatePurchasePercentageRule(false);
        /// now we setup the sell percentage rule
        uint16 tokenPercentageSell = 30; /// 0.30%
        _setSellPercentageRule(tokenPercentageSell, 24); ///  24 hour periods
        vm.warp(Blocktime + 36 hours);
        /// now we test
        switchToUser();
        /// we test selling the *tokenPercentage* of the NFTs total supply -1 to get to the limit of the rule
        for(uint i; i < (erc721Liq * tokenPercentageSell) / 10000 - 1; i++){
            _testSellNFT(i,  0);
        }
        /// If try to sell one more, it should fail in this period.
        vm.expectRevert(0xb17ff693);
        _sell(30);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xb17ff693);
        _sell(222);
        /// let's go to another period
        vm.warp(Blocktime + 72 hours);
        switchToUser();
        /// now it should work
        _testSellNFT(30,  0);
        /// with another user
         vm.stopPrank();
        vm.startPrank(user1);
        _sell(222);

    }

    /// HELPER INTERNAL FUNCTIONS


    function _checkLiquidity() internal {
        /// Make sure the tokens made it
        assertEq(dualLinearERC271AMM.getERC20Reserves(),erc20Liq);
        assertEq(dualLinearERC271AMM.getERC721Reserves(), erc721Liq);
        /// another way of doing the same
        assertEq(applicationCoin.balanceOf(address(dualLinearERC271AMM)), erc20Liq);
        assertEq(applicationNFT.balanceOf(address(dualLinearERC271AMM)), erc721Liq);
    }

    function _safeMintERC721(uint256 amount) internal {
        for(uint256 i; i < amount; i++){
            applicationNFT.safeMint(appAdministrator);
        }
    }

    function _approveTokens(uint256 amountERC20, bool _isApprovalERC721) internal {
        applicationCoin.approve(address(dualLinearERC271AMM), amountERC20);
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), _isApprovalERC721);
    }

    function _addLiquidityInBatchERC721(uint256 amount) private {
        uint256[] memory nfts = new uint256[](amount);
        for(uint256 i; i < amount; i++){
            nfts[i] = i;
        }
        dualLinearERC271AMM.addLiquidityERC721InBatch(nfts);
    }

    function _addAllLiquidityERC721OneByOne(uint256 amount) private {
        for(uint256 i; i < amount; i++){
            dualLinearERC271AMM.addLiquidityERC721(i);
        }
    }

    function _removeLiquidityInBatchERC721(uint256 from, uint256 to) internal {
        for(uint256 i=from; i < to; i++){
            dualLinearERC271AMM.removeERC721(i);
        }
    }

    function _testBuyNFT(uint256 _tokenId, uint256 _fees) internal {
        switchToUser();

        uint256 price;
        uint256 fees; 
        uint256 pricePlusFees; 
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.getERC20Reserves();
        uint256 initialERC721Reserves = dualLinearERC271AMM.getERC721Reserves();
        
        if(_fees > 0){
            (price, fees) = _testFeesInPurchase(_tokenId, _fees);
            pricePlusFees = price + fees;
        }else{
            ( price, fees) = dualLinearERC271AMM.getBuyPrice();
            pricePlusFees = price + fees;
            _buy(pricePlusFees, _tokenId);
        }
        

        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.getERC20Reserves(), initialERC20Reserves + price);
        assertEq(dualLinearERC271AMM.getERC721Reserves(), initialERC721Reserves - 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance - pricePlusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance + 1);
    }

    function _testFeesInPurchase(uint256 _tokenId, uint256 _fees) internal returns(uint256 price, uint256 fees){
        (price, fees) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFees = price + fees;
        uint256 initialTreasuryBalance = applicationCoin.balanceOf(treasuryAddress);
        uint256 expectedFees = (price + fees) * _fees / 10000;
        assertEq(expectedFees, fees);

        _buy(pricePlusFees, _tokenId);

        uint256 treasuryBalance = applicationCoin.balanceOf(treasuryAddress);
        assertEq(treasuryBalance, initialTreasuryBalance + expectedFees);
    }

    function _buy(uint256 price, uint256 _tokenId) internal {
        dualLinearERC271AMM.swap(address(applicationCoin), price, _tokenId);
    }

    function _testSellNFT(uint256 _tokenId, uint256 _fees) internal {
        switchToUser();

        uint256 price;
        uint256 fees; 
        uint256 priceMinusFees; 
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.getERC20Reserves();
        uint256 initialERC721Reserves = dualLinearERC271AMM.getERC721Reserves();

        if(_fees > 0){
            (price, fees) = _testFeesInSale(_tokenId, _fees);
        }else{
            (price, fees) = dualLinearERC271AMM.getSellPrice();
            _sell(_tokenId);
        }
        priceMinusFees = price - fees;
        

        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.getERC20Reserves(), initialERC20Reserves - price);
        assertEq(dualLinearERC271AMM.getERC721Reserves(), initialERC721Reserves + 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance + priceMinusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance - 1);
    }

    function _testFeesInSale(uint256 _tokenId, uint256 _fees) internal returns(uint256 price, uint256 fees){
        uint256 initialTreasuryBalance = applicationCoin.balanceOf(treasuryAddress);
        (price, fees) = dualLinearERC271AMM.getSellPrice();
        uint256 expectedFees = (price) * _fees / 10000 ;
        assertEq(expectedFees, fees);

        _sell(_tokenId);
        
        uint256 treasuryBalance = applicationCoin.balanceOf(treasuryAddress);
        assertEq(treasuryBalance, initialTreasuryBalance + expectedFees);
    }

    function _sell(uint256 _tokenId) internal {
        dualLinearERC271AMM.swap(address(applicationNFT), 1, _tokenId);
    }

    function _setSellRule(bytes32 _tag, uint192 _sellAmount,  uint16 _sellPeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        uint64[] memory startTime = new uint64[](1);
        accs[0] = bytes32(_tag);
        sellAmounts[0] = _sellAmount; ///Amount to trigger Sell freeze rules
        sellPeriod[0] = _sellPeriod; ///Hours
        startTime[0] = uint64(Blocktime);
        ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, startTime);
        applicationAMMHandler.setSellLimitRuleId(ruleId);
    }

    function _setFeeRule(uint256 testFees) internal returns (uint32 ruleId){
        switchToRuleAdmin();
        /// make sure that no bogus fee percentage can get in
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 10001);
        vm.expectRevert(abi.encodeWithSelector(selector, 0));
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 0);
        /// now add the good rule
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), testFees);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);
    }

    function _setSanctionOracleRule() internal returns(uint32 ruleId){
        switchToRuleAdmin();
        ruleId = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(ruleId);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        applicationAMMHandler.setOracleRuleId(ruleId);
    }

    function _setAllowedOracleRule() internal returns(uint32 ruleId){
        switchToRuleAdmin();
        ruleId = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(ruleId);
        assertEq(rule.oracleType, 1);
        assertEq(rule.oracleAddress, address(oracleAllowed));
        applicationAMMHandler.setOracleRuleId(ruleId);
    }

    function _setPurchasePercentageRule(uint16 _tokenPercentage, uint16  _purchasePeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        uint16 tokenPercentage = _tokenPercentage; 
        uint16 purchasePeriod = _purchasePeriod; 
        uint256 totalSupply = 0;
        uint64 ruleStartTime = Blocktime;
        ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
    }

    function _setSellPercentageRule(uint16 _tokenPercentageSell, uint16  _sellPeriod) internal returns(uint32 ruleId){
        switchToRuleAdmin();
        uint16 tokenPercentageSell = _tokenPercentageSell; 
        uint16 sellPeriod = _sellPeriod;
        uint256 totalSupply = 0;
        uint64 ruleStartTime = Blocktime;
        ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentageSellRule(address(applicationAppManager), tokenPercentageSell, sellPeriod, totalSupply, ruleStartTime);
        applicationAMMHandler.setSellPercentageRuleId(ruleId);
    }

    function _fundThreeAccounts() internal {
        switchToAppAdministrator();
        applicationCoin.transfer(user, 50_000_000_000 * ATTO);
        applicationCoin.transfer(user2, 50_000_000_000 * ATTO);
        applicationCoin.transfer(user1, 50_000_000_000 * ATTO);
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
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
    uint256 erc20Liq = 1_000; // there will be only no NFTs left outside the AMM. ERC20 liquidity should get filled by swaps. We only add some for tests (1 * 10 ** (-14)).
    uint256 erc721Liq = 10_000;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();

        /// we mint coins and nfts for the appAdmin
        applicationCoin.mint(appAdministrator, 1_000_000_000_000 * (ATTO));
        _safeMintERC721(10_000); // usual amount of NFTs in a collection

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

    //Test adding liquidity to the AMM
    function testAddLiquidityDualLinearNFTAMM() public {
        switchToAppAdministrator();
        /// Approve the transfer of tokens into AMM
        _approveTokens(erc20Liq, true);

        /// Transfer the tokens into the AMM
        _addLiquidityInBatchERC721(erc721Liq);
        dualLinearERC271AMM.addLiquidityERC20(erc20Liq);
        
        /// Make sure the tokens made it
        assertEq(dualLinearERC271AMM.reserveERC20(),erc20Liq);
        assertEq(dualLinearERC271AMM.reserveERC721(), erc721Liq);
        /// another way of doing the same
        assertEq(applicationCoin.balanceOf(address(dualLinearERC271AMM)), erc20Liq);
        assertEq(applicationNFT.balanceOf(address(dualLinearERC271AMM)), erc721Liq);
    }

    
    function testNegativeRemoveERC20s() public {
        testAddLiquidityDualLinearNFTAMM();
        /// try to remove more coins than what it has
        vm.expectRevert(abi.encodeWithSignature("AmountExceedsBalance(uint256)", erc20Liq + 1));
        dualLinearERC271AMM.removeERC20(erc20Liq + 1);
    }

    function testRemoveERC20s() public {
        testAddLiquidityDualLinearNFTAMM();
        /// Get user's initial balance
        uint256 balanceAppAdmin = applicationCoin.balanceOf(appAdministrator);
        /// Remove some coins
        dualLinearERC271AMM.removeERC20(500 );
        /// Make sure they came back to admin
        assertEq(balanceAppAdmin + 500 , applicationCoin.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(erc20Liq - 500 , dualLinearERC271AMM.reserveERC20());
    }

    function testRemoveNFTs() public {
        testAddLiquidityDualLinearNFTAMM();
        /// Get user's initial balance
        uint256 balance = applicationNFT.balanceOf(appAdministrator);
        /// Remove some NFTs
        _removeLiquidityInBatchERC721(0, 500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationNFT.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(erc721Liq - 500, dualLinearERC271AMM.reserveERC721());
    }

    function testNegSwapZeroAmountERC20() public {
        testAddLiquidityDualLinearNFTAMM();
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 500_000_000_000 * ATTO);
        switchToUser();
        /// Approve transfer
        applicationCoin.approve(address(dualLinearERC271AMM), 500_000_000_000 * ATTO);
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        dualLinearERC271AMM.swap(address(applicationCoin), 0, 123);
    }

    function testNegInvalidERC20AddressForSwap() public {
        testAddLiquidityDualLinearNFTAMM();
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        switchToUser();
        ApplicationERC20 wrongCoin = new ApplicationERC20("WrongCoin", "WC", address(applicationAppManager));
        vm.expectRevert(abi.encodeWithSignature("TokenInvalid(address)", address(wrongCoin)));
        dualLinearERC271AMM.swap(address(wrongCoin), 100000, 123);
    }

    /// Test linear swaps
    function testBuyFirstNFT() public {
        testNegSwapZeroAmountERC20();
        _testBuyNFT(0, 0, address(0));
    }

    function testBuySecondNFT() public {
        testBuyFirstNFT();
        _testBuyNFT(1, 0, address(0));
    }

    function testSellFirstNFT() public {
        // we cannot sell without having bought first since q can't be negative
        testBuySecondNFT(); // user buys NFTs 0 and 1
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        _testSellNFT(0, 0, address(0)); // user sells back NFT 0
    }

    function testNegSwapZeroAmountERC721() public {
        testBuyFirstNFT(); // user buys NFT with Id 0
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        dualLinearERC271AMM.swap(address(applicationNFT), 0, 123);
    }

     function testNegativeRemoveERC721s() public {
        testBuyFirstNFT(); // user buys NFT with Id 0
        /// try to remove an NFT that the pool doesn't own
        switchToAppAdministrator();
        vm.expectRevert(abi.encodeWithSignature("NotTheOwnerOfNFT(uint256)", 0));
        dualLinearERC271AMM.removeERC721(0);
    }

    function testBuyAllNFTs() public{
         testNegSwapZeroAmountERC20();
         uint256 balanceBefore = applicationCoin.balanceOf(user);
         for(uint i; i < erc721Liq;){
            _testBuyNFT(i, 0, address(0));
            unchecked{
                ++i;
            }
         }
         console.log("Spent buying all NFTs", balanceBefore - applicationCoin.balanceOf(user));
    }

    function testSellAllNFTs() public{
         testBuyAllNFTs();
         applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
         uint256 balanceBefore = applicationCoin.balanceOf(user);
         for(uint i; i < erc721Liq;){
            _testSellNFT(i, 0, address(0));
            unchecked{
                ++i;
            }
         }
         console.log("Made selling all NFTs", applicationCoin.balanceOf(user) - balanceBefore);
    }

    
    function testSellRuleNFTAMM() public {
        testBuyAllNFTs();

        vm.stopPrank();
        vm.startPrank(superAdmin);
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
        applicationAMMHandler.setSellLimitRuleId(ruleId);
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

    function testSellRuleDualLinearNFTAMM() public {
        testBuyAllNFTs();

        vm.stopPrank();
        vm.startPrank(superAdmin);
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
        applicationAMMHandler.setSellLimitRuleId(ruleId);
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

    /// test AMM Fees
    function testDualLinearNFTAMMFees() public {
        uint256 testFees = 300;
        address testTreasury = address(99);

        testAddLiquidityDualLinearNFTAMM();
        /// we add the rule.
        switchToRuleAdmin();
        /// make sure that no bogus fee percentage can get in
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        uint32 ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 10001);
        vm.expectRevert(abi.encodeWithSelector(selector, 0));
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 0);
        /// now add the good rule
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), testFees);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);

        switchToAppAdministrator();
        /// set the treasury address
        dualLinearERC271AMM.setTreasuryAddress(testTreasury);
        applicationCoin.transfer(user, 500_000_000_000 * ATTO);

        switchToUser();
        /// Approve transfer
        _approveTokens(5 * 10 ** 9 * ATTO, true);

        for(uint i; i < erc721Liq;){
            _testBuyNFT(i, testFees,  testTreasury);
            unchecked{
                ++i;
            }
        }
        
        for(uint i; i < erc721Liq;){
            _testSellNFT(i, testFees,  testTreasury);
            unchecked{
                ++i;
            }
        }
    }

    
    function testAMMOracle() public {
        testAddLiquidityDualLinearNFTAMM();
        /// we add the rule.
        switchToRuleAdmin();

        // BLOCKLIST ORACLE
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        switchToAppAdministrator();
        applicationCoin.transfer(user, 50_000_000_000 * ATTO);
        applicationCoin.transfer(address(0xC1A), 50_000_000_000 * ATTO);
        applicationCoin.transfer(address(0xB0B), 50_000_000_000 * ATTO);
        // add a blocked address
        badBoys.push(address(0xC1A));
        oracleRestricted.addToSanctionsList(badBoys);
        switchToRuleAdmin();
        /// connect the rule to this handler
        applicationAMMHandler.setOracleRuleId(_index);

        (uint256 priceA, uint256 feesA) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFeesA = priceA + feesA;

        /// we test that bad boys can't trade
        vm.stopPrank();
        vm.startPrank(address(0xC1A));
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        vm.expectRevert(0x6bdfffc0);
        _buy(pricePlusFeesA, 345);
        /// this should go through since user is not a bad boy
        switchToUser();
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        _buy(pricePlusFeesA, 345);

        /// ALLOWLIST ORACLE
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationAMMHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(address(0xB0B));
        oracleAllowed.addToAllowList(goodBoys);

        (uint256 priceB, uint256 feesB) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFeesB = priceB + feesB;

        switchToUser();
        vm.expectRevert(0x7304e213);
        _buy(pricePlusFeesB, 456);
        vm.stopPrank();
        vm.startPrank(address(0xB0B));
        _approveTokens(5 * 10 ** 8 * ATTO, true);
        _buy(pricePlusFeesB, 456);
    }


    function testUpgradeHandlerAMM() public {
        /// Deploy the modified AMM Handler contract
        ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(applicationAppManager), address(ruleProcessor), address(dualLinearERC271AMM));
       
        /// connect AMM to new Handler
        dualLinearERC271AMM.connectHandlerToAMM(address(assetHandler));
        /// must deregister and reregister AMM
        applicationAppManager.deRegisterAMM(address(dualLinearERC271AMM));
        applicationAppManager.registerAMM(address(dualLinearERC271AMM));
        testBuyAllNFTs();

        vm.stopPrank();
        vm.startPrank(superAdmin);
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

    // /**
    //  * @dev this function tests the purchase percentage rule via AMM
    //  */
    // function testPurchasePercentageRule() public {
    //     /// initialize AMM and give two users more app tokens and "chain native" tokens
    //     initializeAMMAndUsers();
    //     applicationCoin2.transfer(user1, 50_000_000 * ATTO);
    //     applicationCoin2.transfer(user2, 30_000_000 * ATTO);
    //     applicationCoin.transfer(user1, 50_000_000 * ATTO);
    //     applicationCoin.transfer(user2, 30_000_000 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * ATTO);
    //     /// set up rule
    //     uint16 tokenPercentage = 5000; /// 50%
    //     uint16 purchasePeriod = 24; /// 24 hour periods
    //     uint256 totalSupply = 100_000_000;
    //     uint64 ruleStartTime = Blocktime;
    //     switchToRuleAdmin();
    //     uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
    //     /// add and activate rule
    //     applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
    //     vm.warp(Blocktime + 36 hours);
    //     /// test swap below percentage
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000); /// percentage limit hit now
    //     /// test swaps after we hit limit
    //     vm.expectRevert(0xb634aad9);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);
    //     /// switch users and test rule still fails
    //     vm.stopPrank();
    //     vm.startPrank(user2);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     vm.expectRevert(0xb634aad9);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);
    //     /// wait until new period
    //     vm.warp(Blocktime + 72 hours);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10_000_000);

    //     /// check that rule does not apply to coin 0 as this would be a sell
    //     dualLinearERC271AMM.swap(address(applicationCoin), 60_000_000);

    //     /// Low percentage rule checks
    //     switchToRuleAdmin();
    //     /// create new rule
    //     uint16 newTokenPercentage = 1; /// .01%
    //     uint256 newTotalSupply = 100_000;
    //     uint32 newRuleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(applicationAppManager), newTokenPercentage, purchasePeriod, newTotalSupply, ruleStartTime);
    //     /// add and activate rule
    //     applicationAMMHandler.setPurchasePercentageRuleId(newRuleId);
    //     vm.warp(Blocktime + 96 hours);
    //     /// test swap below percentage
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 1);

    //     vm.expectRevert(0xb634aad9);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 9);
    // }

    // function testSellPercentageRule() public {
    //     /// initialize AMM and give two users more app tokens and "chain native" tokens
    //     initializeAMMAndUsers();
    //     applicationCoin2.transfer(user1, 50_000_000 * ATTO);
    //     applicationCoin2.transfer(user2, 30_000_000 * ATTO);
    //     applicationCoin.transfer(user1, 50_000_000 * ATTO);
    //     applicationCoin.transfer(user2, 30_000_000 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * ATTO);
    //     /// set up rule
    //     uint16 tokenPercentage = 5000; /// 50%
    //     uint16 purchasePeriod = 24; /// 24 hour periods
    //     uint256 totalSupply = 100_000_000;
    //     uint64 ruleStartTime = Blocktime;
    //     switchToRuleAdmin();
    //     uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentageSellRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
    //     /// add and activate rule
    //     applicationAMMHandler.setSellPercentageRuleId(ruleId);
    //     vm.warp(Blocktime + 36 hours);
    //     /// test swap below percentage
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000); /// percentage limit hit now
    //     /// test swaps after we hit limit
    //     vm.expectRevert(0xb17ff693);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);
    //     /// switch users and test rule still fails
    //     vm.stopPrank();
    //     vm.startPrank(user2);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     vm.expectRevert(0xb17ff693);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);
    //     /// wait until new period
    //     vm.warp(Blocktime + 72 hours);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10_000_000);

    //     /// check that rule does not apply to coin 0 as this would be a sell
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 60_000_000);
    // }


    /// HELPER INTERNAL FUNCTIONS

    function _safeMintERC721(uint256 amount) internal {
        for(uint256 i; i < amount;){
            applicationNFT.safeMint(appAdministrator);
            unchecked{
                ++i;
            }
        }
    }

    function _approveTokens(uint256 amountERC20, bool _isApprovalERC721) internal {
        applicationCoin.approve(address(dualLinearERC271AMM), amountERC20);
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), _isApprovalERC721);
    }

    function _addLiquidityInBatchERC721(uint256 amount) private {
        for(uint256 i; i < amount;){
            dualLinearERC271AMM.addLiquidityERC721(i);
            unchecked{
                ++i;
            }
        }
    }

    function _removeLiquidityInBatchERC721(uint256 from, uint256 to) internal {
        for(uint256 i=from; i < to;){
            dualLinearERC271AMM.removeERC721(i);
            unchecked{
                ++i;
            }
        }
    }

    function _testBuyNFT(uint256 _tokenId, uint256 _fees, address treasury) internal {
        switchToUser();

        uint256 price;
        uint256 fees; 
        uint256 pricePlusFees; 
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.reserveERC20();
        uint256 initialERC721Reserves = dualLinearERC271AMM.reserveERC721();
        
        if(_fees > 0){
            (price, fees) = _testBuyWithFee(_tokenId, _fees, treasury);
        }else{
            ( price, fees) = dualLinearERC271AMM.getBuyPrice();
            _buy(pricePlusFees, _tokenId);
        }
        pricePlusFees = price + fees;

        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.reserveERC20(), initialERC20Reserves + price);
        assertEq(dualLinearERC271AMM.reserveERC721(), initialERC721Reserves - 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance - pricePlusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance + 1);
    }

    function _testBuyWithFee(uint256 _tokenId, uint256 _fees, address treasury) internal returns(uint256 price, uint256 fees){
        (price, fees) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFees = price + fees;
        uint256 initialTreasuryBalance = applicationCoin.balanceOf(treasury);
        uint256 expectedFees = (price + fees) * _fees / 10000;
        assertEq(expectedFees, fees);

        _buy(pricePlusFees, _tokenId);

        uint256 treasuryBalance = applicationCoin.balanceOf(treasury);
        assertEq(treasuryBalance, initialTreasuryBalance + expectedFees);
    }

    function _buy(uint256 price, uint256 _tokenId) internal {
        dualLinearERC271AMM.swap(address(applicationCoin), price, _tokenId);
    }

    function _testSellNFT(uint256 _tokenId, uint256 _fees, address trasury) internal {
        switchToUser();

        uint256 price;
        uint256 fees; 
        uint256 priceMinusFees; 
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.reserveERC20();
        uint256 initialERC721Reserves = dualLinearERC271AMM.reserveERC721();

        if(_fees > 0){
            (price, fees) = _testSellWithFee(_tokenId, _fees, trasury);
        }else{
            (price, fees) = dualLinearERC271AMM.getSellPrice();
            _sell(_tokenId);
        }
        priceMinusFees = price - fees;
        

        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.reserveERC20(), initialERC20Reserves - price);
        assertEq(dualLinearERC271AMM.reserveERC721(), initialERC721Reserves + 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance + priceMinusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance - 1);
    }

    function _testSellWithFee(uint256 _tokenId, uint256 _fees, address treasury) internal returns(uint256 price, uint256 fees){
        uint256 initialTreasuryBalance = applicationCoin.balanceOf(treasury);
        (price, fees) = dualLinearERC271AMM.getSellPrice();
        uint256 expectedFees = (price) * _fees / 10000 ;
        assertEq(expectedFees, fees);

        _sell(_tokenId);
        
        uint256 treasuryBalance = applicationCoin.balanceOf(treasury);
        assertEq(treasuryBalance, initialTreasuryBalance + expectedFees);
    }

    function _sell(uint256 _tokenId) internal {
        dualLinearERC271AMM.swap(address(applicationNFT), 1, _tokenId);
    }
}

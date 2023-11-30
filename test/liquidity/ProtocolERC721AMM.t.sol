// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
//import "src/liquidity/ProtocolERC721AMM.sol";
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
        LineInput memory buy = LineInput(2 * 10 ** 7, 10 * ATTO); /// buy slope = 0.2; b = 10
        LineInput memory sell = LineInput(18 * 10 ** 6, 98 * 10 ** 17); /// sell slope = 0.18; b = 9.8
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
        applicationCoin.transfer(user, 22 * ATTO);
        switchToUser();
        /// Approve transfer
        applicationCoin.approve(address(dualLinearERC271AMM), 22 * ATTO);
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
        _testBuyNFT(0);
    }

    function testBuySecondNFT() public {
        testBuyFirstNFT();
        _testBuyNFT(1);
    }

    function testSellFirstNFT() public {
        // we cannot sell without having bought first since q can't be negative
        testBuySecondNFT(); // user buys NFTs 0 and 1
        applicationNFT.setApprovalForAll(address(dualLinearERC271AMM), true);
        _testSellNFT(0); // user sells back NFT 0
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

    // function testSwapLinearToken1() public {
    //     /// Approve the transfer of tokens into AMM
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1000000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1000000);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1000000, 1000000);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000000);
    //     /// Set up a regular user with some tokens
    //     applicationCoin2.transfer(user, 100000);
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 100000);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 100000);
    //     /// Make sure AMM balances show change
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1100000);
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 900000);
    //     vm.stopPrank();
    //     vm.startPrank(superAdmin);

    //     /// Make sure user's wallet shows change
    //     assertEq(applicationCoin2.balanceOf(user), 0);
    //     assertEq(applicationCoin.balanceOf(user), 100000);
    // }

    // /// Test constant product swaps
    // function testSwapCPToken0() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1000000000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1000000000);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1000000000, 1000000000);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000000000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000000000);
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user, 50000);
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer(1M)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 50000);
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin), 50000);
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 49997);
    //     /// Make sure AMM balances show change
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000050000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 999950003);
    //     vm.stopPrank();
    //     vm.startPrank(superAdmin);

    //     /// Make sure user's wallet shows change
    //     assertEq(applicationCoin.balanceOf(user), 0);
    //     assertEq(applicationCoin2.balanceOf(user), 49997);
    // }

    // function testSwapCPToken1() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1000000000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1000000000);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1000000000, 1000000000);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000000000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000000000);
    //     /// Set up a regular user with some tokens
    //     applicationCoin2.transfer(user, 50000);
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 50000);
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin2), 50000);
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 49997);
    //     /// Make sure AMM balances show change
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000050000);
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 999950003);
    //     vm.stopPrank();
    //     vm.startPrank(superAdmin);

    //     /// Make sure user's wallet shows change
    //     assertEq(applicationCoin2.balanceOf(user), 0);
    //     assertEq(applicationCoin.balanceOf(user), 49997);
    // }

    // /// Test sample 1 function swaps
    // function testSwapSample1BackAndForth() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * ATTO, 4 * ATTO, address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 100_000 * (ATTO));
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10_000 * (ATTO));
    //     /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
    //     dualLinearERC271AMM.addLiquidity(100000 * (ATTO), 10_000 * (ATTO));
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 100_000 * (ATTO));
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 10_000 * (ATTO));
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user, 3 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1 * (ATTO));
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin), 1 * (ATTO));
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 15 * (10 ** 17));

    //     /// now make the opposite trade to ensure we get the proper value back
    //     vm.stopPrank();
    //     vm.startPrank(appAdministrator);
    //     applicationCoin2.transfer(user, 10 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 3 * (ATTO));
    //     uint256 rValue2 = dualLinearERC271AMM.swap(address(applicationCoin2), 3 * (ATTO));
    //     /// make sure swap returns correct value
    //     assertEq(rValue2, 1 * (ATTO));

    //     /// Now try trade application coin 0 for 1
    //     /// Approve transfer
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1 * (ATTO));
    //     rValue = dualLinearERC271AMM.swap(address(applicationCoin), 1 * (ATTO));
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 15 * (10 ** 17));
    // }

    // /// Test sample 1 function swaps
    // function testSwapSample1Token0() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * ATTO, 4 * ATTO, address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 100_000 * (ATTO));
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10_000 * (ATTO));
    //     /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
    //     dualLinearERC271AMM.addLiquidity(100000 * (ATTO), 10_000 * (ATTO));
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 100_000 * (ATTO));
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 10_000 * (ATTO));
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user, 3 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1 * (ATTO));
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin), 1 * (ATTO));
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 15 * (10 ** 17));
    // }

    // /// Test sample 1 function swaps
    // function testSwapSample1Token1() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * ATTO, 4 * ATTO, address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 100_000 * (ATTO));
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10_000 * (ATTO));
    //     /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
    //     dualLinearERC271AMM.addLiquidity(100000 * (ATTO), 10_000 * (ATTO));
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 100_000 * (ATTO));
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 10_000 * (ATTO));
    //     /// Set up a regular user with some tokens
    //     applicationCoin2.transfer(user, 5 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 5 * (ATTO));
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin2), 5 * (ATTO));
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 1 * (ATTO));
    // }

    // /// Test sample 1 function swaps failure for shallow pool
    // function testSwapSample1Token1PoolFail() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * ATTO, 4 * ATTO, address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10 * (ATTO));
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10 * (ATTO));
    //     /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
    //     dualLinearERC271AMM.addLiquidity(5 * (ATTO), 5 * (ATTO));
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 5 * (ATTO));
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 5 * (ATTO));
    //     /// Set up a regular user with some tokens
    //     applicationCoin2.transfer(user, 10000 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * (ATTO));
    //     bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
    //     vm.expectRevert(abi.encodeWithSelector(selector, 5 * (ATTO), 98019998000000000000));
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10000 * (ATTO));
    //     /// make sure swap returns correct value
    //     // assertEq(rValue, 1 * (ATTO));
    // }

    // /// Test sample 1 function swaps failure for shallow pool
    // function testSwapSample1Token0PoolFail() public {
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * ATTO, 4 * ATTO, address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 5 * (ATTO));
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 5 * (ATTO));
    //     /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
    //     dualLinearERC271AMM.addLiquidity(5 * (ATTO), 5 * (ATTO));
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 5 * (ATTO));
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 5 * (ATTO));
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user, 10000 * (ATTO));
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * (ATTO));
    //     bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
    //     vm.expectRevert(abi.encodeWithSelector(selector, 5 * (ATTO), -49980000000000000000000000));
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10000 * (ATTO));
    // }

    // ///TODO Test Purchase rule through AMM once Purchase functionality is created
    // function testSellRule() public {
    //     /// Set Up AMM, approve and swap with user without tags
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1000000000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1000000000);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1000000000, 1000000000);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000000000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000000000);
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user1, 60000);
    //     applicationCoin2.transfer(user1, 60000);
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     /// Approve transfer(1M)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 50000);
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin), 50000);
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 49997);
    //     /// Make sure AMM balances show change
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000050000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 999950003);

    //     vm.stopPrank();
    //     vm.startPrank(superAdmin);
    //     ///Add tag to user
    //     bytes32[] memory accs = new bytes32[](1);
    //     uint192[] memory sellAmounts = new uint192[](1);
    //     uint16[] memory sellPeriod = new uint16[](1);
    //     uint64[] memory startTime = new uint64[](1);
    //     accs[0] = bytes32("SellRule");
    //     sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
    //     sellPeriod[0] = uint16(36); ///Hours
    //     startTime[0] = uint64(Blocktime);

    //     /// Set the rule data
    //     applicationAppManager.addGeneralTag(user1, "SellRule");
    //     applicationAppManager.addGeneralTag(user2, "SellRule");
    //     /// add the rule.
    //     switchToRuleAdmin();
    //     uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, startTime);
    //     ///update ruleId in application AMM rule handler
    //     applicationAMMHandler.setSellLimitRuleId(ruleId);
    //     /// Swap that passes rule check
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     /// Approve transfer(1M)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 50000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 50000);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 500);

    //     /// Swap that fails
    //     vm.expectRevert(0xc11d5f20);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 500);
    // }

    // /// test updating min transfer rule
    // function testAMMPassesMinTransferRule() public {
    //     /// initialize the AMM
    //     initializeAMMAndUsers();
    //     /// we add the rule.
    //     switchToRuleAdmin();
    //     uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(applicationAppManager), 10);
    //     /// we update the rule id in the token
    //     applicationAMMHandler.setMinTransferRuleId(ruleId);
    //     /// Set up this particular swap
    //     /// Approve transfer
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10);
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), 10), 10);

    //     /// now we check for proper failure
    //     applicationCoin.approve(address(dualLinearERC271AMM), 9);
    //     vm.expectRevert(0x70311aa2);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 9);
    // }

    // /// test AMM Fees
    // function testAMMFees() public {
    //     /// initialize the AMM
    //     initializeAMMAndUsers();
    //     /// we add the rule.
    //     switchToRuleAdmin();
    //     /// make sure that no bogus fee percentage can get in
    //     bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
    //     vm.expectRevert(abi.encodeWithSelector(selector, 10001));
    //     uint32 ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 10001);
    //     vm.expectRevert(abi.encodeWithSelector(selector, 0));
    //     ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 0);
    //     /// now add the good rule
    //     ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), 300);
    //     /// we update the rule id in the token
    //     applicationAMMHandler.setAMMFeeRuleId(ruleId);
    //     switchToAppAdministrator();
    //     /// set the treasury address
    //     dualLinearERC271AMM.setTreasuryAddress(address(99));
    //     /// Set up this particular swap
    //     /// Approve transfer
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 100 * ATTO);
    //     // should get 97% back
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), 100 * ATTO), 97 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(address(99)), 3 * ATTO);
    //     // Now try the other direction. Since only token1 is used for fees, it is worth testing it as well. This
    //     // is the linear swap so the test is easy. For other styles, it can be more difficult because the fee is
    //     // assessed prior to the swap calculation
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 100 * ATTO);
    //     // should get 97% back
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin2), 100 * ATTO), 97 * ATTO);

    //     // Now try one that isn't as easy
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1 * ATTO);
    //     // should get 97% back but not an easy nice token
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), 1 * ATTO), 97 * 10 ** 16);

    //     // Now try one that is even harder
    //     applicationCoin.approve(address(dualLinearERC271AMM), 7 * 10 ** 12);
    //     // should get 97% back but not an easy nice token
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), 7 * 10 ** 12), 679 * 10 ** 10);
    // }

    // /// test AMM Fees
    // function testAMMFeesFuzz(uint256 feePercentage, uint8 _addressIndex, uint256 swapAmount) public {
    //     vm.assume(feePercentage < 10000 && feePercentage > 0);
    //     if (swapAmount > 999999) swapAmount = 999999;
    //     address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
    //     address ammUser = addressList[0];
    //     address treasury = addressList[1];
    //     /// Approve the transfer of tokens into AMM
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1_000_000_000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1_000_000_000 * ATTO);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1_000_000_000 * ATTO, 1_000_000_000 * ATTO);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1_000_000_000 * ATTO);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1_000_000_000 * ATTO);
    //     console.logString("Transfer tokens to ammUser");
    //     applicationCoin.transfer(ammUser, swapAmount);

    //     /// we add the rule.
    //     switchToRuleAdmin();
    //     console.logString("Create the Fee Rule");
    //     uint32 ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(applicationAppManager), feePercentage);
    //     /// we update the rule id in the token
    //     applicationAMMHandler.setAMMFeeRuleId(ruleId);
    //     switchToAppAdministrator();
    //     /// set the treasury address
    //     dualLinearERC271AMM.setTreasuryAddress(treasury);
    //     /// Set up this particular swap
    //     /// Approve transfer
    //     vm.stopPrank();
    //     vm.startPrank(ammUser);
    //     applicationCoin.approve(address(dualLinearERC271AMM), swapAmount);
    //     // should get x% of swap return
    //     console.logString("Perform the swap");
    //     if (swapAmount == 0) vm.expectRevert(0x5b2790b5); // if swap amount is zero, revert correctly
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), swapAmount), swapAmount - ((swapAmount * feePercentage) / 10000));
    //     assertEq(applicationCoin2.balanceOf(ammUser), swapAmount - ((swapAmount * feePercentage) / 10000));
    //     assertEq(applicationCoin2.balanceOf(treasury), (swapAmount * feePercentage) / 10000);
    // }

    // /**
    //  * @dev Test the oracle rule, both allow and restrict types
    //  */
    // function testAMMOracleFuzz(uint8 amount1, uint8 amount2, uint8 target, uint8 secondTrader) public {
    //     /// initialize the AMM
    //     initializeAMMAndUsers();
    //     /// skiping not-allowed values
    //     vm.assume(amount1 != 0 && amount2 != 0);

    //     /// selecting ADDRESSES randomly
    //     address targetedTrader = addresses[target % addresses.length];
    //     address traderB = addresses[secondTrader % addresses.length];

    //     // BLOCKLIST ORACLE
    //     switchToRuleAdmin();
    //     uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
    //     assertEq(_index, 0);
    //     NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
    //     assertEq(rule.oracleType, 0);
    //     assertEq(rule.oracleAddress, address(oracleRestricted));
    //     switchToAppAdministrator();
    //     // add a blocked address
    //     badBoys.push(targetedTrader);
    //     oracleRestricted.addToSanctionsList(badBoys);
    //     switchToRuleAdmin();
    //     /// connect the rule to this handler
    //     applicationAMMHandler.setOracleRuleId(_index);
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     uint balanceABefore = applicationCoin.balanceOf(user1);
    //     uint balanceBBefore = applicationCoin2.balanceOf(user1);
    //     uint reserves0 = dualLinearERC271AMM.reserveERC20();
    //     uint reserves1 = dualLinearERC271AMM.reserveERC721();
    //     console.log(dualLinearERC271AMM.reserveERC721());
    //     applicationCoin.approve(address(dualLinearERC271AMM), amount1);
    //     if (targetedTrader == user1) vm.expectRevert(0x6bdfffc0);
    //     dualLinearERC271AMM.swap(address(applicationCoin), amount1);
    //     if (targetedTrader != user1) {
    //         assertEq(applicationCoin.balanceOf(user1), balanceABefore - amount1);
    //         assertEq(applicationCoin2.balanceOf(user1), balanceBBefore + amount1);
    //         assertEq(dualLinearERC271AMM.reserveERC20(), reserves0 + amount1);
    //         assertEq(dualLinearERC271AMM.reserveERC721(), reserves1 - amount1);
    //     }

    //     /// ALLOWLIST ORACLE
    //     switchToRuleAdmin();
    //     _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
    //     /// connect the rule to this handler
    //     applicationAMMHandler.setOracleRuleId(_index);
    //     switchToAppAdministrator();
    //     // add an allowed address
    //     goodBoys.push(targetedTrader);
    //     oracleAllowed.addToAllowList(goodBoys);
    //     balanceABefore = applicationCoin.balanceOf(traderB);
    //     balanceBBefore = applicationCoin2.balanceOf(traderB);
    //     reserves0 = dualLinearERC271AMM.reserveERC20();
    //     reserves1 = dualLinearERC271AMM.reserveERC721();
    //     vm.stopPrank();
    //     vm.startPrank(traderB);
    //     applicationCoin.approve(address(dualLinearERC271AMM), amount2);
    //     if (targetedTrader != traderB) vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), amount2);
    //     if (targetedTrader == traderB) {
    //         assertEq(applicationCoin.balanceOf(traderB), balanceABefore - amount2);
    //         assertEq(applicationCoin2.balanceOf(traderB), balanceBBefore + amount2);
    //         assertEq(dualLinearERC271AMM.reserveERC20(), reserves0 + amount2);
    //         assertEq(dualLinearERC271AMM.reserveERC721(), reserves1 - amount2);
    //     }
    // }

    // /// set up the AMM(linear) for rule tests. Also set up user1 with applicationCoin and user2 with applicationCoin2
    // function initializeAMMAndUsers() public {
    //     /// Approve the transfer of tokens into AMM
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1_000_000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1_000_000 * ATTO);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1_000_000 * ATTO, 1_000_000 * ATTO);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1_000_000 * ATTO);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1_000_000 * ATTO);
    //     applicationCoin.transfer(user1, 1000 * ATTO);
    //     applicationCoin.transfer(user2, 1000 * ATTO);
    //     applicationCoin.transfer(user3, 1000 * ATTO);
    //     applicationCoin.transfer(rich_user, 1000 * ATTO);
    //     applicationCoin2.transfer(user1, 1000 * ATTO);
    //     applicationCoin2.transfer(user2, 1000 * ATTO);
    //     applicationCoin.transfer(address(69), 1000 * ATTO);
    //     applicationCoin2.transfer(address(69), 1000 * ATTO);
    // }

    // function testMinMaxAccountBalanceAMM() public {
    //     initializeAMMAndUsers();
    //     ///Token 0 Limits
    //     bytes32[] memory accs = new bytes32[](1);
    //     uint256[] memory min = new uint256[](1);
    //     uint256[] memory max = new uint256[](1);
    //     accs[0] = bytes32("MINMAXTAG");
    //     min[0] = uint256(10 * ATTO);
    //     max[0] = uint256(1100 * ATTO);
    //     switchToRuleAdmin();
    //     /// add the actual rule
    //     uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);

    //     ///Token 1 Limits
    //     bytes32[] memory accs1 = new bytes32[](1);
    //     uint256[] memory min1 = new uint256[](1);
    //     uint256[] memory max1 = new uint256[](1);
    //     accs1[0] = bytes32("MINMAX");
    //     min1[0] = uint256(500 * ATTO);
    //     max1[0] = uint256(2000 * ATTO);
    //     /// add the actual rule
    //     uint32 ruleId1 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs1, min1, max1);
    //     ////update ruleId in coin rule handler
    //     applicationAMMHandler.setMinMaxBalanceRuleIdToken0(ruleId);
    //     applicationAMMHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
    //     switchToAppAdministrator();
    //     ///Add GeneralTag to account
    //     applicationAppManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user1, "MINMAXTAG"));
    //     applicationAppManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user2, "MINMAXTAG"));
    //     applicationAppManager.addGeneralTag(user1, "MINMAX"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user1, "MINMAX"));
    //     applicationAppManager.addGeneralTag(user2, "MINMAX"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user2, "MINMAX"));

    //     ///perform transfer that checks rule
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);

    //     dualLinearERC271AMM.swap(address(applicationCoin), 10 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 990 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1010 * ATTO);

    //     dualLinearERC271AMM.swap(address(applicationCoin), 100 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 200 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 690 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1310 * ATTO);

    //     dualLinearERC271AMM.swap(address(applicationCoin2), 100 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 200 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 1000 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1000 * ATTO);

    //     // make sure the minimum rules fail results in revert
    //     // vm.expectRevert("Balance Will Drop Below Minimum");
    //     vm.expectRevert(0xf1737570);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 990 * ATTO);

    //     /// make sure the maximum rule fail results in revert
    //     /// vm.expectRevert("Balance Will Exceed Maximum");
    //     vm.expectRevert(0x24691f6b);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 500 * ATTO);

    //     ///vm.expectRevert("Balance Will Exceed Maximum");
    //     vm.expectRevert(0x24691f6b);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 150 * ATTO);

    //     /// make sure the minimum rules fail results in revert
    //     ///vm.expectRevert("Balance Will Drop Below Minimum");
    //     vm.expectRevert(0xf1737570);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 650 * ATTO);
    // }

    // function testPauseRulesViaAppManagerAMM() public {
    //     initializeAMMAndUsers();
    //     applicationCoin.transfer(appAdministrator, 1000);
    //     applicationCoin2.transfer(appAdministrator, 1000);
    //     ///set pause rule and check check that the transaction reverts
    //     switchToRuleAdmin();
    //     applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
    //     vm.warp(Blocktime + 1001);

    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000);
    //     vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     //Check that appAdministrators can still transfer within pausePeriod
    //     switchToAppAdministrator();
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);
    //     ///move blocktime after pause to resume transfers
    //     vm.warp(Blocktime + 1600);
    //     ///transfer again to check
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     // dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     ///create new pause rule to check that swaps and transfers are paused
    //     switchToRuleAdmin();
    //     applicationAppManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
    //     vm.warp(Blocktime + 1750);

    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     vm.expectRevert();
    //     applicationCoin.transfer(user2, 100);

    //     ///Set multiple pause rules and ensure pauses during and regular function between
    //     switchToRuleAdmin();
    //     applicationAppManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
    //     applicationAppManager.addPauseRule(Blocktime + 2750, Blocktime + 3000);
    //     applicationAppManager.addPauseRule(Blocktime + 3150, Blocktime + 3500);

    //     vm.warp(Blocktime + 2050); ///Expire previous pause rule
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     vm.warp(Blocktime + 2150);
    //     vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     vm.warp(Blocktime + 2501); ///Expire Pause rule
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     vm.warp(Blocktime + 2755);
    //     vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     switchToAppAdministrator();
    //     // dualLinearERC271AMM.swap(address(applicationCoin), 10); ///Show Application Administrators can utilize system during pauses

    //     vm.warp(Blocktime + 3015); ///Expire previous pause rule
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10);

    //     vm.warp(Blocktime + 3300); ///Expire previous pause rule
    //     vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100);

    //     vm.warp(Blocktime + 3501); ///Expire previous pause rule
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10);
    // }

    // /**
    //  * @dev Test the AccessLevel = 0 rule
    //  */
    // function testAccessLevel0AMM() public {
    //     /// initialize the AMM
    //     initializeAMMAndUsers();

    //     /// Set up this particular swap
    //     /// Approve transfer
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10);
    //     // this one should pass because the rule is off
    //     assertEq(dualLinearERC271AMM.swap(address(applicationCoin), 10), 10);
    //     /// turn the rule on
    //     switchToRuleAdmin();
    //     applicationHandler.activateAccessLevel0Rule(true);
    //     /// now we check for proper failure
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 9);
    //     vm.expectRevert(0x3fac082d);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 9);
    //     /// now add a AccessLevel score and try again
    //     switchToAccessLevelAdmin();
    //     applicationAppManager.addAccessLevel(user1, 1);
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 9);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 9);
    // }

    // function testUpgradeHandlerAMM() public {
    //     /// Deploy the modified AMM Handler contract
    //     ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(applicationAppManager), address(ruleProcessor), address(dualLinearERC271AMM));

    //     /// connect AMM to new Handler
    //     dualLinearERC271AMM.connectHandlerToAMM(address(assetHandler));
    //     /// must deregister and reregister AMM
    //     applicationAppManager.deRegisterAMM(address(dualLinearERC271AMM));
    //     applicationAppManager.registerAMM(address(dualLinearERC271AMM));

    //     /// Test Min Max Balance Rule with New Handler
    //     initializeAMMAndUsers();
    //     ///Token 0 Limits
    //     bytes32[] memory accs = new bytes32[](1);
    //     uint256[] memory min = new uint256[](1);
    //     uint256[] memory max = new uint256[](1);
    //     accs[0] = bytes32("MINMAXTAG");
    //     min[0] = uint256(10 * ATTO);
    //     max[0] = uint256(1100 * ATTO);
    //     /// add the actual rule
    //     switchToRuleAdmin();
    //     uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
    //     ///Token 1 Limits
    //     bytes32[] memory accs1 = new bytes32[](1);
    //     uint256[] memory min1 = new uint256[](1);
    //     uint256[] memory max1 = new uint256[](1);
    //     accs1[0] = bytes32("MINMAX");
    //     min1[0] = uint256(500 * ATTO);
    //     max1[0] = uint256(2000 * ATTO);
    //     /// add the actual rule
    //     uint32 ruleId1 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(applicationAppManager), accs1, min1, max1);
    //     ////update ruleId in coin rule handler
    //     assetHandler.setMinMaxBalanceRuleIdToken0(ruleId);
    //     assetHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
    //     switchToAppAdministrator();
    //     ///Add GeneralTag to account
    //     applicationAppManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user1, "MINMAXTAG"));
    //     applicationAppManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user2, "MINMAXTAG"));
    //     applicationAppManager.addGeneralTag(user1, "MINMAX"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user1, "MINMAX"));
    //     applicationAppManager.addGeneralTag(user2, "MINMAX"); ///add tag
    //     assertTrue(applicationAppManager.hasTag(user2, "MINMAX"));
    //     ///perform transfer that checks rule
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 10 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 990 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1010 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 100 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 200 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 690 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1310 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 100 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 10 * ATTO);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 200 * ATTO);
    //     assertEq(applicationCoin.balanceOf(user1), 1000 * ATTO);
    //     assertEq(applicationCoin2.balanceOf(user1), 1000 * ATTO);
    //     // make sure the minimum rules fail results in revert
    //     // vm.expectRevert("Balance Will Drop Below Minimum");
    //     vm.expectRevert(0xf1737570);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 990 * ATTO);
    //     /// make sure the maximum rule fail results in revert
    //     /// vm.expectRevert("Balance Will Exceed Maximum");
    //     vm.expectRevert(0x24691f6b);
    //     dualLinearERC271AMM.swap(address(applicationCoin), 500 * ATTO);
    //     ///vm.expectRevert("Balance Will Exceed Maximum");
    //     vm.expectRevert(0x24691f6b);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 150 * ATTO);
    //     /// make sure the minimum rules fail results in revert
    //     ///vm.expectRevert("Balance Will Drop Below Minimum");
    //     vm.expectRevert(0xf1737570);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), 650 * ATTO);
    //     /// test new function in new handler
    //     address testAddress = assetHandler.newTestFunction();
    //     console.log(assetHandler.newTestFunction(), testAddress);
    // }

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

    // function testPurchasePercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint16 purchasePeriod, uint64 ruleStartTime) public {
    //     initializeAMMAndUsers();
    //     vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && purchasePeriod > 0 && ruleStartTime > 0);

    //     if (purchasePeriod > 23) {
    //         purchasePeriod = 23;
    //     }
    //     if (ruleStartTime > block.timestamp) ruleStartTime = uint64(block.timestamp);
    //     uint256 totalSupply = 100_000_000;
    //     uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
    //     switchToRuleAdmin();
    //     uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
    //     /// add and activate rule
    //     applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
    //     vm.warp(Blocktime + 36 hours);
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);

    //     if (amountA > amountB) vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin2), amountA);

    //     vm.warp(Blocktime + 72 hours);
    //     vm.stopPrank();
    //     vm.startPrank(user2);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);

    //     if (amountA > amountB) vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin2), amountA);
    //     dualLinearERC271AMM.swap(address(applicationCoin), amountA);
    // }

    // function testSellPercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint16 sellPeriod, uint64 ruleStartTime) public {
    //     initializeAMMAndUsers();
    //     vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && sellPeriod > 0 && ruleStartTime > 0);

    //     if (sellPeriod > 23) {
    //         sellPeriod = 23;
    //     }
    //     if (ruleStartTime > block.timestamp) ruleStartTime = uint64(block.timestamp);
    //     uint256 totalSupply = 100_000_000;
    //     uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
    //     switchToRuleAdmin();
    //     uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentageSellRule(address(applicationAppManager), tokenPercentage, sellPeriod, totalSupply, ruleStartTime);
    //     /// add and activate rule
    //     applicationAMMHandler.setSellPercentageRuleId(ruleId);
    //     vm.warp(Blocktime + 36 hours);
    //     vm.stopPrank();
    //     vm.startPrank(user1);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);

    //     if (amountA > amountB) vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), amountA);

    //     vm.warp(Blocktime + 72 hours);
    //     vm.stopPrank();
    //     vm.startPrank(user2);
    //     applicationCoin.approve(address(dualLinearERC271AMM), 10000 * ATTO);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 10000 * ATTO);

    //     if (amountA > amountB) vm.expectRevert();
    //     dualLinearERC271AMM.swap(address(applicationCoin), amountA);
    //     dualLinearERC271AMM.swap(address(applicationCoin2), amountA);
    // }

    // /// Test constant product swaps that use a factory created calculator
    // function testSwapCPToken0ThroughFactory() public {
    //     factory = new ProtocolAMMCalculatorFactory();
    //     address calcAddress = factory.createConstantProduct(address(applicationAppManager));
    //     /// change AMM to use the CP calculator
    //     dualLinearERC271AMM.setCalculatorAddress(calcAddress);
    //     /// Approve the transfer of tokens into AMM(1B)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 1000000000);
    //     applicationCoin2.approve(address(dualLinearERC271AMM), 1000000000);
    //     /// Transfer the tokens into the AMM
    //     dualLinearERC271AMM.addLiquidity(1000000000, 1000000000);
    //     /// Make sure the tokens made it
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000000000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 1000000000);
    //     /// Set up a regular user with some tokens
    //     applicationCoin.transfer(user, 50000);
    //     vm.stopPrank();
    //     vm.startPrank(user);
    //     /// Approve transfer(1M)
    //     applicationCoin.approve(address(dualLinearERC271AMM), 50000);
    //     uint256 rValue = dualLinearERC271AMM.swap(address(applicationCoin), 50000);
    //     /// make sure swap returns correct value
    //     assertEq(rValue, 49997);
    //     /// Make sure AMM balances show change
    //     assertEq(dualLinearERC271AMM.reserveERC20(), 1000050000);
    //     assertEq(dualLinearERC271AMM.reserveERC721(), 999950003);
    //     vm.stopPrank();
    //     vm.startPrank(superAdmin);

    //     /// Make sure user's wallet shows change
    //     assertEq(applicationCoin.balanceOf(user), 0);
    //     assertEq(applicationCoin2.balanceOf(user), 49997);
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

    function _testBuyNFT(uint256 _tokenId) internal {
        switchToUser();
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.reserveERC20();
        uint256 initialERC721Reserves = dualLinearERC271AMM.reserveERC721();
        (uint256 price, uint256 fees) = dualLinearERC271AMM.getBuyPrice();
        uint256 pricePlusFees = price + fees;

        dualLinearERC271AMM.swap(address(applicationCoin), pricePlusFees, _tokenId);
        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.reserveERC20(), initialERC20Reserves + pricePlusFees);
        assertEq(dualLinearERC271AMM.reserveERC721(), initialERC721Reserves - 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance - pricePlusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance + 1);
    }

    function _testSellNFT(uint256 _tokenId) internal {
        switchToUser();
        uint256 initialUserCoinBalance = applicationCoin.balanceOf(user);
        uint256 initialUserNFTBalance = applicationNFT.balanceOf(user);
        uint256 initialERC20Reserves = dualLinearERC271AMM.reserveERC20();
        uint256 initialERC721Reserves = dualLinearERC271AMM.reserveERC721();
        (uint256 price, uint256 fees) = dualLinearERC271AMM.getSellPrice();
        uint256 priceMinusFees = price - fees;

        dualLinearERC271AMM.swap(address(applicationNFT), 1, _tokenId);
        /// Make sure AMM balances show change
        assertEq(dualLinearERC271AMM.reserveERC20(), initialERC20Reserves - priceMinusFees);
        assertEq(dualLinearERC271AMM.reserveERC721(), initialERC721Reserves + 1);
        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), initialUserCoinBalance + priceMinusFees);
        assertEq(applicationNFT.balanceOf(user), initialUserNFTBalance - 1);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/example/ApplicationERC20.sol";
import "../src/example/liquidity/ApplicationAMM.sol";
import "../src/example/liquidity/ApplicationAMMCalcLinear.sol";
import "../src/example/liquidity/ApplicationAMMCalcCP.sol";
import "../src/example/liquidity/ApplicationAMMCalcSample01.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import {ApplicationAMMHandler} from "../src/example/liquidity/ApplicationAMMHandler.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {FeeRuleDataFacet} from "../src/economic/ruleStorage/FeeRuleDataFacet.sol";
import {ApplicationAMMHandlerMod} from "./helpers/ApplicationAMMHandlerMod.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    ApplicationAMMHandler handler;
    ApplicationAMM applicationAMM;
    ApplicationAMMCalcLinear applicationAMMLinearCalc;
    ApplicationAMMCalcCP applicationAMMCPCalc;
    ApplicationAMMCalcSample01 applicationAMMSample01Calc;
    ApplicationERC20 applicationCoin;
    ApplicationERC20 applicationCoin2;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationAMMHandler applicationAMMHandler;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    ApplicationAMMHandlerMod newAssetHandler;

    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address user1 = address(11);
    address user2 = address(22);
    address user3 = address(33);
    address rich_user = address(44);
    address treasuryAddress = address(55);
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    address[] addresses = [user1, user2, user3, rich_user];
    address[] ADDRESSES = [address(0xFF1), address(0xFF2), address(0xFF3), address(0xFF4), address(0xFF5), address(0xFF6), address(0xFF7), address(0xFF8)];

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        /// add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        appManager.addAccessTier(AccessTier);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));

        /// Create two tokens and mint a bunch
        applicationCoin = new ApplicationERC20("application", "GMC", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationCoin.mint(defaultAdmin, 1_000_000_000_000 * (10 ** 18));
        applicationCoin2 = new ApplicationERC20("application2", "GMC2", address(appManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), false);
        applicationCoin2.connectHandlerToToken(address(applicationCoinHandler2));
        applicationCoin2.mint(defaultAdmin, 1_000_000_000_000 * (10 ** 18));
        
        /// Create calculators for the AMM
        applicationAMMLinearCalc = new ApplicationAMMCalcLinear();
        applicationAMMCPCalc = new ApplicationAMMCalcCP();
        applicationAMMSample01Calc = new ApplicationAMMCalcSample01();
        /// Set up the AMM
        handler = new ApplicationAMMHandler(address(appManager), address(ruleProcessor));
        applicationAMM = new ApplicationAMM(address(applicationCoin), address(applicationCoin2), address(appManager), address(applicationAMMLinearCalc));
        applicationAMM.connectHandlerToAMM(address(handler));
        applicationAMMHandler = ApplicationAMMHandler(applicationAMM.getHandlerAddress());
        /// Register AMM
        appManager.registerAMM(address(applicationAMM));
        /// set the treasury address
        applicationAMM.setTreasuryAddress(treasuryAddress);
        appManager.addAppAdministrator(treasuryAddress);

        /// set the erc20 pricer
        erc20Pricer = new ApplicationERC20Pricing();
        /// connect ERC20 pricer to applicationCoinHandler
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        vm.warp(Blocktime);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }

    //Test adding liquidity to the AMM
    function testAddLiquidity() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000);
        applicationCoin2.approve(address(applicationAMM), 1000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000);
        assertEq(applicationAMM.getReserve1(), 1000);
    }

    /// Test removing liquidity from the AMM(token0)
    function testRemoveToken0() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000);
        applicationCoin2.approve(address(applicationAMM), 1000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000);
        assertEq(applicationAMM.getReserve1(), 1000);
        /// Get user's initial balance
        uint256 balance = applicationCoin.balanceOf(defaultAdmin);
        /// Remove some token0's
        applicationAMM.removeToken0(500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationCoin.balanceOf(defaultAdmin));
        /// Make sure they no longer show in AMM
        assertEq(500, applicationAMM.getReserve0());
    }

    /// Test removing liquidity from the AMM(token1)
    function testRemoveToken1() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000);
        applicationCoin2.approve(address(applicationAMM), 1000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000);
        assertEq(applicationAMM.getReserve1(), 1000);
        /// Get user's initial balance
        uint256 balance = applicationCoin2.balanceOf(defaultAdmin);
        /// Remove some token0's
        applicationAMM.removeToken1(500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationCoin2.balanceOf(defaultAdmin));
        /// Make sure they no longer show in AMM
        assertEq(500, applicationAMM.getReserve1());
    }

    ///Test fail linear swaps
    function testFailZerosSwap() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(applicationCoin), 0);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1100000);
        assertEq(applicationAMM.getReserve1(), 900000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    /// Test fail invalid token address swaps
    function testFailInvalidToken() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(new ApplicationERC20("application3", "GMC3", address(appManager))), 100000);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1100000);
        assertEq(applicationAMM.getReserve1(), 900000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    /// Test linear swaps
    function testSwapLinearToken0() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(applicationCoin), 100000);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1100000);
        assertEq(applicationAMM.getReserve1(), 900000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    function testSwapLinearToken1() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000);
        applicationCoin2.approve(address(applicationAMM), 1000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000);
        assertEq(applicationAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(applicationAMM), 100000);
        applicationAMM.swap(address(applicationCoin2), 100000);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve1(), 1100000);
        assertEq(applicationAMM.getReserve0(), 900000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin2.balanceOf(user), 0);
        assertEq(applicationCoin.balanceOf(user), 100000);
    }

    /// Test constant product swaps
    function testSwapCPToken0() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMCPCalc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 1000000000);
        applicationCoin2.approve(address(applicationAMM), 1000000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000000);
        assertEq(applicationAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 50000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer(1M)
        applicationCoin.approve(address(applicationAMM), 50000);
        uint256 rValue = applicationAMM.swap(address(applicationCoin), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1000050000);
        assertEq(applicationAMM.getReserve1(), 999950003);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 49997);
    }

    function testSwapCPToken1() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMCPCalc));
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1000000000);
        applicationCoin2.approve(address(applicationAMM), 1000000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000000);
        assertEq(applicationAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 50000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(applicationAMM), 50000);
        uint256 rValue = applicationAMM.swap(address(applicationCoin2), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve1(), 1000050000);
        assertEq(applicationAMM.getReserve0(), 999950003);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin2.balanceOf(user), 0);
        assertEq(applicationCoin.balanceOf(user), 49997);
    }

    /// Test sample 1 function swaps
    function testSwapSample1BackAndForth() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMSample01Calc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(applicationAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        applicationAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(applicationAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 3 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 1 * (10 ** 18));
        uint256 rValue = applicationAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));

        /// now make the opposite trade to ensure we get the proper value back
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        applicationCoin2.transfer(user, 10 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(applicationAMM), 3 * (10 ** 18));
        uint256 rValue2 = applicationAMM.swap(address(applicationCoin2), 3 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue2, 1 * (10 ** 18));

        /// Now try trade application coin 0 for 1
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 1 * (10 ** 18));
        rValue = applicationAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));
    }

    /// Test sample 1 function swaps
    function testSwapSample1Token0() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMSample01Calc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(applicationAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        applicationAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(applicationAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 3 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 1 * (10 ** 18));
        uint256 rValue = applicationAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));
    }

    /// Test sample 1 function swaps
    function testSwapSample1Token1() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMSample01Calc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(applicationAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        applicationAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(applicationAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 5 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(applicationAMM), 5 * (10 ** 18));
        uint256 rValue = applicationAMM.swap(address(applicationCoin2), 5 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 1 * (10 ** 18));
    }

    /// Test sample 1 function swaps failure for shallow pool
    function testSwapSample1Token1PoolFail() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMSample01Calc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 10 * (10 ** 18));
        applicationCoin2.approve(address(applicationAMM), 10 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        applicationAMM.addLiquidity(5 * (10 ** 18), 5 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 5 * (10 ** 18));
        assertEq(applicationAMM.getReserve1(), 5 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 10000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(applicationAMM), 10000 * (10 ** 18));
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 5 * (10 ** 18), 98019998000000000000));
        applicationAMM.swap(address(applicationCoin2), 10000 * (10 ** 18));
        /// make sure swap returns correct value
        // assertEq(rValue, 1 * (10 ** 18));
    }

    /// Test sample 1 function swaps failure for shallow pool
    function testSwapSample1Token0PoolFail() public {
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMSample01Calc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 5 * (10 ** 18));
        applicationCoin2.approve(address(applicationAMM), 5 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        applicationAMM.addLiquidity(5 * (10 ** 18), 5 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 5 * (10 ** 18));
        assertEq(applicationAMM.getReserve1(), 5 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 10000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(applicationAMM), 10000 * (10 ** 18));
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 5 * (10 ** 18), -49980000000000000000000000));
        applicationAMM.swap(address(applicationCoin), 10000 * (10 ** 18));
    }

    ///TODO Test Purchase rule through AMM once Purchase functionality is created
    function testSellRule() public {
        /// Set Up AMM, approve and swap with user without tags
        /// change AMM to use the CP calculator
        applicationAMM.setCalculatorAddress(address(applicationAMMCPCalc));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(applicationAMM), 1000000000);
        applicationCoin2.approve(address(applicationAMM), 1000000000);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1000000000);
        assertEq(applicationAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user1, 60000);
        applicationCoin2.transfer(user1, 60000);
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(applicationAMM), 50000);
        uint256 rValue = applicationAMM.swap(address(applicationCoin), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(applicationAMM.getReserve0(), 1000050000);
        assertEq(applicationAMM.getReserve1(), 999950003);

        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint32[] memory sellPeriod = new uint32[](1);
        uint32[] memory startTime = new uint32[](1);
        accs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint32(36); ///Hours
        startTime[0] = uint32(12); ///Hours

        /// Set the rule data
        appManager.addGeneralTag(user1, "SellRule");
        appManager.addGeneralTag(user2, "SellRule");
        /// add the rule.
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(appManager), accs, sellAmounts, sellPeriod, startTime);
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setSellLimitRuleId(ruleId);
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(applicationAMM), 50000);
        applicationCoin2.approve(address(applicationAMM), 50000);
        applicationAMM.swap(address(applicationCoin), 500);

        /// Swap that fails
        vm.expectRevert(0xc11d5f20);
        applicationAMM.swap(address(applicationCoin), 500);
    }

    /// test updating min transfer rule
    function testAMMPassesMinTransferRule() public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// we add the rule.
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(appManager), 10);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10);
        assertEq(applicationAMM.swap(address(applicationCoin), 10), 10);

        /// now we check for proper failure
        applicationCoin.approve(address(applicationAMM), 9);
        vm.expectRevert(0x70311aa2);
        applicationAMM.swap(address(applicationCoin), 9);
    }

    /// test AMM Fees
    function testAMMFees() public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// we add the rule.
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// make sure that no bogus fee percentage can get in
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        uint32 ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(appManager), 10001);
        vm.expectRevert(abi.encodeWithSelector(selector, 0));
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(appManager), 0);
        /// now add the good rule
        ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(appManager), 300);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);
        /// set the treasury address
        applicationAMM.setTreasuryAddress(address(99));
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(applicationAMM.swap(address(applicationCoin), 100 * 10 ** 18), 97 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(address(99)), 3 * 10 ** 18);
        // Now try the other direction. Since only token1 is used for fees, it is worth testing it as well. This
        // is the linear swap so the test is easy. For other styles, it can be more difficult because the fee is
        // assessed prior to the swap calculation
        applicationCoin2.approve(address(applicationAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(applicationAMM.swap(address(applicationCoin2), 100 * 10 ** 18), 97 * 10 ** 18);

        // Now try one that isn't as easy
        applicationCoin.approve(address(applicationAMM), 1 * 10 ** 18);
        // should get 97% back but not an easy nice token
        assertEq(applicationAMM.swap(address(applicationCoin), 1 * 10 ** 18), 97 * 10 ** 16);

        // Now try one that is even harder
        applicationCoin.approve(address(applicationAMM), 7 * 10 ** 12);
        // should get 97% back but not an easy nice token
        assertEq(applicationAMM.swap(address(applicationCoin), 7 * 10 ** 12), 679 * 10 ** 10);
    }

    /// test AMM Fees
    function testAMMFeesFuzz(uint256 feePercentage, uint8 _addressIndex, uint256 swapAmount) public {
        vm.assume(feePercentage < 10000 && feePercentage > 0);
        if (swapAmount > 999999) swapAmount = 999999;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address ammUser = addressList[0];
        address treasury = addressList[1];
        appManager.addAccessTier(treasury);
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1_000_000_000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 1_000_000_000 * 10 ** 18);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1_000_000_000 * 10 ** 18, 1_000_000_000 * 10 ** 18);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1_000_000_000 * 10 ** 18);
        assertEq(applicationAMM.getReserve1(), 1_000_000_000 * 10 ** 18);
        console.logString("Transfer tokens to ammUser");
        applicationCoin.transfer(ammUser, swapAmount);

        /// we add the rule.
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        console.logString("Create the Fee Rule");
        uint32 ruleId = FeeRuleDataFacet(address(ruleStorageDiamond)).addAMMFeeRule(address(appManager), feePercentage);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);
        /// set the treasury address
        applicationAMM.setTreasuryAddress(treasury);
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(ammUser);
        applicationCoin.approve(address(applicationAMM), swapAmount);
        // should get x% of swap return
        console.logString("Perform the swap");
        if (swapAmount == 0) vm.expectRevert(0x5b2790b5); // if swap amount is zero, revert correctly
        assertEq(applicationAMM.swap(address(applicationCoin), swapAmount), swapAmount - ((swapAmount * feePercentage) / 10000));
        assertEq(applicationCoin2.balanceOf(ammUser), swapAmount - ((swapAmount * feePercentage) / 10000));
        assertEq(applicationCoin2.balanceOf(treasury), (swapAmount * feePercentage) / 10000);
    }

    /**
     * @dev Test the oracle rule, both allow and restrict types
     */
    function testAMMOracleFuzz(uint8 amount1, uint8 amount2, uint8 target, uint8 secondTrader) public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// skiping not-allowed values
        vm.assume(amount1 != 0 && amount2 != 0);

        /// selecting addresses randomly
        address targetedTrader = addresses[target % addresses.length];
        address traderB = addresses[secondTrader % addresses.length];

        // BLOCKLIST ORACLE
        uint32 _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = RuleDataFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        // add a blocked address
        badBoys.push(targetedTrader);
        oracleRestricted.addToSanctionsList(badBoys);
        /// connect the rule to this handler
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAMMHandler.setOracleRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        uint balanceABefore = applicationCoin.balanceOf(user1);
        uint balanceBBefore = applicationCoin2.balanceOf(user1);
        uint reserves0 = applicationAMM.getReserve0();
        uint reserves1 = applicationAMM.getReserve1();
        console.log(applicationAMM.getReserve1());
        applicationCoin.approve(address(applicationAMM), amount1);
        if (targetedTrader == user1) vm.expectRevert(0x6bdfffc0);
        applicationAMM.swap(address(applicationCoin), amount1);
        if (targetedTrader != user1) {
            assertEq(applicationCoin.balanceOf(user1), balanceABefore - amount1);
            assertEq(applicationCoin2.balanceOf(user1), balanceBBefore + amount1);
            assertEq(applicationAMM.getReserve0(), reserves0 + amount1);
            assertEq(applicationAMM.getReserve1(), reserves1 - amount1);
        }

        /// ALLOWLIST ORACLE
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        _index = RuleDataFacet(address(ruleStorageDiamond)).addOracleRule(address(appManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationAMMHandler.setOracleRuleId(_index);
        // add an allowed address
        goodBoys.push(targetedTrader);
        oracleAllowed.addToAllowList(goodBoys);
        balanceABefore = applicationCoin.balanceOf(traderB);
        balanceBBefore = applicationCoin2.balanceOf(traderB);
        reserves0 = applicationAMM.getReserve0();
        reserves1 = applicationAMM.getReserve1();
        vm.stopPrank();
        vm.startPrank(traderB);
        applicationCoin.approve(address(applicationAMM), amount2);
        if (targetedTrader != traderB) vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), amount2);
        if (targetedTrader == traderB) {
            assertEq(applicationCoin.balanceOf(traderB), balanceABefore - amount2);
            assertEq(applicationCoin2.balanceOf(traderB), balanceBBefore + amount2);
            assertEq(applicationAMM.getReserve0(), reserves0 + amount2);
            assertEq(applicationAMM.getReserve1(), reserves1 - amount2);
        }
    }

    /// set up the AMM(linear) for rule tests. Also set up user1 with applicationCoin and user2 with applicationCoin2
    function initializeAMMAndUsers() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(applicationAMM), 1_000_000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 1_000_000 * 10 ** 18);
        /// Transfer the tokens into the AMM
        applicationAMM.addLiquidity(1_000_000 * 10 ** 18, 1_000_000 * 10 ** 18);
        /// Make sure the tokens made it
        assertEq(applicationAMM.getReserve0(), 1_000_000 * 10 ** 18);
        assertEq(applicationAMM.getReserve1(), 1_000_000 * 10 ** 18);
        applicationCoin.transfer(user1, 1000 * 10 ** 18);
        applicationCoin.transfer(user2, 1000 * 10 ** 18);
        applicationCoin.transfer(user3, 1000 * 10 ** 18);
        applicationCoin.transfer(rich_user, 1000 * 10 ** 18);
        applicationCoin2.transfer(user1, 1000 * 10 ** 18);
        applicationCoin2.transfer(user2, 1000 * 10 ** 18);
        applicationCoin.transfer(address(69), 1000 * 10 ** 18);
        applicationCoin2.transfer(address(69), 1000 * 10 ** 18);
    }

    function testMinMaxAccountBalanceAMM() public {
        initializeAMMAndUsers();
        ///Token 0 Limits
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("MINMAXTAG");
        min[0] = uint256(10 * 10 ** 18);
        max[0] = uint256(1100 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);

        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs1, min1, max1);
        ////update ruleId in coin rule handler
        applicationAMMHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        applicationAMMHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
        ///Add GeneralTag to account
        appManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
        assertTrue(appManager.hasTag(user1, "MINMAXTAG"));
        appManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
        assertTrue(appManager.hasTag(user2, "MINMAXTAG"));
        appManager.addGeneralTag(user1, "MINMAX"); ///add tag
        assertTrue(appManager.hasTag(user1, "MINMAX"));
        appManager.addGeneralTag(user2, "MINMAX"); ///add tag
        assertTrue(appManager.hasTag(user2, "MINMAX"));

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);

        applicationAMM.swap(address(applicationCoin), 10 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 990 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1010 * 10 ** 18);

        applicationAMM.swap(address(applicationCoin), 100 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 690 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1310 * 10 ** 18);

        applicationAMM.swap(address(applicationCoin2), 100 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 10 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 1000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1000 * 10 ** 18);

        // make sure the minimum rules fail results in revert
        // vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationAMM.swap(address(applicationCoin), 990 * 10 ** 18);

        /// make sure the maximum rule fail results in revert
        /// vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationAMM.swap(address(applicationCoin), 500 * 10 ** 18);

        ///vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationAMM.swap(address(applicationCoin2), 150 * 10 ** 18);

        /// make sure the minimum rules fail results in revert
        ///vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationAMM.swap(address(applicationCoin2), 650 * 10 ** 18);
    }

    function testPauseRulesViaAppManagerAMM() public {
        initializeAMMAndUsers();
        applicationCoin.transfer(appAdministrator, 1000);
        applicationCoin2.transfer(appAdministrator, 1000);
        ///set pause rule and check check that the transaction reverts
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        applicationHandler.activatePauseRule(true); 
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000);
        applicationCoin2.approve(address(applicationAMM), 10000);
        vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), 100);

        //Check that appAdministrators can still transfer within pausePeriod
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationCoin.approve(address(applicationAMM), 10000);
        applicationCoin2.approve(address(applicationAMM), 10000);
        applicationAMM.swap(address(applicationCoin), 100);
        ///move blocktime after pause to resume transfers
        vm.warp(Blocktime + 1600);
        ///transfer again to check
        vm.stopPrank();
        vm.startPrank(user1);
        // applicationAMM.swap(address(applicationCoin), 100);

        ///create new pause rule to check that swaps and trasnfers are paused
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
        vm.warp(Blocktime + 1750);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), 100);

        vm.expectRevert();
        applicationCoin.transfer(user2, 100);

        ///Set multiple pause rules and ensure pauses during and regular function between
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
        appManager.addPauseRule(Blocktime + 2750, Blocktime + 3000);
        appManager.addPauseRule(Blocktime + 3150, Blocktime + 3500);

        vm.warp(Blocktime + 2050); ///Expire previous pause rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2150);
        vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2501); ///Expire Pause rule
        applicationAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2755);
        vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), 100);

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        // applicationAMM.swap(address(applicationCoin), 10); ///Show Application Administrators can utilize system during pauses

        vm.warp(Blocktime + 3015); ///Expire previous pause rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationAMM.swap(address(applicationCoin), 10);

        vm.warp(Blocktime + 3300); ///Expire previous pause rule
        vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 3501); ///Expire previous pause rule
        applicationAMM.swap(address(applicationCoin), 10);
    }

    /**
     * @dev Test the AccessLevel = 0 rule
     */
    function testAccessLevel0AMM() public {
        /// initialize the AMM
        initializeAMMAndUsers();

        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10);
        // this one should pass because the rule is off
        assertEq(applicationAMM.swap(address(applicationCoin), 10), 10);
        /// turn the rule on
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationHandler.activateAccessLevel0Rule(true);
        /// now we check for proper failure
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 9);
        vm.expectRevert(0x3fac082d);
        applicationAMM.swap(address(applicationCoin), 9);
        /// now add a AccessLevel score and try again
        vm.stopPrank();
        vm.startPrank(AccessTier);
        appManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 9);
        applicationAMM.swap(address(applicationCoin), 9);
    }

    function testUpgradeHandlerAMM() public {
        /// Deploy the modified AMM Handler contract
        ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(appManager), address(ruleProcessor));

        /// connect AMM to new Handler
        applicationAMM.connectHandlerToAMM(address(assetHandler));

        /// Test Min Max Balance Rule with New Handler
        initializeAMMAndUsers();
        ///Token 0 Limits
        bytes32[] memory accs = new bytes32[](1);
        uint256[] memory min = new uint256[](1);
        uint256[] memory max = new uint256[](1);
        accs[0] = bytes32("MINMAXTAG");
        min[0] = uint256(10 * 10 ** 18);
        max[0] = uint256(1100 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs, min, max);
        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(appManager), accs1, min1, max1);
        ////update ruleId in coin rule handler
        assetHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        assetHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
        ///Add GeneralTag to account
        appManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
        assertTrue(appManager.hasTag(user1, "MINMAXTAG"));
        appManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
        assertTrue(appManager.hasTag(user2, "MINMAXTAG"));
        appManager.addGeneralTag(user1, "MINMAX"); ///add tag
        assertTrue(appManager.hasTag(user1, "MINMAX"));
        appManager.addGeneralTag(user2, "MINMAX"); ///add tag
        assertTrue(appManager.hasTag(user2, "MINMAX"));
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin), 10 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 990 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1010 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin), 100 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 690 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1310 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 100 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 10 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 1000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1000 * 10 ** 18);
        // make sure the minimum rules fail results in revert
        // vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationAMM.swap(address(applicationCoin), 990 * 10 ** 18);
        /// make sure the maximum rule fail results in revert
        /// vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationAMM.swap(address(applicationCoin), 500 * 10 ** 18);
        ///vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        applicationAMM.swap(address(applicationCoin2), 150 * 10 ** 18);
        /// make sure the minimum rules fail results in revert
        ///vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        applicationAMM.swap(address(applicationCoin2), 650 * 10 ** 18);
        /// test new function in new handler
        address testAddress = assetHandler.newTestFunction();
        console.log(assetHandler.newTestFunction(), testAddress);
    }

    /**
     * @dev this function tests the purchase percentage rule via AMM
     */
    function testPurchasePercentageRule() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        initializeAMMAndUsers();
        applicationCoin2.transfer(user1, 50_000_000 * 10 ** 18);
        applicationCoin2.transfer(user2, 30_000_000 * 10 ** 18);
        applicationCoin.transfer(user1, 50_000_000 * 10 ** 18);
        applicationCoin.transfer(user2, 30_000_000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * 10 ** 18);
        /// set up rule
        uint16 tokenPercentage = 5000; /// 50%
        uint32 purchasePeriod = 24; /// 24 hour periods
        uint256 totalSupply = 100_000_000;
        uint32 ruleStartTime = 12; /// start at 12 hours into the day
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(appManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);
        applicationAMM.swap(address(applicationCoin2), 10_000_000); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xb634aad9);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        vm.expectRevert(0xb634aad9);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);
        /// wait until new period
        vm.warp(Blocktime + 72 hours);
        applicationAMM.swap(address(applicationCoin2), 10_000_000);

        /// check that rule does not apply to coin 0 as this would be a sell
        applicationAMM.swap(address(applicationCoin), 60_000_000);

        /// Low percentage rule checks 
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        /// create new rule 
        uint16 newTokenPercentage = 1; /// .01%
        uint256 newTotalSupply = 100_000; 
        uint32 newRuleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(appManager), newTokenPercentage, purchasePeriod, newTotalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(newRuleId);
        vm.warp(Blocktime + 96 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin2), 1);

        vm.expectRevert(0xb634aad9);
        applicationAMM.swap(address(applicationCoin2), 9);
    }

    function testSellPercentageRule() public {
        /// initialize AMM and give two users more app tokens and "chain native" tokens
        initializeAMMAndUsers();
        applicationCoin2.transfer(user1, 50_000_000 * 10 ** 18);
        applicationCoin2.transfer(user2, 30_000_000 * 10 ** 18);
        applicationCoin.transfer(user1, 50_000_000 * 10 ** 18);
        applicationCoin.transfer(user2, 30_000_000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 50_001_000 * 10 ** 18);
        /// set up rule
        uint16 tokenPercentage = 5000; /// 50%
        uint32 purchasePeriod = 24; /// 24 hour periods
        uint256 totalSupply = 100_000_000;
        uint32 ruleStartTime = 12; /// start at 12 hours into the day
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentageSellRule(address(appManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setSellPercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationAMM.swap(address(applicationCoin), 10_000_000);
        applicationAMM.swap(address(applicationCoin), 10_000_000);
        applicationAMM.swap(address(applicationCoin), 10_000_000);
        applicationAMM.swap(address(applicationCoin), 10_000_000); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xb17ff693);
        applicationAMM.swap(address(applicationCoin), 10_000_000);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);
        vm.expectRevert(0xb17ff693);
        applicationAMM.swap(address(applicationCoin), 10_000_000);
        /// wait until new period
        vm.warp(Blocktime + 72 hours);
        applicationAMM.swap(address(applicationCoin), 10_000_000);

        /// check that rule does not apply to coin 0 as this would be a sell
        applicationAMM.swap(address(applicationCoin2), 60_000_000);
    }

    function testPurchasePercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint32 purchasePeriod, uint32 ruleStartTime) public {
        initializeAMMAndUsers();
        vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && purchasePeriod > 0 && ruleStartTime > 0);

        if (purchasePeriod > 23) {
            purchasePeriod = 23;
        }
        if (ruleStartTime > 12) {
            ruleStartTime = 12;
        }
        uint256 totalSupply = 100_000_000;
        uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(address(appManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        applicationAMM.swap(address(applicationCoin2), amountA);

        vm.warp(Blocktime + 72 hours);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        applicationAMM.swap(address(applicationCoin2), amountA);
        applicationAMM.swap(address(applicationCoin), amountA);
    }

    function testSellPercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint32 sellPeriod, uint32 ruleStartTime) public {
        initializeAMMAndUsers();
        vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && sellPeriod > 0 && ruleStartTime > 0);

        if (sellPeriod > 23) {
            sellPeriod = 23;
        }
        if (ruleStartTime > 12) {
            ruleStartTime = 12;
        }
        uint256 totalSupply = 100_000_000;
        uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
        uint32 ruleId = RuleDataFacet(address(ruleStorageDiamond)).addPercentageSellRule(address(appManager), tokenPercentage, sellPeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setSellPercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), amountA);

        vm.warp(Blocktime + 72 hours);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(applicationAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(applicationAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        applicationAMM.swap(address(applicationCoin), amountA);
        applicationAMM.swap(address(applicationCoin2), amountA);
    }

    /**
     * @dev this function ensures that unique addresses can be randomly retrieved from the address array.
     */
    function getUniqueAddresses(uint256 _seed, uint8 _number) public view returns (address[] memory _addressList) {
        _addressList = new address[](ADDRESSES.length);
        // first one will simply be the seed
        _addressList[0] = ADDRESSES[_seed];
        uint256 j;
        if (_number > 1) {
            // loop until all unique addresses are returned
            for (uint256 i = 1; i < _number; i++) {
                // find the next unique address
                j = _seed;
                do {
                    j++;
                    // if end of list reached, start from the beginning
                    if (j == ADDRESSES.length) {
                        j = 0;
                    }
                    if (!exists(ADDRESSES[j], _addressList)) {
                        _addressList[i] = ADDRESSES[j];
                        break;
                    }
                } while (0 == 0);
            }
        }
        return _addressList;
    }

    // Check if an address exists in the list
    function exists(address _address, address[] memory _addressList) public pure returns (bool) {
        for (uint256 i = 0; i < _addressList.length; i++) {
            if (_address == _addressList[i]) {
                return true;
            }
        }
        return false;
    }
}

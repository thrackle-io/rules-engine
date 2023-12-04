// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/liquidity/ProtocolAMM.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/example/OracleRestricted.sol";
import "src/example/OracleAllowed.sol";
import "test/helpers/TestCommonFoundry.sol";
import {ApplicationAMMHandler} from "../../src/example/liquidity/ApplicationAMMHandler.sol";
import {ApplicationAMMHandlerMod} from "../helpers/ApplicationAMMHandlerMod.sol";
import {TaggedRuleDataFacet} from "src/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/economic/ruleProcessor/AppRuleDataFacet.sol";
import {FeeRuleDataFacet} from "src/economic/ruleProcessor/FeeRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules} from "src/economic/ruleProcessor/RuleDataInterfaces.sol";
import {ERC20RuleProcessorFacet} from "src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMTest is TestCommonFoundry {
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

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        switchToAppAdministrator();
        applicationCoin.mint(appAdministrator, 1_000_000_000_000 * (10 ** 18));
        applicationCoin2 = _createERC20("application2", "GMC2", applicationAppManager);
        applicationCoinHandler2 = _createERC20Handler(ruleProcessor, applicationAppManager, applicationCoin2);
        /// register the token
        applicationAppManager.registerToken("application2", address(applicationCoin2));
        applicationCoin2.mint(appAdministrator, 1_000_000_000_000 * (10 ** 18));

        /// Set up the AMM
        protocolAMMFactory = createProtocolAMMFactory();
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        protocolAMM = ProtocolAMM(protocolAMMFactory.createConstantAMM(address(applicationCoin), address(applicationCoin2),1,1, address(applicationAppManager)));
        handler = new ApplicationAMMHandler(address(applicationAppManager), address(ruleProcessor), address(protocolAMM));
        protocolAMM.connectHandlerToAMM(address(handler));
        applicationAMMHandler = ApplicationAMMHandler(protocolAMM.getHandlerAddress());
        /// Register AMM
        applicationAppManager.registerAMM(address(protocolAMM));
        /// set the treasury address
        protocolAMM.setTreasuryAddress(treasuryAddress);
        applicationAppManager.registerTreasury(treasuryAddress);
        // applicationAppManager.addAppAdministrator(treasuryAddress);

        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        vm.warp(Blocktime);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();
    }

    //Test adding liquidity to the AMM
    function testAddLiquidity() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000);
        applicationCoin2.approve(address(protocolAMM), 1000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000);
        assertEq(protocolAMM.getReserve1(), 1000);
    }

    /// Test removing liquidity from the AMM(token0)
    function testRemoveToken0() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000);
        applicationCoin2.approve(address(protocolAMM), 1000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000);
        assertEq(protocolAMM.getReserve1(), 1000);
        /// Get user's initial balance
        uint256 balance = applicationCoin.balanceOf(appAdministrator);
        /// Remove some token0's
        protocolAMM.removeToken0(500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationCoin.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(500, protocolAMM.getReserve0());
    }

    /// Test removing liquidity from the AMM(token1)
    function testRemoveToken1() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000);
        applicationCoin2.approve(address(protocolAMM), 1000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000, 1000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000);
        assertEq(protocolAMM.getReserve1(), 1000);
        /// Get user's initial balance
        uint256 balance = applicationCoin2.balanceOf(appAdministrator);
        /// Remove some token0's
        protocolAMM.removeToken1(500);
        /// Make sure they came back to admin
        assertEq(balance + 500, applicationCoin2.balanceOf(appAdministrator));
        /// Make sure they no longer show in AMM
        assertEq(500, protocolAMM.getReserve1());
    }

    ///Test fail linear swaps
    function testFailZerosSwap() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000000);
        applicationCoin2.approve(address(protocolAMM), 1000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000);
        assertEq(protocolAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        switchToUser();
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 100000);
        protocolAMM.swap(address(applicationCoin), 0);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1100000);
        assertEq(protocolAMM.getReserve1(), 900000);
        switchToSuperAdmin();

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    /// Test fail invalid token address swaps
    function testFailInvalidToken() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000000);
        applicationCoin2.approve(address(protocolAMM), 1000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000);
        assertEq(protocolAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        switchToUser();
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 100000);
        protocolAMM.swap(address(new ApplicationERC20("application3", "GMC3", address(applicationAppManager))), 100000);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1100000);
        assertEq(protocolAMM.getReserve1(), 900000);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    /// Test linear swaps
    function testSwapLinearToken0() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000000);
        applicationCoin2.approve(address(protocolAMM), 1000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000);
        assertEq(protocolAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 100000);
        protocolAMM.swap(address(applicationCoin), 100000);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1100000);
        assertEq(protocolAMM.getReserve1(), 900000);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 100000);
    }

    function testSwapLinearToken1() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000000);
        applicationCoin2.approve(address(protocolAMM), 1000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000, 1000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000);
        assertEq(protocolAMM.getReserve1(), 1000000);
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 100000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(protocolAMM), 100000);
        protocolAMM.swap(address(applicationCoin2), 100000);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve1(), 1100000);
        assertEq(protocolAMM.getReserve0(), 900000);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin2.balanceOf(user), 0);
        assertEq(applicationCoin.balanceOf(user), 100000);
    }

    /// Test constant product swaps
    function testSwapCPToken0() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 1000000000);
        applicationCoin2.approve(address(protocolAMM), 1000000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000000);
        assertEq(protocolAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 50000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer(1M)
        applicationCoin.approve(address(protocolAMM), 50000);
        uint256 rValue = protocolAMM.swap(address(applicationCoin), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1000050000);
        assertEq(protocolAMM.getReserve1(), 999950003);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 49997);
    }

    function testSwapCPToken1() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1000000000);
        applicationCoin2.approve(address(protocolAMM), 1000000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000000);
        assertEq(protocolAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 50000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(protocolAMM), 50000);
        uint256 rValue = protocolAMM.swap(address(applicationCoin2), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve1(), 1000050000);
        assertEq(protocolAMM.getReserve0(), 999950003);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin2.balanceOf(user), 0);
        assertEq(applicationCoin.balanceOf(user), 49997);
    }

    /// Test sample 1 function swaps
    function testSwapSample1BackAndForth() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * 10 ** 18, 4 * 10 ** 18, address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(protocolAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        protocolAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(protocolAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 3 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 1 * (10 ** 18));
        uint256 rValue = protocolAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));

        /// now make the opposite trade to ensure we get the proper value back
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationCoin2.transfer(user, 10 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(protocolAMM), 3 * (10 ** 18));
        uint256 rValue2 = protocolAMM.swap(address(applicationCoin2), 3 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue2, 1 * (10 ** 18));

        /// Now try trade application coin 0 for 1
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 1 * (10 ** 18));
        rValue = protocolAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));
    }

    /// Test sample 1 function swaps
    function testSwapSample1Token0() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * 10 ** 18, 4 * 10 ** 18, address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(protocolAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        protocolAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(protocolAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 3 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 1 * (10 ** 18));
        uint256 rValue = protocolAMM.swap(address(applicationCoin), 1 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 15 * (10 ** 17));
    }

    /// Test sample 1 function swaps
    function testSwapSample1Token1() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * 10 ** 18, 4 * 10 ** 18, address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 100_000 * (10 ** 18));
        applicationCoin2.approve(address(protocolAMM), 10_000 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        protocolAMM.addLiquidity(100000 * (10 ** 18), 10_000 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 100_000 * (10 ** 18));
        assertEq(protocolAMM.getReserve1(), 10_000 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 5 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(protocolAMM), 5 * (10 ** 18));
        uint256 rValue = protocolAMM.swap(address(applicationCoin2), 5 * (10 ** 18));
        /// make sure swap returns correct value
        assertEq(rValue, 1 * (10 ** 18));
    }

    /// Test sample 1 function swaps failure for shallow pool
    function testSwapSample1Token1PoolFail() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * 10 ** 18, 4 * 10 ** 18, address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 10 * (10 ** 18));
        applicationCoin2.approve(address(protocolAMM), 10 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        protocolAMM.addLiquidity(5 * (10 ** 18), 5 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 5 * (10 ** 18));
        assertEq(protocolAMM.getReserve1(), 5 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin2.transfer(user, 10000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin2.approve(address(protocolAMM), 10000 * (10 ** 18));
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 5 * (10 ** 18), 98019998000000000000));
        protocolAMM.swap(address(applicationCoin2), 10000 * (10 ** 18));
        /// make sure swap returns correct value
        // assertEq(rValue, 1 * (10 ** 18));
    }

    /// Test sample 1 function swaps failure for shallow pool
    function testSwapSample1Token0PoolFail() public {
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createSample01(8 * 10 ** 18, 4 * 10 ** 18, address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 5 * (10 ** 18));
        applicationCoin2.approve(address(protocolAMM), 5 * (10 ** 18));
        /// Transfer the tokens into the AMM(token0 = Application Coin, token1 = Source Coin)
        protocolAMM.addLiquidity(5 * (10 ** 18), 5 * (10 ** 18));
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 5 * (10 ** 18));
        assertEq(protocolAMM.getReserve1(), 5 * (10 ** 18));
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 10000 * (10 ** 18));
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer
        applicationCoin.approve(address(protocolAMM), 10000 * (10 ** 18));
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,int256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 5 * (10 ** 18), -49980000000000000000000000));
        protocolAMM.swap(address(applicationCoin), 10000 * (10 ** 18));
    }

    ///TODO Test Purchase rule through AMM once Purchase functionality is created
    function testSellRule() public {
        /// Set Up AMM, approve and swap with user without tags
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(protocolAMMCalculatorFactory.createConstantProduct(address(applicationAppManager)));
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 1000000000);
        applicationCoin2.approve(address(protocolAMM), 1000000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000000);
        assertEq(protocolAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user1, 60000);
        applicationCoin2.transfer(user1, 60000);
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(protocolAMM), 50000);
        uint256 rValue = protocolAMM.swap(address(applicationCoin), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1000050000);
        assertEq(protocolAMM.getReserve1(), 999950003);

        vm.stopPrank();
        vm.startPrank(superAdmin);
        ///Add tag to user
        bytes32[] memory accs = new bytes32[](1);
        uint192[] memory sellAmounts = new uint192[](1);
        uint16[] memory sellPeriod = new uint16[](1);
        uint64[] memory startTime = new uint64[](1);
        accs[0] = bytes32("SellRule");
        sellAmounts[0] = uint192(600); ///Amount to trigger Sell freeze rules
        sellPeriod[0] = uint16(36); ///Hours
        startTime[0] = uint64(Blocktime);

        /// Set the rule data
        applicationAppManager.addGeneralTag(user1, "SellRule");
        applicationAppManager.addGeneralTag(user2, "SellRule");
        /// add the rule.
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sellAmounts, sellPeriod, startTime);
        ///update ruleId in application AMM rule handler
        applicationAMMHandler.setSellLimitRuleId(ruleId);
        /// Swap that passes rule check
        vm.stopPrank();
        vm.startPrank(user1);
        /// Approve transfer(1M)
        applicationCoin.approve(address(protocolAMM), 50000);
        applicationCoin2.approve(address(protocolAMM), 50000);
        protocolAMM.swap(address(applicationCoin), 500);

        /// Swap that fails
        vm.expectRevert(0xc11d5f20);
        protocolAMM.swap(address(applicationCoin), 500);
    }

    /// test updating min transfer rule
    function testAMMPassesMinTransferRule() public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// we add the rule.
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 10);
        /// we update the rule id in the token
        applicationAMMHandler.setMinTransferRuleId(ruleId);
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10);
        assertEq(protocolAMM.swap(address(applicationCoin), 10), 10);

        /// now we check for proper failure
        applicationCoin.approve(address(protocolAMM), 9);
        vm.expectRevert(0x70311aa2);
        protocolAMM.swap(address(applicationCoin), 9);
    }

    /// test AMM Fees
    function testAMMFees() public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// we add the rule.
        switchToRuleAdmin();
        /// make sure that no bogus fee percentage can get in
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 10001));
        uint32 ruleId = FeeRuleDataFacet(address(ruleProcessor)).addAMMFeeRule(address(applicationAppManager), 10001);
        vm.expectRevert(abi.encodeWithSelector(selector, 0));
        ruleId = FeeRuleDataFacet(address(ruleProcessor)).addAMMFeeRule(address(applicationAppManager), 0);
        /// now add the good rule
        ruleId = FeeRuleDataFacet(address(ruleProcessor)).addAMMFeeRule(address(applicationAppManager), 300);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);
        switchToAppAdministrator();
        /// set the treasury address
        protocolAMM.setTreasuryAddress(address(99));
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18), 97 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(address(99)), 3 * 10 ** 18);
        // Now try the other direction. Since only token1 is used for fees, it is worth testing it as well. This
        // is the linear swap so the test is easy. For other styles, it can be more difficult because the fee is
        // assessed prior to the swap calculation
        applicationCoin2.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(protocolAMM.swap(address(applicationCoin2), 100 * 10 ** 18), 97 * 10 ** 18);

        // Now try one that isn't as easy
        applicationCoin.approve(address(protocolAMM), 1 * 10 ** 18);
        // should get 97% back but not an easy nice token
        assertEq(protocolAMM.swap(address(applicationCoin), 1 * 10 ** 18), 97 * 10 ** 16);

        // Now try one that is even harder
        applicationCoin.approve(address(protocolAMM), 7 * 10 ** 12);
        // should get 97% back but not an easy nice token
        assertEq(protocolAMM.swap(address(applicationCoin), 7 * 10 ** 12), 679 * 10 ** 10);
    }

    /// test AMM Fees
    function testAMMFeesFuzz(uint256 feePercentage, uint8 _addressIndex, uint256 swapAmount) public {
        vm.assume(feePercentage < 10000 && feePercentage > 0);
        if (swapAmount > 999999) swapAmount = 999999;
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address ammUser = addressList[0];
        address treasury = addressList[1];
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1_000_000_000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 1_000_000_000 * 10 ** 18);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1_000_000_000 * 10 ** 18, 1_000_000_000 * 10 ** 18);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1_000_000_000 * 10 ** 18);
        assertEq(protocolAMM.getReserve1(), 1_000_000_000 * 10 ** 18);
        console.logString("Transfer tokens to ammUser");
        applicationCoin.transfer(ammUser, swapAmount);

        /// we add the rule.
        switchToRuleAdmin();
        console.logString("Create the Fee Rule");
        uint32 ruleId = FeeRuleDataFacet(address(ruleProcessor)).addAMMFeeRule(address(applicationAppManager), feePercentage);
        /// we update the rule id in the token
        applicationAMMHandler.setAMMFeeRuleId(ruleId);
        switchToAppAdministrator();
        /// set the treasury address
        protocolAMM.setTreasuryAddress(treasury);
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(ammUser);
        applicationCoin.approve(address(protocolAMM), swapAmount);
        // should get x% of swap return
        console.logString("Perform the swap");
        if (swapAmount == 0) vm.expectRevert(0x5b2790b5); // if swap amount is zero, revert correctly
        assertEq(protocolAMM.swap(address(applicationCoin), swapAmount), swapAmount - ((swapAmount * feePercentage) / 10000));
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

        /// selecting ADDRESSES randomly
        address targetedTrader = addresses[target % addresses.length];
        address traderB = addresses[secondTrader % addresses.length];

        // BLOCKLIST ORACLE
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleRestricted));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleRestricted));
        switchToAppAdministrator();
        // add a blocked address
        badBoys.push(targetedTrader);
        oracleRestricted.addToSanctionsList(badBoys);
        switchToRuleAdmin();
        /// connect the rule to this handler
        applicationAMMHandler.setOracleRuleId(_index);
        vm.stopPrank();
        vm.startPrank(user1);
        uint balanceABefore = applicationCoin.balanceOf(user1);
        uint balanceBBefore = applicationCoin2.balanceOf(user1);
        uint reserves0 = protocolAMM.getReserve0();
        uint reserves1 = protocolAMM.getReserve1();
        console.log(protocolAMM.getReserve1());
        applicationCoin.approve(address(protocolAMM), amount1);
        if (targetedTrader == user1) vm.expectRevert(0x6bdfffc0);
        protocolAMM.swap(address(applicationCoin), amount1);
        if (targetedTrader != user1) {
            assertEq(applicationCoin.balanceOf(user1), balanceABefore - amount1);
            assertEq(applicationCoin2.balanceOf(user1), balanceBBefore + amount1);
            assertEq(protocolAMM.getReserve0(), reserves0 + amount1);
            assertEq(protocolAMM.getReserve1(), reserves1 - amount1);
        }

        /// ALLOWLIST ORACLE
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationAMMHandler.setOracleRuleId(_index);
        switchToAppAdministrator();
        // add an allowed address
        goodBoys.push(targetedTrader);
        oracleAllowed.addToAllowList(goodBoys);
        balanceABefore = applicationCoin.balanceOf(traderB);
        balanceBBefore = applicationCoin2.balanceOf(traderB);
        reserves0 = protocolAMM.getReserve0();
        reserves1 = protocolAMM.getReserve1();
        vm.stopPrank();
        vm.startPrank(traderB);
        applicationCoin.approve(address(protocolAMM), amount2);
        if (targetedTrader != traderB) vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), amount2);
        if (targetedTrader == traderB) {
            assertEq(applicationCoin.balanceOf(traderB), balanceABefore - amount2);
            assertEq(applicationCoin2.balanceOf(traderB), balanceBBefore + amount2);
            assertEq(protocolAMM.getReserve0(), reserves0 + amount2);
            assertEq(protocolAMM.getReserve1(), reserves1 - amount2);
        }
    }

    /// set up the AMM(linear) for rule tests. Also set up user1 with applicationCoin and user2 with applicationCoin2
    function initializeAMMAndUsers() public {
        /// Approve the transfer of tokens into AMM
        applicationCoin.approve(address(protocolAMM), 1_000_000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 1_000_000 * 10 ** 18);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1_000_000 * 10 ** 18, 1_000_000 * 10 ** 18);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1_000_000 * 10 ** 18);
        assertEq(protocolAMM.getReserve1(), 1_000_000 * 10 ** 18);
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
        switchToRuleAdmin();
        /// add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);

        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleProcessor)).addBalanceLimitRules(address(applicationAppManager), accs1, min1, max1);
        ////update ruleId in coin rule handler
        applicationAMMHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        applicationAMMHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
        switchToAppAdministrator();
        ///Add GeneralTag to account
        applicationAppManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MINMAXTAG"));
        applicationAppManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MINMAXTAG"));
        applicationAppManager.addGeneralTag(user1, "MINMAX"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MINMAX"));
        applicationAppManager.addGeneralTag(user2, "MINMAX"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MINMAX"));

        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);

        protocolAMM.swap(address(applicationCoin), 10 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 990 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1010 * 10 ** 18);

        protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 690 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1310 * 10 ** 18);

        protocolAMM.swap(address(applicationCoin2), 100 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 10 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 1000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1000 * 10 ** 18);

        // make sure the minimum rules fail results in revert
        // vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        protocolAMM.swap(address(applicationCoin), 990 * 10 ** 18);

        /// make sure the maximum rule fail results in revert
        /// vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        protocolAMM.swap(address(applicationCoin), 500 * 10 ** 18);

        ///vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        protocolAMM.swap(address(applicationCoin2), 150 * 10 ** 18);

        /// make sure the minimum rules fail results in revert
        ///vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        protocolAMM.swap(address(applicationCoin2), 650 * 10 ** 18);
    }

    function testPauseRulesViaAppManagerAMM() public {
        initializeAMMAndUsers();
        applicationCoin.transfer(appAdministrator, 1000);
        applicationCoin2.transfer(appAdministrator, 1000);
        ///set pause rule and check check that the transaction reverts
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1000, Blocktime + 1500);
        vm.warp(Blocktime + 1001);

        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000);
        applicationCoin2.approve(address(protocolAMM), 10000);
        vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), 100);

        //Check that appAdministrators can still transfer within pausePeriod
        switchToAppAdministrator();
        applicationCoin.approve(address(protocolAMM), 10000);
        applicationCoin2.approve(address(protocolAMM), 10000);
        protocolAMM.swap(address(applicationCoin), 100);
        ///move blocktime after pause to resume transfers
        vm.warp(Blocktime + 1600);
        ///transfer again to check
        vm.stopPrank();
        vm.startPrank(user1);
        // protocolAMM.swap(address(applicationCoin), 100);

        ///create new pause rule to check that swaps and transfers are paused
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 1700, Blocktime + 2000);
        vm.warp(Blocktime + 1750);

        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), 100);

        vm.expectRevert();
        applicationCoin.transfer(user2, 100);

        ///Set multiple pause rules and ensure pauses during and regular function between
        switchToRuleAdmin();
        applicationAppManager.addPauseRule(Blocktime + 2100, Blocktime + 2500);
        applicationAppManager.addPauseRule(Blocktime + 2750, Blocktime + 3000);
        applicationAppManager.addPauseRule(Blocktime + 3150, Blocktime + 3500);

        vm.warp(Blocktime + 2050); ///Expire previous pause rule
        vm.stopPrank();
        vm.startPrank(user1);
        protocolAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2150);
        vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2501); ///Expire Pause rule
        protocolAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 2755);
        vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), 100);

        switchToAppAdministrator();
        // protocolAMM.swap(address(applicationCoin), 10); ///Show Application Administrators can utilize system during pauses

        vm.warp(Blocktime + 3015); ///Expire previous pause rule
        vm.stopPrank();
        vm.startPrank(user1);
        protocolAMM.swap(address(applicationCoin), 10);

        vm.warp(Blocktime + 3300); ///Expire previous pause rule
        vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), 100);

        vm.warp(Blocktime + 3501); ///Expire previous pause rule
        protocolAMM.swap(address(applicationCoin), 10);
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
        applicationCoin.approve(address(protocolAMM), 10);
        // this one should pass because the rule is off
        assertEq(protocolAMM.swap(address(applicationCoin), 10), 10);
        /// turn the rule on
        switchToRuleAdmin();
        applicationHandler.activateAccessLevel0Rule(true);
        /// now we check for proper failure
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 9);
        vm.expectRevert(0x3fac082d);
        protocolAMM.swap(address(applicationCoin), 9);
        /// now add a AccessLevel score and try again
        switchToAccessLevelAdmin();
        applicationAppManager.addAccessLevel(user1, 1);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 9);
        protocolAMM.swap(address(applicationCoin), 9);
    }

    function testUpgradeHandlerAMM() public {
        /// Deploy the modified AMM Handler contract
        ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(applicationAppManager), address(ruleProcessor), address(protocolAMM));

        /// connect AMM to new Handler
        protocolAMM.connectHandlerToAMM(address(assetHandler));
        /// must deregister and reregister AMM
        applicationAppManager.deRegisterAMM(address(protocolAMM));
        applicationAppManager.registerAMM(address(protocolAMM));

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
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addBalanceLimitRules(address(applicationAppManager), accs, min, max);
        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleProcessor)).addBalanceLimitRules(address(applicationAppManager), accs1, min1, max1);
        ////update ruleId in coin rule handler
        assetHandler.setMinMaxBalanceRuleIdToken0(ruleId);
        assetHandler.setMinMaxBalanceRuleIdToken1(ruleId1);
        switchToAppAdministrator();
        ///Add GeneralTag to account
        applicationAppManager.addGeneralTag(user1, "MINMAXTAG"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MINMAXTAG"));
        applicationAppManager.addGeneralTag(user2, "MINMAXTAG"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MINMAXTAG"));
        applicationAppManager.addGeneralTag(user1, "MINMAX"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "MINMAX"));
        applicationAppManager.addGeneralTag(user2, "MINMAX"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "MINMAX"));
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin), 10 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 990 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1010 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 690 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1310 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 100 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 10 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 200 * 10 ** 18);
        assertEq(applicationCoin.balanceOf(user1), 1000 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(user1), 1000 * 10 ** 18);
        // make sure the minimum rules fail results in revert
        // vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        protocolAMM.swap(address(applicationCoin), 990 * 10 ** 18);
        /// make sure the maximum rule fail results in revert
        /// vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        protocolAMM.swap(address(applicationCoin), 500 * 10 ** 18);
        ///vm.expectRevert("Balance Will Exceed Maximum");
        vm.expectRevert(0x24691f6b);
        protocolAMM.swap(address(applicationCoin2), 150 * 10 ** 18);
        /// make sure the minimum rules fail results in revert
        ///vm.expectRevert("Balance Will Drop Below Minimum");
        vm.expectRevert(0xf1737570);
        protocolAMM.swap(address(applicationCoin2), 650 * 10 ** 18);
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
        uint16 purchasePeriod = 24; /// 24 hour periods
        uint256 totalSupply = 100_000_000;
        uint64 ruleStartTime = Blocktime;
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);
        protocolAMM.swap(address(applicationCoin2), 10_000_000); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xb634aad9);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        vm.expectRevert(0xb634aad9);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);
        /// wait until new period
        vm.warp(Blocktime + 72 hours);
        protocolAMM.swap(address(applicationCoin2), 10_000_000);

        /// check that rule does not apply to coin 0 as this would be a sell
        protocolAMM.swap(address(applicationCoin), 60_000_000);

        /// Low percentage rule checks
        switchToRuleAdmin();
        /// create new rule
        uint16 newTokenPercentage = 1; /// .01%
        uint256 newTotalSupply = 100_000;
        uint32 newRuleId = RuleDataFacet(address(ruleProcessor)).addPercentagePurchaseRule(address(applicationAppManager), newTokenPercentage, purchasePeriod, newTotalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(newRuleId);
        vm.warp(Blocktime + 96 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin2), 1);

        vm.expectRevert(0xb634aad9);
        protocolAMM.swap(address(applicationCoin2), 9);
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
        uint16 purchasePeriod = 24; /// 24 hour periods
        uint256 totalSupply = 100_000_000;
        uint64 ruleStartTime = Blocktime;
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addPercentageSellRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setSellPercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        /// test swap below percentage
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        protocolAMM.swap(address(applicationCoin), 10_000_000);
        protocolAMM.swap(address(applicationCoin), 10_000_000);
        protocolAMM.swap(address(applicationCoin), 10_000_000);
        protocolAMM.swap(address(applicationCoin), 10_000_000); /// percentage limit hit now
        /// test swaps after we hit limit
        vm.expectRevert(0xb17ff693);
        protocolAMM.swap(address(applicationCoin), 10_000_000);
        /// switch users and test rule still fails
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);
        vm.expectRevert(0xb17ff693);
        protocolAMM.swap(address(applicationCoin), 10_000_000);
        /// wait until new period
        vm.warp(Blocktime + 72 hours);
        protocolAMM.swap(address(applicationCoin), 10_000_000);

        /// check that rule does not apply to coin 0 as this would be a sell
        protocolAMM.swap(address(applicationCoin2), 60_000_000);
    }

    function testPurchasePercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint16 purchasePeriod, uint64 ruleStartTime) public {
        initializeAMMAndUsers();
        vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && purchasePeriod > 0 && ruleStartTime > 0);

        if (purchasePeriod > 23) {
            purchasePeriod = 23;
        }
        if (ruleStartTime > block.timestamp) ruleStartTime = uint64(block.timestamp);
        uint256 totalSupply = 100_000_000;
        uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addPercentagePurchaseRule(address(applicationAppManager), tokenPercentage, purchasePeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setPurchasePercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        protocolAMM.swap(address(applicationCoin2), amountA);

        vm.warp(Blocktime + 72 hours);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        protocolAMM.swap(address(applicationCoin2), amountA);
        protocolAMM.swap(address(applicationCoin), amountA);
    }

    function testSellPercentageRuleFuzz(uint256 amountA, uint16 tokenPercentage, uint16 sellPeriod, uint64 ruleStartTime) public {
        initializeAMMAndUsers();
        vm.assume(amountA > 0 && amountA < 99999999 && tokenPercentage > 0 && tokenPercentage < 9999 && sellPeriod > 0 && ruleStartTime > 0);

        if (sellPeriod > 23) {
            sellPeriod = 23;
        }
        if (ruleStartTime > block.timestamp) ruleStartTime = uint64(block.timestamp);
        uint256 totalSupply = 100_000_000;
        uint256 amountB = ((totalSupply / tokenPercentage) * 10000);
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addPercentageSellRule(address(applicationAppManager), tokenPercentage, sellPeriod, totalSupply, ruleStartTime);
        /// add and activate rule
        applicationAMMHandler.setSellPercentageRuleId(ruleId);
        vm.warp(Blocktime + 36 hours);
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), amountA);

        vm.warp(Blocktime + 72 hours);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationCoin.approve(address(protocolAMM), 10000 * 10 ** 18);
        applicationCoin2.approve(address(protocolAMM), 10000 * 10 ** 18);

        if (amountA > amountB) vm.expectRevert();
        protocolAMM.swap(address(applicationCoin), amountA);
        protocolAMM.swap(address(applicationCoin2), amountA);
    }

    /// Test constant product swaps that use a factory created calculator
    function testSwapCPToken0ThroughFactory() public {
        factory = new ProtocolAMMCalculatorFactory();
        address calcAddress = factory.createConstantProduct(address(applicationAppManager));
        /// change AMM to use the CP calculator
        protocolAMM.setCalculatorAddress(calcAddress);
        /// Approve the transfer of tokens into AMM(1B)
        applicationCoin.approve(address(protocolAMM), 1000000000);
        applicationCoin2.approve(address(protocolAMM), 1000000000);
        /// Transfer the tokens into the AMM
        protocolAMM.addLiquidity(1000000000, 1000000000);
        /// Make sure the tokens made it
        assertEq(protocolAMM.getReserve0(), 1000000000);
        assertEq(protocolAMM.getReserve1(), 1000000000);
        /// Set up a regular user with some tokens
        applicationCoin.transfer(user, 50000);
        vm.stopPrank();
        vm.startPrank(user);
        /// Approve transfer(1M)
        applicationCoin.approve(address(protocolAMM), 50000);
        uint256 rValue = protocolAMM.swap(address(applicationCoin), 50000);
        /// make sure swap returns correct value
        assertEq(rValue, 49997);
        /// Make sure AMM balances show change
        assertEq(protocolAMM.getReserve0(), 1000050000);
        assertEq(protocolAMM.getReserve1(), 999950003);
        vm.stopPrank();
        vm.startPrank(superAdmin);

        /// Make sure user's wallet shows change
        assertEq(applicationCoin.balanceOf(user), 0);
        assertEq(applicationCoin2.balanceOf(user), 49997);
    }
}

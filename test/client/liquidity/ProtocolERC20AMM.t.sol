// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "test/util/TestCommonFoundry.sol";
import {ApplicationAMMHandler} from "src/example/liquidity/ApplicationAMMHandler.sol";
import {ApplicationAMMHandlerMod} from "test/util/ApplicationAMMHandlerMod.sol";
import {ConstantRatio} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";

/**
 * @title Test all AMM related functions
 * @notice This tests every function related to the AMM including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolERC20AMMTest is TestCommonFoundry {

    uint256 constant MAX_FEE = 10000;
    uint256 constant MAX_FEE_TRADE = 999999;
    uint256 constant MIN_FEE_BALANCE = 0;
    uint256 constant MAX_FEE_BALANCE = type(uint256).max;

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
        ConstantRatio memory cr = ConstantRatio(1,1);
        protocolAMM = ProtocolERC20AMM(protocolAMMFactory.createConstantAMM(address(applicationCoin), address(applicationCoin2),cr, address(applicationAppManager)));
        handler = new ApplicationAMMHandler(address(applicationAppManager), address(ruleProcessor), address(protocolAMM), false);
        protocolAMM.connectHandlerToAMM(address(handler));
        applicationAMMHandler = ApplicationAMMHandler(protocolAMM.getHandlerAddress());
        /// Register AMM
        applicationAppManager.registerAMM(address(protocolAMM));
        applicationCoinHandler2.setERC20PricingAddress(address(erc20Pricer));
        vm.warp(Blocktime);

        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleDenied = new OracleDenied();
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
        protocolAMM.addLiquidity(100_000 * (10 ** 18), 10_000 * (10 ** 18));
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
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth(uint256,uint256)"));
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
        bytes4 selector = bytes4(keccak256("InsufficientPoolDepth()"));
        vm.expectRevert(abi.encodeWithSelector(selector));
        protocolAMM.swap(address(applicationCoin), 10000 * (10 ** 18));
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
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount2 = user10;
        address targetAccount3 = user9;
        // create a fee
        applicationAMMHandler.addFee("cheap", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationAMMHandler.getFee("cheap");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, MIN_FEE_BALANCE);
        assertEq(fee.maxBalance, MAX_FEE_BALANCE);
        assertEq(1, applicationAMMHandler.getFeeTotal());
        
        // now test the fee assessment
        applicationAppManager.addGeneralTag(user1, "cheap"); ///add tag
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18), 97 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(targetAccount), 3 * 10 ** 18);
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

        // Now one with multiple treasuries
        switchToRuleAdmin();
        applicationAMMHandler.addFee("expensive1", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount2);
        feePercentage = 600;
        applicationAMMHandler.addFee("expensive2", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount3);
        switchToAppAdministrator();
        applicationAppManager.removeGeneralTag(user1, "cheap"); ///remove tag
        applicationAppManager.addGeneralTag(user1, "expensive1"); ///add tag
        applicationAppManager.addGeneralTag(user1, "expensive2"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 91% back but not an easy nice token
        assertEq(protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18), 91 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(targetAccount2), 3 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(targetAccount3), 6 * 10 ** 18);
    }

    function testAMMFeesBlankTag() public {
        /// initialize the AMM
        initializeAMMAndUsers();
        /// we add the rule.
        switchToRuleAdmin();
        int24 feePercentage = 300;
        address targetAccount = rich_user;
        address targetAccount3 = user9;
        // create a fee
        applicationAMMHandler.addFee("", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount);
        switchToAppAdministrator();
        Fees.Fee memory fee = applicationAMMHandler.getFee("");
        assertEq(fee.feePercentage, feePercentage);
        assertEq(fee.minBalance, MIN_FEE_BALANCE);
        assertEq(fee.maxBalance, MAX_FEE_BALANCE);
        assertEq(1, applicationAMMHandler.getFeeTotal());
        
        // now test the fee assessment
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18), 97 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(targetAccount), 3 * 10 ** 18);
        // Now try the other direction. Since only token1 is used for fees, it is worth testing it as well. This
        // is the linear swap so the test is easy. For other styles, it can be more difficult because the fee is
        // assessed prior to the swap calculation
        applicationCoin2.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 97% back
        assertEq(protocolAMM.swap(address(applicationCoin2), 100 * 10 ** 18), 97 * 10 ** 18);
        
        // Now one with multiple treasuries
        switchToRuleAdmin();
        feePercentage = 600;
        applicationAMMHandler.addFee("expensive", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount3);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(user1, "expensive"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        applicationCoin.approve(address(protocolAMM), 100 * 10 ** 18);
        // should get 91% back but not an easy nice token
        assertEq(protocolAMM.swap(address(applicationCoin), 100 * 10 ** 18), 91 * 10 ** 18);
        assertEq(applicationCoin2.balanceOf(targetAccount3), 6 * 10 ** 18);
    }

    /// test AMM Fees
    function testAMMFeesFuzz(uint256 _feePercentage, uint8 _addressIndex, uint256 _swapAmount) public {
        int24 feePercentage = int24(int256((bound(_feePercentage, 1, MAX_FEE))));  
        uint256 swapAmount = uint256(bound(_swapAmount, 1, MAX_FEE_TRADE));  
        address[] memory addressList = getUniqueAddresses(_addressIndex % ADDRESSES.length, 2);
        address ammUser = addressList[0];
        address targetAccount = addressList[1];
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
        applicationAMMHandler.addFee("cheap", MIN_FEE_BALANCE, MAX_FEE_BALANCE, feePercentage, targetAccount);
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(ammUser, "cheap"); ///add tag
        /// Set up this particular swap
        /// Approve transfer
        vm.stopPrank();
        vm.startPrank(ammUser);
        applicationCoin.approve(address(protocolAMM), swapAmount);
        // should get x% of swap return
        console.logString("Perform the swap");
        uint256 expectedFee = ((swapAmount * uint24(feePercentage)) / 10000);
        if (swapAmount == 0) vm.expectRevert(0x5b2790b5); // if swap amount is zero, revert correctly
        assertEq(protocolAMM.swap(address(applicationCoin), swapAmount), swapAmount - expectedFee);
        assertEq(applicationCoin2.balanceOf(ammUser), swapAmount - expectedFee);
        assertEq(applicationCoin2.balanceOf(targetAccount), expectedFee);
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
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        switchToAppAdministrator();
        // add a blocked address
        badBoys.push(targetedTrader);
        oracleDenied.addToDeniedList(badBoys);
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
        if (targetedTrader == user1) vm.expectRevert(0x2767bda4);
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
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);

        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs1, min1, max1);
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
        applicationCoin.transfer(ruleBypassAccount, 1000);
        applicationCoin2.transfer(ruleBypassAccount, 1000);
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
        switchToRuleBypassAccount();
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
        ApplicationAMMHandlerMod assetHandler = new ApplicationAMMHandlerMod(address(applicationAppManager), address(ruleProcessor), address(protocolAMM), false);

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
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        ///Token 1 Limits
        bytes32[] memory accs1 = new bytes32[](1);
        uint256[] memory min1 = new uint256[](1);
        uint256[] memory max1 = new uint256[](1);
        accs1[0] = bytes32("MINMAX");
        min1[0] = uint256(500 * 10 ** 18);
        max1[0] = uint256(2000 * 10 ** 18);
        /// add the actual rule
        uint32 ruleId1 = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs1, min1, max1);
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

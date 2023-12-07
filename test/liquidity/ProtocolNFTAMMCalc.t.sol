// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/liquidity/ProtocolERC20AMM.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LinearInput} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "../../src/liquidity/calculators/ProtocolNFTAMMCalcDualLinear.sol";

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMFactoryTest is TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        protocolAMMFactory = createProtocolAMMFactory();
        switchToAppAdministrator();
    }

    function testCreateNFTAMMCalculator() public returns(ProtocolNFTAMMCalcDualLinear calc) {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 10
        LinearInput memory buy = LinearInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.18; b = 9.8
        LinearInput memory sell = LinearInput(18 * 10 ** 6, 98 * 10 ** 17);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testCreateNFTAMMCalculatorWithExtremelyHighParameters() public returns(ProtocolNFTAMMCalcDualLinear calc) {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 1_000_000_000_000_000_000_000_000; b = 1_000_000_000_000_000_000_000_000
        LinearInput memory buy = LinearInput(1_000_000_000_000_000_000_000_000 * 10 ** 8, 1_000_000_000_000_000_000_000_000 * 10 ** 18);
        /// sell slope = 990 sextillion; b = 990 sextillion
        LinearInput memory sell = LinearInput(990_000_000_000_000_000_000_000 * 10 ** 8, 990_000_000_000_000_000_000_000 * 10 ** 18);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testCreateNFTAMMCalculatorWithExtremelyLowParameters() public returns(ProtocolNFTAMMCalcDualLinear calc) {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.00000002; b = 0.0000000000000001
        LinearInput memory buy = LinearInput(2, 100);
        /// sell slope = 0.00000001; b = 0.000000000000000099
        LinearInput memory sell = LinearInput(1, 99);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testNegCreateNFTAMMCalculatorIntersectingCurvesAtLow_q() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 10
        LinearInput memory buy = LinearInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.18; b = 11
        LinearInput memory sell = LinearInput(18 * 10 ** 6, 11 * 10 ** 18);
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorIntersectingCurvesAtHigh_q() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 10
        LinearInput memory buy = LinearInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.22; b = 9.8
        LinearInput memory sell = LinearInput(22 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorYAboveLimit() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 1_000_000_000_001
        LinearInput memory buy = LinearInput(2 * 10 ** 7, 1_000_000_000_000_000_000_000_001 * 10 ** 18);
        /// sell slope = 0.18; b = 9.8
        LinearInput memory sell = LinearInput(18 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)", 1_000_000_000_000_000_000_000_001 * 10 ** 18));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorMAboveLimit() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 1_000_000_000_001 ; b = 10
        LinearInput memory buy = LinearInput(1_000_000_000_000_000_000_000_001 * 10 ** 8, 10 * 10 ** 18 );
        /// sell slope = 0.18; b = 9.8
        LinearInput memory sell = LinearInput(18 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)", 1_000_000_000_000_000_000_000_001 * 10 ** 8));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegUpdateBuyCurveIntersectingAtLow_q() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newBuy = LinearInput(2 * 10 ** 7, 97 * 10 ** 17 ); // m = 0.2, b = 9.7
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        calc.setBuyCurve(newBuy);
    }

    function testNegUpdateBuyCurveIntersectingAtHigh_q() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newBuy = LinearInput(15 * 10 ** 6, 10 * 10 ** 18 ); // m = 0.15, b = 10
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        calc.setBuyCurve(newBuy);
    }

    function testUpdateBuyCurve() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newBuy = LinearInput(22 * 10 ** 7, 11 * 10 ** 18 ); // m = 0.22, b = 11
        calc.setBuyCurve(newBuy);
    }

    function testNegUpdateSellCurveIntersectingAtLow_q() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newSell = LinearInput(18 * 10 ** 6, 11 * 10 ** 18 ); // m = 0.18, b = 11
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        calc.setSellCurve(newSell);
    }

    function testNegUpdateSellCurveIntersectingAtHigh_q() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newSell = LinearInput(3 * 10 ** 7, 98 * 10 ** 17 ); // m = 0.3, b = 9.8
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        calc.setSellCurve(newSell);
    }

    function testUpdateSellCurve() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();
        LinearInput memory newSell = LinearInput(1 * 10 ** 7, 5 * 10 ** 18 ); // m = 0.1, b = 5
        calc.setSellCurve(newSell);
    }

   function testBuyCurve() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();

        uint256 priceA;
        uint256 priceB;
        // we test buying 1 NFT when q is 10
        calc.set_q(10);

        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 12
        assertEq(priceA, priceB);
        assertEq(priceA, 12 * 10 ** 18);
        assertEq(calc.q(), 11);
        // we test buying 1 NFT when q is 1_000
        calc.set_q(1_000);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 210
        assertEq(priceA, priceB);
        assertEq(priceA, 210 * 10 ** 18);
        assertEq(calc.q(), 1_001);
        // we test buying 1 NFT when q is a mill
        calc.set_q(1_000_000);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 200010
        assertEq(priceA, priceB);
        assertEq(priceA, 200010 * 10 ** 18);
        assertEq(calc.q(), 1_000_001);
   }

   function testBuyCurveWithExtremelyHighParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyHighParameters();

        uint256 priceA;
        uint256 priceB;
        // we test buying 1 NFT when q is 1_000
        calc.set_q(1_000);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 1.001 x 10^27
        assertEq(priceA, priceB);
        assertEq(priceA, 1001 * 10 ** 24 * 10 ** 18);
        assertEq(calc.q(), 1_001);
        // we test buying 1 NFT when q is a septillion
        calc.set_q(1_000_000_000_000_000_000_000_000);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 1.000000000000000000000001 x 10^48
        assertEq(priceA, priceB);
        assertEq(priceA, 1000000000000000000000001 * 10 ** 24 * 10 ** 18);
        assertEq(calc.q(), 1_000_000_000_000_000_000_000_001);
       
   }

   function testBuyCurveWithExtremelyLowParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyLowParameters();

        uint256 priceA;
        uint256 priceB;
        // we test buying 1 NFT when q is 0
        calc.set_q(0);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 1 * 10^-16
        assertEq(priceA, priceB);
        assertEq(priceA, 100);
        assertEq(calc.q(), 1);
        // we test buying 1 NFT when q is 1
        calc.set_q(1);
        priceB = calc.simulateSwap(0, 0, 0, 1);
        priceA = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 2.00000001 x 10^-8
        assertEq(priceA, priceB);
        assertEq(priceA, 20000000100);
        assertEq(calc.q(), 2);
   }


   function testSellCurveSimple() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();

        uint256 priceA;
        uint256 priceB;
        // we test selling 1 NFT when q is 10
        calc.set_q(10);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 11.42 * 10^19 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 1142 * 10 ** 16);
        assertEq(calc.q(), 10 - 1);
        // we test selling 1 NFT when q is 1_000
        calc.set_q(1_000);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 1.8962 * 10^20 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 18962 * 10 ** 16);
        assertEq(calc.q(), 1_000 - 1);
        // we test selling 1 NFT when q is a mill
        calc.set_q(1_000_000);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 18000962 * 10^23 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 18000962 * 10 ** 16);
        assertEq(calc.q(), 1_000_000 - 1);
   }

   function testSellCurveWithExtremelyHighParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyHighParameters();

        uint256 priceA;
        uint256 priceB;
        // we test selling 1 NFT when q is 1_000
        calc.set_q(1_000);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 9.999 x 10^25 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 99 * 10 ** 25 * 10 ** 18);       
        assertEq(calc.q(), 1_000 - 1);
        // we test selling 1 NFT when q is a septillion
        calc.set_q(1_000_000_000_000_000_000_000_000);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 1.000000000000000000000001 x 10^48 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 99 * 10 ** 46 * 10 ** 18);
        assertEq(calc.q(), 1_000_000_000_000_000_000_000_000 - 1);
   }

   function testSellCurveWithExtremelyLowParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyLowParameters();

        uint256 priceA;
        uint256 priceB;
        // we test selling 1 NFT when q is 0
        calc.set_q(1);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 9.9 * 10^-17 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 99);
        assertEq(calc.q(), 1 - 1);
        // we test selling 1 NFT when q is 1
        calc.set_q(2);
        priceB = calc.simulateSwap(0, 0, 1, 0);
        priceA = calc.calculateSwap(0, 0, 1, 0);
        // according to desmos, the price should be 1.0000000099 * 10−8 (let's remember sell is calculated with q-1)
        assertEq(priceA, priceB);
        assertEq(priceA, 10000000099);
        assertEq(calc.q(), 2 - 1);
   }
}

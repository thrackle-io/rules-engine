// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/liquidity/ProtocolAMM.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LineInput} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";
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
        LineInput memory buy = LineInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.18; b = 9.8
        LineInput memory sell = LineInput(18 * 10 ** 6, 98 * 10 ** 17);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testCreateNFTAMMCalculatorWithExtremelyHighParameters() public returns(ProtocolNFTAMMCalcDualLinear calc) {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 1_000_000_000_000_000_000_000_000; b = 1_000_000_000_000_000_000_000_000
        LineInput memory buy = LineInput(1_000_000_000_000_000_000_000_000 * 10 ** 8, 1_000_000_000_000_000_000_000_000 * 10 ** 18);
        /// sell slope = 990 sextillion; b = 990 sextillion
        LineInput memory sell = LineInput(990_000_000_000_000_000_000_000 * 10 ** 8, 990_000_000_000_000_000_000_000 * 10 ** 18);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testCreateNFTAMMCalculatorWithExtremelyLowParameters() public returns(ProtocolNFTAMMCalcDualLinear calc) {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.00000002; b = 0.0000000000000001
        LineInput memory buy = LineInput(2, 100);
        /// sell slope = 0.00000001; b = 0.000000000000000099
        LineInput memory sell = LineInput(1, 99);
        calc = ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }

    function testNegCreateNFTAMMCalculatorIntersectingCurvesAtLow_q() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 10
        LineInput memory buy = LineInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.18; b = 11
        LineInput memory sell = LineInput(18 * 10 ** 6, 11 * 10 ** 18);
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorIntersectingCurvesAtHigh_q() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 10
        LineInput memory buy = LineInput(2 * 10 ** 7, 10 * 10 ** 18);
        /// sell slope = 0.22; b = 9.8
        LineInput memory sell = LineInput(22 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("CurvesInvertedOrIntersecting()"));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorYAboveLimit() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 0.2; b = 1_000_000_000_001
        LineInput memory buy = LineInput(2 * 10 ** 7, 1_000_000_000_000_000_000_000_001 * 10 ** 18);
        /// sell slope = 0.18; b = 9.8
        LineInput memory sell = LineInput(18 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)", 1_000_000_000_000_000_000_000_001 * 10 ** 18));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

    function testNegCreateNFTAMMCalculatorMAboveLimit() public {
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        /// buy slope = 1_000_000_000_001 ; b = 10
        LineInput memory buy = LineInput(1_000_000_000_000_000_000_000_001 * 10 ** 8, 10 * 10 ** 18 );
        /// sell slope = 0.18; b = 9.8
        LineInput memory sell = LineInput(18 * 10 ** 6, 98 * 10 ** 17);
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)", 1_000_000_000_000_000_000_000_001 * 10 ** 8));
        ProtocolNFTAMMCalcDualLinear(protocolAMMCalculatorFactory.createDualLinearNFT(buy, sell, address(applicationAppManager)));
    }

   function testBuyCurve() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();

        uint256 price;
        // we test buying 1 NFT when q is 10
        price = calc.calculateSwap(0, 10, 0, 1);
        // according to desmos, the price should be 12
        assertEq(price, 12 * 10 ** 18);
        // we test buying 1 NFT when q is 1_000
        price = calc.calculateSwap(0, 1_000, 0, 1);
        // according to desmos, the price should be 210
        assertEq(price, 210 * 10 ** 18);
        // we test buying 1 NFT when q is a mill
        price = calc.calculateSwap(0, 1_000_000, 0, 1);
        // according to desmos, the price should be 200010
        assertEq(price, 200010 * 10 ** 18);
   }

   function testBuyCurveWithExtremelyHighParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyHighParameters();

        uint256 price;
        // we test buying 1 NFT when q is 1_000
        price = calc.calculateSwap(0, 1_000, 0, 1);
        // according to desmos, the price should be 1.001 x 10^27
        assertEq(price, 1001 * 10 ** 24 * 10 ** 18);
        // we test buying 1 NFT when q is a septillion
        price = calc.calculateSwap(0, 1_000_000_000_000_000_000_000_000, 0, 1);
        // according to desmos, the price should be 1.000000000000000000000001 x 10^48
        assertEq(price, 1000000000000000000000001 * 10 ** 24 * 10 ** 18);
       
   }

   function testBuyCurveWithExtremelyLowParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyLowParameters();

        uint256 price;
        // we test buying 1 NFT when q is 0
        price = calc.calculateSwap(0, 0, 0, 1);
        // according to desmos, the price should be 1 * 10^-16
        assertEq(price, 100);
        // we test buying 1 NFT when q is 1
        price = calc.calculateSwap(0, 1, 0, 1);
        // according to desmos, the price should be 2.00000001 x 10^-8
        assertEq(price, 20000000100);
   }


   function testSellCurveSimple() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculator();

        uint256 price;
        // we test selling 1 NFT when q is 10
        price = calc.calculateSwap(0, 10, 1, 0);
        // according to desmos, the price should be 11.42 * 10^19 (let's remember sell is calculated with q-1)
        assertEq(price, 1142 * 10 ** 16);
        // we test selling 1 NFT when q is 1_000
        price = calc.calculateSwap(0, 1_000, 1, 0);
        // according to desmos, the price should be 1.8962 * 10^20 (let's remember sell is calculated with q-1)
        assertEq(price, 18962 * 10 ** 16);
        // we test selling 1 NFT when q is a mill
        price = calc.calculateSwap(0, 1_000_000, 1, 0);
        // according to desmos, the price should be 18000962 * 10^23 (let's remember sell is calculated with q-1)
        assertEq(price, 18000962 * 10 ** 16);
   }

   function testSellCurveWithExtremelyHighParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyHighParameters();

        uint256 price;
        // we test selling 1 NFT when q is 1_000
        price = calc.calculateSwap(0, 1_000, 1, 0);
        // according to desmos, the price should be 9.999 x 10^25 (let's remember sell is calculated with q-1)
        assertEq(price, 99 * 10 ** 25 * 10 ** 18);
        // we test selling 1 NFT when q is a septillion
        price = calc.calculateSwap(0, 1_000_000_000_000_000_000_000_000, 1, 0);
        // according to desmos, the price should be 1.000000000000000000000001 x 10^48 (let's remember sell is calculated with q-1)
        assertEq(price, 99 * 10 ** 46 * 10 ** 18);
       
   }

   function testSellCurveWithExtremelyLowParameter() public {
        ProtocolNFTAMMCalcDualLinear calc = testCreateNFTAMMCalculatorWithExtremelyLowParameters();

        uint256 price;
        // we test selling 1 NFT when q is 0
        price = calc.calculateSwap(0, 1, 1, 0);
        // according to desmos, the price should be 9.9 * 10^-17 (let's remember sell is calculated with q-1)
        assertEq(price, 99);
        // we test selling 1 NFT when q is 1
        price = calc.calculateSwap(0, 2, 1, 0);
        // according to desmos, the price should be 1.0000000099 * 10−8 (let's remember sell is calculated with q-1)
        assertEq(price, 10000000099);
   }
}

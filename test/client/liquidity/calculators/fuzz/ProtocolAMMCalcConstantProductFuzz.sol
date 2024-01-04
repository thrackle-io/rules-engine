// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "test/util/TestCommonFoundry.sol";
import {ConstantProduct} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "test/util/Utils.sol";

/**
 * @title Test Constant Product AMM Calculator 
 * @notice This tests the calculations that occur within the CP AMM Calculator
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcConstantProductFuzzTest is TestCommonFoundry, Utils {
    event Log(bytes data);
    event AMM___Return(uint);
    event PythonReturn(uint);
    using Strings for uint32;
    using Strings for uint256;
    ProtocolAMMCalculatorFactory ammCalcfactory;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;
    ConstantProduct curve;
    address calcAddress;
    ProtocolAMMCalcCP calc;
    uint256 returnVal;
    uint resUint;
    uint256 constant MAX_TRADE_AMOUNT = 1_000_000 * ATTO;
    uint256 constant RESERVE = 1_000_000_000 * ATTO;


    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        ammCalcfactory = createProtocolAMMCalculatorFactory();
    }
    /**
     * Test the the creation of Constant Product get Y calculation module. All of the results are matched up to a python calculation
     */
    function testFactoryCPFuzzGetY(uint256 _x_in) public { 
        
        uint256 amount0 = bound(uint256(_x_in), 1, MAX_TRADE_AMOUNT);
        uint256 reserve0 = RESERVE;
        uint256 reserve1 = RESERVE;
        uint256 amount1 = 0;
        setCurve(reserve0,reserve1);  
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFICalculator_getY(curve, amount0);
        res = vm.ffi(inputs); 
        emit Log(res);
        // ƒoundry gets weird with the return values so we have to jump through hoops.
        if (isPossiblyAnAscii(res)){
            /// we decode the ascii into a uint
            resUint = decodeAsciiUint(res);
        } else {
            resUint= decodeFakeDecimalBytes(res);
        }
        /// some debug logging 
        logSwap();
        // If the comparison fails, it may be due to a false positive from isPossiblyAnAscii. Try to convert it as a fake decimal to be certain
        if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN)){
            resUint= decodeFakeDecimalBytes(res);
            emit PythonReturn(resUint);
        }
        assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN));

    }

    /**
     * Test the the creation of Constant Product get X calculation module. All of the results are matched up to a python calculation
     */
    function testFactoryCPFuzzGetX(uint256 _y_in) public { 
        
        uint256 amount1 = bound(uint256(_y_in), 1, MAX_TRADE_AMOUNT);
        uint256 reserve0 = RESERVE;
        uint256 reserve1 = RESERVE;
        setCurve(reserve0,reserve1);
        uint256 amount0 = 0;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFICalculator_getX(curve, amount1);
        res = vm.ffi(inputs); 
        emit Log(res);
        // ƒoundry gets weird with the return values so we have to jump through hoops.
        if (isPossiblyAnAscii(res)){
            /// we decode the ascii into a uint
            resUint = decodeAsciiUint(res);
        } else {
            resUint= decodeFakeDecimalBytes(res);
        }
        /// some debug logging 
        logSwap();
        // If the comparison fails, it may be due to a false positive from isPossiblyAnAscii. Try to convert it as a fake decimal to be certain
        if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN)){
            resUint= decodeFakeDecimalBytes(res);
            emit PythonReturn(resUint);
        }
        assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN));
    }

   /**
    * @dev creates the input array specifically for the calculator_constant_product_getY.py script.
    * @param curveInput curve data
    * @param x_in amount of token1 being swapped
    */
    function _buildFFICalculator_getY(ConstantProduct memory curveInput, uint256 x_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](5);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_constant_product_getY.py"; 
        inputs[2] = curveInput.x.toString();
        inputs[3] = curveInput.y.toString();
        inputs[4] = x_in.toString();
        return inputs;
    }

    /**
    * @dev creates the input array specifically for the calculator_constant_product_getX.py script.
    * @param curveInput curve data
    * @param y_in amount of token1 being swapped
    */
    function _buildFFICalculator_getX(ConstantProduct memory curveInput, uint256 y_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](5);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_constant_product_getX.py"; 
        inputs[2] = curveInput.x.toString();
        inputs[3] = curveInput.y.toString();
        inputs[4] = y_in.toString();
        return inputs;
    }

    /**
     * Create the calculator objects and set the curve
     */
    function setCurve(uint256 x, uint256 y) internal {
        curve = ConstantProduct(x, y);
        calcAddress = ammCalcfactory.createConstantProduct(address(applicationAppManager));
        calc = ProtocolAMMCalcCP(calcAddress);
    }


    /**
     * Log the pertinent swap results from python and the amm
     */
    function logSwap() internal{
        emit AMM___Return(returnVal);
        emit PythonReturn(resUint);
    }
}

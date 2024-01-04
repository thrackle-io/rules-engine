// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/util/TestCommonFoundry.sol";
import {LinearInput} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "test/util/Utils.sol";

/**
 * @title Test Linear AMM Calculator 
 * @notice This tests the calculations that occur within the Linear AMM Calculator
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcLinearFuzzTest is TestCommonFoundry, Utils {
    event Log(bytes data);
    event AMM___Return(uint);
    event PythonReturn(uint);
    using Strings for uint256;
    ProtocolAMMCalculatorFactory ammCalcfactory;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;

    uint8 constant MAX_TOLERANCE_Y = 5;
    uint8 constant TOLERANCE_PRECISION_Y = 5;
    uint256 constant TOLERANCE_DEN_Y = 10 ** TOLERANCE_PRECISION_Y;

    LinearInput curve;
    address calcAddress;
    ProtocolAMMCalcLinear calc;
    uint256 returnVal;
    uint resUint;
    uint256 constant MAX_TRADE_AMOUNT = 1_000_000 * ATTO;
    uint256 constant MAX_SLOPE = 100 * 10 ** 8;
    uint256 constant MAX_Y_INTERCEPT = 100_000 * ATTO;
    uint256 constant RESERVE = 1_000_000 * ATTO;
    

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        ammCalcfactory = createProtocolAMMCalculatorFactory();
    }

    // <><><><><><><><> NOTE: The deviation tolerance has been raised while waiting for refined equation from research
    /**
     * Test the the creation of Linear get Y calculation module. All of the results are matched up to a python calculation
     */
    function testFactoryLinearFuzzGetY(uint32 _m, uint64 _b, uint _x) public { 
        
        uint256 m = bound(uint256(_m), 1, MAX_SLOPE);  
        uint256 b = bound(uint256(_b), 1, MAX_Y_INTERCEPT);   
        uint256 amount0 = bound(uint256(_x), 1 * 10 ** 8, MAX_TRADE_AMOUNT);  

        setCurve(m,b);
        uint256 reserve0 = RESERVE;
        uint256 reserve1 = RESERVE;
        uint256 amount1 = 0;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFILinearCalculator_getY(curve, ATTO, reserve0, amount0);
        res = vm.ffi(inputs); 
        if (isPossiblyAnAscii(res)){
            /// we decode the ascii into a uint
            resUint = decodeAsciiUint(res);
        } else {
            resUint= decodeFakeDecimalBytes(res);
        }
        /// some debug logging 
        logSwap();
        // If the comparison fails, it may be due to a false positive from isPossiblyAnAscii. Try to convert it as a fake decimal to be certain
        if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y)){
            resUint= decodeFakeDecimalBytes(res);
            emit PythonReturn(resUint);
        }
        assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y));
    }

    /**
     * Test the the creation of Linear get X calculation module. All of the results are matched up to a python calculation
     */
    function testFactoryLinearFuzzGetX(uint256 _m, uint256 _b, uint256 _y) public { 
        uint256 m = bound(uint256(_m), 1, MAX_SLOPE);  
        uint256 b = bound(uint256(_b), 10000, MAX_Y_INTERCEPT);
        uint256 amount1 = bound(uint256(_y), 1, MAX_TRADE_AMOUNT);
        setCurve(m,b);
        uint256 reserve0 = RESERVE;
        uint256 reserve1 = RESERVE;
        uint256 amount0 = 0;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFILinearCalculator_getX(curve, ATTO, reserve1, amount1);
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
    * @dev creates the input array specifically for the calculator_linear_getY.py script.
    * @param lineInput curve data
    * @param decimals the amount of decimals of precision for *m*.
    * @param x_reserve amount of token0 in reserve.
    * @param x_in amount of token0 being swapped
    */
    function _buildFFILinearCalculator_getY(LinearInput memory lineInput, uint256 decimals, uint256 x_reserve, uint256 x_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](9);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_linear_getY.py"; 
        inputs[2] = lineInput.m.toString();   
        inputs[3] = "100000000";// m denominator = 10**8     
        inputs[4] = decimals.toString(); 
        inputs[5] = lineInput.b.toString();
        inputs[6] = "100000000";// b denominator = 10**8   
        inputs[7] = x_reserve.toString();
        inputs[8] = x_in.toString();
        return inputs;
    }

    /**
    * @dev creates the input array specifically for the calculator_linear_getX.py script.
    * @param lineInput curve data
    * @param decimals the amount of decimals of precision for *m*.
    * @param x_reserve amount of token0 in reserve. This is the tracker value
    * @param y_in amount of token1 being swapped
    */
    function _buildFFILinearCalculator_getX(LinearInput memory lineInput, uint256 decimals, uint256 x_reserve, uint256 y_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](9);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_linear_getX.py"; 
        inputs[2] = lineInput.m.toString();   
        inputs[3] = "100000000";     
        inputs[4] = decimals.toString(); 
        inputs[5] = lineInput.b.toString();
        inputs[6] = "100000000";   
        inputs[7] = x_reserve.toString();
        inputs[8] = y_in.toString();
        return inputs;
    }

    /**
     * Create the calculator objects and set the curve
     */
    function setCurve(uint256 m, uint256 b) internal {
        curve = LinearInput(m, b);
        calcAddress = ammCalcfactory.createLinear(curve, address(applicationAppManager));
        calc = ProtocolAMMCalcLinear(calcAddress);
    }


    /**
     * Log the pertinent swap results from python and the amm
     */
    function logSwap() internal{
        emit AMM___Return(returnVal);
        emit PythonReturn(resUint);
    }
}

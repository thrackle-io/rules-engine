// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/liquidity/calculators/ProtocolAMMCalcSample01.sol";
import "test/util/TestCommonFoundry.sol";
import {Sample01Struct} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";
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
    using Strings for int256;
    ProtocolAMMCalculatorFactory ammCalcfactory;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;
    // NOTE: A high tolerance is being used for getY. This equation needs to be refined because solidity is getting rounding errors
    uint8 constant MAX_TOLERANCE_Y = 1;
    uint8 constant TOLERANCE_PRECISION_Y = 1;
    uint256 constant TOLERANCE_DEN_Y = 10 ** TOLERANCE_PRECISION_Y;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        ammCalcfactory = createProtocolAMMCalculatorFactory();
    }
    /**
     * Test the the creation of Sample01 get Y calculation module. All of the results are matched up to a python calculation
     */
    function testFactorySample01GetY(uint256 _x_in) public { 
        
        uint256 amount0 = bound(uint256(_x_in), 1, 1 * 10 ** 18);
        uint256 reserve0 = 4;
        uint256 reserve1 = 4;
        Sample01Struct memory curve = Sample01Struct(amount0, int256(reserve1));
        address calcAddress = ammCalcfactory.createSample01(int256(reserve0), int256(reserve1), address(applicationAppManager));
        ProtocolAMMCalcSample01 calc = ProtocolAMMCalcSample01(calcAddress);
        uint256 amount1 = 0;
        uint256 returnVal;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFICalculator_getY(curve);
        res = vm.ffi(inputs); 
        emit Log(res);
        uint resUint;
        // ƒoundry gets weird with the return values so we have to jump through hoops.
        if (isPossiblyAnAscii(res)){
            /// we decode the ascii into a uint
            resUint = decodeAsciiUint(res);
        } else {
            resUint= decodeFakeDecimalBytes(res);
        }
        /// some debug logging 
        emit AMM___Return(returnVal);
        emit PythonReturn(resUint);
        // If the comparison fails, it may be due to a false positive from isPossiblyAnAscii. Try to convert it as a fake decimal to be certain
        if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y)){
            resUint= decodeFakeDecimalBytes(res);
            emit PythonReturn(resUint);
        }
        assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y));

    }
    // NOTE:  The getX part of this AMM calculation is not even close. It needs fully reworked.
    /**
     * Test the the creation of Sample01 get X calculation module. All of the results are matched up to a python calculation
     */
    // function testFactorySample01GetX(uint256 _y_in) public { 
        
    //     uint256 amount1 = bound(uint256(_y_in), 1, 1_000_000 * 10 ** 18);
    //     uint256 reserve0 = 4;
    //     uint256 reserve1 = 4;
    //     Sample01Struct memory curve = Sample01Struct(amount1, int256(reserve1));
    //     address calcAddress = ammCalcfactory.createSample01(int256(reserve0), int256(reserve1), address(applicationAppManager));
    //     ProtocolAMMCalcSample01 calc = ProtocolAMMCalcSample01(calcAddress);
    //     uint256 amount0 = 0;
    //     uint256 returnVal;
    //     returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
    //     /// the response from the Python script that will contain the price calculated "offchain"
    //     bytes memory res;
    //     /// we then call the Python script to calculate the price "offchain" and store it in *res*
    //     string[] memory inputs = _buildFFICalculator_getX(curve);
    //     res = vm.ffi(inputs); 
    //     emit Log(res);
    //     uint resUint;
    //     // ƒoundry gets weird with the return values so we have to jump through hoops.
    //     if (isPossiblyAnAscii(res)){
    //         /// we decode the ascii into a uint
    //         resUint = decodeAsciiUint(res);
    //     } else {
    //         resUint= decodeFakeDecimalBytes(res);
    //     }
    //     /// some debug logging 
    //     emit AMM___Return(returnVal);
    //     emit PythonReturn(resUint);
    //     // If the comparison fails, it may be due to a false positive from isPossiblyAnAscii. Try to convert it as a fake decimal to be certain
    //     if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y)){
    //         resUint= decodeFakeDecimalBytes(res);
    //         emit PythonReturn(resUint);
    //     }
    //     assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE_Y, TOLERANCE_DEN_Y));
    // }

   /**
    * @dev creates the input array specifically for the calculator_sample01_getY.py script.
    * @param curveInput curve data
    */
    function _buildFFICalculator_getY(Sample01Struct memory curveInput) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](4);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_sample01_getY.py"; 
        inputs[2] = curveInput.tracker.toString();
        inputs[3] = curveInput.amountIn.toString();
        return inputs;
    }

    /**
    * @dev creates the input array specifically for the calculator_sample01_getX.py script.
    * @param curveInput curve data
    */
    function _buildFFICalculator_getX(Sample01Struct memory curveInput) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](4);
        inputs[0] = "python3";
        inputs[1] = "script/python/calculator_sample01_getX.py"; 
        inputs[2] = curveInput.tracker.toString();
        inputs[3] = curveInput.amountIn.toString();
        return inputs;
    }

}

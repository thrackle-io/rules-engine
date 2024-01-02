// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/client/liquidity/ProtocolERC20AMM.sol";
import "src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/client/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/util/TestCommonFoundry.sol";
import {ConstantRatio, LinearInput} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";
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
    event AMM___ReturnString(string);
    using Strings for uint256;
    ProtocolAMMCalculatorFactory factory;
    uint8 constant MAX_TOLERANCE = 5;
    uint8 constant TOLERANCE_PRECISION = 11;
    uint256 constant TOLERANCE_DEN = 10 ** TOLERANCE_PRECISION;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        switchToAppAdministrator();
        factory = new ProtocolAMMCalculatorFactory();
    }
   
    /**
     * Test the the creation of Linear get Y calculation module. All of the results are matched up to a python calculation
     */
    function testFactoryLinearGetY(uint32 _m, uint64 _b, uint _x) public { 
        uint256 m = bound(uint256(_m), 1, 100 * 10 ** 8);  
        uint256 b = bound(uint256(_b), 1, 100_000 * 10 ** 18);   
        uint256 amount0 = bound(uint256(_x), 1 * 10 ** 8, 1_000_000 * 10 ** 18);  

        LinearInput memory curve = LinearInput(m, b);
        address calcAddress = factory.createLinear(curve, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * 10 ** 18;
        uint256 reserve1 = 1_000_000 * 10 ** 18;
        uint256 amount1 = 0;
        uint256 returnVal;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        string[] memory inputs = _buildFFILinearCalculator_getY(curve, ATTO, reserve0, amount0);
        res = vm.ffi(inputs); 
        uint resUint;
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
        if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN)){
            resUint= decodeFakeDecimalBytes(res);
            emit PythonReturn(resUint);
        }
        assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN));
    }
    
    // <><><><><><><><> NOTE: This is commented out while waiting for refined equation from research
    /**
     * Test the the creation of Linear get X calculation module. All of the results are matched up to a python calculation
     */
    // function testFactoryLinearGetX(uint256 _m, uint256 _b, uint256 _y) public { 
    //     uint256 m = bound(uint256(_m), 1, 100 * 10 ** 8);  
    //     uint256 b = bound(uint256(_b), 10000, 100_000 * 10 ** 8);
    //     uint256 amount1 = bound(uint256(_y), 1, 1_000_000 * 10 ** 18);
    //     LinearInput memory curve = LinearInput(m, b);
    //     address calcAddress = factory.createLinear(curve, address(applicationAppManager));
    //     ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
    //     uint256 reserve0 = 1_000_000 * 10 ** 18;
    //     uint256 reserve1 = 1_000_000 * 10 ** 18;
    //     uint256 amount0 = 0;
    //     uint256 returnVal;
    //     returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
    //     /// the response from the Python script that will contain the price calculated "offchain"
    //     bytes memory res;
    //     /// we then call the Python script to calculate the price "offchain" and store it in *res*
    //     string[] memory inputs = _buildFFILinearCalculator_getX(curve, ATTO, reserve1, amount1);
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
    //     if (!areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN)){
    //         resUint= decodeFakeDecimalBytes(res);
    //         emit PythonReturn(resUint);
    //     }
    //     assertTrue(areWithinTolerance(returnVal, resUint, MAX_TOLERANCE, TOLERANCE_DEN));
    // }

   /**
    * @dev creates the input array specifically for the linear_calculator_y.py script.
    * @param lineInput curve data
    * @param decimals the amount of decimals of precision for *m*.
    * @param x_reserve amount of token0 in reserve.
    * @param x_in amount of token0 being swapped
    */
    function _buildFFILinearCalculator_getY(LinearInput memory lineInput, uint256 decimals, uint256 x_reserve, uint256 x_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](9);
        inputs[0] = "python3";
        inputs[1] = "script/python/linear_calculator_getY.py"; 
        inputs[2] = lineInput.m.toString();   
        inputs[3] = "100000000";     
        inputs[4] = decimals.toString(); 
        inputs[5] = lineInput.b.toString();
        inputs[6] = "100000000";   
        inputs[7] = x_reserve.toString();
        inputs[8] = x_in.toString();
        return inputs;
    }

    /**
    * @dev creates the input array specifically for the linear_calculator_y.py script.
    * @param lineInput curve data
    * @param decimals the amount of decimals of precision for *m*.
    * @param y_reserve amount of token1 in reserve.
    * @param y_in amount of token1 being swapped
    */
    function _buildFFILinearCalculator_getX(LinearInput memory lineInput, uint256 decimals, uint256 y_reserve, uint256 y_in) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](9);
        inputs[0] = "python3";
        inputs[1] = "script/python/linear_calculator_getX.py"; 
        inputs[2] = lineInput.m.toString();   
        inputs[3] = "100000000";     
        inputs[4] = decimals.toString(); 
        inputs[5] = lineInput.b.toString();
        // inputs[6] = "1000000000000000000";   
        inputs[6] = "100000000";   
        inputs[7] = y_reserve.toString();
        inputs[8] = y_in.toString();
        return inputs;
    }

}

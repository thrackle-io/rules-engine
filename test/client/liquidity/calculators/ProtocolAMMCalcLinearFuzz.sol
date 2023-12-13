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
    event Price(uint);
    using Strings for uint256;
    ProtocolAMMCalculatorFactory factory;
    uint256 constant M_PRECISION_DECIMALS = 8;
    uint256 constant Y_MAX = 1_000_000_000_000_000_000_000_000 * ATTO;
    uint256 constant M_MAX = 1_000_000_000_000_000_000_000_000 * 10 ** M_PRECISION_DECIMALS;
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
     * Test the the creation of Linear X calculation module. All of the results are matched up to a desmos file
     */
    function testFactoryLinearGetY() public {
        // create a linear calculator (y=mx+b))
        // m = .00006(this is set as 8 digits)
        // b = 1.5
        LinearInput memory curve = LinearInput(6000, 15 * 10 ** 17);
        address calcAddress = factory.createLinear(curve, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * 10 ** 18;
        uint256 reserve1 = 1_000_000 * 10 ** 18;
        uint256 amount0 = 2 * 10 ** 18;
        uint256 amount1 = 0;
        uint256 returnVal;
        // swap 2*10**18 token0 for 123000120000000000000 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 123000120000000000000);
        /// the response from the Python script that will contain the price calculated "offchain"
        bytes memory res;
        /// we then call the Python script to calculate the price "offchain" and store it in *res*
        uint88 q = 1_000_000 * 10 ** 18;
        string[] memory inputs = _buildFFILinearCalculator_getY(curve, M_PRECISION_DECIMALS, q);
        res = vm.ffi(inputs); 

        /// some debug logging 
        emit Price(returnVal);
        emit Price(decodeFakeDecimalBytes(res));
    }

    /**
     * Test the the creation of Linear Y calculation module. All of the results are matched up to a desmos file
     */
    function testFactoryLinearGetX() public {
        // create a linear calculator (y=mx+b))
        // m = .00006(this is set as 8 digits) = 6000
        // b = 1.5
        LinearInput memory curve = LinearInput(6000, 15 * 10 ** 17);
        address calcAddress = factory.createLinear(curve, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * 10 ** 18;
        uint256 reserve1 = 1_000_000 * 10 ** 18;
        uint256 amount0 = 0;
        uint256 amount1 = 2 * 10 ** 18;
        uint256 returnVal;
        // swap 2 token1 for 180886341437069888 token0)
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 180886341437069888);
        // swap 50 token1 for 4522211804403591519 token0)
        amount1 = 50 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 4522211804403591519);
        // swap 100 token1 for 9 token0)
        amount1 = 100;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 9);
        // swap 10 token1 for 0 token0)
        amount1 = 10;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 0);

        // work with another slope
        // m = .00005(this is set as 8 digits)
        curve = LinearInput(5000, 15 * 10 ** 17);
        calc.setCurve(curve);
        // swap 1 *10**18 token1 for 98893659466214506 token0
        amount1 = 1 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 98893659466214506);

        // work with another y-intercept
        // m = .00005(this is set as 8 digits)
        curve = LinearInput(5000, 2 * 10 ** 18);
        calc.setCurve(curve);
        // swap 1 *10**18 token1 for 98058091140754206 token0
        amount1 = 1 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 98058091140754206);
        // swap 1_000_000 *10**18 token1 for 163960780543711393201128 token0
        amount1 = 1_000_000 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 163960780543711393201128);
    }

   /**
    * @dev creates the input array specifically for the linear_calculator_y.py script.
    * @param lineInput the lineIput struct that defines the curve function ƒ.
    * @param decimals the amount of decimals of precision for *m*.
    * @param q in this case, the value of x to solve ƒ(x).
    */
    function _buildFFILinearCalculator_getY(LinearInput memory lineInput, uint256 decimals, uint88 q) internal pure returns(string[] memory) {
        string[] memory inputs = new string[](7);
        inputs[0] = "python3";
        inputs[1] = "script/python/linear_calculator_y.py"; 
        inputs[2] = lineInput.m.toString();
        inputs[3] = decimals.toString(); 
        inputs[4] = lineInput.b.toString();
        inputs[5] = uint256(q).toString();
        inputs[6] = "1"; /// y formatted in atto
        return inputs;
    }

}

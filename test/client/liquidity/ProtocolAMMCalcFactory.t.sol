// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/client/liquidity/ProtocolERC20AMM.sol";
import "src/client/liquidity/ProtocolAMMCalculatorFactory.sol";
import "src/client/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/client/liquidity/calculators/ProtocolAMMCalcConst.sol";
import {ProtocolAMMCalcLinear} from "src/client/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/util/TestCommonFoundry.sol";
import "test/util/Utils.sol";
import {ConstantRatio, LinearInput} from "src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol";

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcFactoryTest is TestCommonFoundry, Utils {
    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 8;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        factory = new ProtocolAMMCalculatorFactory();
        switchToAppAdministrator();
    }

    /**
     * Test the the creation of Constant calculation module
     */
    function testFactoryConstant() public {
        // create a constant calculator with 2 to 1 ration token0 to token1

        ConstantRatio memory cr = ConstantRatio(2, 1);
        address calcAddress = factory.createConstant(cr, address(applicationAppManager));
        ProtocolAMMCalcConst calc = ProtocolAMMCalcConst(calcAddress);
        uint256 reserve0 = 0;
        uint256 reserve1 = 0;
        uint256 amount0 = 0;
        uint256 amount1 = 4;
        uint256 returnVal;
        // swap 4 token0 for 8 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 8);
        // swap 8 token1 for 4 token0
        amount0 = 8;
        amount1 = 0;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 4);

        // make sure non appAdmin cannot change the ratio
        cr.x = type(uint32).max;
        cr.y = 1;
        switchToUser();
        vm.expectRevert(0xba80c9e5);
        calc.setRatio(cr);

        // // make sure the ratio can't be too large
         switchToAppAdministrator();

        // make sure it changes the ratio and works
        cr.x = 1;
        cr.y = 4;
        calc.setRatio(cr);
        amount0 = 1;
        amount1 = 0;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 4);
    }

    /**
     * Test the the creation of Constant Product calculation module
     */
    function testFactoryConstantProduct() public {
        // create a constant calculator with 2 to 1 ration token0 to token1
        address calcAddress = factory.createConstantProduct(address(applicationAppManager));
        IProtocolAMMFactoryCalculator calc = IProtocolAMMFactoryCalculator(calcAddress);
        uint256 reserve0 = 1000000000;
        uint256 reserve1 = 1000000000;
        uint256 amount0 = 50000;
        uint256 amount1 = 0;
        uint256 returnVal;
        // swap 50000 token0 for 49997 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 49997);
        amount0 = 0;
        amount1 = 50000;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 49997);
    }

    /**
     * Test the the creation of Linear X calculation module. All of the results are matched up to a desmos file
     */
     function testFactoryLinearX() public {
        // create a linear calculator (y=mx+b))
        // m = .00006(this is set as 8 digits)
        // b = 1.5
        LinearInput memory curve = LinearInput(6 * 10 ** (M_PRECISION_DECIMALS - 5), 15 * 10 ** (B_PRECISION_DECIMALS - 1));
        address calcAddress = factory.createLinear(curve, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * 10 ** 18;
        uint256 reserve1 = 1_000_000 * 10 ** 18;
        uint256 amount0 = 1 * 10 ** 18;
        uint256 amount1 = 0;
        uint256 returnVal;
        // swap 1*10**18 token0 for 61499970000000000000 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 61499970000000000000);

        amount0 = 4 * 10 ** 18;
        // swap 4*10**18 token0 for 245999520010000000000 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 245999520000000000000);

        amount0 = 50_000 * 10 ** 18;
        // swap 50,000 *10**18 token0 for 3000000000000000000000000 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 3000000000000000000000000);
       
        // work with another slope
        // m = .00005(this is set as 8 digits)
        curve = LinearInput(5 * 10 ** (M_PRECISION_DECIMALS - 5), 15 * 10 ** (B_PRECISION_DECIMALS - 1));
        calc.setCurve(curve);
        // swap 1 *10**10 token0 for 51499975000000000000 token1
        amount0 = 1 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 51499975000000000000);

        // work with another slope
        // m = .00001(this is set as 8 digits)
        curve = LinearInput(1 * 10 ** (M_PRECISION_DECIMALS - 5), 15 * 10 ** (B_PRECISION_DECIMALS - 1));
        calc.setCurve(curve);
        // swap 1 *10**10 token0 for 11499995000000000000 token1
        amount0 = 1 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 11499995000000000000);
    }

    /**
     * Test the the creation of Linear Y calculation module. All of the results are matched up to a desmos file
     */
    function testFactoryLinearY2() public {
        // create a linear calculator (y=mx+b))
        // m = .00006(this is set as 8 digits) = 6000
        // b = 1.5
        LinearInput memory curve = LinearInput(6 * 10 ** (M_PRECISION_DECIMALS - 5), 15 * 10 ** (B_PRECISION_DECIMALS - 1));
        address calcAddress = factory.createLinear(curve, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * ATTO;
        uint256 reserve1 = 31_500_000 * ATTO;

        uint256 amount0 = 0;
        uint256 amount1 = 2 * ATTO;
        uint256 returnVal;
        // swap 2 token1 for 3.2520324687363492×10**16 token0)
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertLe(absoluteDiff(returnVal, 3_2520324687363492), 5);
        // swap 50 token1 for 8.13007807651205376×10**17 token0)
        amount1 = 50 * ATTO;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertLe(absoluteDiff(returnVal, 8_13007807651205376),167);
        // swap 100 token1 for 9 token0)
        amount1 = 100;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 1);
        // swap 10 token1 for 0 token0)
        amount1 = 10;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 0);
    }

    /**
     * Test the the validation of entry parametes for Linear calc
     */
    function testParameterValidationFactoryLinear() public {
        address calcAddress;
        // validate parameters at constructor level
        bytes4 selector = bytes4(keccak256("ValueOutOfRange(uint256)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 101 * 10 ** 8));
        LinearInput memory curve = LinearInput(101 * 10 ** 8, 15 * 10 ** 17);
        factory.createLinear(curve, address(applicationAppManager));
        vm.expectRevert(abi.encodeWithSelector(selector, 100_001 * 10 ** 18));
        curve = LinearInput(600, 100_001 * 10 ** 18);
        factory.createLinear(curve, address(applicationAppManager));
        curve = LinearInput(100 * 10 ** 8, 100_000 * 10 ** 18);
        calcAddress = factory.createLinear(curve, address(applicationAppManager));
        // validate parameters at setter level
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        curve = LinearInput(101 * 10 ** 8, 100_000 * 10 ** 18);
        vm.expectRevert(abi.encodeWithSelector(selector, 101 * 10 ** 8));
        calc.setCurve(curve);
        curve = LinearInput(100 * 10 ** 8, 101_000 * 10 ** 18);
        vm.expectRevert(abi.encodeWithSelector(selector, 101_000 * 10 ** 18));
        calc.setCurve(curve);
        // Make sure zeros are allowed for m and y
        curve = LinearInput(0, 0);
        calc.setCurve(curve);
    }
}

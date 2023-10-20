// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/example/liquidity/ApplicationAMM.sol";
import "src/liquidity/ProtocolAMMCalculatorFactory.sol";
import "src/liquidity/calculators/IProtocolAMMFactoryCalculator.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "test/helpers/TestCommon.sol";

/**
 * @title Test all AMM Calculator Factory related functions
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcFactoryTest is TestCommon {
    ProtocolAMMCalculatorFactory factory;

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManager();
        factory = new ProtocolAMMCalculatorFactory(address(applicationAppManager));
        switchToAppAdministrator();
    }

    /**
     * Test the the creation of Constant calculation module
     */
    function testFactoryFuzzConstantToken0(uint32 _x, uint32 _y, uint128 _amount) public {
        // create a constant calculator with random ratio token0 to token1
        uint256 x = bound(_x, 1, type(uint32).max);
        uint256 y = bound(_y, 1, type(uint32).max);
        address calcAddress = factory.createConstant(x, y, address(applicationAppManager));
        ProtocolAMMCalcConst calc = ProtocolAMMCalcConst(calcAddress);
        uint256 returnVal;
        // swap
        if (_amount == 0) vm.expectRevert(0x5b2790b5);
        returnVal = calc.calculateSwap(0, 0, _amount, 0); //reserves irrelevant in this calc
        assertEq(returnVal, ((_amount * ((y * (10 ** 20)) / x)) / (10 ** 20)));
    }

    /**
     * Test the the creation of Constant calculation module
     */
    function testFactoryFuzzConstantToken1(uint32 _x, uint32 _y, uint128 _amount) public {
        // create a constant calculator with random ratio token0 to token1
        uint256 x = bound(_x, 1, type(uint32).max); //must put them into 256 for calculation purposes
        uint256 y = bound(_y, 1, type(uint32).max);
        address calcAddress = factory.createConstant(x, y, address(applicationAppManager));
        ProtocolAMMCalcConst calc = ProtocolAMMCalcConst(calcAddress);
        uint256 returnVal;
        // swap
        if (_amount == 0) vm.expectRevert(0x5b2790b5);
        returnVal = calc.calculateSwap(0, 0, 0, _amount); //reserves irrelevant in this calc
        assertEq(returnVal, ((_amount * ((x * (10 ** 20)) / y)) / (10 ** 20)));
    }

    /**
     * Test the the creation of Constant calculation module
     */
    function testFactoryConstant() public {
        // create a constant calculator with 2 to 1 ration token0 to token1
        address calcAddress = factory.createConstant(2, 1, address(applicationAppManager));
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
        switchToUser();
        vm.expectRevert(0xba80c9e5);
        calc.setRatio(type(uint32).max, 1);

        // make sure the ratio can't be too large
        switchToAppAdministrator();
        vm.expectRevert(0x7db3aba7);
        calc.setRatio(uint256((type(uint32).max)) + 1, 1);

        // make sure it changes the ratio and works
        calc.setRatio(1, 4);
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
     * Test the the creation of Constant Product calculation module
     */
    function testFactoryFuzzConstantProductToken0(uint128 _reserve0, uint128 _reserve1, uint128 _amount) public {
        uint256 reserve0 = bound(_reserve0, 100, type(uint32).max);
        uint256 reserve1 = bound(_reserve1, 100, type(uint32).max);
        // make sure the amount to trade is less than the lowest reserve(this validation usually happens in AMM)
        uint256 minReserve = reserve0 < reserve1 ? uint256(reserve0) : uint256(reserve1);
        uint256 amount = bound(_amount, 1, minReserve - 10);
        // create a constant calculator with 2 to 1 ration token0 to token1
        address calcAddress = factory.createConstantProduct(address(applicationAppManager));
        IProtocolAMMFactoryCalculator calc = IProtocolAMMFactoryCalculator(calcAddress);
        uint256 returnVal;
        // swap
        if (amount == 0) vm.expectRevert(0x5b2790b5);
        returnVal = calc.calculateSwap(reserve0, reserve1, amount, 0);
        assertEq(returnVal, (amount * reserve1) / (reserve0 + amount));
    }

    /**
     * Test the the creation of Constant Product calculation module
     */
    function testFactoryFuzzConstantProductToken1(uint128 _reserve0, uint128 _reserve1, uint128 _amount) public {
        uint256 reserve0 = bound(_reserve0, 100, type(uint32).max);
        uint256 reserve1 = bound(_reserve1, 100, type(uint32).max);
        // make sure the amount to trade is less than the lowest reserve(this validation usually happens in AMM)
        uint256 minReserve = reserve0 < reserve1 ? uint256(reserve0) : uint256(reserve1);
        uint256 amount = bound(_amount, 1, minReserve - 10);
        // create a constant calculator with 2 to 1 ration token0 to token1
        address calcAddress = factory.createConstantProduct(address(applicationAppManager));
        IProtocolAMMFactoryCalculator calc = IProtocolAMMFactoryCalculator(calcAddress);
        uint256 returnVal;
        // swap
        if (amount == 0) vm.expectRevert(0x5b2790b5);
        returnVal = calc.calculateSwap(reserve0, reserve1, 0, amount);
        assertEq(returnVal, (amount * reserve0) / (reserve1 + amount));
    }

    /**
     * Test the the creation of Linear calculation module
     */
    function testFactoryLinear() public {
        // create a linear calculator (y=mx+b))
        // m = .00006(this is set as 8 digits)
        // b = 1.5
        address calcAddress = factory.createLinear(600, 15 * 10 ** 17, 2_000_000 * 10 ** 18, address(applicationAppManager));
        ProtocolAMMCalcLinear calc = ProtocolAMMCalcLinear(calcAddress);
        uint256 reserve0 = 1_000_000 * 10 ** 18;
        uint256 reserve1 = 1_000_000 * 10 ** 18;
        uint256 amount0 = 2 * 10 ** 18;
        uint256 amount1 = 0;
        uint256 returnVal;
        // swap 2*10**18 token0 for 2999880000000000060 token1
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 2999880000000000060);

        // swap 1*10**18 token1 for 1207550000000000000000 token0)
        amount0 = 0;
        amount1 = 1 * 10 ** 18;
        returnVal = calc.calculateSwap(reserve0, reserve1, amount0, amount1);
        assertEq(returnVal, 1);
    }
}

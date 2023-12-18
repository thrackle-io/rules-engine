// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "test/helpers/TestCommonFoundry.sol";
import {LinearInput, LinearFractionB, ConstantRatio} from "../../src/liquidity/calculators/dataStructures/CurveDataStructures.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConcLiqMulCurves.sol";
import "../helpers/Utils.sol";

/**
 * @title Test AMM Calculator with Concentrated Liquidity Regions with Multiple Curves
 * @notice This tests every function related to the AMM Calculator Factory including the different types of calculators
 * @dev A substantial amount of set up work is needed for each test.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcConcLiqMulCurvesTest is TestCommonFoundry, Utils {

    uint256 constant M_PRECISION_DECIMALS = 8;
    uint256 constant B_PRECISION_DECIMALS = 18;
    uint256 constant Y_MAX = 100_000 * 10 ** 18;
    uint256 constant M_MAX = 100 * 10 ** 8;

    LinearInput linearA = LinearInput(1 * 10 ** (M_PRECISION_DECIMALS - 4), 5 * (10 ** (B_PRECISION_DECIMALS - 1))); //m=0.0001; b=0.5
    ConstantRatio constRatioA = ConstantRatio(20_000, 30_000); // ratio = 3y per 2x
    uint256 constProductA = 7_000_000 * ATTO * 7_000_000 * ATTO;
    uint256[] upperLimitsA = [10_000 * ATTO, 1_000_000 * ATTO, 10_000_000 * ATTO]; 
    ProtocolAMMCalcConcLiqMulCurves calc;
    // LinearInput linearA = LinearInput(1 * 10 ** (M_PRECISION_DECIMALS - 4), 5 * (10 ** (B_PRECISION_DECIMALS - 1))); //m=0.0001; b=0.5
    // ConstantRatio constRatioA = ConstantRatio(20_000, 30_000); // ratio = 3y per 2x
    // uint256 constProductA = 7_000 * ATTO * 7_000 * ATTO;
    // uint256[] upperLimitsA = [1_000 * ATTO, 7_000 * ATTO, 50_000 * ATTO]; 

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        protocolAMMFactory = createProtocolAMMFactory();
        protocolAMMCalculatorFactory = createProtocolAMMCalculatorFactory();
        calc = ProtocolAMMCalcConcLiqMulCurves(protocolAMMCalculatorFactory.createConcLiqMulCurves(address(applicationAppManager)));
        switchToAppAdministrator();
    }

    function testAMMCalcConcLiqMulCurves_Calculatordeployed() public {
        assertEq(calc.appManagerAddress(),address(applicationAppManager));
    }


    /// Add LinearA Test

    /// build + execution block 
    function _addLinearA() internal {
        calc.addLinear(linearA);
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_AddLinearA_Positive() public {
        _addLinearA();
        (uint256 m_num, uint256 m_den, uint256 b_num, uint256 b_den) = calc.linears(0);
        assertEq(m_num , linearA.m);
        assertEq(m_den , 10 ** M_PRECISION_DECIMALS);
        assertEq(b_num , 2 * linearA.b);
        assertEq(b_den , 2 * 10 ** B_PRECISION_DECIMALS);
    }

    function testAMMCalcConcLiqMulCurves_AddLinearA_BTooLarge() public {
        LinearInput memory linearBTooLarge = LinearInput(1 * 10 ** (M_PRECISION_DECIMALS - 1), Y_MAX + 1);
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)",Y_MAX + 1));
        calc.addLinear(linearBTooLarge);
    }

    function testAMMCalcConcLiqMulCurves_AddLinearA_MTooLarge() public {
        LinearInput memory linearMTooLarge = LinearInput(M_MAX + 1, 50 * (10 ** B_PRECISION_DECIMALS));
        vm.expectRevert(abi.encodeWithSignature("ValueOutOfRange(uint256)",M_MAX + 1));
        calc.addLinear(linearMTooLarge);
    }


    /// Add ConstRatioA Test

    /// build + execution block 
    function _addConstRatioA() internal {
        calc.addConstantRatio(constRatioA);
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_AddConstRatioA_Positive() public {
        _addConstRatioA();
        (uint256 x, uint256 y) = calc.constRatios(0);
        assertEq(x, constRatioA.x);
        assertEq(y, constRatioA.y);
    }

    function testAMMCalcConcLiqMulCurves_AddConstRatioA_Negative() public {
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        calc.addConstantRatio(ConstantRatio(0, 0));
    }
    

    /// Add ConstProductA Test

    /// build + execution block 
    function _addConstProductA() internal {
        calc.addConstantProduct(constProductA);
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_AddConstProductA_Positive() public {
        _addConstProductA();
        uint256 k = calc.constProducts(0);
        assertEq(k, constProductA);
    }

    function testAMMCalcConcLiqMulCurves_AddConstProductA_Negative() public {
        vm.expectRevert(abi.encodeWithSignature("AmountsAreZero()"));
        calc.addConstantProduct(0);
    }


    /// setting upperLimitsA Test

    /// build + execution block 
    function _setUpperLimitsA() internal {
        calc.setUpperLimits(upperLimitsA);
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_SetUpperLimitsA_Positive() public {
        _setUpperLimitsA();
        for(uint i; i < upperLimitsA.length;i++){
            assertEq(calc.sectionUpperLimits(i), upperLimitsA[i]);
        }
    }

    function testAMMCalcConcLiqMulCurves_SetUpperLimitsA_WrongOrder() public {
        upperLimitsA[0] = 100_000_000 * ATTO; // we make the first element greater than the second
        vm.expectRevert(abi.encodeWithSignature("WrongArrayOrder()"));
        calc.setUpperLimits(upperLimitsA);
    }

    /// encapsulation of previous steps for future buildings
    function _setCurvesA() internal{
        _addLinearA();
        _addConstRatioA();
        _addConstProductA();
        _setUpperLimitsA();
    }


    /// setting sectionLinearA Test

    /// build + execution block 
    function _addSectionLinearAToIndex0() internal {
        _setCurvesA();
        SectionCurve memory linearASection = SectionCurve(CurveTypes.LINEAR_FRACTION_B, 0);
        calc.addCurveToSection(linearASection); // this means section 0 will be linearA
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_AddSectionLinearAToIndex0_Positive() public {
        _addSectionLinearAToIndex0();
        (CurveTypes _type, uint256 index) = calc.sectionCurves(0);
        assertEq(uint256(_type), uint256(CurveTypes.LINEAR_FRACTION_B));
        assertEq(index, 0);
    }

    function testAMMCalcConcLiqMulCurves_AddSectionLinearAToIndex0_Negative() public {
        _setCurvesA();
        SectionCurve memory linearASection = SectionCurve(CurveTypes.LINEAR_FRACTION_B, 1);
        vm.expectRevert(abi.encodeWithSignature("IndexOutOfRange()"));
        calc.addCurveToSection(linearASection); 
    }


    /// setting sectionConstantRatioA Test

    /// build + execution block 
    function _addSectionConstRatioAToIndex1() internal {
        _addSectionLinearAToIndex0();
        SectionCurve memory constRatioASection = SectionCurve(CurveTypes.CONST_RATIO, 0);
        calc.addCurveToSection(constRatioASection); // this means section 1 will be constRatio
    }

    /// tests
    function testAMMCalcConcLiqMulCurves_AddSectionConstRatioAToIndex1_Positive() public {
        _addSectionConstRatioAToIndex1();
        (CurveTypes _type, uint256 index) = calc.sectionCurves(1);
        assertEq(uint256(_type), uint256(CurveTypes.CONST_RATIO));
        assertEq(index, 0);
    }

    function testAMMCalcConcLiqMulCurves_AddSectionConstRatioAToIndex1_Negative() public {
        _addSectionLinearAToIndex0();
        SectionCurve memory constRatioASection = SectionCurve(CurveTypes.CONST_RATIO, 1);
        vm.expectRevert(abi.encodeWithSignature("IndexOutOfRange()"));
        calc.addCurveToSection(constRatioASection);
    }


    /// setting sectionConstantProductA Test

    /// build + execution block 
    function _addSectionConstProductToIndex2() internal {
        _addSectionConstRatioAToIndex1();
        SectionCurve memory constProductSection = SectionCurve(CurveTypes.CONST_PRODUCT, 0);
        calc.addCurveToSection(constProductSection); // this means section 2 will be constProduct
    }

    /// test
    function testAMMCalcConcLiqMulCurves_AddSectionConstProductAToIndex2_Positive() public {
        _addSectionConstProductToIndex2();
        (CurveTypes _type, uint256 index) = calc.sectionCurves(2);
        assertEq(uint256(_type), uint256(CurveTypes.CONST_PRODUCT));
        assertEq(index, 0);
    }

    function testAMMCalcConcLiqMulCurves_AddSectionConstProductAToIndex2_Negative() public {
        _addSectionConstRatioAToIndex1();
        SectionCurve memory constProductSection = SectionCurve(CurveTypes.CONST_PRODUCT, 1);
        vm.expectRevert(abi.encodeWithSignature("IndexOutOfRange()"));
        calc.addCurveToSection(constProductSection);
    }

    /// General negative case for setting a curve section: Invalid Curve Type
    function testAMMCalcConcLiqMulCurves_AddSection_Negative() public {
        _addSectionConstRatioAToIndex1();
        SectionCurve memory constProductSection = SectionCurve(CurveTypes.LINEAR_WHOLE_B, 0); // index don't matter here
        vm.expectRevert(abi.encodeWithSignature("InvalidCurveType()"));
        calc.addCurveToSection(constProductSection); 
   }

    /// encapsulation of all previous positive tests for future buildings
   function _setSectionsA() internal{
        _addSectionConstProductToIndex2();
   }


    /// ################## Math Tests ########################

    /// Linear Region

    function _setupLinearReserves() internal {
        _setSectionsA();
        /// According to desmos. Spot price should be 0.6
        uint256 reserves0 = 1_000 * ATTO;
        calc.set_x_offset(reserves0);
    }

    function _setupLinearReservesAt5k() internal {
        _setSectionsA();
        /// According to desmos. Spot price should be 0.6
        uint256 reserves0 = 5_000 * ATTO;
        calc.set_x_offset(reserves0);
    }

    function _setupLinearReservesAt9k() internal {
        _setSectionsA();
        /// According to desmos. Spot price should be 0.6
        uint256 reserves0 = 9_000 * ATTO;
        calc.set_x_offset(reserves0);
    }

    function _linearRegionExchange1XtoY() internal returns(uint256 amountOut){
        _setupLinearReserves();
        amountOut = calc.calculateSwap(0, 0, 1 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchange1XtoY() public {
        uint256 amountOut = _linearRegionExchange1XtoY();
        /// according to desmos result should be 6.0005 * 10 ^ 17
        assertEq(amountOut, 6_0005 * (10 ** (17 - 4)));
    }

    function _linearRegionExchangesomeYto1X() internal returns(uint256 amountOut){
        _linearRegionExchange1XtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 6_0005 * (10 ** (17 - 4)));
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeSomeYto1X() public {
        uint256 amountOut = _linearRegionExchangesomeYto1X();
        /// according to desmos result should be 1.666898212470894848 * 10^18
        assertLe(absoluteDiff(1 * ATTO, amountOut), 1);
    }

    function _linearRegionExchange2XtoY() internal returns(uint256 amountOut){
        _setupLinearReserves();
        amountOut = calc.calculateSwap(0, 0, 2 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchange2XtoY() public {
        uint256 amountOut = _linearRegionExchange2XtoY();
        /// according to desmos result should be 1.2002 * 10 ^ 18
        assertEq(amountOut, 1_2002 * (10 ** (18 - 4)));
    }

    function _linearRegionExchangeSomeYto2X() internal returns(uint256 amountOut){
        _linearRegionExchange2XtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 1_2002 * (10 ** (18 - 4)));
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeSomeYto2X() public {
        uint256 amountOut = _linearRegionExchangeSomeYto2X();
        /// according to desmos result should be 3.33425977420053504 * 10 ^ 18
        assertLe(absoluteDiff( 2 * ATTO, amountOut), 1); /// here the error is 3
    }

    function _linearRegionExchangeFrom5KUntilFirstUpperLimit() internal returns(uint256 amountOut){
        _setupLinearReservesAt5k();
        amountOut = calc.calculateSwap(0, 0, upperLimitsA[0] - 5_000 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeFrom5KUntilFirstUpperLimit() public {
        uint256 amountOut = _linearRegionExchangeFrom5KUntilFirstUpperLimit();
        /// according to desmos result should be 6250 * ATTO
        assertEq(amountOut, 6250 * ATTO);
    }

    function _linearRegionExchangeBackFromFirstUpperLimitTo5k() internal returns(uint256 amountOut){
        _linearRegionExchangeFrom5KUntilFirstUpperLimit();
        amountOut = calc.calculateSwap(0, 0, 0, 6250 * ATTO);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeBackFromFirstUpperLimitTo5k() public {
        uint256 amountOut = _linearRegionExchangeBackFromFirstUpperLimitTo5k();
        /// result should be the initial amount 
        assertEq(amountOut, upperLimitsA[0] - 5_000 * ATTO);
    }

    function _linearRegionExchangeFrom9KUntilFirstUpperLimit() internal returns(uint256 amountOut){
        _setupLinearReservesAt5k();
        amountOut = calc.calculateSwap(0, 0, upperLimitsA[0] - 9_000 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeFrom9KUntilFirstUpperLimit() public {
        uint256 amountOut = _linearRegionExchangeFrom9KUntilFirstUpperLimit();
        /// according to desmos result should be 1050 * ATTO
        assertEq(amountOut, 1050 * ATTO);
    }

    function _linearRegionExchangeBackFromFirstUpperLimitTo9K() internal returns(uint256 amountOut){
        _linearRegionExchangeFrom9KUntilFirstUpperLimit();
        amountOut = calc.calculateSwap(0, 0, 0, 1050 * ATTO);
    }

    function testAMMCalcConcLiqMulCurves_LinearRegionExchangeBackFromFirstUpperLimitTo9K() public {
        uint256 amountOut = _linearRegionExchangeBackFromFirstUpperLimitTo9K();
        /// result should be the initial amount 
        assertEq(amountOut, upperLimitsA[0] - 9_000 * ATTO);
    }



    /// Constant Ratio Region

    function _setupConstantRatioReserves() internal {
        _setSectionsA();
        /// spot price should be 1.5
        uint256 reserves0 = 100_000 * ATTO;
        calc.set_x_offset(reserves0);
        // reserves1 = 150_000 * ATTO;
    }

    function _ConstantRatioRegionExchange1XtoY() internal returns(uint256 amountOut){
        _setupConstantRatioReserves();
        amountOut = calc.calculateSwap(0, 0, 1 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_ConstantRatioRegionExchange1XtoY() public {
        uint256 amountOut = _ConstantRatioRegionExchange1XtoY();
        assertEq(amountOut, 15 * ATTO / 10);
    }

    function _ConstantRatioRegionExchange1point5YtoX() internal returns(uint256 amountOut){
        _ConstantRatioRegionExchange1XtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 15 * (ATTO / 10));
    }

    function testAMMCalcConcLiqMulCurves_ConstantRatioRegionExchange1point5YtoX() public {
        uint256 amountOut = _ConstantRatioRegionExchange1point5YtoX();
        assertLt(1 * ATTO - amountOut, 2); // we test that the difference is not more than 1 ATTO
    }

    function _ConstantRatioRegionExchange2XtoY() internal returns(uint256 amountOut){
        _setupConstantRatioReserves();
        amountOut = calc.calculateSwap(0, 0, 2 * ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_ConstantRatioRegionExchange2XtoY() public {
        uint256 amountOut = _ConstantRatioRegionExchange2XtoY();
        assertEq(amountOut, 3 * ATTO);
    }

    function _ConstantRatioRegionExchange3YtoX() internal returns(uint256 amountOut){
        _ConstantRatioRegionExchange2XtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 3 * ATTO);
    }

    function testAMMCalcConcLiqMulCurves_ConstantRatioRegionExchange3YtoX() public {
        uint256 amountOut = _ConstantRatioRegionExchange3YtoX();
        assertLt(2 * ATTO - amountOut , 2); // we test that the difference is not more than 1 ATTO
    }

    /// Constant Product Region
    function _setupConstantProductReserves() internal {
        _setSectionsA();
        /// spot price should be 1.96 -> region 2 according to upperLimitsA
        uint256 reserves0 = 5_000_000 * ATTO;
        calc.set_x_offset(reserves0);
    }

    function _ConstantProductRegionExchange1XtoY() internal returns(uint256 amountOut){
        _setupConstantProductReserves();
        amountOut = calc.calculateSwap(0, 0, 1 * ATTO , 0);
    }

    function testAMMCalcConcLiqMulCurves__ConstantProductRegionExchange1XtoY() public {
        uint256 amountOut = _ConstantProductRegionExchange1XtoY();
        assertEq(absoluteDiff(amountOut, 1959999608000078600), 201); 
    }

    function _ConstantProductRegionExchangeYbackto1X() internal returns(uint256 amountOut){
        _ConstantProductRegionExchange1XtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 1959999608000078600 - 201);
    }

    function testAMMCalcConcLiqMulCurves_ConstantProductRegionExchangeYbackto1X() public {
        uint256 amountOut = _ConstantProductRegionExchangeYbackto1X();
        assertLe(1 * ATTO - amountOut, 1 ); // we test that the difference is not more than 1 ATTO
    }

    function _ConstantProductRegionExchange20kxtoY() internal returns(uint256 amountOut){
        _setupConstantProductReserves();
        amountOut = calc.calculateSwap(0, 0, 2*ATTO, 0);
    }

    function testAMMCalcConcLiqMulCurves_ConstantProductRegionExchange20kxtoY() public {
        uint256 amountOut = _ConstantProductRegionExchange20kxtoY();
        assertEq(absoluteDiff(amountOut, 3919998432000627000), 199); // this is high for some reason
    }

    function _ConstantProductRegionExchangeYbackto2X() internal returns(uint256 amountOut){
        _ConstantProductRegionExchange20kxtoY();
        amountOut = calc.calculateSwap(0, 0, 0, 3919998432000627000 - 199);
    }

    function testAMMCalcConcLiqMulCurves_ConstantProductRegionExchangeYbackto2X() public {
        uint256 amountOut = _ConstantProductRegionExchangeYbackto2X();
        assertLe(absoluteDiff(2 * ATTO, amountOut) , 204); // this is high for some reason
    }


    /// ################## testing swaps that cross regions ##################

    function _goFromX5000ToHighestUpperLimitMinus1() internal returns(uint256 amountOut){
        _setSectionsA();
        uint256 reserves0 = 5_000 * ATTO;
        calc.set_x_offset(reserves0);
        /// we move x from 5_000 ATTOs to the very edge of the last region - 1. This way, we cross all 
        /// liquidity regions with a single swap
        amountOut = calc.calculateSwap(0, 0, upperLimitsA[upperLimitsA.length - 1] -  reserves0 - 1, 0);
    }

    function testAMMCalcConcLiqMulCurves_GoFromX5000ToHighestUpperLimitMinus1() public{
        /**
        * Linear region: 6250 * ATTO (x_0 = 5000, x_change = upperLimitsA[0])
        * Constant Ratio region:  1485000 * ATTO (x_0 = upperLimitsA[0], x_change = upperLimitsA[1])
        * SubTotal: 1491250 * ATTO (x_0 = upperLimitsA[1], x_change = upperLimitsA[2] - 1)
        * Constant Product region: 4.41e+25
        * TOTAL: 4.559125e+25
        */
         uint256 amountOut = _goFromX5000ToHighestUpperLimitMinus1();
        assertLe(absoluteDiff(45_591_250 * ATTO, amountOut) , 1_000_000_000); 
        
    }

    function _goFromHighestUpperLimitMinus1ToX5000() internal returns(uint256 amountOut){
        _goFromX5000ToHighestUpperLimitMinus1();
        /// we move x from 5_000 ATTOs to the very edge of the last region - 1. This way, we cross all 
        /// liquidity regions with a single swap
        amountOut = calc.calculateSwap(0, 0, 0, 45_591_250 * ATTO);
    }

    function testAMMCalcConcLiqMulCurves_GoFromHighestUpperLimitMinus1ToX5000() public{
        /**
        * Linear region: 6250 * ATTO (x_0 = 5000, x_change = upperLimitsA[0])
        * Constant Ratio region:  1485000 * ATTO (x_0 = upperLimitsA[0], x_change = upperLimitsA[1])
        * SubTotal: 1491250 * ATTO (x_0 = upperLimitsA[1], x_change = upperLimitsA[2] - 1)
        * Constant Product region: 8.82e+24
        * TOTAL: 1.0311250000000001 * (ATTO/(10**9))
        */
         uint256 amountOut = _goFromHighestUpperLimitMinus1ToX5000();
        assertLe(absoluteDiff(upperLimitsA[upperLimitsA.length - 1] -  5_000 * ATTO - 1, amountOut) , 1_000_000_000); 
        
    }

}

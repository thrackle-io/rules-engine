// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {
    LinearFractionB, 
    LinearInput, 
    ConstantRatio, 
    ConstantProduct, 
    Curve
} from "./libraries/Curve.sol";
import "./dataStructures/CurveTypes.sol";
import {CurveErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Concentrated Liquidity with Multiple Curve Types Automated Market Maker Calculator
 * @notice This calculator supports multiple curve types for different price ranges
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcConcLiqMulCurves is IProtocolAMMFactoryCalculator {

    using Curve for LinearFractionB;
    using Curve for ConstantRatio;
    using Curve for ConstantProduct;

    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 100_000 * ATTO;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 18;

    LinearFractionB[] public linears;
    ConstantRatio[] public constRatios;

    /// in terms of token1 per token0 in ATTOs
    SectionCurve[] public sectionCurves;
    uint256[] public sectionUpperLimits;

    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _appManagerAddress appManager address
     */
    constructor(address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token1 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return _amountOut
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external view override returns (uint256) {
        return simulateSwap( _reserve0, _reserve1, _amount0, _amount1);  
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token1 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return price
     */
    function simulateSwap(
            uint256 _reserve0, 
            uint256 _reserve1, 
            uint256 _amount0, 
            uint256 _amount1
        )
         public 
         view 
         override 
         returns (uint256) 
         {
            _validateNoneAreZero(_amount0, _amount1);
            /// spotPrice will be x/y or y/x. If buying token0 (x), then x/y. If buying token1 (y) then y/x
            uint256 spotPriceNumerator = _amount0 == 0 ? (_reserve0 * ATTO) / _reserve1 : (_reserve1 * ATTO) / _reserve0;
            //uint256 spotPriceDenominator = ATTO;
            for(uint i; i < sectionUpperLimits.length;){
                /// find curve for current value of x
                if(spotPriceNumerator < (_amount0 == 0 ? ATTO ** 2 / sectionUpperLimits[i] : sectionUpperLimits[i] )){
                    /// we calculate depending on the curve
                    uint256 _index = sectionCurves[i].index;
                    /// constant ratio
                    if(sectionCurves[i].curveType == CurveTypes.CONST_RATIO){
                        return _getConstantRatioY(_index, _amount0, _amount1);

                    /// constant product
                    }else if(sectionCurves[i].curveType == CurveTypes.CONST_PRODUCT){
                        return _getConstantProductY(_reserve0, _reserve1,_amount0, _amount1);

                    /// linear
                    }else if(sectionCurves[i].curveType == CurveTypes.LINEAR_FRACTION_B){
                        return _getLinearY(_index, _reserve0, _reserve1, _amount0, _amount1);
                    
                    /// revert if type was none of the above
                    }else{
                        revert InvalidCurveType();
                    }
                }
                unchecked{
                    ++i;
                }
            }
            /// if we made it here that means that x is out of range
            revert InvalidCurveType();
    }

    /**
     * @dev Set the equation variables
    * @param _curve the definition of the linear ecuation
     */
    function addLinear(LinearInput memory _curve) external appAdministratorOnly(appManagerAddress) {
        _validateSingleCurve(_curve);
        linears.push(LinearFractionB(1,1,1,1));/// we add a dummy linear to be able to build it from library
        linears[linears.length - 1].fromInput(_curve, M_PRECISION_DECIMALS, B_PRECISION_DECIMALS);
    }

    /**
     * @dev Set the equation variables
    * @param _constRatio the definition of the ratio
     */
    function addConstantRatio(ConstantRatio memory _constRatio) external appAdministratorOnly(appManagerAddress) {
        _validateAreNotZero(_constRatio.x, _constRatio.y); // neither can be 0
        constRatios.push(_constRatio);
    }

    function addAnUpperLimit(uint256 upperLimit) external appAdministratorOnly(appManagerAddress) {
        uint256 length = sectionUpperLimits.length;
        if ( (length > 0) && (sectionUpperLimits[length - 1] > upperLimit) ) 
            revert WrongArrayOrder();
        sectionUpperLimits.push(upperLimit);
    }

    function setAnUpperLimit(uint256 upperLimit, uint8 index) external appAdministratorOnly(appManagerAddress) {
        if( ( (index > 0) && (upperLimit <= sectionUpperLimits[index - 1]) ) || 
            ( (sectionUpperLimits.length > 0) && (upperLimit >= sectionUpperLimits[index + 1])) )
                revert WrongArrayOrder();
        sectionUpperLimits[index] = upperLimit;
    }

    function setUpperLimits(uint256[] calldata upperLimits) external appAdministratorOnly(appManagerAddress) {
        for(uint i=1; i < upperLimits.length;){
            if(upperLimits[i] <= upperLimits[i - 1]) 
                revert WrongArrayOrder();
            unchecked{
                ++i;
            }
        }
        sectionUpperLimits = upperLimits;
    }

    function addCurveToSection(SectionCurve calldata selectedCurve) external appAdministratorOnly(appManagerAddress){
         _validateSectionCurve(selectedCurve);
        sectionCurves.push(selectedCurve);
    }

    function setCurveToSection(
            SectionCurve calldata selectedCurve, 
            uint8 index
        ) 
        external
        appAdministratorOnly(appManagerAddress)
        {
            _validateSectionCurve(selectedCurve);
            sectionCurves[index] = selectedCurve;
    }

    function _validateSectionCurve(SectionCurve calldata selectedCurve) internal view{
        if (selectedCurve.curveType == CurveTypes.CONST_RATIO){
            if(selectedCurve.index >= constRatios.length) 
                revert IndexOutOfRange();
        }
        else if(selectedCurve.curveType == CurveTypes.LINEAR_FRACTION_B){
            if(selectedCurve.index >= linears.length) 
                revert IndexOutOfRange();
        }
        else if (selectedCurve.curveType != CurveTypes.CONST_PRODUCT) 
            revert InvalidCurveType();
    }

    function _getConstantRatioY(uint256 _index, uint256 _amount0, uint256 _amount1) internal view returns(uint256){
            return constRatios[_index].getY(_amount0, _amount1);
    }

    function _getConstantProductY(
            uint256 _reserve0, 
            uint256 _reserve1,
            uint256 _amount0, 
            uint256 _amount1
        ) 
        internal 
        pure
        returns(uint256)
        {
            return ConstantProduct(_reserve0,_reserve1).getY(_amount0, _amount1);
    }

    function _getLinearY(
            uint256 _index, 
            uint256 _reserve0, 
            uint256 _reserve1,
            uint256 _amount0, 
            uint256 _amount1
        ) 
        internal 
        view
        returns(uint256)
        {
            return linears[_index].getY(_reserve0, _reserve1,_amount0, _amount1);
    }

    /**
    * @dev validates that the definition of a curve is within the safe mathematical limits
    * @param _curve the definition of the curve
    */
    function _validateSingleCurve(LinearInput memory _curve) internal pure { // good candidate to move up to common
        if (_curve.m > M_MAX) revert ValueOutOfRange(_curve.m);
        if (_curve.b > Y_MAX) revert ValueOutOfRange(_curve.b);
    }

    function _validateAreNotZero(uint256 a, uint256 b) internal pure { // good candidate to move up to common
        if (a == 0 || b == 0) 
            revert AmountsAreZero();
    }

    function _validateNoneAreZero(uint256 a, uint256 b) internal pure { // good candidate to move up to common
        if (a == 0 && b == 0) 
            revert AmountsAreZero();
    }

}

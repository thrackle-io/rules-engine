// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {
    LinearFractionB, 
    LinearInput, 
    ConstantRatio, 
    ConstantProduct, 
    Curve,
    AMMMath
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
    using AMMMath for uint256;

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
     * @return amountOut
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
         returns (uint256 amountOut) 
         {
            _validateNoneAreZero(_amount0, _amount1);
            bool isAmount0Not0 = _amount0 != 0;
            uint256 reserve0 = _reserve0;
            uint256 reserve1 = _reserve1; 
            uint256 amount0 = _amount0; 
            uint256 amount1 = _amount1;
            uint256 amountInLeft = isAmount0Not0 ? _amount0 : _amount1;
            uint256 regionOut;
            
            for(uint i; i < sectionUpperLimits.length;){
                /// spotPrice will be y/x
                uint256 spotPriceNumerator = (reserve1 * ATTO) / reserve0;
                /// find curve for current value of x
                if( spotPriceNumerator < sectionUpperLimits[i] ){
                    /// adding to reserve0 (x) will always make the price go down. We check for lower limit
                    if ( isAmount0Not0){
                        /// we only check if there is a lower limit
                        if(i != 0){
                            /// lower limit is simply the upper limit of the past region
                            uint256 maxX = _getRegionsXmax( i - 1, reserve0, reserve1);
                            if(amountInLeft + reserve0 > maxX){
                                amount0 = maxX - reserve0;
                                amountInLeft -= amount0;
                            }else{
                                amount0 = amountInLeft;
                                amountInLeft = 0;
                            }
                        }else{
                            amountInLeft=0;
                        }
                    /// ading to reserve1 (y) will always make the price go up. We check for upper limit    
                    }else{
                        uint256 maxY = _getRegionsYmax(i, reserve0, reserve1);
                        if(amountInLeft + reserve1 > maxY){
                            amount1 = maxY - reserve1;
                            amountInLeft -= amount1;
                        }else{
                            amount1 = amountInLeft;
                            amountInLeft = 0;
                        }
                    }
                    /// we calculate depending on the curve
                    uint256 _index = sectionCurves[i].index;
                    /// constant ratio
                    if(sectionCurves[i].curveType == CurveTypes.CONST_RATIO){
                        regionOut = _getConstantRatioY(_index, amount0, amount1);
                        
                    /// constant product
                    }else if(sectionCurves[i].curveType == CurveTypes.CONST_PRODUCT){
                        regionOut = _getConstantProductY(reserve0, reserve1, amount0, amount1);

                    /// linear
                    }else if(sectionCurves[i].curveType == CurveTypes.LINEAR_FRACTION_B){
                        regionOut = _getLinearY(_index, reserve0, reserve1, amount0, amount1);
                    
                    /// revert if type was none of the above
                    }else{
                        revert InvalidCurveType();
                    }

                    if(isAmount0Not0){
                        reserve0 += amount0;
                        reserve1 -= regionOut;
                    }else{
                        reserve0 -= regionOut;
                        reserve1 += amount1;
                    }
                    amountOut += regionOut;
                }
                unchecked{
                    ++i;
                }
            }
            if((reserve1 * ATTO) / reserve0 > sectionUpperLimits[ sectionUpperLimits.length - 1])
                revert("OUT OF LIMITS");
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

      function _getRegionsXmax(uint256 _regionIndex, uint256 _reserve0, uint256 _reserve1) internal view returns(uint256){
        uint256 maxRegionPrice = sectionUpperLimits[_regionIndex];
        return (((_reserve0 * _reserve1 * ATTO) / maxRegionPrice)).sqrt() * ATTO.sqrt(); 
    }

    function _getRegionsYmax(uint256 _regionIndex, uint256 _reserve0, uint256 _reserve1) internal view returns(uint256){
        uint256 maxRegionPrice = sectionUpperLimits[_regionIndex];
        return ((_reserve0 * 10_000).sqrt() * (_reserve1 * 10_000).sqrt() * maxRegionPrice.sqrt()) / (10_000 * ATTO.sqrt());
    }

}

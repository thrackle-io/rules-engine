// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {
    LinearFractionB, 
    LinearInput, 
    ConstantRatio, 
    ConstantProductK, 
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
    using Curve for ConstantProductK;
    using AMMMath for uint256;

    uint256 constant ATTO = 10 ** 18;
    uint256 constant Y_MAX = 100_000 * ATTO;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 18;
    uint256 x_trackerOffset;
    uint256 x_tracker;

    /// curves stored in the contract to use in regions
    LinearFractionB[] public linears;
    ConstantRatio[] public constRatios;
    ConstantProductK[] public constProducts;

    /// defines which curve in what section
    SectionCurve[] public sectionCurves;
    /// in terms of token0 (x axis)
    uint256[] public sectionUpperLimits;

    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _appManagerAddress appManager address
     */
    constructor(uint256 _x_trackerOffset, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        x_trackerOffset = _x_trackerOffset;
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token1 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return amountOut
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external override returns (uint256 amountOut) {
        amountOut = simulateSwap( _reserve0, _reserve1, _amount0, _amount1);  
        if(_amount0 == 0)
            x_tracker -= amountOut;
        else
            x_tracker += _amount0;
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
            _reserve0; 
            _reserve1;
            bool isAmount0Not0 = _amount0 != 0;
            uint256 amount0 = _amount0; 
            uint256 amount1 = _amount1;
            uint256 amountInLeft = isAmount0Not0 ? _amount0 : _amount1;
            uint256 regionOut;
            uint256 i;
            uint256 _x_tracker = x_tracker + x_trackerOffset;
            
            while(amountInLeft != 0 && i < sectionUpperLimits.length){
                /// spotPrice will be y/x
                uint256 maxX = sectionUpperLimits[i];

                /// find curve for current value of x
                if( _x_tracker < maxX ){
                    if ( isAmount0Not0){
                        /// if the trade will trespass current region, then only trade until max for this curve
                        if(amountInLeft + _x_tracker > maxX){
                            amount0 = maxX - _x_tracker;
                            amountInLeft -= amount0;
                        /// if the trade won't trespass current region, then simply trade and reset amountInLeft
                        }else{
                            amount0 = amountInLeft;
                            amountInLeft = 0;
                        }   
                    }
                    uint256 _index = sectionCurves[i].index;

                    /// constant ratio
                    if(sectionCurves[i].curveType == CurveTypes.CONST_RATIO){
                        if(!isAmount0Not0)
                            (amountInLeft, amount1 ) = _determinAmountLeftY(_x_tracker, amount0, amount1, amountInLeft, CurveTypes.CONST_RATIO, i);
                        regionOut = _getConstantRatioY(_index, amount0, amount1);
                        
                    /// constant product
                    }else if(sectionCurves[i].curveType == CurveTypes.CONST_PRODUCT){
                        if(!isAmount0Not0)
                            (amountInLeft, amount1 ) = _determinAmountLeftY(_x_tracker, amount0, amount1, amountInLeft, CurveTypes.CONST_PRODUCT, i);
                        regionOut = _getConstantProductY(_index, _x_tracker, amount0, amount1);

                    /// linear
                    }else if(sectionCurves[i].curveType == CurveTypes.LINEAR_FRACTION_B){
                        if(!isAmount0Not0)
                            (amountInLeft, amount1 ) = _determinAmountLeftY(_x_tracker, amount0, amount1, amountInLeft, CurveTypes.LINEAR_FRACTION_B, i);
                        regionOut = _getLinearY(_index, _x_tracker, amount0, amount1);

                    /// revert if type was none of the above
                    }else{
                        revert InvalidCurveType();
                    }
                    /// if we are in here, we modify i depending on the direction fo the swap
                    if(isAmount0Not0){
                        _x_tracker += amount0;
                        unchecked{
                            ++i;
                        }
                    }
                    else{
                        _x_tracker -= amountOut;
                        unchecked{
                            if(i > 0) --i;
                            // else{
                            //     if(amountInLeft > 0)
                            //         revert("OUT OF LIMITS");
                            // }
                        }
                    }
                    amountOut += regionOut;
                }else{
                    unchecked{
                        ++i;
                    }
                }
            }
            if(amountInLeft > 0)
                revert("OUT OF LIMITS");
    }

    function set_x_offset(uint256 offset) external appAdministratorOnly(appManagerAddress) {
        x_trackerOffset = offset;
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
    * @dev Adds a constant product value to the list
    * @param k the definition of the constant product
    */
    function addConstantProduct(uint256 k) external appAdministratorOnly(appManagerAddress) {
        _validateAreNotZero(k, k); 
        constProducts.push(ConstantProductK(k));
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
        else if (selectedCurve.curveType == CurveTypes.CONST_PRODUCT){
            if(selectedCurve.index >= constProducts.length) 
                revert IndexOutOfRange();
        }else
            revert InvalidCurveType();
    }

    function _getConstantRatioY(uint256 _index, uint256 _amount0, uint256 _amount1) internal view returns(uint256){
            return constRatios[_index].getY(_amount0, _amount1);
    }

    function _getConstantProductY(uint256 _index, uint256 x, uint256 amount0, uint256 amount1) internal view returns(uint256){
        return constProducts[_index].getY(x, amount0, amount1);
    }

    function _getLinearY(uint256 _index,  uint256 x, uint256 _amount0, uint256 _amount1) internal view returns(uint256){
            return linears[_index].getY(x, _amount0, _amount1);
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

    function _determinAmountLeftY(uint256 _x_tracker, uint256 amount0, uint256 amount1, uint256 amountInLeft, CurveTypes _type, uint256 i) internal view returns(uint256 newAmountInLeft, uint256 newAmount1){
        bool isAmount0Not0 = amount0 != 0;
        uint256 _index = sectionCurves[i].index;
        if(i != 0 && !isAmount0Not0){
            uint256 maxY;
            if(_type == CurveTypes.LINEAR_FRACTION_B) maxY = _getLinearY(_index, _x_tracker, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0);
            else if(_type == CurveTypes.CONST_PRODUCT) maxY = _getConstantProductY(_index, _x_tracker, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0);
            else if(_type == CurveTypes.CONST_RATIO) maxY = _getConstantRatioY(_index, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0); /// this has to have its own equation where x_0 is the upper limit
            if(maxY < amount1){
                amount1 = amountInLeft - maxY;
                amountInLeft -= amount1;
            }else{
                amount1 = amountInLeft;
                amountInLeft = 0;
            }
        }else if(i == 0 && !isAmount0Not0){
            amount1 = amountInLeft;
            amountInLeft = 0;
        }
        newAmountInLeft = amountInLeft;
        newAmount1 = amount1;
    }

}

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


    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 8;
    uint256 constant Y_MAX = 100_000 * (10 ** B_PRECISION_DECIMALS);
    uint256 constant M_MAX = 100 * (10 ** M_PRECISION_DECIMALS);
    uint256 x_trackerOffset;
    uint256 x_tracker;

    /// curves stored in the contract to use in regions
    LinearFractionB[] public linears;
    ConstantRatio[] public constRatios;
    ConstantProductK[] public constProducts;

    /// defines which curve in what section
    SectionCurve[] public sectionCurves;
    /// in terms of token0 (x axis). Upper Limits are exclusive
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
        _validateOneIsNotZero(_amount0, _amount1);
        bool isAmount0Not0 = _amount0 != 0;
        uint256 amount0 = _amount0; 
        uint256 amount1 = _amount1;
        uint256 amountInLeft = isAmount0Not0 ? _amount0 : _amount1;
        uint256 i;
        uint256 _x_tracker = x_tracker + x_trackerOffset;
        uint256 regionOut;
        
        while(amountInLeft != 0 && i < sectionUpperLimits.length){
            uint256 max_x = sectionUpperLimits[i];
            /// find curve for current value of x
            if( _x_tracker < max_x ){
                /// constant ratio
                if(sectionCurves[i].curveType == CurveTypes.CONST_RATIO){
                    (regionOut, amountInLeft, amount0, amount1) = _calculateConstantRatio(_x_tracker, max_x, amountInLeft, amount0, amount1, i);
                    amountOut += regionOut;
                /// constant product
                }else if(sectionCurves[i].curveType == CurveTypes.CONST_PRODUCT){
                    (regionOut, amountInLeft, amount0, amount1) = _calculateConstantProduct(_x_tracker, max_x, amountInLeft, amount0, amount1, i);
                    amountOut += regionOut;
                /// linear
                }else if(sectionCurves[i].curveType == CurveTypes.LINEAR_FRACTION_B){
                    (regionOut, amountInLeft, amount0, amount1) = _calculateLinear(_x_tracker, max_x, amountInLeft, amount0, amount1, i);
                    amountOut += regionOut;
                /// revert if type was none of the above
                }else
                    revert InvalidCurveType();
                /// if we are in here, we modify i depending on the direction fo the swap
                if(isAmount0Not0){
                    _x_tracker += amount0;
                    unchecked{
                        ++i;
                    }
                }else{
                    _x_tracker -= amountOut;
                    unchecked{
                        if(i > 0)
                            --i;
                        else if(amountInLeft > 0){
                            revert("OUT OF LIMITS");
                        }
                    }
                }
            }else{
                unchecked{
                    ++i;
                }
            }
        }
        if(amountInLeft > 0)
            revert("OUT OF LIMITS");
        _reserve0; 
        _reserve1;
    }

    /**
    * @dev Sets the x_trackerOffset value
    * @param offset new value for x_trackerOffset
    */
    function set_x_offset(uint256 offset) external appAdministratorOnly(appManagerAddress) {
        x_trackerOffset = offset;
    }

    /**
    * @dev Sets the equation variables
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
        _validateNoneAreZero(k, k); 
        constProducts.push(ConstantProductK(k));
    }

    /**
    * @dev Set the equation variables
    * @param _constRatio the definition of the ratio
    */
    function addConstantRatio(ConstantRatio memory _constRatio) external appAdministratorOnly(appManagerAddress) {
        _validateNoneAreZero(_constRatio.x, _constRatio.y); // neither can be 0
        constRatios.push(_constRatio);
    }

    /**
    * @dev appends an element to the end of the sectionUpperLimits array
    * @param upperLimit the upper limit to append to the list of upper limits
    */
    function addAnUpperLimit(uint256 upperLimit) external appAdministratorOnly(appManagerAddress) {
        uint256 length = sectionUpperLimits.length;
        if ( (length > 0) && (sectionUpperLimits[length - 1] > upperLimit) ) 
            revert WrongArrayOrder();
        sectionUpperLimits.push(upperLimit);
    }

    /**
    * @dev updates an upper limit value
    * @param upperLimit the upper limit to append to the list of upper limits
    * @param index position of the upper limit to update in the list
    */
    function updateAnUpperLimit(uint256 upperLimit, uint8 index) external appAdministratorOnly(appManagerAddress) {
        if( ( (index > 0) && (upperLimit <= sectionUpperLimits[index - 1]) ) || 
            ( (sectionUpperLimits.length > 0) && (upperLimit >= sectionUpperLimits[index + 1])) )
                revert WrongArrayOrder();
        sectionUpperLimits[index] = upperLimit;
    }

    /**
    * @dev sets the whole upperLimits array at once
    * @param upperLimits the array which is wished to be used as upperLimits
    */
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

    /**
    * @dev add a curve to a section
    * @param selectedCurve of SectionCurve type where a pointer to a curve stored in the contract is appended to the sectionCurves list
    */
    function addCurveToSection(SectionCurve calldata selectedCurve) external appAdministratorOnly(appManagerAddress){
         _validateSectionCurve(selectedCurve);
        sectionCurves.push(selectedCurve);
    }

    /**
    * @dev sets a curve to a section
    * @param selectedCurve of SectionCurve type where a pointer to a curve stored in the contract is set to a specific index of the sectionCurves list
    */
    function setCurveToSection( SectionCurve calldata selectedCurve, uint8 index) external appAdministratorOnly(appManagerAddress) {
        _validateSectionCurve(selectedCurve);
        sectionCurves[index] = selectedCurve;
    }

    /**
    * @dev helper function to validate that a SetionCurve input points to an exisiting curve in the contract
    * @param selectedCurve of SectionCurve type where a pointer to a curve stored in the contract is trying to be added to the sectionCurves list
    */
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

    /**
    * @dev calculates constant ratio amountOut and updates the values of the amounts and trackers
    * @param _x_tracker the current value of the x tracker including the offset
    * @param max_x max amount of x for the current region
    * @param amountInLeft current amount of the input tokens to be exchanged
    * @param amount0 current value of amount0
    * @param amount1 current value of amount1
    * @param i index of the current section 
    * @return amountOut the amount out for this region
    * @return newAmountInLeft updated value for amountInLeft
    * @return newAmount0 the updated value for amount0
    * @return newAmount1 the updated value for amount1
    */
    function _calculateConstantRatio(
        uint256 _x_tracker, 
        uint256 max_x, 
        uint256 amountInLeft, 
        uint256 amount0, 
        uint256 amount1,
        uint256 i
    ) 
    internal 
    view 
    returns(
        uint256 amountOut, 
        uint256 newAmountInLeft, 
        uint256 newAmount0, 
        uint256 newAmount1
    )
    {
        if (amount0 != 0)
            (newAmountInLeft, amount0) = _determineAmountLeftX( _x_tracker, max_x, amountInLeft);
        else
            (newAmountInLeft, amount1) = _determineAmountLeftY(_x_tracker, amount1, amountInLeft, CurveTypes.CONST_RATIO, i);
        amountOut = _getConstantRatioY(sectionCurves[i].index, amount0, amount1);
        newAmount0 = amount0;
        newAmount1 = amount1;
    }

    /**
    * @dev calculates constant product amountOut and updates the values of the amounts and trackers
    * @param _x_tracker the current value of the x tracker including the offset
    * @param max_x max amount of x for the current region
    * @param amountInLeft current amount of the input tokens to be exchanged
    * @param amount0 current value of amount0
    * @param amount1 current value of amount1
    * @param i index of the current section 
    * @return amountOut the amount out for this region
    * @return newAmountInLeft updated value for amountInLeft
    * @return newAmount0 the updated value for amount0
    * @return newAmount1 the updated value for amount1
    */
    function _calculateConstantProduct(
        uint256 _x_tracker, 
        uint256 max_x, 
        uint256 amountInLeft, 
        uint256 amount0, 
        uint256 amount1,
        uint256 i
    ) 
    internal 
    view 
    returns(
        uint256 amountOut, 
        uint256 newAmountInLeft, 
        uint256 newAmount0, 
        uint256 newAmount1
    )
    {
        if (amount0 != 0)
            (newAmountInLeft, amount0) = _determineAmountLeftX( _x_tracker, max_x, amountInLeft);
        else
            (newAmountInLeft, amount1) = _determineAmountLeftY(_x_tracker, amount1, amountInLeft, CurveTypes.CONST_PRODUCT, i);
        amountOut = _getConstantProductY(sectionCurves[i].index, _x_tracker, amount0, amount1);
        newAmount0 = amount0;
        newAmount1 = amount1;
    }

    /**
    * @dev calculates linears amountOut and updates the values of the amounts and trackers
    * @param _x_tracker the current value of the x tracker including the offset
    * @param max_x max amount of x for the current region
    * @param amountInLeft current amount of the input tokens to be exchanged
    * @param amount0 current value of amount0
    * @param amount1 current value of amount1
    * @param i index of the current section 
    * @return amountOut the amount out for this region
    * @return newAmountInLeft updated value for amountInLeft
    * @return newAmount0 the updated value for amount0
    * @return newAmount1 the updated value for amount1
    */
    function _calculateLinear(
        uint256 _x_tracker, 
        uint256 max_x, 
        uint256 amountInLeft, 
        uint256 amount0, 
        uint256 amount1,
        uint256 i
    ) 
    internal 
    view 
    returns(
        uint256 amountOut, 
        uint256 newAmountInLeft, 
        uint256 newAmount0, 
        uint256 newAmount1
    )
    {
        if (amount0 != 0)
            (newAmountInLeft, amount0) = _determineAmountLeftX( _x_tracker, max_x, amountInLeft);
        else
            (newAmountInLeft, amount1) = _determineAmountLeftY(_x_tracker, amount1, amountInLeft, CurveTypes.LINEAR_FRACTION_B, i);
        amountOut = _getLinearY(sectionCurves[i].index, _x_tracker, amount0, amount1);
        newAmount0 = amount0;
        newAmount1 = amount1;
    }

    /**
    * @dev calculates the amount out for constant ratio
    * @param _index the index of the curve in the constRatios array
    * @param _amount0 amount of token0 being sent to the AMM
    * @param _amount1 amount of token1 being sent to the AMM
    * @return amount out
    */
    function _getConstantRatioY(uint256 _index, uint256 _amount0, uint256 _amount1) internal view returns(uint256){
            return constRatios[_index].getY(_amount0, _amount1);
    }

    /**
    * @dev calculates the amount out for constant product
    * @param _index the index of the curve in the constProducts array
    * @param _x_tracker the current value of the x tracker including the offset
    * @param amount0 amount of token0 being sent to the AMM
    * @param amount1 amount of token1 being sent to the AMM
    * @return amount out
    */
    function _getConstantProductY(uint256 _index, uint256 _x_tracker, uint256 amount0, uint256 amount1) internal view returns(uint256){
        return constProducts[_index].getY(_x_tracker, amount0, amount1);
    }

    /**
    * @dev calculates the amount out for linear
    * @param _index the index of the curve in the linears array
    * @param _x_tracker the current value of the x tracker including the offset
    * @param amount0 amount of token0 being sent to the AMM
    * @param amount1 amount of token1 being sent to the AMM
    * @return amount out
    */
    function _getLinearY(uint256 _index,  uint256 _x_tracker, uint256 amount0, uint256 amount1) internal view returns(uint256){
            return linears[_index].getY(_x_tracker, amount0, amount1);
    }

    /**
    * @dev validates that the definition of a curve is within the safe mathematical limits
    * @param _curve the definition of the curve
    */
    function _validateSingleCurve(LinearInput memory _curve) internal pure { // good candidate to move up to common
        if (_curve.m > M_MAX) revert ValueOutOfRange(_curve.m);
        if (_curve.b > Y_MAX) revert ValueOutOfRange(_curve.b);
    }

    /**
    * @dev validates that none out of 2 numbers are zero
    * @param a first value to check
    * @param b second value to check
    */
    function _validateNoneAreZero(uint256 a, uint256 b) internal pure { // good candidate to move up to common
        if (a == 0 || b == 0) 
            revert AmountsAreZero();
    }

    /**
    * @dev validates that both numbers are not zero. Only one of them can be
    * @param a first value to check
    * @param b second value to check
    */
    function _validateOneIsNotZero(uint256 a, uint256 b) internal pure { // good candidate to move up to common
        if (a == 0 && b == 0) 
            revert AmountsAreZero();
    }

    /**
    * @dev calculates how much of the amountIn can be traded under current section before the trade enters into another region, and updates the value for amount1
    * @param _x_tracker the current value of the x tracker including the offset
    * @param amount1 current vlaue of amount1 
    * @param amountInLeft current amount of the input tokens to be exchanged
    * @param _type the type of curve of the section
    * @param i index of the current section 
    * @return newAmountInLeft the updated value for amountInLeft
    * @return newAmount1 the updated value for amount1
    */
    function _determineAmountLeftY(uint256 _x_tracker, uint256 amount1, uint256 amountInLeft, CurveTypes _type, uint256 i) internal view returns(uint256 newAmountInLeft, uint256 newAmount1){
        uint256 _index = sectionCurves[i].index;

        if(i != 0){
            uint256 maxY;

            if(_type == CurveTypes.LINEAR_FRACTION_B) maxY = _getLinearY(_index, _x_tracker, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0);
            else if(_type == CurveTypes.CONST_PRODUCT) maxY = _getConstantProductY(_index, _x_tracker, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0);
            else if(_type == CurveTypes.CONST_RATIO) maxY = _getConstantRatioY(_index, _x_tracker - (sectionUpperLimits[i - 1] + 1), 0); /// this has to have its own equation where x_0 is the upper limit
            
            if(maxY < amount1){
                newAmount1 = amountInLeft - maxY;
                newAmountInLeft -= amount1;
            }else{
                newAmount1 = amountInLeft;
                newAmountInLeft = 0;
            }
        }
        else{
            newAmount1 = amountInLeft;
            newAmountInLeft = 0;
        }
    }

    /**
    * @dev calculates how much of the amountIn can be traded under current section before the trade enters into another region, and updates the value for amount1
    * @param _x_tracker the current value of the x tracker including the offset
    * @param max_x max value for the _x_tracker for current section
    * @param amountInLeft current amount of the input tokens to be exchanged
    * @return newAmountInLeft the updated value for amountInLeft
    * @return newAmount0 the updated value for amount0
    */
    function _determineAmountLeftX(uint256 _x_tracker, uint256 max_x, uint256 amountInLeft) internal pure returns(uint256 newAmountInLeft, uint256 newAmount0){
        /// if the trade will trespass current region, then only trade until max for this curve
        if(amountInLeft + _x_tracker > max_x){
            newAmount0 = max_x - _x_tracker;
            newAmountInLeft = amountInLeft - newAmount0;
        /// if the trade won't trespass current region, then simply trade and reset amountInLeft
        }else{
            newAmount0 = amountInLeft;
            newAmountInLeft = 0;
        }   
    }

}

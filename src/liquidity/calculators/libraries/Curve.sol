// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {
    LinearWholeB, 
    LinearFractionB, 
    Sample01Struct, 
    LinearInput, 
    ConstantRatio, 
    ConstantProduct, 
    ConstantProductK
} from "../dataStructures/CurveDataStructures.sol";
import {AMMMath} from "./AMMMath.sol";

/**
 * @title Curve Library
 * @dev This is a library for AMM Bonding Curves to have their functions in a standarized API.
 * @notice This library only contains 2 function which are overloaded to accept different curves. 
 * Every curve should has its own implementation of both getY() function and fromInput() function.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
library Curve {

    using AMMMath for uint256;
    uint256 constant ATTO = 10 ** 18;
    error InsufficientPoolDepth();


    /// ~~~~~~~~~~~~~~ LinearWholeB ~~~~~~~~~~~~~~
    /**
    * @dev calculates ƒ(x) for linear curve. 
    * @notice the original ecuation y = mx + b  is replacing m by m_num/m_den.
    * @param line the LinearWholeB curve or function *ƒ*
    * @param x the scalar on the abscissa axis to calculate *ƒ(x)*.
    * @return y the value of ƒ(x) on the ordinate axis in ATTOs
    */
    function getY(LinearWholeB memory line, uint256 x)  internal pure returns(uint256 y){
        unchecked{
            y = ((line.m_num * x * ATTO) / line.m_den) + line.b;
        }
    }
    
    function integral(LinearWholeB memory line, uint256 x) internal pure returns(uint256 a){
       /// a = (((line.m_num * line.m_num) / (line.m_den * line.m_den)) * (x * x) * ATTO) + (line.b * x);
    }
    /**
    * @dev creates a LinearWholeB curve from a user's LinearInput. This mostly means that m is represented now by m_num/m_den.
    * @param line the LinearWholeB in storage that will be built from the input.
    * @param input the LinearInput entered by the user to be stored.
    * @param precisionDecimals the amount of precision decimals that the input's slope is formatted with.
    */
    function fromInput(LinearWholeB storage line, LinearInput memory input, uint256 precisionDecimals) internal {

        if (precisionDecimals % 2 == 0) {
            line.m_num = input.m;
            line.m_den = 10 ** precisionDecimals;
        }else{
            line.m_num = input.m * 10;
            line.m_den = 10 ** (precisionDecimals + 1);
        }
        line.b = input.b;
    }



    /// ~~~~~~~~~~~~~~ LinearFractionB ~~~~~~~~~~~~~~
    /**
    * @dev calculates ƒ(x) for linear curve. 
    * @notice the original ecuation y = mx + b  is replacing m by m_num/m_den.
    * @param line the LinearWholeB curve or function *ƒ*
    * @param _amount0 the token0s received 
    * @param _amount1 the token1s received 
    * @param x_0 tracker of x or amount of reserves in token0
    * @return y the value of ƒ(x) on the ordinate axis in ATTOs
    */
    function getY(LinearFractionB memory line, uint256 x_0, uint256 _amount0, uint256 _amount1)  internal pure returns(uint256 y){
        if (_amount0 != 0) {
            y = (((line.b_num * _amount0) / line.b_den) + ((line.m_num * ((2 * x_0 * _amount0) + _amount0 ** 2))) / ((2 * ATTO) * line.m_den)); 
        } else {
            uint y_0 = (line.b_num * x_0) / (line.b_den) + (((x_0 ** 2) * line.m_num) / (2 * line.m_den)) / ATTO;
            y = ((2 * (ATTO.sqrt())) * (_amount1 * line.b_den) * line.m_den.sqrt()) /
                (((ATTO * (line.b_num ** 2) * line.m_den) + 2 * y_0 * line.m_num * (line.b_den ** 2)).sqrt() + ((ATTO * (line.b_num ** 2) * line.m_den) + 2 * (y_0 - _amount1) * line.m_num * (line.b_den ** 2)).sqrt());
        }
    }

    /**
    * @dev creates a LinearWholeB curve from a user's LinearInput. This mostly means that m and b are represented by fractions.
    * @param line the LinearWholeB in storage that will be built from the input.
    * @param input the LinearInput entered by the user to be stored.
    * @param precisionDecimals_m the amount of precision decimals that the input's slope is formatted with.
    * @param precisionDecimals_b the amount of precision decimals that the input's intersection with the Y axis is formatted with.
    */
    function fromInput(LinearFractionB storage line, LinearInput memory input, uint256 precisionDecimals_m, uint256 precisionDecimals_b) internal {
        // if precisionDecimals is even, then we simply save input's m as numerator, and we make the denominator to have as many
        // zeros as *precisionDecimals*. This will make sure that m is a perfect square
        if (precisionDecimals_m % 2 == 0) {
            line.m_num = input.m;
            line.m_den = 10 ** precisionDecimals_m;
        // if precisionDecimals is NOT even, then we make it even by adding one more decimal on both denominator and numerator.
        }else{
            line.m_num = input.m * 10;
            line.m_den = 10 ** (precisionDecimals_m + 1);
        }
        // set b num so that it is a whole number but keep the ratio intact. This will make sure that b is a perfect square
        if (input.b < 1 * (10 ** precisionDecimals_b)) {
            uint256 b_extraDecimals = precisionDecimals_b - input.b.getNumberOfDigits();
            line.b_num = input.b * (2 * (10 ** b_extraDecimals));
            line.b_den = 2 * 10 ** (b_extraDecimals + precisionDecimals_b); /// this is different than original. Double check
        } else {
            line.b_num = 2 * input.b;
            line.b_den = 2 * 10 ** precisionDecimals_b;
        }
    }



    /// ~~~~~~~~~~~~~~ ConstantRatio ~~~~~~~~~~~~~~
    /**
    * @dev calculates ƒ(amountIn) for a constant-ratio AMM. 
    * @param cr the values of x and y for the constant ratio.
    * @param _amount0 the token0s received 
    * @param _amount1 the token1s received 
    * @return amountOut
    */
    function getY(ConstantRatio memory cr, uint256 _amount0, uint256 _amount1)  internal pure returns(uint256 amountOut){
        uint256 x = uint256(cr.x);
        uint256 y = uint256(cr.y);
        if(_amount0 != 0){
            unchecked{
                amountOut = (_amount0 * ((y * (10 ** 20)) / x)) / (10 ** 20);
            }
        }else{
            unchecked{
                amountOut = (_amount1 * ((x * (10 ** 20)) / y)) / (10 ** 20);
            }
        }
    }



    /// ~~~~~~~~~~~~~~ ConstantProduct ~~~~~~~~~~~~~~
    /**
    * @dev calculates ƒ(amountIn) for a constant-product AMM. 
    *      Based on (x + a) * (y - b) = x * y
    *      This is sometimes simplified as xy = k
    *      x = _reserve0
    *      y = _reserve1
    *      a = _amount0
    *      b = _amount1
    *      k = _reserve0 * _reserve1
    *
    * @param constantProduct the values of x and y for the constant product.
    * @param _amount0 the amount received of token0
    * @param _amount1 the amount received of token1
    * @return amountOut
    */
    function getY(ConstantProduct memory constantProduct, uint256 _amount0, uint256 _amount1)  internal pure returns(uint256 amountOut){
        if (_amount0 == 0) {
            amountOut =  (_amount1 * constantProduct.x ) / (constantProduct.y + _amount1);
        } else {
            amountOut = (_amount0 * constantProduct.y ) / (constantProduct.x + _amount0);
        }
    }



    /* @dev calculates x or y from a constant k:
    *
    *       x * y = k
    * x = k / y  - or -  y = k / x
    *
    * @param cp ConstantProductK that represents the curve of the constant product
    * @param x the known value of reserves0
    * @param _amount0 the amount received of token0
    * @param _amount1 the amount received of token1
    * @return amountOut 
    */
    function getY(ConstantProductK memory cp, uint256 x, uint256 _amount0, uint256 _amount1)  internal pure returns(uint256 amountOut){
        uint y = cp.k / x;
        if (_amount0 == 0) {
            amountOut =  (_amount1 * x ) / (y + _amount1);
        } else {
            amountOut = (_amount0 * y ) / (x + _amount0);
        }
    }



    /// ~~~~~~~~~~~~~~ Sample01Struct ~~~~~~~~~~~~~~
    function getY(Sample01Struct memory curve, bool isSwap1For0)  internal pure returns(uint256 amountOut){
        if (isSwap1For0) {
            uint256 deltaYSquareRoot = uint(curve.tracker + int(curve.amountIn )).sqrt();
            uint256 trackerSquareRoot = uint(curve.tracker).sqrt();
            if(deltaYSquareRoot < trackerSquareRoot) 
                revert InsufficientPoolDepth();
            amountOut = (10 ** 9) * (deltaYSquareRoot - trackerSquareRoot); /// check for tracker sign!!
        
        } else {
            uint256 tenMinusTrackerSquare = uint((((10 ** 19)) - curve.tracker) ** 2);
            uint256 tenMinusDeltaSquare = uint(((10 ** 19) - ((curve.tracker + int(curve.amountIn)))) ** 2);
            if(tenMinusTrackerSquare < tenMinusDeltaSquare) 
                revert InsufficientPoolDepth();
            amountOut = (tenMinusTrackerSquare - tenMinusDeltaSquare) / (2 * (10 ** 18));
        }
    }

}
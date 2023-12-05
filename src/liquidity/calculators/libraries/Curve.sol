// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Line, LineInput, ConstantRatio, SigmoidFakeS} from "../dataStructures/CurveDataStructures.sol";
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

    /**
    * @dev calculates ƒ(x) for linear curve. 
    * @notice the original ecuation y = mx + b  is replacing m by m_num/m_den.
    * @param line the Line curve or function *ƒ*
    * @param x the scalar on the abscissa axis to calculate *ƒ(x)*.
    * @return y the value of ƒ(x) on the ordinate axis in ATTOs
    */
    function getY(Line memory line, uint256 x)  internal pure returns(uint256 y){
        unchecked{
            y = ((line.m_num * x * ATTO) / line.m_den) + line.b;
        }
    }
    
    function integral(Line memory line, uint256 x) internal pure returns(uint256 a){
       /// a = (((line.m_num * line.m_num) / (line.m_den * line.m_den)) * (x * x) * ATTO) + (line.b * x);
    }

    /**
    * @dev creates a Line curve from a user's LineInput. This mostly means that m is represented now by m_num/m_den.
    * This is done to have as much precision as possible when calculating *y*
    * @param line the Line in storage that will be built from the input.
    * @param input the LineInput entered by the user to be stored.
    * @param precisionDecimals the amount of precision decimals that the input's slope is formatted on.
    */

    function fromInput(Line storage line, LineInput memory input, uint256 precisionDecimals) internal {

        // if precisionDecimals is even, then we simply save input's m as numerator, and we make the denominator to have as many
        // zeros as *precisionDecimals*
        if (precisionDecimals % 2 == 0) {
            line.m_num = input.m;
            line.m_den = 10 ** precisionDecimals;
        // if precisionDecimals is NOT even, then we make it even by adding one more decimal on both denominator and numerator.
        }else{
            line.m_num = input.m * 10;
            line.m_den = 10 ** (precisionDecimals + 1);
        }

        line.b = input.b;
    }

    /**
    * @dev calculates ƒ(amountIn) for a constant-ratio AMM. 
    * @param cr the values of x and y for the constant ratio.
    * @param amountIn the amount received in exchange for the other token
    * @param isAmountInToken0 boolean indicating if amountIn is token0 (constantRatio.x) or token1 (constantRatio.y)
    * @return amountOut
    */
    function getY(ConstantRatio memory cr, uint256 amountIn, bool isAmountInToken0)  internal pure returns(uint256 amountOut){
        uint256 x = uint256(cr.x);
        uint256 y = uint256(cr.y);
        if(isAmountInToken0){
            unchecked{
                amountOut = (amountIn * ((y * (10 ** 20)) / x)) / (10 ** 20);
            }
        }else{
            unchecked{
                amountOut = (amountIn * ((x * (10 ** 20)) / y)) / (10 ** 20);
            }
        }
    }

    /** 
    *  PLACE HOLDER for sigmoidal
    */
    function getY(SigmoidFakeS memory sigmoid, uint256 x) pure internal returns(uint256 y){
       // y = sigmoid.a * ( ( (sigmoid.a - sigmoid.b) / ((x - sigmoid.b) * (x - sigmoid.b) + sigmoid.c).sqrt() ) + 1);
    }

    /** 
    *  PLACE HOLDER for sigmoidal
    */
    function fromInput(SigmoidFakeS storage sigmoid, LineInput memory input, uint8 precisionDecimals) internal {
        /// body here
    }



}
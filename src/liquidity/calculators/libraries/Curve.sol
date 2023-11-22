// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Line, LineInput, SigmoidFakeS} from "./CurveDataStructures.sol";
import {Math} from "./Math.sol";

/**
 * @title Curve Library
 * @dev This is a library for AMM Bonding Curves to have their functions in a standarized API.
 * @notice This library only contains 2 function which are overloaded to accept different curves. 
 * Every curve should has its own implementation of both getY() function and fromInput() function.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
library Curve{

    using Math for uint256;

    /**
    * @dev calculates f(x) for linear curve. 
    * @notice the original ecuation y = mx + b  is replacing m by m_num/m_den and b by b_num/b_den.
    * The ecuation was then reorganized to keep as much precision as possible while avoiding early overflows.
    * @param line the Line curve or function *f*
    * @param x the scalar on the abscissa axis to calculate *f(x)*.
    * @return y the value of f(x) on the ordinate axis
    */
    function getY(Line memory line, uint256 x) pure internal returns(uint256 y){
        y = x * (((line.b_den * line.m_num ) + (line.b_num * line.m_den) / x) / (line.m_den * line.b_den));
    }

    /**
    * @dev creates a Line curve from a user's LineInput. This mostly means that m is represented now by m_num/m_den,
    * and b is now represented by b_num/b_den. This is done to have as much precision as possible when calculating *y*
    * @param line the Line in storage that will be built from the input.
    * @param input the LineInput entered by the user to be stored.
    * @param precisionDecmls the amount of precision decimals that the input is formatted on.
    */
    function fromInput(Line storage line, LineInput memory input, uint8 precisionDecmls) internal {

        // if precisionDecmls is even, then we simply save input's m as numerator, and we make the denominator to have as many
        // zeros as *precisionDecmls*
        if (precisionDecmls % 2 > 0) {
            line.m_num = input.m;
            line.m_den = 10 ** precisionDecmls;
        // if precisionDecmls is NOT even, then we make it even by adding one more decimal on both denominator and numerator.
        }else{
            line.m_num = input.m * 10;
            line.m_den = 10 ** (precisionDecmls + 1);
        }

        // if y-intersection is less than 1, then we add more zeros to the numerator and denominator to avoid losing precision.
        if(input.b < 1 * 10 ** 18){
            uint256 bAdjust = 18 - input.b.getNumberOfDigits();
            line.b_num = input.b * (2 * 10 ** bAdjust);
            line.b_den = 2 * 10 ** (bAdjust + 18);
        // if not, then we simply store standard values.
        }else{
            line.b_num = input.b;
            line.b_den = 10 ** 18;
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
    function fromInput(SigmoidFakeS storage sigmoid, LineInput memory input, uint8 precisionDecmls) internal {
        /// body here
    }



}
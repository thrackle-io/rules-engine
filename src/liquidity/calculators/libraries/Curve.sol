// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Line, LineInput, SigmoidFakeS} from "./CurveDataStructures.sol";
import {Math} from "./Math.sol";

/**
 * @title Curve Library
 * @dev This is a library for AMM Bonding Curves to have their funcyions in a standarized API.
 * @notice This library only contains 2 function which are overloaded to accept different curves. 
 * Every curve should has its own implementation of both getY() function and fromInput() function.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
library Curve{

    using Math for uint256;

    /**
    * for linear
    */
    function getY(Line memory line, uint256 x) pure internal returns(uint256 y){
        y = x * (((line.b_den * line.m_num ) + (line.b_num * line.m_den) / x) / (line.m_den * line.b_den));
    }

    function fromInput(Line storage line, LineInput memory input, uint8 precisionDecmls) internal {
        // we initialize the slope denominator to be 1 plus as many zeros to the right as *precisionDecmls*.
        line.m_den = 10 ** precisionDecmls;

        // if precisionDecmls is not even, then we make it even by adding one more decimal on both denominator and numerator.
        if (precisionDecmls % 2 > 0) {
            line.m_num = input.m * 10;
            line.m_den *= 10;
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


    /** ########### THIS IS NOT A REAL IMPLEMENTATION. THIS IS JUST AN EXAMPLE FOR FUTURE CURVES YET TO BE IMPLEMENTED ############# 
    * for sigmoidal
    */
    function getY(SigmoidFakeS memory sigmoid, uint256 x) pure internal returns(uint256 y){
       // y = sigmoid.a * ( ( (sigmoid.a - sigmoid.b) / ((x - sigmoid.b) * (x - sigmoid.b) + sigmoid.c).sqrt() ) + 1);
    }

    function fromInput(SigmoidFakeS storage sigmoid, LineInput memory input, uint8 precisionDecmls) internal {
        /// body here
    }



}
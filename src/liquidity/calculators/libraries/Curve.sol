// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Line, LineInput, SigmoidFakeS} from "../dataStructures/CurveDataStructures.sol";
import {Math} from "./Math.sol";

/**
 * @title Curve Library
 * @dev This is a library for AMM Bonding Curves to have their functions in a standarized API.
 * @notice This library only contains 2 function which are overloaded to accept different curves. 
 * Every curve should has its own implementation of both getY() function and fromInput() function.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
library Curve {

    using Math for uint256;

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
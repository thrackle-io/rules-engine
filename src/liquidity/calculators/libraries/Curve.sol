// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {LineS, SigmoidS} from "./CurveStructs.sol";


library Curve{

    int256 constant _E = 2718281828459045000;

    /**
    * for linear
    */
    function getY(LineS calldata line, uint256 x) pure internal returns(uint256 y){
        y = line.m * x + line.b;
    }

    /**
    * for sigmoidal
    */
    function getY(SigmoidS calldata sigmoid, uint256 x) pure internal returns(uint256 y){
        y = sigmoid.a * ( ( (sigmoid.a - sigmoid.b) / (sqrt(x - sigmoid.b) * (x - sigmoid.b) + sigmoid.c) ) + 1);
    }

    /**
     * @dev This function calculates the square root using uniswap style logic
     */
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

}
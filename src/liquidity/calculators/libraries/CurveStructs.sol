// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/** 
* y = mX + b
*/
struct LineS{
    uint256 m;
    uint256 b;
}

/**
* S(x) = a * ( ( (a - b) / ((x - b) ^ 2 + c) ^ 1/2 ) + 1)
*/
struct SigmoidS{
    uint256 a;
    uint256 b;
    uint256 c;
}
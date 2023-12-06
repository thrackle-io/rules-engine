// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title Curve Data Structures
 * @dev This is a collection of data structures that define different curves for TBCs.
 * @notice Every TBC curve must have its definition here.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */


/** 
* @dev Linear curve
* definition: y = m*x + b
*/
struct LineInput{
    uint256 m;
    uint256 b;
}


/** 
* @dev Linear curve expressed in fractions.
* @notice this is how the internal line should be saved since this will allow more precision during mathematical operations.
* definition: y = (m_num/m_den) * x + b
*/ 
struct Line_mF { // if someone can think of a better name, please feel free to change it
    uint256 m_num;
    uint256 m_den;
    uint256 b;
}


/** 
* @dev Linear curve expressed in fractions.
* @notice this is how the internal line should be saved since this will allow more precision during mathematical operations.
* definition: y = (m_num/m_den) * x + b
*/ 
struct Line_mbF{ // if someone can think of a better name,  please feel free to change it
    uint256 m_num;
    uint256 m_den;
    uint256 b_num;
    uint256 b_den;
}


/** 
* @dev Constant Ratio.
*/ 
struct ConstantRatio{
    uint32 x;
    uint32 y;
}


/** 
* @dev Constant Ratio.
*/ 
struct ConstantProduct{
    uint256 x;
    uint256 y;
}

/** 
* @dev 
*/ 
struct Sample01Struct{
    uint256 reserves;
    uint256 amountIn;
}


/** 
* PLACE HOLDER FOR SIGMOIDAL 
* @dev Sigmoidal curve
* definition: S(x) = a*( ( (a - b) / ((x - b) ^ 2 + c) ^ 1/2 ) + 1)
*/
struct SigmoidFakeInput{
    uint256 a;
    uint256 b;
    uint256 c;
}


/** 
* PLACE HOLDER FOR SIGMOIDAL 
* @dev Sigmoidal curve expressed in fractions.
* @notice this is how the internal sigmoid should be saved since this will allow more precision during mathematical operations.
* definition: S(x) = (a_num/a_den)*( ( ((a_num/a_den) - (b_num/b_den)) / ((x - (b_num/b_den)) ^ 2 + (c_num/c_den)) ^ 1/2 ) + 1)
*/ 
struct SigmoidFakeS{
    uint256 a_num;
    uint256 a_den;
    uint256 b_num;
    uint256 b_den;
    uint256 c_num;
    uint256 c_den;
}
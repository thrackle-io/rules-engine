// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {Line, LineS} from "./libraries/Line.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator
 * @notice This contains the calculations for AMM swap. y = mx + b
 * y = token0 amount
 * x = token1 amount
 * m = slope
 * b = y-intercept
 * l = reserve
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolNFTAMMCalcLinear is IProtocolAMMFactoryCalculator {

    using Line for LineS;
    uint256 constant Y_MAX = 100_000 * 10 ** 18;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant M_DIGITS = 8;
    LineS Buy;
    LineS Sell;
    uint256 m_denom;
    uint256 b_num;
    uint256 b_denom;

    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _slope slope = m This is expected as 10e8 to represent decimal slopes. For instance, 800000000 would be a slope of 8, 65 would be a slope of 
     .00000065
     * @param _y_intercept y_intercept = b(expected as 10e18)
     * @param _appManagerAddress appManager address
     */
    constructor(uint256 _slopeBuy, uint256 _slopeSell, uint256 _y_interceptBuy, uint256 _y_interceptSell, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        if(_slopeBuy <= _slopeBuy) revert(); //FIX FOR CUSTOME ERROR
        if(_y_interceptBuy <= _y_interceptSell) revert(); //FIX FOR CUSTOME ERROR
        _setVariables(_slope, _y_intercept);
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev Make adjustments necessary to account for decimal conversions of the entry parameters while keeping the slope and y-intercept ratios the same. Also do adjustments to reduce any precision issues on sqrt matth.
     * @param _m slope = m This is expected as 10e8 to represent decimal slopes. For instance, 800000000 would be a slope of 8, 65 would be a slope of 
     .00000065
     */
    function _calculateSlopeAndInterceptAdjustment(LineS storage _line) private {
        // adjust the m_denom so that it matches the whole number m. This is done because the of the conversion of decimal to a number with 8 digits.(the ratio must stay the same)
        m_denom = 10 ** (M_DIGITS);
        // set m num so that it will be a perfect square by insuring the adjustment is an even number. This reduces precision loss during the sqrt function
        if (M_DIGITS % 2 > 0) {
            m = m * 10;
            m_denom = m_denom * 10;
        }
        // set b num so that it is a whole number but keep the ratio intact
        if (b < 1 * 10 ** 18) {
            uint256 b_adjust = 18 - _numDigits(b);
            b_num = b * (2 * 10 ** b_adjust);
            b_denom = 2 * 10 ** b_adjust;
        } else {
            b_num = b;
            b_denom = 10 ** 18;
        }
    }

    /**
     * @dev calculate the total digits in a number.
     * @param _number number to count digits for
     */
    function _numDigits(uint256 _number) private pure returns (uint8) {
        uint8 digits = 0;
        //if (number < 0) digits = 1; // enable this line if '-' counts as a digit
        while (_number != 0) {
            _number /= 10;
            digits++;
        }
        return digits;
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 being swapped for unknown amount of token1
     * @param _reserve1 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @return _amountOut
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external view override returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 != 0) {
            // swap token0 for token1
            _amount1 = (((3 * _amount0) / 2) + ((m * ((2 * _reserve0 * _amount0) + _amount0 ** 2))) / ((2 * 10 ** 18) * m_denom));
            return _amount1;
        } else {
            // swap token1 for token0
            _amount0 =
                ((2 * (10 ** 9)) * (_amount1 * b_denom) * sqrt(m_denom)) /
                (sqrt(((10 ** 18) * (b_num ** 2) * m_denom) + 2 * _reserve1 * m * (b_denom ** 2)) + sqrt(((10 ** 18) * (b_num ** 2) * m_denom) + 2 * (_reserve1 - _amount1) * m * (b_denom ** 2)));

            return _amount0;
        }
    }

    /**
     * @dev Set the equation variables and perform calculation adjustments
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     */
    function _setLine(LineS storage _line, uint256 _slope,  uint256 _y_intercept) private {
        // y-intercept must be positive and from 0 to 100_000
        if (_y_intercept > Y_MAX  ) revert ValueOutOfRange();
        // slope must be positive and from 0 to 100
        if (_slope > M_MAX ) revert ValueOutOfRange();
        _line.m = _slope;
        _line.b = _y_intercept;
        _calculateSlopeAndInterceptAdjustment(_line);
    }

    /**
     * @dev Set the equation variables
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     */
    function setVariables(uint256 _slope, uint256 _y_intercept) external appAdministratorOnly(appManagerAddress) {
        _setVariables(_slope, _y_intercept);
    }

    /**
     *  @dev get the slope value of the linear ratio
     */
    function getSlope() external view returns (uint256) {
        return m;
    }

    /**
     *  @dev get the y-intercept value of the linear ratio
     */
    function getYIntercept() external view returns (uint256) {
        return b;
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

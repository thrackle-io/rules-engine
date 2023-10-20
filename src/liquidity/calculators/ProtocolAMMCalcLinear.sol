// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";

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
contract ProtocolAMMCalcLinear is IProtocolAMMFactoryCalculator {
    uint256 m;
    uint256 b;
    uint256 l;
    uint256 constant mDigits = 8;
    uint256 mAdjust;
    event Log(string _type, uint256 _value);

    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _slope slope = m This is expected as 10e8 to represent decimal slopes. For instance, 800000000 would be a slope of 8, 65 would be a slope of 
     .00000065
     * @param _y_intercept y_intercept = b(expected as 10e18)
     * @param _range range = l(expected as 10e18)
     * @param _appManagerAddress appManager address
     */
    constructor(uint256 _slope, uint256 _y_intercept, uint256 _range, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        _setVariables(_slope, _y_intercept, _range);
        appManagerAddress = _appManagerAddress;
    }

    function _calculateSlopeAdjustment(uint256 _m) private {
        mAdjust = 10 ** (4 + _numDigits(_m));
    }

    function _numDigits(uint256 number) private returns (uint8) {
        uint8 digits = 0;
        //if (number < 0) digits = 1; // enable this line if '-' counts as a digit
        while (number != 0) {
            number /= 10;
            digits++;
        }
        emit Log("digits", digits);
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
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external override returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 != 0) {
            //emit Log("m * (l - _reserve0)", m * (l - _reserve0));
            // emit Log("(m * _amount0 ** 2) / 2)", (m * _amount0 ** 2) / 2);
            // emit Log(" ((m / 2) * _amount0 ** 2)", ((m / 2) * _amount0 ** 2));
            // emit Log("m * (l - _reserve0) + mAdjust * b * _amount0 ", m * (l - _reserve0) + mAdjust * b * _amount0);
            // emit Log("mAdjust * b * _amount0 ", mAdjust * b * _amount0);
            // _amount1 = (((m * (l - _reserve0)) - b) * _amount0 - ((m * (_amount0 ** 2)) / 2));
            // _amount1 = m * (l - _reserve0) + _mAdjust * b * _amount0 - ((m / 2) * _amount0 ** 2);
            _amount1 = (m * (l - _reserve0) + mAdjust * b * _amount0 - (m * _amount0 ** 2) / 2) / (10 ** 18 * mAdjust);
            return _amount1;
        } else {
            emit Log("(((2 * 10 ** 18) * _reserve1) / (m * mAdjust)))", (((2 * 10 ** 18) * _reserve1) / (m * mAdjust)));

            // emit Log("l", l);
            // emit Log("_reserve0", _reserve0);
            // 1st half
            uint256 _a = (((10 ** 4) * (mAdjust ** 2) * (b ** 2)) + (2 * mAdjust * m * (10 ** 22) * (_reserve1 + _amount1)));
            emit Log("_a", _a);
            emit Log("sqrt _a", sqrt(_a));
            uint256 _b = (((10 ** 4) * (mAdjust ** 2) * (b ** 2)) + (2 * mAdjust * m * (10 ** 22) * _reserve1));
            emit Log("_b", _b);
            emit Log("sqrt _b", sqrt(_b));
            _amount0 = (sqrt(_a) - sqrt(_b)) / (10 ** 2 * m);

            return _amount0;
        }
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 being swapped for unknown amount of token1
     * @param _reserve1 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @return _amountOut
     */
    function calculateSwapBU(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 != 0) {
            //emit Log("m * (l - _reserve0)", m * (l - _reserve0));
            // emit Log("(m * _amount0 ** 2) / 2)", (m * _amount0 ** 2) / 2);
            // emit Log(" ((m / 2) * _amount0 ** 2)", ((m / 2) * _amount0 ** 2));
            // emit Log("m * (l - _reserve0) + mAdjust * b * _amount0 ", m * (l - _reserve0) + mAdjust * b * _amount0);
            // emit Log("mAdjust * b * _amount0 ", mAdjust * b * _amount0);
            // _amount1 = (((m * (l - _reserve0)) - b) * _amount0 - ((m * (_amount0 ** 2)) / 2));
            // _amount1 = m * (l - _reserve0) + _mAdjust * b * _amount0 - ((m / 2) * _amount0 ** 2);
            _amount1 = (m * (l - _reserve0) + mAdjust * b * _amount0 - (m * _amount0 ** 2) / 2) / (10 ** 18 * mAdjust);
            return _amount1;
        } else {
            emit Log("(((2 * 10 ** 18) * _reserve1) / (m * mAdjust)))", (((2 * 10 ** 18) * _reserve1) / (m * mAdjust)));

            // emit Log("l", l);
            // emit Log("_reserve0", _reserve0);
            // 1st half
            uint256 _a = ((b ** 2) / (m ** 2)) + ((((2 * 10 ** 18) * (_reserve1 + _amount1))) / (m * mAdjust));
            emit Log("_a", _a);
            emit Log("sqrt _a", sqrt(_a));
            uint256 _b = (((b ** 2) / (m ** 2)) + (((2 * 10 ** 18) * _reserve1) / (m * mAdjust)));
            emit Log("_b", _b);
            emit Log("sqrt _b", sqrt(_b));
            _amount0 = mAdjust * (sqrt(_a) - sqrt(_b));

            return _amount0;
        }
    }

    /**
     * @dev Set the equation variables
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     * @param _range range = l
     */
    function _setVariables(uint256 _slope, uint256 _y_intercept, uint256 _range) private {
        m = _slope;
        b = _y_intercept;
        l = _range;
        _calculateSlopeAdjustment(m);
    }

    /**
     * @dev Set the equation variables
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     * @param _range range = l
     */
    function setVariables(uint256 _slope, uint256 _y_intercept, uint256 _range) external appAdministratorOnly(appManagerAddress) {
        _setVariables(_slope, _y_intercept, _range);
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

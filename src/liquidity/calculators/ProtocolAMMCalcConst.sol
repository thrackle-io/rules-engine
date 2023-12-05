// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";

/**
 * @title Automated Market Maker Swap Constant Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example constant that uses ratio x/y. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcConst is IProtocolAMMFactoryCalculator {
    uint256 x;
    uint256 y;

    /**
     * @dev Set up the ratio and appManager for permissions
     * @param _x ratio value representing token0
     * @param _y ratio value representing token1
     * @param _appManagerAddress appManager address
     */
    constructor(uint256 _x, uint256 _y, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        _setRatio(_x, _y);
        appManagerAddress = _appManagerAddress;
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
        _reserve0;
        _reserve1;
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 == 0) {
            return (_amount1 * ((x * (10 ** 20)) / y)) / (10 ** 20);
        } else {
            return (_amount0 * ((y * (10 ** 20)) / x)) / (10 ** 20);
        }
    }

    /**
     * @dev Set the ratio
     * @param _x ratio value representing token0
     * @param _y ratio value representing token1
     */
    function _setRatio(uint256 _x, uint256 _y) private {
        // neither can be 0
        if (_x == 0 || _y == 0) revert AmountsAreZero();
        // ratio numbers must be limited to allow for larger swaps without over/under flow. max uint32 is the limit
        if (_x > type(uint32).max || _x > type(uint32).max) revert OutOfRange();
        x = _x;
        y = _y;
    }

    /**
     * @dev Set the ratio
     * @param _x ratio value representing token0
     * @param _y ratio value representing token1
     */
    function setRatio(uint256 _x, uint256 _y) external appAdministratorOnly(appManagerAddress) {
        _setRatio(_x, _y);
    }

    /**
     *  @dev get the x value of the linear ratio
     */
    function getX() external view returns (uint256) {
        return x;
    }

    /**
     *  @dev get the y value of the linear ratio
     */
    function getY() external view returns (uint256) {
        return y;
    }
}

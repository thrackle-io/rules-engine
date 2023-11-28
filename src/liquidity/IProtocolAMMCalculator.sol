// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {AMMCalculatorErrors, IZeroAddressError} from "../interfaces/IErrors.sol";

/**
 * @title Automated Market Maker Swap Calculator Interface
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
interface IProtocolAMMCalculator is AMMCalculatorErrors, IZeroAddressError {
    /**
     * @dev This performs the swap from token0 to token1
     * @param _reserve0 total amount of token0 in reserve
     * @param _reserve1 total amount of token1 in reserve
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return _amountOut amount of alternate coming out of the pool
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external returns (uint256 _amountOut);
}

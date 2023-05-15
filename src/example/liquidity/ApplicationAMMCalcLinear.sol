// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../liquidity/IProtocolAMMCalculator.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. 1 for 1
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMCalcLinear is IProtocolAMMCalculator {
    error AmountsAreZero();

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 being swapped for unknown amount of token1
     * @param _reserve1 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @param _amount0 amount of token1 coming out of the pool
     * @return _amountOut
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external pure returns (uint256) {
        _reserve0;
        _reserve1;
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 != 0) {
            return _amount0;
        } else {
            return _amount1;
        }
    }
}

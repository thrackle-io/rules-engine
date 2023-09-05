// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../liquidity/IProtocolAMMCalculator.sol";

/**
 * @title Automated Market Maker Swap Constant Product Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolAMM. The intention is to be able to change the calculations
 *      as needed. It contains an example Constant Product xy = k
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMCalcCP is IProtocolAMMCalculator {
    

    /**
     * @dev This performs the swap from token0 to token1.
     *      Based on (x + a) * (y - b) = x * y
     *      This is sometimes simplified as xy = k
     *      x = _reserve0
     *      y = _reserve1
     *      a = _amount0
     *      b = _amount1
     *      k = _reserve0 * _reserve1
     *
     * @param _reserve0 total amount of token0 in reserve
     * @param _reserve1 total amount of token1 in reserve
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return _amountOut amount of alternate coming out of the pool
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external pure returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) {
            revert AmountsAreZero();
        }
        if (_amount0 == 0) {
            return (_amount1 * _reserve0) / (_reserve1 + _amount1);
        } else {
            return (_amount0 * _reserve1) / (_reserve0 + _amount0);
        }
    }
}

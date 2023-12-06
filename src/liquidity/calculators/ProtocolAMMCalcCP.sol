// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {ConstantProduct, Curve} from "./libraries/Curve.sol";


/**
 * @title Automated Market Maker Swap Constant Product Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example Constant Product xy = k. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcCP is IProtocolAMMFactoryCalculator {
    using Curve for ConstantProduct;
    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _appManagerAddress appManager address
     */
    constructor(address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This performs the swap from token0 to token1.
     * @param _reserve0 total amount of token0 in reserve
     * @param _reserve1 total amount of token1 in reserve
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return _amountOut amount of alternate coming out of the pool
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external pure override returns (uint256) {
        return simulateSwap(_reserve0, _reserve1, _amount0, _amount1);
    }

    /**
     * @dev This performs the swap from token0 to token1.
     * @param _reserve0 total amount of token0 in reserve
     * @param _reserve1 total amount of token1 in reserve
     * @param _amount0 amount coming to the pool of token0
     * @param _amount1 amount coming to the pool of token1
     * @return price
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) public pure override returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) 
            revert AmountsAreZero();
        ConstantProduct memory cp = ConstantProduct(_reserve0, _reserve1);
        return cp.getY(_amount0, _amount1);
    }
}

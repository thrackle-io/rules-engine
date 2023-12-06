// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {Line_mbF, LineInput, Curve} from "./libraries/Curve.sol";
import {CurveErrors} from "../../interfaces/IErrors.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator
 * @notice This contains the calculations for AMM swap. y = mx + b
 * y = token0 amount
 * x = token1 amount
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcLinear is IProtocolAMMFactoryCalculator {

    using Curve for Line;

    uint256 constant Y_MAX = 100_000 * 10 ** 18;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 18;
    Line_mbF public curve;

    /**
     * @dev Set up the calculator and appManager for permissions
    * @param _curve the definition of the linear ecuation
     * @param _appManagerAddress appManager address
     */
    constructor(LineInput memory _curve, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        _setCurve(_curve);
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
        return simulateSwap( _reserve0, _reserve1, _amount0, _amount1);  
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 not used in this case.
     * @param _reserve1 not used in this case.
     * @param _amountERC20 amount of ERC20 coming out of the pool
     * @param _amountNFT amount of NFTs coming out of the pool (restricted to 1 for now)
     * @return price
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amountERC20, uint256 _amountNFT) public view override returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) 
            revert AmountsAreZero();
        return curve.getY(_amount0, _amount1);
    }

    /**
     * @dev Set the equation variables
    * @param _curve the definition of the linear ecuation
     */
    function setCurve(LineInput memory _curve) external appAdministratorOnly(appManagerAddress) {
        _setCurve(_curve);
    }

    /**
     * @dev Set the equation variables
     * @param _curve the definition of the linear ecuation
     */
    function _setCurve(LineInput memory _curve) internal {
        _validateSingleCurve(_slope, _y_intercept);
        curve.fromInput(_curve, M_PRECISION_DECIMALS, B_PRECISION_DECIMALS);
    }

    /**
    * @dev validates that the definition of a curve is within the safe mathematical limits
    * @param _curve the definition of the curve
    */
    function _validateSingleCurve(LineInput memory _curve) internal pure {
        if (_curve.m > M_MAX) revert ValueOutOfRange(_curve.m);
        if (_curve.b > Y_MAX) revert ValueOutOfRange(_curve.b);
    }

}

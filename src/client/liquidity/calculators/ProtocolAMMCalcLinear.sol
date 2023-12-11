// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {LinearFractionB, LinearInput, Curve} from "./libraries/Curve.sol";
import {CurveErrors} from "src/common/IErrors.sol";
import {IAMMCalculatorEvents} from "src/common//IEvents.sol";

/**
 * @title Automated Market Maker Swap Linear Calculator
 * @notice This contains the calculations for AMM swap. y = mx + b
 * y = token0 amount
 * x = token1 amount
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example linear. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcLinear is IProtocolAMMFactoryCalculator, IAMMCalculatorEvents {

    using Curve for LinearFractionB;

    uint256 constant Y_MAX = 100_000 * 10 ** 18;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant M_PRECISION_DECIMALS = 8;
    uint8 constant B_PRECISION_DECIMALS = 18;
    LinearFractionB public curve;

    /**
     * @dev Set up the calculator and appManager for permissions
    * @param _curve the definition of the linear ecuation
     * @param _appManagerAddress appManager address
     */
    constructor(LinearInput memory _curve, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        _setCurve(_curve);
        appManagerAddress = _appManagerAddress;
        emit AMMCalculatorDeployed(); 
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token1 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return _amountOut
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external view override returns (uint256) {
        return simulateSwap( _reserve0, _reserve1, _amount0, _amount1);  
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token1 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return price
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) public view override returns (uint256) {
        if (_amount0 == 0 && _amount1 == 0) 
            revert AmountsAreZero();
        return curve.getY(_reserve0, _reserve1, _amount0, _amount1);
    }

    /**
     * @dev Set the equation variables
    * @param _curve the definition of the linear ecuation
     */
    function setCurve(LinearInput memory _curve) external appAdministratorOnly(appManagerAddress) {
        _setCurve(_curve);
    }

    /**
     * @dev Set the equation variables
     * @param _curve the definition of the linear ecuation
     */
    function _setCurve(LinearInput memory _curve) internal {
        _validateSingleCurve(_curve);
        curve.fromInput(_curve, M_PRECISION_DECIMALS, B_PRECISION_DECIMALS);
    }

    /**
    * @dev validates that the definition of a curve is within the safe mathematical limits
    * @param _curve the definition of the curve
    */
    function _validateSingleCurve(LinearInput memory _curve) internal pure {
        if (_curve.m > M_MAX) revert ValueOutOfRange(_curve.m);
        if (_curve.b > Y_MAX) revert ValueOutOfRange(_curve.b);
    }

}

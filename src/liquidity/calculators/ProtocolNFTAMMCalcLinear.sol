// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {Line, LineInput, Curve} from "./libraries/Curve.sol";
import {CurveErrors} from "../../interfaces/IErrors.sol";

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
contract ProtocolNFTAMMCalcLinear is IProtocolAMMFactoryCalculator, CurveErrors {

    using Curve for Line;

    uint256 constant Y_MAX = 100_000 * 10 ** 18;
    uint256 constant M_MAX = 100 * 10 ** 8;
    uint8 constant PRECISION_DECIMALS = 8;
    Line public buyCurve;
    Line public sellCurve;

    constructor(
            LineInput memory _buyCurve, 
            LineInput memory _sellCurve, 
            address _appManagerAddress
        ) {
            // validation block
            if (_appManagerAddress == address(0)) revert ZeroAddress();
            _validateSingleCurve(_buyCurve);
            _validateSingleCurve(_sellCurve);
            _validateCurvePair(_buyCurve, _sellCurve);

            // setting variables
            buyCurve.fromInput(_buyCurve, PRECISION_DECIMALS);
            sellCurve.fromInput(_sellCurve, PRECISION_DECIMALS);
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
        // if (_amount0 == 0 && _amount1 == 0) {
        //     revert AmountsAreZero();
        // }
        // if (_amount0 != 0) {
        //     // swap token0 for token1
        //     _amount1 = (((3 * _amount0) / 2) + ((m * ((2 * _reserve0 * _amount0) + _amount0 ** 2))) / ((2 * 10 ** 18) * m_denom));
        //     return _amount1;
        // } else {
        //     // swap token1 for token0
        //     _amount0 =
        //         ((2 * (10 ** 9)) * (_amount1 * b_denom) * sqrt(m_denom)) /
        //         (sqrt(((10 ** 18) * (b_num ** 2) * m_denom) + 2 * _reserve1 * m * (b_denom ** 2)) + sqrt(((10 ** 18) * (b_num ** 2) * m_denom) + 2 * (_reserve1 - _amount1) * m * (b_denom ** 2)));

        //     return _amount0;
        // }
    }

    function setBuyCurve(LineInput memory _buyCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_buyCurve);
        _validateCurvePair(_buyCurve, sellCurve);
        buyCurve.fromInput(_buyCurve, PRECISION_DECIMALS);
    }

    function setSellCurve(LineInput memory _sellCurve) external appAdministratorOnly(appManagerAddress){
        _validateSingleCurve(_sellCurve);
        _validateCurvePair(buyCurve, _sellCurve);
        sellCurve.fromInput(_sellCurve, PRECISION_DECIMALS);
    }

    /// #### Validation Functions ####
    function _validateSingleCurve(LineInput memory curve) internal pure {
        if (curve.m > M_MAX) revert ValueOutOfRange(curve.m);
        if (curve.b > Y_MAX) revert ValueOutOfRange(curve.b);
    }

     function _validateCurvePair(LineInput memory _buyCurve, LineInput memory _sellCurve) internal pure {
        if(_buyCurve.m <= _sellCurve.m) revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b <= _sellCurve.b) revert CurvesInvertedOrIntersecting(); 
    }

    function _validateCurvePair(LineInput memory _buyCurve, Line memory _sellCurve) internal pure {
        if(_buyCurve.m * (_sellCurve.m_den / PRECISION_DECIMALS) <= _sellCurve.m_num) revert CurvesInvertedOrIntersecting(); 
        if( _buyCurve.b * ( _sellCurve.b_den / 10 ** 18)  <= _sellCurve.b_num) revert CurvesInvertedOrIntersecting(); 
    }

    function _validateCurvePair(Line memory _buyCurve, LineInput memory _sellCurve) internal pure {
        if(_buyCurve.m_num <= _sellCurve.m * (_buyCurve.m_den / PRECISION_DECIMALS))  revert CurvesInvertedOrIntersecting(); 
        if(_buyCurve.b_num <= _sellCurve.b * ( _buyCurve.b_den / 10 ** 18)) revert CurvesInvertedOrIntersecting(); 
    }

  
}

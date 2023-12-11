// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {ConstantRatio, Curve} from "./libraries/Curve.sol";
import {IAMMCalculatorEvents} from "src/common/IEvents.sol";

/**
 * @title Automated Market Maker Swap Constant Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example constant that uses ratio x/y. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcConst is IProtocolAMMFactoryCalculator, IAMMCalculatorEvents {
    ConstantRatio public constRatio;
    using Curve for ConstantRatio;

    /**
     * @dev Set up the ratio and appManager for permissions
     * @param _constRatio the values of x and y for the constant ratio
     * @param _appManagerAddress appManager address
     * @notice x represents token0 and y represents token1
     */
    constructor(ConstantRatio memory _constRatio, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        _setRatio(_constRatio);
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
        return simulateSwap(_reserve0, _reserve1, _amount0, _amount1);
    }

    /**
     * @dev This performs the swap from token0 to token1. It is a linear calculation.
     * @param _reserve0 amount of token0 in the pool
     * @param _reserve1 amount of token1 in the pool
     * @param _amount0 amount of token0 coming to the pool
     * @param _amount1 amount of token1 coming to the pool
     * @return _amountOut
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) public view override returns (uint256) {
        _reserve0;
        _reserve1;
        if (_amount0 == 0 && _amount1 == 0) 
            revert AmountsAreZero();
        return constRatio.getY(_amount0, _amount1);

    }

    /**
     * @dev Sets the ratio
     * @param _constRatio the values of x and y for the constant ratio
     * @notice x represents token0 and y represents token1
     */
    function setRatio(ConstantRatio memory _constRatio) external appAdministratorOnly(appManagerAddress)  {
        _setRatio(_constRatio);
    }

    /**
     * @dev Sets the ratio
     * @param _constRatio the values of x and y for the constant ratio
     * @notice x represents token0 and y represents token1
     */
    function _setRatio(ConstantRatio memory _constRatio) internal  {
        // neither can be 0
        if (_constRatio.x == 0 || _constRatio.y == 0) revert AmountsAreZero();
        constRatio.x = _constRatio.x;
        constRatio.y = _constRatio.y;
    }
}

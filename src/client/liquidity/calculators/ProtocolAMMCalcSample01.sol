// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./IProtocolAMMFactoryCalculator.sol";
import {Sample01Struct, Curve, AMMMath} from "./libraries/Curve.sol";

/**
 * @title Automated Market Maker Swap Constant Calculator
 * @notice This contains the calculations for AMM swap.
 * @dev This is external and used by the ProtocolERC20AMM. The intention is to be able to change the calculations
 *      as needed. It contains an example constant that uses ratio x/y. It is built through ProtocolAMMCalculationFactory
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalcSample01 is IProtocolAMMFactoryCalculator {
    using Curve for Sample01Struct;
    using AMMMath for uint256;
    int256 f_tracker;
    int256 g_tracker;

    /**
     * @dev Set up the calculator and appManager for permissions
     * @param _f_tracker f(x) tracker value
     * @param _g_tracker f(x) tracker value
     * @param _appManagerAddress appManager address
     */
    constructor(int256 _f_tracker, int256 _g_tracker, address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        f_tracker = _f_tracker;
        g_tracker = _g_tracker;
        appManagerAddress = _appManagerAddress;
    }


    /**
     * @dev This is the overall swap function. It branches to the necessary swap subfunction
     *      x = _reserve0
     *      y = _reserve1
     *      a = _amount0
     *      b = _amount1
     *      k = _reserve0 * _reserve1
     *
     * @param _reserve0 not used in this case
     * @param _reserve1 not used in this case
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return amountOut amount of alternate coming out of the pool
     */
    function calculateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) external override returns (uint256 amountOut) {
        amountOut = simulateSwap(_reserve0, _reserve1, _amount0, _amount1);
        if (_amount0 == 0) {
            // increment the tracker
            g_tracker += int(_amount1);
            // set the inverse tracker
            f_tracker = (10 ** 19) - ((10 ** 9) * int256(uint(g_tracker).sqrt()));
        } else {
            // increment the tracker
            f_tracker += int(_amount0);
            // set the inverse tracker
            g_tracker = (((10 ** 19) - (f_tracker)) ** 2) / (10 ** 18);
        }
    }

    /**
     * @dev This performs the swap from ERC20s to NFTs. It is a linear calculation.
     * @param _reserve0 not used in this case
     * @param _reserve1 not used in this case
     * @param _amount0 amount of token0 possibly coming into the pool
     * @param _amount1 amount of token1 possibly coming into the pool
     * @return amountOut
     */
    function simulateSwap(uint256 _reserve0, uint256 _reserve1, uint256 _amount0, uint256 _amount1) public view override returns (uint256 amountOut) {
        _reserve0;
        _reserve1;
        if (_amount0 == 0 && _amount1 == 0)  
            revert AmountsAreZero();

        if (_amount0 == 0) {
            Sample01Struct memory curve = Sample01Struct(_amount1, g_tracker);
            amountOut = curve.getY(true);
        } else {
            Sample01Struct memory curve = Sample01Struct(_amount0, f_tracker);
            amountOut = curve.getY(false);
        }
    }


    /**
     * set the F Tracker value
     * @param _f_tracker f(x) tracker value
     */
    function setFTracker(int256 _f_tracker) external appAdministratorOnly(appManagerAddress){
        f_tracker = _f_tracker;
    }

    /**
     * @dev Retrieve the F Tracker value
     * @return f_tracker
     */
    function getFTracker() external view returns(int256){
        return f_tracker;
    }

    /**
     * set the G Tracker value
     * @param _g_tracker f(x) tracker value
     */
    function setGTracker(int256 _g_tracker) external appAdministratorOnly(appManagerAddress){
        g_tracker = _g_tracker;
    }

    /**
     * @dev Retrieve the G Tracker value
     * @return g_tracker
     */
    function getGTracker() external view returns(int256){
        return g_tracker;
    }

}
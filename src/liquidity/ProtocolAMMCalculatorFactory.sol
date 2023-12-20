// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolNFTAMMCalcDualLinear.sol";
import "src/liquidity/calculators/ProtocolAMMCalcSample01.sol";
import "./calculators/ProtocolAMMCalcMulCurves.sol";
import "src/economic/AppAdministratorOnly.sol";
import {LinearInput, ConstantRatio} from "./calculators/dataStructures/CurveDataStructures.sol";
import {IZeroAddressError} from "src/interfaces/IErrors.sol";
import {IAMMFactoryEvents} from "src/interfaces/IEvents.sol";

/**
 * @title Automated Market Maker Calculator Factory
 * @notice This is a factory responsible for creating Protocol AMM calculators: Constant, Linear, Sigmoid
 * @dev This will allow any application to create and attach a calculation module to a specific AMM.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalculatorFactory is AppAdministratorOnly, IZeroAddressError, IAMMFactoryEvents {
    address appManagerAddress;

    constructor() {
        emit AMMCalculatorFactoryDeployed(address(this));
    }

    /**
     * @dev This creates a linear calculation module.
     * @param curve the definition of the curve's equation
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createLinear(LinearInput memory curve, address _appManagerAddress) external returns (address) {
        ProtocolAMMCalcLinear protocolAMMCalcLinear = new ProtocolAMMCalcLinear(curve, _appManagerAddress);
        return address(protocolAMMCalcLinear);
    }

    /**
     * @dev This creates a linear calculation module.
     * @notice a LinearInput has the shape {uint256 m; uint256 b}
     *    *m* is the slope of the line expressed with 8 decimals of precision. Input of 100000001 means -> 1.00000001
     *    *b* is the intersection of the line with the ordinate axis expressed in atto (18 decimals of precision). 1 ^ 10 ** 18 means -> 1
     * @param buyCurve the definition of the buyCurve
     * @param sellCurve the definition of the sellCurve
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createDualLinearNFT(LinearInput memory buyCurve, LinearInput memory sellCurve, address _appManagerAddress) external returns (address) {
        // LinearInput memory buyCurve = LinearInput(_buySlope, _buy_y_intercept);
        // LinearInput memory sellCurve = LinearInput(_sellSlope, _sell_y_intercept);
        ProtocolNFTAMMCalcDualLinear protocolAMMCalcLinear = new ProtocolNFTAMMCalcDualLinear(buyCurve, sellCurve, _appManagerAddress);
        return address(protocolAMMCalcLinear);
    }

    /**
     * @dev This creates a linear calculation module.
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantProduct(address _appManagerAddress) external returns (address) {
        ProtocolAMMCalcCP protocolAMMCalcCP = new ProtocolAMMCalcCP(_appManagerAddress);
        return address(protocolAMMCalcCP);
    }

    /**
     * @dev This creates a constant calculation module.
     * @param _constRatio the values of x and y for the constant ratio
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstant(ConstantRatio memory _constRatio, address _appManagerAddress) external returns (address) {
        ProtocolAMMCalcConst protocolAMMCalcConst = new ProtocolAMMCalcConst(_constRatio, _appManagerAddress);
        return address(protocolAMMCalcConst);
    }

    /**
     * @dev This creates a sample 1 calculation module.
     * @param _f_tracker f(x) tracker value
     * @param _g_tracker g(x) tracker value
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createSample01(int256 _f_tracker, int256 _g_tracker, address _appManagerAddress) external returns (address) {
        ProtocolAMMCalcSample01 protocolAMMCalcSample01 = new ProtocolAMMCalcSample01(_f_tracker, _g_tracker, _appManagerAddress);
        return address(protocolAMMCalcSample01);
    }

    /**
     * @dev This creates a concentrated liquidity with multiple curves calculator.
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConcLiqMulCurves(address _appManagerAddress) external returns(address){
        ProtocolAMMCalcMulCurves protocolAMMCalcConcLiqMulCurves = new ProtocolAMMCalcMulCurves(0, _appManagerAddress);
        return address(protocolAMMCalcConcLiqMulCurves);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/liquidity/calculators/ProtocolAMMCalcLinear.sol";
import "src/liquidity/calculators/ProtocolAMMCalcConst.sol";
import "src/liquidity/calculators/ProtocolAMMCalcCP.sol";
import "src/liquidity/calculators/ProtocolAMMCalcSigmoid.sol";
import "src/economic/AppAdministratorOnly.sol";
import {IZeroAddressError} from "src/interfaces/IErrors.sol";

/**
 * @title Automated Market Maker Calculator Factory
 * @notice This is a factory responsible for creating Protocol AMM calculators: Constant, Linear, Sigmoid
 * @dev This will allow any application to create and attach a calculation module to a specific AMM.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMCalculatorFactory is AppAdministratorOnly, IZeroAddressError {
    address appManagerAddress;

    constructor(address _appManagerAddress) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev This creates a linear calculation module.
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     * @param _range range = l
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createLinear(uint256 _slope, uint256 _y_intercept, uint256 _range, address _appManagerAddress) external appAdministratorOnly(appManagerAddress) returns (address) {
        ProtocolAMMCalcLinear protocolAMMCalcLinear = new ProtocolAMMCalcLinear(_slope, _y_intercept, _range, _appManagerAddress);
        return address(protocolAMMCalcLinear);
    }

    /**
     * @dev This creates a sigmoid calculation module.
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createSigmoid(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) returns (address) {
        ProtocolAMMCalcSigmoid protocolAMMCalcSigmoid = new ProtocolAMMCalcSigmoid(_appManagerAddress);
        return address(protocolAMMCalcSigmoid);
    }

    /**
     * @dev This creates a linear calculation module.
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantProduct(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) returns (address) {
        ProtocolAMMCalcCP protocolAMMCalcCP = new ProtocolAMMCalcCP(_appManagerAddress);
        return address(protocolAMMCalcCP);
    }

    /**
     * @dev This creates a constant calculation module.
     * @param _x x value of the ratio
     * @param _y y value of the ration
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstant(uint256 _x, uint256 _y, address _appManagerAddress) external appAdministratorOnly(appManagerAddress) returns (address) {
        ProtocolAMMCalcConst protocolAMMCalcConst = new ProtocolAMMCalcConst(_x, _y, _appManagerAddress);
        return address(protocolAMMCalcConst);
    }
}

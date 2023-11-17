// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/liquidity/ProtocolAMMCalculatorFactory.sol";
import "src/liquidity/ProtocolAMM.sol";
import "src/economic/AppAdministratorOnly.sol";
import {IZeroAddressError} from "src/interfaces/IErrors.sol";
import {IAMMFactoryEvents} from "src/interfaces/IEvents.sol";

/**
 * @title Automated Market Maker Factory
 * @notice This is a factory responsible for creating Protocol AMM
 * @dev This will allow any application to create a specific AMM.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ProtocolAMMFactory is AppAdministratorOnly, IZeroAddressError, IAMMFactoryEvents {
    ProtocolAMMCalculatorFactory protocolAMMCalculatorFactory;

    constructor(address _protocolAMMCalculatorFactory) {
        if (_protocolAMMCalculatorFactory == address(0)) revert ZeroAddress();
        protocolAMMCalculatorFactory = ProtocolAMMCalculatorFactory(_protocolAMMCalculatorFactory);
        emit AMMFactoryDeployed(address(this));
    }
    /**
     * @dev Create an AMM. Must provide the addresses for both tokens that will provide liquidity
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _appManagerAddress valid address of the corresponding app manager
     * @param _calculatorAddress valid address of the corresponding calculator for the AMM
     */
    function createAMM(address _token0, address _token1, address _appManagerAddress, address _calculatorAddress) public returns (address){
        if (_token0 == address(0) || _token1 == address(0) || _appManagerAddress == address(0) || _calculatorAddress == address(0)) revert ZeroAddress();
        
        return address(new ProtocolAMM(_token0, _token1, _appManagerAddress, _calculatorAddress));
    }

    /**
     * @dev This creates a linear AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _slope slope = m
     * @param _y_intercept y_intercept = b
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createLinearAMM(address _token0, address _token1, uint256 _slope, uint256 _y_intercept, address _appManagerAddress) external returns (address) {
        return address(createAMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createLinear(_slope, _y_intercept, _appManagerAddress))));
    }

    /**
     * @dev This creates a linear AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantProductAMM(address _token0, address _token1, address _appManagerAddress) external returns (address){
        return address(createAMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createConstantProduct(_appManagerAddress))));
    }

    /**
     * @dev This creates a constant AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _x x value of the ratio
     * @param _y y value of the ratio
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantAMM(address _token0, address _token1, uint256 _x, uint256 _y, address _appManagerAddress) external returns (address) {
        return address(createAMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createConstant(_x, _y, _appManagerAddress))));
    }

    /**
     * @dev This creates a sample01 AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _f_tracker f(x) tracker value
     * @param _g_tracker g(x) tracker value
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createSample01AMM(address _token0, address _token1, int256 _f_tracker, int256 _g_tracker, address _appManagerAddress) external returns (address) {
        return address(createAMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createSample01(_f_tracker, _g_tracker, _appManagerAddress))));
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/liquidity/ProtocolAMMCalculatorFactory.sol";
import "src/liquidity/ProtocolERC20AMM.sol";
import "src/liquidity/ProtocolERC721AMM.sol";
import "src/economic/AppAdministratorOnly.sol";
import {IZeroAddressError} from "src/interfaces/IErrors.sol";
import {IAMMFactoryEvents} from "src/interfaces/IEvents.sol";
import {LineInput, ConstantRatio} from "./calculators/dataStructures/CurveDataStructures.sol";

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
    function createERC20AMM(address _token0, address _token1, address _appManagerAddress, address _calculatorAddress) public returns (address){
        if (_token0 == address(0) || _token1 == address(0) || _appManagerAddress == address(0) || _calculatorAddress == address(0)) revert ZeroAddress();
        
        return address(new ProtocolERC20AMM(_token0, _token1, _appManagerAddress, _calculatorAddress));
    }

    /**
     * @dev Create an AMM. Must provide the addresses for both tokens that will provide liquidity
     * @param _ERC20Token valid ERC20 address
     * @param _ERC721Token valid ERC721 address
     * @param _appManagerAddress valid address of the corresponding app manager
     * @param _calculatorAddress valid address of the corresponding calculator for the AMM
     */
    function createERC721AMM(address _ERC20Token, address _ERC721Token, address _appManagerAddress, address _calculatorAddress) public returns (address){
        if (_ERC20Token == address(0) || _ERC721Token == address(0) || _appManagerAddress == address(0) || _calculatorAddress == address(0)) revert ZeroAddress();
        
        return address(new ProtocolERC721AMM(_ERC20Token, _ERC721Token, _appManagerAddress, _calculatorAddress));
    }

    /**
     * @dev This creates a linear AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param curve LineInput for the linear curve equation
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createLinearAMM(address _token0, address _token1, LineInput memory curve, address _appManagerAddress) external returns (address) {
        return address(createERC20AMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createLinear(curve, _appManagerAddress))));
    }

    /**
     * @dev This creates a linear AMM and calculation module.
     * @param _ERC20Token valid ERC20 address
     * @param _ERC721Token valid ERC721 address
     * @param buyCurve LineInput for buy curve
     * @param sellCurve LineInput for sell curve
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createDualLinearERC721AMM(address _ERC20Token, address _ERC721Token, LineInput memory buyCurve, LineInput memory sellCurve, address _appManagerAddress) external returns (address) {
        return address(createERC721AMM(_ERC20Token, _ERC721Token, _appManagerAddress, address(protocolAMMCalculatorFactory.createDualLinearNFT(buyCurve, sellCurve, _appManagerAddress))));
    }

    /**
     * @dev This creates a linear AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantProductAMM(address _token0, address _token1, address _appManagerAddress) external returns (address){
        return address(createERC20AMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createConstantProduct(_appManagerAddress))));
    }

    /**
     * @dev This creates a constant AMM and calculation module.
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _constantRatio the values of x and y for the constant ratio
     * @notice x represents token0 and y represents token1
     * @param _appManagerAddress address of the application's appManager
     * @return _calculatorAddress
     */
    function createConstantAMM(address _token0, address _token1, ConstantRatio memory _constantRatio, address _appManagerAddress) external returns (address) {
        return address(createERC20AMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createConstant(_constantRatio, _appManagerAddress))));
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
        return address(createERC20AMM(_token0, _token1, _appManagerAddress, address(protocolAMMCalculatorFactory.createSample01(_f_tracker, _g_tracker, _appManagerAddress))));
    }
}

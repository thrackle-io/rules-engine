// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../../liquidity/ProtocolAMM.sol";

/**
 * @title Example of an Automated Market Maker
 * @notice This is the example implementation for a protocol AMM.
 * @dev All the good stuff happens in the ProtocolAMM
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMM is ProtocolAMM {
    /**
     * @dev Must provide the addresses for both tokens that will provide liquidity
     * @param _token0 valid ERC20 address
     * @param _token1 valid ERC20 address
     * @param _appManagerAddress valid address of the corresponding app manager
     * @param _calculatorAddress valid address of the corresponding calculator for the AMM
     */
    constructor(
        address _token0,
        address _token1,
        address _appManagerAddress,
        address _calculatorAddress
    ) ProtocolAMM(_token0, _token1, _appManagerAddress, _calculatorAddress) {}
}

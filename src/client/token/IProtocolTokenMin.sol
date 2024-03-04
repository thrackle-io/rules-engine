// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


/**
 * @title Protocol Token Interface Minimal implementation model
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, mpetersoCode55
 * @notice This is the base contract for all protocol ERC20s
 * @dev Using this interface requires the implementing token properly handle the listed functions as well as insert the checkAllRules hook into _beforeTokenTransfer
 */
interface IProtocolTokenMin {
    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _handlerAddress) external;

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address);
}
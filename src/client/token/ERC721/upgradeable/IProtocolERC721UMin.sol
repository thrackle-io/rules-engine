// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

/**
 * @title  Upgradeable ERC721 Protocol Interface Minimal implementation model
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeables
 * @dev Using this interface requires the implementing token properly handle the listed functions as well as insert the checkAllRules hook into _beforeTokenTransfer
 */
abstract contract IProtocolERC721UMin is ERC721EnumerableUpgradeable {
    event HandlerConnected(address indexed handlerAddress, address indexed assetAddress);
    error ZeroAddress();

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external virtual view returns (address);

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external virtual;
}

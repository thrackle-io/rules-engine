// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../../token/ProtocolERC721WSoftStaking.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation of the protocol ERC721 where minting is only available for app administrators or contract owners.
 */

contract ApplicationERC721 is ProtocolERC721 {

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri) {}

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../token/ProtocolERC721A.sol";

/**
 * @title ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment,  _appManagerAddress = AppManager contract address
 */

contract ApplicationERC721A is ProtocolERC721A {
    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _erc721HandlerAddress Address of this ERC721a's handler
     * @param baseUri URI for the base token
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _erc721HandlerAddress,
        address _appManagerAddress,
        string memory baseUri
    ) ProtocolERC721A(_name, _symbol, _erc721HandlerAddress, _appManagerAddress, baseUri) {
        _setBaseURI(baseUri);
    }

    function mint(uint256 quantity) external payable {
        _mint(msg.sender, quantity);
    }
}

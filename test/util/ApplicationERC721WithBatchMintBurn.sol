// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "src/client/token/ERC721/ProtocolERC721.sol";

/**
 * @title ApplicationERC721WithBatchMintBurn
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that has batch mint/burn. It is only used for testing.
 * @dev The logic and stability of this contract is of little concern. It's only purpose is for use in reversion testing for attempted batch mint/burn
 */

contract ApplicationERC721WithBatchMintBurn is ProtocolERC721 {
    /// The next token ID to be minted.
    uint256 private _currentIndex;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri) {}

    function mint(uint256 quantity) external payable {
        _mint(msg.sender, quantity);
    }

    function _mint(address to, uint256 quantity) internal override {
        uint256 startTokenId = _currentIndex;
        _beforeTokenTransfer(address(0), to, startTokenId, quantity);
        // for loop
        for (uint i = 0; i < quantity; i++) {
            _mint(to, startTokenId + i);
        }
        _currentIndex += quantity;
        _update(address(0), to, startTokenId, quantity);
    }

    function burn(uint256 quantity) public override {
        _burn(msg.sender, quantity);
    }

    function _burn(address to, uint256 quantity) internal virtual {
        uint256 startTokenId = _currentIndex;
        _beforeTokenTransfer(address(0), to, startTokenId, quantity);
        // for loop
        for (uint i = 0; i < quantity; i++) {
            _burn(to, startTokenId - i);
        }
        _currentIndex -= quantity;
        _update(address(0), to, startTokenId, quantity);
    }
}

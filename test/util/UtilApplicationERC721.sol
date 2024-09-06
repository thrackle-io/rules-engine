// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/UtilProtocolERC721.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor
 */
contract UtilApplicationERC721 is UtilProtocolERC721 {
    using Counters for Counters.Counter;
    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _appManagerAddress App Manager address
     */
     // slither-disable-next-line shadowing-local
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) UtilProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri){}

    /**
     * @dev Function mints new tokens. Allows for free and open minting of tokens. 
     * @param to recipient address
     */
    /*function safeMint(address to) public payable override {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }*/
}
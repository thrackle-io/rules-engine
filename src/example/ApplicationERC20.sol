// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../token/ProtocolERC20.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor
 */
contract ApplicationERC20 is ProtocolERC20 {
    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol  Symbol of the token
     * @param _appManagerAddress App Manager address
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress) ProtocolERC20(_name, _symbol, _appManagerAddress) {}

    /**
     * @dev Function mints new tokens. Allows for free and open minting of tokens. Comment out to use appAdministatorOnly minting.
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public override {
        _mint(to, amount);
    }
}

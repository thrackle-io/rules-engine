// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/util/UtilProtocolERC20.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor
 */
contract UtilApplicationERC20 is UtilProtocolERC20 {
    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _appManagerAddress App Manager address
     */
     // slither-disable-next-line shadowing-local
    constructor(string memory _name, string memory _symbol, address _appManagerAddress) UtilProtocolERC20(_name, _symbol, _appManagerAddress) {}

    /**
     * @dev Function mints new tokens. Allows for free and open minting of tokens. 
     * @param to recipient address
     * @param amount number of tokens to mint
     */
    function mint(address to, uint256 amount) public override {
        _mint(to, amount);
    }
}
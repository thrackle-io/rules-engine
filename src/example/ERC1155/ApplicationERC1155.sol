// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../token/ERC1155/ProtocolERC1155.sol";

/**
 * @title Example ERC1155 ApplicationERC1155
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor
 */
contract ApplicationERC1155 is ProtocolERC1155 {
    /**
     * @dev Constructor sets name and symbol for the ERC1155 token and makes connections to the protocol.
     * @param _url metadata url
     * @param _appManagerAddress address of app manager contract
     */
    constructor(string memory _url, address _appManagerAddress) ProtocolERC1155(_url, _appManagerAddress) {}

    /**
     * @dev mint assets
     * @param to recipient of mint
     * @param id asset's tokenID
     * @param amount amount to mint
     * @param data data
     */
    function mint(address to, uint256 id, uint256 amount, bytes memory data) public virtual {
        _mint(to, id, amount, data);
    }
}

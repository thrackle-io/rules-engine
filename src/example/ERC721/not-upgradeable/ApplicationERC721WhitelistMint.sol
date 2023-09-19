// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../../token/ProtocolERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation of the protocol ERC721 where minting is open only to whitelisted address,
 * and they have a certain amount of availbale mints.
 */

contract ApplicationERC721 is ProtocolERC721 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    mapping (address => uint8) public mintsAvailable;
    uint8 mintsAllowed;

    error NoMintsAvailable();

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     * @param _mintsAllowed the amount of mints per whitelisted address
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri, uint8 _mintsAllowed) ProtocolERC721(_name, _symbol, _appManagerAddress,  _baseUri) {
        mintsAllowed = _mintsAllowed;
    }

    /**
     * @dev Function mints a new token to anybody in the whitelist, and updates the amount of mints available for the address.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable override whenNotPaused{
        if(mintsAvailable[_msgSender()] == 0) revert NoMintsAvailable();
        mintsAvailable[_msgSender()] -= 1;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /**
     * @dev add an address to the whitelist
     * @param _address Address to enjoy the free mints
     * @notice the amount of free mints granted to this address is limited and it will be equal to "mintsAllowed"
     */
    function addAddressToWhitelist(address _address) external appAdministratorOrOwnerOnly(appManagerAddress){
        mintsAvailable[_address] = mintsAllowed;
    }

    /**
     * @dev update the value of "mintsAllowed"
     * @notice this variable will affect directly the amount of free mints granted to an address through "addAddressToWhitelist"
     * @param _mintsAllowed uint8 that represents the amount of free mints granted through "addAddressToWhitelist" from now on
     */
    function updateMintsAmount(uint8 _mintsAllowed) external appAdministratorOrOwnerOnly(appManagerAddress){
        mintsAllowed = _mintsAllowed;
    }
}
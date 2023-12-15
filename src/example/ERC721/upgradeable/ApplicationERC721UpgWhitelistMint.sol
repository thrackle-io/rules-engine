// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/token/ERC721/upgradeable/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721UpgAdminOrOwnerMint
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an example implementation that App Devs should use.
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
 * must be performed
 */

contract ApplicationERC721Upgradeable is ProtocolERC721U {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;

    mapping(address => uint8) public mintsAvailable;
    uint8 mintsAllowed;

    /**
     * @dev these storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
     * like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.
     * @notice the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
     * storage slots available for variables in future upgrades and avoid storage collisions.
     */
    uint256[48] reservedStorage;

    error NoMintsAvailable();

    /**
     * @dev Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     * @param _mintsAllowed the amount of mints per whitelisted address
     */
    function initialize(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri, uint8 _mintsAllowed) external appAdministratorOnly(_appManagerAddress) {
        mintsAllowed = _mintsAllowed;
        super.initialize(_name, _symbol, _appManagerAddress, _baseUri);
    }

    /**
     * @dev Function mints a new token to anybody in the whitelist, and updates the amount of mints available for the address.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable override whenNotPaused {
        if (mintsAvailable[_msgSender()] == 0) revert NoMintsAvailable();
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
    function addAddressToWhitelist(address _address) external appAdministratorOnly(appManagerAddress) {
        mintsAvailable[_address] = mintsAllowed;
    }

    /**
     * @dev update the value of "mintsAllowed"
     * @notice this variable will affect directly the amount of free mints granted to an address through "addAddressToWhitelist"
     * @param _mintsAllowed uint8 that represents the amount of free mints granted through "addAddressToWhitelist" from now on
     */
    function updateMintsAmount(uint8 _mintsAllowed) external appAdministratorOnly(appManagerAddress) {
        mintsAllowed = _mintsAllowed;
    }
}

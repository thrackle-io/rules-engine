// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../token/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721U
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an example implementation that App Devs should use.
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract. Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U
 * must be performed
 */

contract ApplicationERC721U is ProtocolERC721U {
    /// Optional Function Variables and Errors. Uncomment these if using option functions:
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;

    /// Mint Fee
    // uint256 public mintPrice; /// Chain Native Token price used for priced minting.
    /// Treasury Address
    // address payable private treasury;
    // error MintFeeNotReached();
    // error TreasuryAddressCannotBeTokenContract();

    /// Contract Owner Minting

    error OnlyOwnerCanMint();

    /** 
    constructor() {
        owner = msg.sender;
    }
    */

    /// *********************************** OPTIONAL FUNCTIONS ***********************************

    /// Mint Price Options:

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token at mintPrice.
     * @notice Uncomment this function and comment out safeMint() above. This allows for user minting at fixed price.
     * @param to Address of recipient
     * Uncomment setMintPrice(), setTreasuryAddress(), withdrawMintFees() and receive(). It is essential that all of these are implemented so you do not lock up tokens into the contract permanently.
     */
    // function safeMint(address to) public payable override whenNotPaused {
    //     if (msg.value < mintPrice) revert MintFeeNotReached();
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    // }

    /**
     * @dev Function to set the mint price amount in chain native token
     */
    // function setMintPrice(uint256 _mintPrice) external appAdministratorOnly(appManagerAddress) {
    //     mintPrice = _mintPrice;
    // }

    /**
     * @dev Function to set the Treasury address for Mint Fees to be sent upon withdrawal
     * @param _treasury address of the treasury for mint fees to be sent upon withdrawal.
     */
    // function setTreasuryAddress(address payable _treasury) external appAdministratorOnly(appManagerAddress) {
    //     if (_treasury == address(this)) revert TreasuryAddressCannotBeTokenContract();
    //     treasury = _treasury;
    // }

    /**
     * @dev Function to withdraw mint fees collected to treasury address set by admin.
     */
    // function withdrawMintFees() external appAdministratorOnly(appManagerAddress) {
    //     treasury.transfer(balanceOf(address(this)));
    // }

    /**
     * Receive function for contract to receive Chain Native Token for mint fees
     * If receive and Withdrawal are not implemented together this contract will not be able to reveive Chain Native Tokens or may result in tokens being locked permanently in contract.
     * Only use this section if you are using a Fee to mint tokens and have setMintPrice(), setTreasuryAddress(), withdrawMintFees() and receive() implemented with the safeMint() on line 119 commented out.
     */
    // receive() external payable {}

    /// AppAdministratorOnly Minting
    /**
     * @dev Function mints new a new token to appAdministrator with tokenId incremented by 1 from previous minted token.
     * @notice Uncomment this function and comment out safeMint() above. This allows for only application administators to mint.
     * @param to Address of recipient
     */
    // function safeMint(address to) public payable override whenNotPaused appAdministratorOnly(appManagerAddress) {
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    // }

    /// Contract Owner Minting Only
    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token at mintPrice.
     * @notice Uncomment this function and comment out safeMint() above. This allows for user minting at fixed price.
     * @param to Address of recipient
     */
    // function safeMint(address to) public payable override whenNotPaused {
    //     if (msg.sender != owner()) revert OnlyOwnerCanMint();
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _safeMint(to, tokenId);
    // }
}

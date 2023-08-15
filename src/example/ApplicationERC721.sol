// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../token/ProtocolERC721.sol";
import "../economic/AppAdministratorOrOwnerOnly.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation that App Devs should use.
 * During deployment, _handlerAddress = ERC721Handler contract address
 *                    _appManagerAddress = AppManager contract address
 * @dev This contract contains 3 different safeMint implementations: priced minting, app-administrator-only minting, and app-administrator-or-owner-only minting.
 * The safeMint implementation enabled by default is the app-administrator-or-owner-only, but it is possible to choose any of the other 2 options, or even creating  
 * a different safeMint implementation. However, bare in mind that only one safeMint function can exist at a time in the contract unless polymorphism is used. To
 * select the desired safeMint function, simply comment out and/or delete any safeMint implementations and variable that are not going to be used, and make sure
 * that the one implementation you chose and its variables are enabled (not commented out).
 */

contract ApplicationERC721 
    is 
    ProtocolERC721
    ,AppAdministratorOrOwnerOnly
    {

    /// Optional Function Variables and Errors. Uncomment these if using option functions:
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    /// Mint Fee
    // uint256 public mintPrice; /// Chain Native Token price used for priced minting.

    /// Treasury Address
    // address payable private treasury;
    // error MintFeeNotReached();
    // error TreasuryAddressCannotBeTokenContract();
    // error TreasuryAddressNotSet();

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri) {}

    /// *********************************** OPTIONAL FUNCTIONS ***********************************

    /// Mint Price Options:

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token at mintPrice.
     * @notice Uncomment this function. This allows for user minting at fixed price.
     * This function assumes the mintPrice is in Chain Native Token (ETH/MATIC/BNB/etc...)
     * Uncomment setMintPrice(), setTreasuryAddress(), withdrawMintFees() and receive(). It is essential that all of these are implemented so you do not lock up tokens into the contract permanently.
     * @param to Address of recipient
     */
    // function safeMint(address to) public payable override whenNotPaused {
    //     if (msg.value < mintPrice) revert MintFeeNotReached();
    //     uint256 tokenId = _tokenIdCounter.current();
    //     _tokenIdCounter.increment();
    //     _withdrawMintFees(mintPrice);
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
    // function _withdrawMintFees(uint256 _amount) internal {
    //     if (treasury == address(0x00)) revert TreasuryAddressNotSet();
    //     treasury.transfer(_amount);
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

    /// Contract Owner or App Administrator Minting 
    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token at mintPrice.
     * @notice Uncomment this function and comment out safeMint() above. This allows for user minting at fixed price.
     * @param to Address of recipient
     */
      function safeMint(address to) public payable override whenNotPaused appAdministratorOrOwnerOnly(appManagerAddress) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/client/token/ERC721/upgradeable/ProtocolERC721U.sol";

/**
 * @title ApplicationERC721UpgAdminOrOwnerMint
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This is an example implementation for an ERC721 token which can be minted in exchange of an amount (fee) of native tokens (ETH, MATIC, etc.).
 * During deployment, this contract should be deployed first, then initialize should be invoked, then ApplicationERC721UProxy should be deployed and pointed at * this contract.
 * Any special or additional initializations can be done by overriding initialize but all initializations performed in ProtocolERC721U must be performed.
 */

contract ApplicationERC721Upgradeable is ProtocolERC721U {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;

    /// Mint Fee
    uint256 public mintPrice;

    /// Treasury Address
    address private proposedTreasury;
    address payable private treasury;

    /**
     * @dev These storage slots are saved for future upgrades. Please be aware of common constraints for upgradeable contracts regarding storage slots,
     * like maintaining the order of the variables to avoid mislabeling of storage slots, and to keep some reserved slots to avoid storage collisions.
     * @notice the length of this array must be shrunk by the same amount of new variables added in an upgrade. This is to keep track of the remaining
     * storage slots available for variables in future upgrades and avoid storage collisions.
     */
    uint256[47] reservedStorage;

    /// errors
    error MintFeeNotReached();
    error PriceNotSet();
    error CannotWithdrawZero();
    error TreasuryAddressCannotBeTokenContract();
    error TreasuryAddressNotSet();
    error FunctionDoesNotExist();
    error NotEnoughBalance();
    error ZeroValueNotPermited();
    error NotProposedTreasury(address proposedTreasury);
    error TrasferFailed(bytes reason);

    /**
     * @dev Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     * @param _mintPrice price for minting the NFTs in WEIs
     */
    function initialize(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri, uint256 _mintPrice) external appAdministratorOnly(_appManagerAddress) {
        mintPrice = _mintPrice;
        super.initialize(_name, _symbol, _appManagerAddress, _baseUri);
    }

    /**
     * @dev Function mints a new token to caller at mintPrice with tokenId incremented by 1 from previous minted token.
     * @notice This function assumes the mintPrice is in Chain Native Token and in WEI units
     * @param to Address of recipient
     */
    function safeMint(address to) public payable override whenNotPaused {
        if (mintPrice == 0) revert PriceNotSet();
        if (msg.value < mintPrice) revert MintFeeNotReached();
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        // withdrawMintFees(msg.value); // uncomment this if automatic withdrawal is desired. withdrawMintFees should be marked as private
        _safeMint(to, tokenId);
    }

    /**
     * @dev Function to set the mint price amount in chain native token (WEIs)
     */
    function setMintPrice(uint256 _mintPrice) external appAdministratorOnly(appManagerAddress) {
        if (_mintPrice == 0) revert ZeroValueNotPermited();
        mintPrice = _mintPrice;
    }

    /**
     * @dev Function to propose the Treasury address for Mint Fees to be sent upon withdrawal
     * @param _treasury address of the treasury for mint fees to be sent upon withdrawal.
     */
    function proposeTreasuryAddress(address payable _treasury) external appAdministratorOnly(appManagerAddress) {
        if (_treasury == address(this)) revert TreasuryAddressCannotBeTokenContract();
        proposedTreasury = _treasury;
    }

    /**
     * @dev Function to confirm the Treasury address for Mint Fees to be sent upon withdrawal
     * @param _treasury address of the treasury for mint fees to be sent upon withdrawal.
     */
    function confirmTreasuryAddress() external {
        if (_msgSender() != proposedTreasury) revert NotProposedTreasury(proposedTreasury);
        treasury = payable(proposedTreasury);
        delete proposedTreasury;
    }

    /**
     * @dev Function to withdraw a specific amount from this contract to treasury address.
     * @param _amount the amount to withdraw (WEIs)
     */
    function withdrawAmount(uint256 _amount) external appAdministratorOnly(appManagerAddress) {
        if (treasury == address(0x00)) revert TreasuryAddressNotSet();
        if (_amount == 0) revert CannotWithdrawZero();
        if (_amount > address(this).balance) revert NotEnoughBalance();
        (bool sent, bytes memory data) = treasury.call{value: _amount}("");
        if (!sent) revert TrasferFailed(data);
    }

    /**
     * @dev Function to withdraw all fees collected to treasury address.
     */
    function withdrawAll() external appAdministratorOnly(appManagerAddress) {
        if (treasury == address(0x00)) revert TreasuryAddressNotSet();
        uint balance = address(this).balance;
        if (balance == 0) revert CannotWithdrawZero();
        (bool sent, bytes memory data) = treasury.call{value: balance}("");
        if (!sent) revert TrasferFailed(data);
    }

    /**
     * @dev Gets address of treasury
     * @return address of trasury
     */
    function getTreasuryAddress() external view returns (address) {
        return treasury;
    }

    /**
     * @dev Gets address of proposedTreasury
     * @return address of proposedTreasury
     */
    function getProposedTreasuryAddress() external view returns (address) {
        return proposedTreasury;
    }

    /// Receive function for contract to receive chain native tokens in unordinary ways
    receive() external payable {}

    /// Function to handle wrong data sent to this contract
    fallback() external payable {
        revert FunctionDoesNotExist();
    }
}

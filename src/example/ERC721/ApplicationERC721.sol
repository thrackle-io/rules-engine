// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "src/client/token/IProtocolToken.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import {IZeroAddressError} from "src/common/IErrors.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";

/**
 * @title Example ERC721 ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @Palmerg4
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor
 */
contract ApplicationERC721 is ERC721, AccessControl, IProtocolToken, IApplicationEvents, IZeroAddressError, ReentrancyGuard, ERC721Burnable, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdCounter;

    bytes32 constant TOKEN_ADMIN_ROLE = keccak256("TOKEN_ADMIN_ROLE");

    address private handlerAddress;

    /// Base Contract URI
    string public baseUri;

    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol Symbol of the token
     * @param _tokenAdmin Token Admin address
     */
     // slither-disable-next-line shadowing-local
    constructor(string memory _name, string memory _symbol, address _tokenAdmin, string memory _baseUri) ERC721(_name, _symbol) {
        _grantRole(TOKEN_ADMIN_ROLE, _tokenAdmin);
        _setRoleAdmin(TOKEN_ADMIN_ROLE, TOKEN_ADMIN_ROLE);
        setBaseURI(_baseUri);
    }

    /**
     * @dev Function to return baseUri for contract
     * @return baseUri URI link to NFT metadata
     */
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    /**
     * @dev Function to set URI for contract.
     * @notice this is called in the constructor and can be called to update URI metadata pointer
     * @param _baseUri URI to the metadata file(s) for the contract
     */
    function setBaseURI(string memory _baseUri) public virtual onlyRole(TOKEN_ADMIN_ROLE) {
        baseUri = _baseUri;
    }

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * Function is payable for child contracts to override with priced mint function.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable virtual onlyRole(TOKEN_ADMIN_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param batchSize the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will
     * represent the first id to start the batch.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal nonReentrant override(ERC721, ERC721Enumerable) {
        // Rule Processor Module Check
        if (handlerAddress != address(0)) require(IProtocolTokenHandler(handlerAddress).checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, _msgSender(), tokenId));
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been 
        // applied to this function
        // slither-disable-next-line reentrancy-benign
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @notice This function does not check for zero address. Zero address is a valid address for this function's purpose.
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
     // slither-disable-next-line missing-zero-check
    function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE) {
        handlerAddress = _deployedHandlerAddress;
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }

    /**
     * @dev Function to withdraw Ether sent to contract
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function withdraw() public payable virtual onlyRole(TOKEN_ADMIN_ROLE) {
        // Disabling this finding as a false positive. The address is not arbitrary, the funciton modifier guarantees 
        // it is a App Admin.
        // slither-disable-next-line arbitrary-send-eth
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./ProtocolTokenCommon.sol";
import "../economic/AppAdministratorOnly.sol";
import "../economic/AppAdministratorOrOwnerOnly.sol";
import "../token/IProtocolERC721Handler.sol";

/**
 * @title ERC721 Base Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721s
 */

contract ProtocolERC721 is ERC721Burnable, ERC721URIStorage, ERC721Enumerable, Pausable, ProtocolTokenCommon, AppAdministratorOrOwnerOnly {
    using Counters for Counters.Counter;
    address public handlerAddress;
    IProtocolERC721Handler handler;
    Counters.Counter private _tokenIdCounter;

    /// Base Contract URI
    string public baseUri;
    /// keeps track of RULE enum version and other features
    uint8 public constant VERSION = 1;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) ERC721(_name, _symbol) {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        setBaseURI(_baseUri);
        emit NewNFTDeployed(address(this), _appManagerAddress);
    }

    /********** setters and getters for rules  **********/
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
    function setBaseURI(string memory _baseUri) public virtual appAdministratorOnly(appManagerAddress) {
        baseUri = _baseUri;
    }

    /**
     * @dev Function to set URI for specific token
     * @param tokenId Id of token to update
     * @return tokenURI new URI for token Id
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    /*************** END setters and getters ************/
    /**
     * @dev AppAdministratorOnly function takes appManagerAddress as parameter
     * Function puases contract and prevents functions with whenNotPaused modifier
     */
    function pause() public virtual appAdministratorOnly(appManagerAddress) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
     * AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function unpause() public virtual appAdministratorOnly(appManagerAddress) {
        _unpause();
    }

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * Function is payable for child contracts to override with priced mint function.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable virtual whenNotPaused appAdministratorOrOwnerOnly(appManagerAddress) {
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        // Rule Processor Module Check
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, batchSize, tokenId, ActionTypes.TRADE));

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /// The following functions are overrides required by Solidity.
    /**
     * @dev Function to burn or remove token from circulation
     * @param tokenId Id of token to be burned
     */
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) whenNotPaused {
        super._burn(tokenId);
    }

    /**
     * @dev Function to withdraw Ether sent to contract
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function withdraw() public payable virtual appAdministratorOnly(appManagerAddress) {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolERC721Handler(_deployedHandlerAddress);
        emit HandlerConnected(_deployedHandlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override returns (address) {
        return handlerAddress;
    }
}

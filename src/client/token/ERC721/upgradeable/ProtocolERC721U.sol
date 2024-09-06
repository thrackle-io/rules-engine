// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommonU.sol";

/**
 * @title Protocol ERC721 Upgradeable Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeables
 */
contract ProtocolERC721U is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ProtocolTokenCommonU,
    ReentrancyGuard
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    address public handlerAddress;
    IProtocolTokenHandler handler;
    CountersUpgradeable.Counter internal _tokenIdCounter;

    /// Base Contract URI
    string public baseUri;
    /// memory placeholders to allow variable addition without affecting client upgradeability
    // slither-disable-next-line shadowing-local
    uint256[49] __gap;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @notice This function should be called in an "atomic" deploy script when deploying an ERC721Upgradeable contract. 
     * "Front Running" is possible if this function is called individually after the ERC721Upgradeable proxy is deployed. 
     * It is critical to ensure your deploy process mitigates this risk.
     * @param _nameProto Name of NFT
     * @param _symbolProto Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     */
    function initialize(string memory _nameProto, string memory _symbolProto, address _appManagerAddress, string memory _baseUri) public virtual appAdministratorOnly(_appManagerAddress) initializer {
        __ERC721_init(_nameProto, _symbolProto);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        _initializeProtocol(_appManagerAddress);
        setBaseURI(_baseUri);
    }

    /**
     * @dev Private Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _appManagerAddress Address of App Manager
     */
    function _initializeProtocol(address _appManagerAddress) private onlyInitializing {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Function to burn or remove token from circulation
     * @param tokenId Id of token to be burned
     */
    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    /**
     * @dev Function to return baseURI for contract
     * @return baseUri URI link to NFT metadata
     */
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    /**
     * @dev Function to return tokenURI for contract
     * @return tokenURI link to NFT metadata
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
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
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /*************** END setters and getters ************/

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * @param to Address of recipient
     */
    function safeMint(address to) public payable virtual appAdministratorOnly(appManagerAddress) {
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal nonReentrant override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        /// Rule Processor Module Check
        if (handlerAddress != address(0)) require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to,  _msgSender(), tokenId));
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been 
        // applied to this function
        // slither-disable-next-line reentrancy-benign
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Function to withdraw Ether sent to contract
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function withdraw() public payable virtual appAdministratorOnly(appManagerAddress) {
        // Disabling this finding as a false positive. The address is not arbitrary, the funciton modifier guarantees 
        // it is a App Admin.
        // slither-disable-next-line arbitrary-send-eth
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @notice This function does not check for zero address. Zero address is a valid address for this function's purpose.
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
     // slither-disable-next-line missing-zero-check
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}

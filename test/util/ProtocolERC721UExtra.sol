// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommonU.sol";

/**
 * @title ERC721 Upgradeable Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721Upgradeables
 */
contract ProtocolERC721UExtra is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ProtocolTokenCommonU,
    PausableUpgradeable
{
    address public handlerAddress;
    IProtocolTokenHandler handler;
    uint256 private _tokenIdCounter;

    /// Base Contract URI
    string public baseUri;
    /// memory placeholders to allow up variable addition without affecting client upgradeability
    uint256[46] __gap;
    uint256 newVariable1;
    uint256 newVariable2;
    string newVariable3;

    /**
     * @dev Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     */
    function initialize(string memory _name, string memory _symbol, address _appManagerAddress) external virtual appAdministratorOnly(_appManagerAddress) initializer {
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __Pausable_init();
        _initializeProtocol(_appManagerAddress);
    }

    /**
     * @dev Private Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _appManagerAddress Address of App Manager
     */
    function _initializeProtocol(address _appManagerAddress) private onlyInitializing {
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        emit AD1467_NewNFTDeployed(_appManagerAddress);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /**
     * @dev Function to burn or remove token from circulation
     * @param tokenId Id of token to be burned
     */
    // function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
    //     super._burn(tokenId);
    // }

        /**
     * @dev Function to increase balance. This is only done to override OZ dependencies and ensure which balance increase we want.
     * @param account Account to have balance increased
     * @param value Number of assets to be increased by
     */
    function _increaseBalance(address account, uint128 value) internal override(ERC721EnumerableUpgradeable, ERC721Upgradeable) {
        ERC721EnumerableUpgradeable._increaseBalance(account, value);
    }

    /**
     * @dev Function to return baseUri for contract
     * @return baseUri URI link to NFT metadata
     */
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

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
    function safeMint(address to) public payable virtual {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _tokenIdCounter += 1;
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param auth Auth argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     */
    function _update(address to, uint256 tokenId, address auth) internal override (ERC721Upgradeable, ERC721EnumerableUpgradeable) returns (address) {
        require(handler.checkAllRules(balanceOf(_msgSender()), to == address(0) ? 0 : balanceOf(to), _msgSender(), to, _msgSender(), tokenId));
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been 
        // applied to this function
        // slither-disable-next-line reentrancy-benign
        return ERC721EnumerableUpgradeable._update(to, tokenId, auth);
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
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolTokenHandler(handlerAddress);
        emit AD1467_HandlerConnected(_deployedHandlerAddress, address(this));
    }
}

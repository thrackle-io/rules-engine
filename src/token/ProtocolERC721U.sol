// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/CountersUpgradeable.sol";
import "../application/IAppManager.sol";
import "../economic/AppAdministratorOnlyU.sol";
import "../../src/token/ProtocolERC721Handler.sol";
import {IApplicationEvents} from "../interfaces/IEvents.sol";

/**
 * @title ERC721 Upgradeable Protocol Contract
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
    AppAdministratorOnlyU,
    IApplicationEvents,
    PausableUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;
    address public appManagerAddress;
    address public handlerAddress;
    ProtocolERC721Handler handler;
    IAppManager appManager;
    CountersUpgradeable.Counter private _tokenIdCounter;

    /// Base Contract URI
    string public baseUri;
    /// keeps track of RULE enum version and other features
    uint8 public constant VERSION = 1;
    error ZeroAddress();

    /**
     * @dev Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _ruleProcessorProxyAddress of token rule router proxy address
     * @param _baseUri URI for the base token
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        address _appManagerAddress,
        address _ruleProcessorProxyAddress,
        bool _upgradeMode,
        string memory _baseUri
    ) external virtual appAdministratorOnly(_appManagerAddress) initializer {
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
        _initializeProtocol(_appManagerAddress, _ruleProcessorProxyAddress, _upgradeMode, _baseUri);
    }

    /**
     * @dev Private Initializer sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _appManagerAddress Address of App Manager
     * @param _ruleProcessorProxyAddress of token rule router proxy address
     * @param _baseUri URI for the base token
     */
    function _initializeProtocol(address _appManagerAddress, address _ruleProcessorProxyAddress, bool _upgradeMode, string memory _baseUri) private onlyInitializing {
        // _tokenIdCounter.increment();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        setBaseURI(_baseUri);
        if (!_upgradeMode) {
            deployHandler(_ruleProcessorProxyAddress, _appManagerAddress, _upgradeMode);
        }
        emit NewNFTDeployed(address(this), _appManagerAddress);
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
    function safeMint(address to) public virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        // Rule Processor Module Check
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, 1, tokenId, RuleProcessorDiamondLib.ActionTypes.TRADE));

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
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
     * @dev Function to set the appManagerAddress and connect to the new appManager
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function setAppManagerAddress(address _appManagerAddress) external appAdministratorOnly(appManagerAddress) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
    }

    /**
     * @dev This function is called at deployment in the constructor to deploy the Handler Contract for the Token.
     * @param _ruleProcessor address of the rule processor
     * @param _appManagerAddress address of the Application Manager Contract
     * @param _upgradeModeHandler specifies whether this is a fresh Handler or an upgrade replacement.
     * @return handlerAddress address of the new Handler Contract
     */
    function deployHandler(address _ruleProcessor, address _appManagerAddress, bool _upgradeModeHandler) private returns (address) {
        handler = new ProtocolERC721Handler(_ruleProcessor, _appManagerAddress, _upgradeModeHandler);
        handlerAddress = address(handler);
        return handlerAddress;
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external appAdministratorOnly(appManagerAddress) {
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = ProtocolERC721Handler(_deployedHandlerAddress);
        emit HandlerConnectedForUpgrade(_deployedHandlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view returns (address) {
        return handlerAddress;
    }
}

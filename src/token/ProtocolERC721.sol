// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../economic/IERC721HandlerLite.sol";
import "../application/IAppManager.sol";
import "../economic/AppAdministratorOnly.sol";
import "../../src/token/ProtocolERC721Handler.sol";
import {IApplicationEvents} from "../interfaces/IEvents.sol";

/**
 * @title ERC721 Base Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721s
 */

contract ProtocolERC721 is ERC721Burnable, ERC721URIStorage, ERC721Enumerable, Pausable, AppAdministratorOnly, IApplicationEvents {
    using Counters for Counters.Counter;
    address public appManagerAddress;
    address public handlerAddress;
    ProtocolERC721Handler handler;
    IAppManager appManager;
    Counters.Counter private _tokenIdCounter;

    /// Base Contract URI
    string public baseUri;
    /// keeps track of RULE enum version and other features
    uint8 public constant VERSION = 1;
    error ZeroAddress();

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _appManagerAddress Address of App Manager
     * @param _ruleProcessor Address of the protocol rule processor
     * * @param _upgradeMode token deploys a Handler contract, false = handler deployed, true = upgraded token contract and no handler.
     * _upgradeMode is also passed to Handler contract to deploy a new data contract with the handler.
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, address _appManagerAddress, address _ruleProcessor, bool _upgradeMode, string memory _baseUri) ERC721(_name, _symbol) {
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
        setBaseURI(_baseUri);
        if (!_upgradeMode) {
            deployHandler(_ruleProcessor, _appManagerAddress, _upgradeMode);
        }
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
    function setBaseURI(string memory _baseUri) public appAdministratorOnly(appManagerAddress) {
        baseUri = _baseUri;
    }

    /*************** END setters and getters ************/
    /**
     * @dev AppAdministratorOnly function takes appManagerAddress as parameter
     * Function puases contract and prevents functions with whenNotPaused modifier
     */
    function pause() public appAdministratorOnly(appManagerAddress) {
        _pause();
    }

    /**
     * @dev Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
     * AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function unpause() public appAdministratorOnly(appManagerAddress) {
        _unpause();
    }

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * @param to Address of recipient
     */
    function safeMint(address to) public virtual whenNotPaused {
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
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, 1, tokenId, RuleProcessorDiamondLib.ActionTypes.TRADE));

        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        //return(tradesPerToken[tokenId]);
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
     * @dev Function to set URI for specific token
     * @param tokenId Id of token to update
     * @return tokenURI new URI for token Id
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    /**
     * @dev Function to withdraw Ether sent to contract
     * @dev AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function withdraw() public payable appAdministratorOnly(appManagerAddress) {
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
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
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
        handler = ProtocolERC721Handler(_deployedHandlerAddress);
        emit HandlerConnectedForUpgrade(_deployedHandlerAddress, address(this));
    }
}

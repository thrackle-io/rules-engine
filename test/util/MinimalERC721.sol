// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "src/client/token/IProtocolTokenMin.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommon.sol";
import "src/client/token/handler/diamond/ERC721HandlerMainFacet.sol";
import "src/client/token/handler/diamond/IHandlerDiamond.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";

/**
 * @title Minimal ERC20 Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract MinimalERC721 is ERC721, IProtocolTokenMin, ProtocolTokenCommon, ERC721Burnable, ERC721Enumerable, AppAdministratorOrOwnerOnly {
    uint256 internal _tokenIdCounter;
    IHandlerDiamond _handler;

    constructor(string memory _nameProto, string memory _symbolProto, address _appManagerAddress, string memory _baseUri) ERC721(_nameProto, _symbolProto) {
        _baseUri;
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);

        emit AD1467_NewTokenDeployed(_appManagerAddress);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param auth Auth argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     */
    function _update(address to, uint256 tokenId, address auth) internal override(ERC721Enumerable, ERC721) returns (address) {
        require(_handler.checkAllRules(balanceOf(_msgSender()), to == address(0) ? 0 : balanceOf(to), _msgSender(), to, _msgSender(), tokenId));
        // Disabling this finding, it is a false positive. A reentrancy lock modifier has been 
        // applied to this function
        // slither-disable-next-line reentrancy-benign
        return ERC721Enumerable._update(to, tokenId, auth);
    }

        /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _handlerAddress) external override appAdministratorOnly(appManagerAddress) {
        if (_handlerAddress == address(0)) revert ZeroAddress();
        _handler = IHandlerDiamond(_handlerAddress);
        emit AD1467_HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override(IProtocolTokenMin, ProtocolTokenCommon) returns (address) {
        return address(address(_handler));
    }

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * Function is payable for child contracts to override with priced mint function.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable virtual appAdministratorOrOwnerOnly(appManagerAddress) {
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _tokenIdCounter += 1;
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
        return ERC721Enumerable.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to increase balance. This is only done to override OZ dependencies and ensure which balance increase we want.
     * @param account Account to have balance increased
     * @param value Number of assets to be increased by
     */
    function _increaseBalance(address account, uint128 value) internal override(ERC721Enumerable, ERC721) {
        ERC721Enumerable._increaseBalance(account, value);
    }
}
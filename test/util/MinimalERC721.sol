// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "src/client/token/IProtocolTokenHandler.sol";
import "src/client/token/ProtocolTokenCommon.sol";
import "src/client/token/handler/diamond/ERC721HandlerMainFacet.sol";
import "src/client/token/handler/diamond/IHandlerDiamond.sol";
import "src/protocol/economic/AppAdministratorOrOwnerOnly.sol";

/**
 * @title Minimal ERC20 Protocol Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract MinimalERC721 is ERC721, ProtocolTokenCommon, ERC721Burnable, ERC721Enumerable, AppAdministratorOrOwnerOnly {
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdCounter;
    IHandlerDiamond _handler;

    constructor(string memory _nameProto, string memory _symbolProto, address _appManagerAddress, string memory _baseUri) ERC721(_nameProto, _symbolProto) {
        _baseUri;
        if (_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
        appManager = IAppManager(_appManagerAddress);
    }

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param batchSize the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will
     * represent the first id to start the batch.
     */
     // slither-disable-next-line calls-loop
        function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) {
        /// Rule Processor Module Check
        if (handlerAddress != address(0)) require(IHandlerDiamond(_handler).checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, _msgSender(), tokenId));
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _handlerAddress address of the currently deployed Handler Address
     */
    // slither-disable-next-line missing-zero-check
    function connectHandlerToToken(address _handlerAddress) external override(ProtocolTokenCommon) appAdministratorOnly(appManagerAddress) {
        _handler = IHandlerDiamond(_handlerAddress);
        handlerAddress = _handlerAddress;
        emit AD1467_HandlerConnected(_handlerAddress, address(this));
    }

    /**
     * @dev This function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override(ProtocolTokenCommon) returns (address) {
        return address(address(_handler));
    }

    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * Function is payable for child contracts to override with priced mint function.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable virtual appAdministratorOrOwnerOnly(appManagerAddress) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
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
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import ".././token/ERC721/ProtocolERC721.sol";
import ".././token/ProtocolTokenCommon.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@limitbreak/creator-token-contracts/contracts/erc721c/extensions/ERC721CW.sol";


contract StakingWrapper is ERC721CW, ProtocolTokenCommon {

/// @dev Points to an external ERC721 contract that will be wrapped via staking.
IERC721 private immutable wrappedCollectionImmutable;
using Counters for Counters.Counter;
address public handlerAddress;
IProtocolERC721Handler handler;
Counters.Counter private _tokenIdCounter;

constructor(address collectionToWrap, string memory _name, string memory _symbol) 
    ERC721C() 
    ERC721CW(collectionToWrap) 
    ERC721OpenZeppelin(_name, _symbol) {
        wrappedCollectionImmutable = IERC721(collectionToWrap);
        _setNameAndSymbol(_name, _symbol);
} 

    /**
     * @notice Indicates whether the contract implements the specified interface.
     * @dev Overrides supportsInterface in ERC165.
     * @param interfaceId The interface id
     * @return true if the contract implements the specified interface, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721CW) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getWrappedCollectionAddress() public view override(ERC721CW) returns (address) {
        return address(wrappedCollectionImmutable);
    }

    function _requireCallerIsVerifiedEOA() internal view override(ERC721CW) {
        ICreatorTokenTransferValidator transferValidator_ = getTransferValidator();
        if (address(transferValidator_) != address(0)) {
            if (!transferValidator_.isVerifiedEOA(_msgSender())) {
                revert ERC721WrapperBase__CallerSignatureNotVerifiedInEOARegistry();
            }
        }
    }

    function _doTokenMint(address to, uint256 tokenId) internal virtual override(ERC721CW) {
        _mint(to, tokenId);
    }

    function _doTokenBurn(uint256 tokenId) internal virtual override(ERC721CW) {
        _burn(tokenId);
    }

    function _getOwnerOfToken(uint256 tokenId) internal view virtual override(ERC721CW) returns (address) {
        return ownerOf(tokenId);
    }

    function _tokenExists(uint256 tokenId) internal view virtual override(ERC721CW) returns (bool) {
        return _exists(tokenId);
    }

    function _requireCallerIsContractOwner() internal view virtual override {}


    ///////////////////////PROTOCOL HOOKS\\\\\\\\\\\\\\\\\\\\\\\\\\

    /**
     * @dev Function called before any token transfers to confirm transfer is within rules of the protocol
     * @param from sender address
     * @param to recipient address
     * @param tokenId Id of token to be transferred
     * @param batchSize the amount of NFTs to mint in batch. If a value greater than 1 is given, tokenId will
     * represent the first id to start the batch.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        // Rule Processor Module Check
        if(to != address(this) ||  from != address(this)) {
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, batchSize, tokenId, ActionTypes.TRADE));
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
    function setAppManagerAddress(address newAppManager) external  {
        appManagerAddress = newAppManager;
        appManager = IAppManager(newAppManager);
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external {
        if (_deployedHandlerAddress == address(0)) revert("ZeroAddress");
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolERC721Handler(_deployedHandlerAddress);
    }

    function getHandlerAddress() external view virtual override(ProtocolTokenCommon) returns (address){
        return handlerAddress;
    }
}
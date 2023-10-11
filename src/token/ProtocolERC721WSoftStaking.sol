// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ProtocolTokenCommon.sol";
import "./IProtocolERC721Min.sol";
import "../token/IProtocolERC721Handler.sol";

/**
 * @title ERC721 Base Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is the base contract for all protocol ERC721s
 */

contract ProtocolERC721 is IProtocolERC721Min, ERC721Enumerable, ProtocolTokenCommon, Ownable {
    using Counters for Counters.Counter;
    address public handlerAddress;
    IProtocolERC721Handler handler;
    Counters.Counter private _tokenIdCounter;

    error NotAuthorized();
    error HandlerFailed(bytes);

    enum StakingStatus{
        UNLOCKED,
        LOCKED,
        PENDING
    }

    /// NFT staking status
    mapping(uint256 => StakingStatus) public stakingStatusPerNFT;
    mapping(uint128 => uint256) requestIdToNFT;

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     */
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function stakeNFT(uint256 tokenId) external payable{
        // only the owner of the NFT can stake it
        if(msg.sender != ownerOf(tokenId)) revert NotAuthorized();
        /// bytes4(keccak256(bytes('checkStatusOracle(address)')));= 0x1b0a7b60
        (bool success, bytes memory res) = address(handler).call{value: msg.value}(abi.encodeWithSelector(0x1b0a7b60, msg.sender));
        if(!success) revert HandlerFailed(res);
        (uint8 status, uint128 requestId) = abi.decode(res, (uint8, uint128));
        stakingStatusPerNFT[tokenId] = StakingStatus(status);
        requestIdToNFT[requestId] = tokenId;
    }

    function updateStakingStatus(uint128 requestId, bool isApproved) external {
        stakingStatusPerNFT[requestIdToNFT[requestId]] = isApproved ? StakingStatus.LOCKED : StakingStatus.UNLOCKED;
        // we free memory when not needed any more
        delete requestIdToNFT[requestId];
    }


    /**
     * @dev Function mints new a new token to caller with tokenId incremented by 1 from previous minted token.
     * @notice Add appAdministratorOnly modifier to restrict minting privilages
     * Function is payable for child contracts to override with priced mint function.
     * @param to Address of recipient
     */
    function safeMint(address to) public virtual onlyOwner{
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
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override  {
        //soft-staking check
        if(stakingStatusPerNFT[tokenId] != StakingStatus.UNLOCKED) revert("token locked or pending");
        // Rule Processor Module Check
        require(handler.checkAllRules(from == address(0) ? 0 : balanceOf(from), to == address(0) ? 0 : balanceOf(to), from, to, batchSize, tokenId, ActionTypes.TRADE));

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
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, IERC165) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId) || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to connect Token to previously deployed Handler contract
     * @param _deployedHandlerAddress address of the currently deployed Handler Address
     */
    function connectHandlerToToken(address _deployedHandlerAddress) external onlyOwner override(IProtocolERC721Min){
        if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
        handlerAddress = _deployedHandlerAddress;
        handler = IProtocolERC721Handler(_deployedHandlerAddress);
        emit HandlerConnected(_deployedHandlerAddress, address(this));
    }

    /**
     * @dev this function returns the handler address
     * @return handlerAddress
     */
    function getHandlerAddress() external view override(IProtocolERC721Min, ProtocolTokenCommon) returns (address) {
        return handlerAddress;
    }
}

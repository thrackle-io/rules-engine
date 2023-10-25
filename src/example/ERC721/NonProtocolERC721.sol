// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title ApplicationERC721
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This is an example implementation of the protocol ERC721 where minting is open to anybody willing to pay for the NFT.
 */

contract NonProtocolERC721 is ERC721, ERC721Burnable, ERC721URIStorage, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    /// Mint Fee
    uint256 public mintPrice;

    /// Base Contract URI
    string public baseUri;

    /// Treasury Address
    address private proposedTreasury;
    address payable private treasury;

    /// errors
    error MintFeeNotReached();
    error PriceNotSet();
    error CannotWithdrawZero();
    error TreasuryAddressCannotBeTokenContract();
    error TreasuryAddressNotSet();
    error FunctionDoesNotExist();
    error NotEnoughBalance();
    error ZeroValueNotPermited();
    error NotProposedTreasury(address proposedTreasury);
    error TrasferFailed(bytes reason);

    /**
     * @dev Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address
     * @param _name Name of NFT
     * @param _symbol Symbol for the NFT
     * @param _baseUri URI for the base token
     */
    constructor(string memory _name, string memory _symbol, string memory _baseUri) ERC721(_name, _symbol) {}

    /**
     * @dev Function mints a new token to anybody. Don't enabled this function if you are not sure about what you're doing.
     * @notice This allows EVERYBODY TO MINT FOR FREE.
     * @param to Address of recipient
     */
    function safeMint(address to) public payable whenNotPaused {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }


    /**
     * @dev Function to return baseUri for contract
     * @return baseUri URI link to NFT metadata
     */
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
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
    function pause() public virtual onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract. Only whenNotPaused modified functions will work once called. default state of contract is unpaused.
     * AppAdministratorOnly modifier uses appManagerAddress. Only Addresses asigned as AppAdministrator can call function.
     */
    function unpause() public virtual onlyOwner {
        _unpause();
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
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, ERC721URIStorage) returns (bool) {
        return ERC721Enumerable.supportsInterface(interfaceId) || 
        ERC721URIStorage.supportsInterface(interfaceId) || 
        super.supportsInterface(interfaceId);
    }
}

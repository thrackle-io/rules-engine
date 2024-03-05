// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "src/common/IProtocolERC721Pricing.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";

/**
 * @title ERC721 Pricing Template Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is a simple pricing mechanism only. Its main purpose is to store prices.
 * @dev This contract allows for setting prices on entire collections or by tokenId
 */
contract ProtocolERC721Pricing is Ownable, IApplicationEvents, IProtocolERC721Pricing {
    string private constant VERSION="1.1.0";
    using ERC165Checker for address;

    mapping(address => mapping(uint256 => uint256)) public nftPrice;
    mapping(address => uint256) public collectionPrice;

    /**
     * @dev set the price for a single NFT from a collection
     * @param nftContract is the address of the NFT contract
     * @param id of the NFT
     * @param price price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function setSingleNFTPrice(address nftContract, uint256 id, uint256 price) external onlyOwner {
        if (nftContract.supportsInterface(0x80ac58cd)) {
            nftPrice[nftContract][id] = price;
        } else {
            revert NotAnNFTContract(nftContract);
        }
        emit SingleTokenPrice(nftContract, id, price);
    }

    /**
     * @dev set the price for whole collection. If an NFT has a price
     * specific for it, the collection price would have the second priority.
     * @param nftContract is the address of the NFT contract
     * @param price price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function setNFTCollectionPrice(address nftContract, uint256 price) external onlyOwner {
        if (nftContract.supportsInterface(0x80ac58cd)) {
            collectionPrice[nftContract] = price;
        } else {
            revert NotAnNFTContract(nftContract);
        }
        emit CollectionPrice(nftContract, price);
    }

    /**
     * @dev gets the price of an NFT. It will return the NFT's specific price, or the
     * price of the collection if no specific price has been given
     * @param nftContract is the address of the NFT contract
     * @param id of the NFT
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price) {
        uint256 singlePrice = nftPrice[nftContract][id];
        if (singlePrice == 0) {
            return collectionPrice[nftContract];
        } else {
            return singlePrice;
        }
    }

    /**
     * @dev gets the price of an NFT Collection. It will return the NFT Collection price to be used for each token Id (i.e. Floor Price).
     * @param nftContract is the address of the NFT contract
     * @return price for the collection in weis of dollars. 10^18 => $ 1.00 USD
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function getNFTCollectionPrice(address nftContract) external view returns (uint256 price) {
        return collectionPrice[nftContract];
    }

    /**
     * @dev gets the version of the contract
     * @return VERSION
     */
    function version() external pure returns (string memory) {
        return VERSION;
    }
}

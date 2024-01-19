// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {NFTPricingErrors} from "src/common/IErrors.sol";

/**
 * @title ERC721 Pricing interface
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is a simple pricing mechanism only. Its main purpose is to store prices.
 * @dev This interface is used for simplicity in implementation of actual pricing module.
 */
interface IProtocolERC721Pricing is NFTPricingErrors {
    /**
     * @dev gets the price for an NFT. It will return the NFT's specific price, or the
     * price of the collection if no specific price has been given.
     * @param nftContract is the address of the NFT contract
     * @param id of the NFT
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price);

    /**
     * @dev gets the default price for an NFT collection.
     * @param nftContract is the address of the NFT contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getNFTCollectionPrice(address nftContract) external view returns (uint256 price);
}

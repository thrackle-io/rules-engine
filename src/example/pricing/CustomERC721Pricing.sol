// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import {IApplicationEvents} from "src/common/IEvents.sol";
import "src/common/IProtocolERC721Pricing.sol";
import "src/protocol/economic/AppAdministratorOnly.sol";
import "src/example/pricing/AggregatorV3Interface.sol";
import {IZeroAddressError} from "src/common/IErrors.sol";

/**
 * @title CustomERC721 Pricing example contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract is an example of how one could implement a custom pricing solution. It uses a Chainlink Price Feed to get the token price
 */
contract CustomERC721Pricing is Ownable, IApplicationEvents, IProtocolERC721Pricing, AppAdministratorOnly, IZeroAddressError {
    address private pudgyPenguin = 0xBd3531dA5CF5857e7CfAA92426877b022e612cf8;
    address private pudgyPenguinFeed = 0x9f2ba149c2A0Ee76043d83558C4E79E9F3E5731B;

    address private cryptoPunk = 0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB;
    address private cryptoPunkFeed = 0x01B6710B01cF3dd8Ae64243097d91aFb03728Fdd;

    address private azuki = 0xED5AF388653567Af2F388E6224dC7C4b3241C544;
    address private azukiFeed = 0xA8B9A447C73191744D5B79BcE864F343455E1150;

    address private immutable appManagerAddress;

    error NoPriceFeed(address tokenAddress);

    constructor(address _appManagerAddress) {
        if(_appManagerAddress == address(0)) revert ZeroAddress();
        appManagerAddress = _appManagerAddress;
    }

    /**
     * @dev Gets the price of an NFT. It will return the Token's specific price. This function is left here to preserve the function signature. NOTE: This is  * only the floor price at the contract level. As of create date, Chainlink does not have a tokenId based pricing solution.
     * @param nftContract is the address of the NFT contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * @notice that the price is for the whole token and not of its atomic unit. This means that if
     * an ERC721 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price) {
        id;
        if (nftContract == pudgyPenguin) {
            return getChainlinkPudgyToUSDFeedPrice();
        } else if (nftContract == cryptoPunk) {
            return getChainlinkCryptoToUSDFeedPrice();
        } else if (nftContract == azuki) {
            return getChainlinkAzukiToUSDFeedPrice();
        } else {
            revert NoPriceFeed(nftContract);
        }
    }

    /**
     * @dev Gets the price of an NFT. It will return the Token's specific price. This function is left here to preserve the function signature. NOTE: This is  * only the floor price at the contract level. As of create date, Chainlink does not have a tokenId based pricing solution.
     * @param nftContract is the address of the NFT contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     * @notice Chainlink only provides floor price feeds, so this function mirrors getNFTPrice() in functionality.
     * The price is for the whole token and not of its atomic unit. This means that if
     * an ERC721 with 18 decimals has a price of 2 dollars, then its atomic unit would be 2/10^18 USD.
     * 999_999_999_999_999_999 = 0xDE0B6B3A763FFFF, 1_000_000_000_000_000_000 = DE0B6B3A7640000
     */
    function getNFTCollectionPrice(address nftContract) external view returns (uint256 price) {
        if (nftContract == pudgyPenguin) {
            return getChainlinkPudgyToUSDFeedPrice();
        } else if (nftContract == cryptoPunk) {
            return getChainlinkCryptoToUSDFeedPrice();
        } else if (nftContract == azuki) {
            return getChainlinkAzukiToUSDFeedPrice();
        } else {
            revert NoPriceFeed(nftContract);
        }
    }

    /**
     * @dev Gets the Chainlink floor price feed for PudgyPenguins in USD. This is an example that works for any decimal denomination.
     * @return floorPrice The floor price in USD for this collection according to Chainlink aggregation
     */
    function getChainlinkPudgyToUSDFeedPrice() public view returns (uint256) {
        AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(pudgyPenguinFeed);
        uint8 decimals = nftFloorPriceFeed.decimals();
        // prettier-ignore
        // Disabling this finding, the other return values are not needed and needlessly creating variables to 
        // hold them is it's own finding (and just overall inefficient)
        // slither-disable-next-line unused-return
        (
            /*uint80 roundID*/,
            int nftFloorPrice,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = nftFloorPriceFeed.latestRoundData();

        if (decimals < 18) {
            nftFloorPrice = nftFloorPrice * int(10 ** (18 - decimals));
        } else if (decimals > 18) {
            // disabling this finding, the multiplication referenced takes place in a 
            // separate calling function (two calls removed).
            // slither-disable-next-line divide-before-multiply
            nftFloorPrice = nftFloorPrice / int(10 ** (decimals - 18));
        }

        return (uint256(nftFloorPrice));
    }

    /**
     * @dev Gets the Chainlink floor price feed for Cryptopunks in USD. This is an example that works for any decimal denomination.
     * @return floorPrice The floor price in USD for this collection according to Chainlink aggregation
     */
    function getChainlinkCryptoToUSDFeedPrice() public view returns (uint256) {
        AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(cryptoPunkFeed);
        uint8 decimals = nftFloorPriceFeed.decimals();
        // prettier-ignore
        // Disabling this finding, the other return values are not needed and needlessly creating variables to 
        // hold them is it's own finding (and just overall inefficient)
        // slither-disable-next-line unused-return
        (
            /*uint80 roundID*/,
            int nftFloorPrice,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = nftFloorPriceFeed.latestRoundData();

        if (decimals < 18) {
            nftFloorPrice = nftFloorPrice * int(10 ** (18 - decimals));
        } else if (decimals > 18) {
            // disabling this finding, the multiplication referenced takes place in a 
            // separate calling function (two calls removed).
            // slither-disable-next-line divide-before-multiply
            nftFloorPrice = nftFloorPrice / int(10 ** (decimals - 18));
        }

        return (uint256(nftFloorPrice));
    }

    /**
     * @dev Gets the Chainlink floor price feed for Azuki in USD. This is an example that works for any decimal denomination.
     * @return floorPrice The floor price in USD for this collection according to Chainlink aggregation
     */
    function getChainlinkAzukiToUSDFeedPrice() public view returns (uint256) {
        AggregatorV3Interface nftFloorPriceFeed = AggregatorV3Interface(azukiFeed);

        uint8 decimals = nftFloorPriceFeed.decimals();
        // prettier-ignore
        // Disabling this finding, the other return values are not needed and needlessly creating variables to 
        // hold them is it's own finding (and just overall inefficient)
        // slither-disable-next-line unused-return
        (
            /*uint80 roundID*/,
            int nftFloorPrice,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = nftFloorPriceFeed.latestRoundData();

        if (decimals < 18) {
            nftFloorPrice = nftFloorPrice * int(10 ** (18 - decimals));
        } else if (decimals > 18) {
            // disabling this finding, the multiplication referenced takes place in a 
            // separate calling function (two calls removed).
            // slither-disable-next-line divide-before-multiply
            nftFloorPrice = nftFloorPrice / int(10 ** (decimals - 18));
        }

        return (uint256(nftFloorPrice));
    }

    /**
     * @dev This function allows appAdminstrators to set the token address
     */
    function setCryptoPunkAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        cryptoPunk = _address;
    }

    /**
     * @dev This function allows appAdminstrators to set the Chainlink price feed address
     */
    function setCryptoPunkFeedAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        cryptoPunkFeed = _address;
    }

    /**
     * @dev This function allows appAdminstrators to set the token address
     */
    function setAzukiAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        azuki = _address;
    }

    /**
     * @dev This function allows appAdminstrators to set the Chainlink price feed address
     */
    function setAzuikiFeedAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        azukiFeed = _address;
    }

    /**
     * @dev This function allows appAdminstrators to set the token address
     */
    function setPudgyPenguinAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        pudgyPenguin = _address;
    }

    /**
     * @dev This function allows appAdminstrators to set the Chainlink price feed address
     */
    function setPudgyPenguinFeedAddress(address _address) external appAdministratorOnly(appManagerAddress) {
        if(_address == address(0)) revert ZeroAddress();
        pudgyPenguinFeed = _address;
    }
}

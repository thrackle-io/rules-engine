// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";

/**
 * @title Test For The NFTPricing Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests setting a price for a single NFT, for a whole collection
 * and getting the right amount when asked for the price. It also checks the enforcement
 * of the contract being an ERC721 contract before setting a price for an NFT
 * @notice It simulates an NFT-marketplace price source.
 */
contract ERC721PricingTest is TestCommonFoundry {
    function setUp() public {
        setUpProtocolAndAppManagerAndPricingAndTokens();
    }

    function testPricing_ERC721Pricing_PricerVersion() public view {
        string memory version = openOcean.version();
        assertEq(version, "1.3.0");
    }

    /// Testing setting the price for a single NFT under the right conditions
    function testPricing_ERC721Pricing_SettingSingleNFTPrice_Positive() public {
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 5000 * (10 ** 18));
        openOcean.setSingleNFTPrice(address(boredReptilianNFT), 1, 666 * (10 ** 16));
        assertEq(openOcean.getNFTPrice(address(boredReptilianNFT), 1), 666 * (10 ** 16));
    }

    function testPricing_ERC721Pricing_SettingSingleNFTPrice_Negative() public {
        switchToUser();
        vm.expectRevert("Ownable: caller is not the owner");
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
    }

    /// Testing setting the price for a whole NFT contract under the right conditions
    function testPricing_ERC721Pricing_SettingNFTCollectionPrice() public {
        openOcean.setNFTCollectionPrice(address(boredWhaleNFT), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 1000 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(boredReptilianNFT), 6669 * (10 ** 16));
        assertEq(openOcean.getNFTPrice(address(boredReptilianNFT), 1), 6669 * (10 ** 16));
    }

    /// Testing that single-NFT price will prevail over contract price
    function testPricing_ERC721Pricing_NFTPricePriority() public {
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(boredWhaleNFT), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 2), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 5000 * (10 ** 18));
    }

    /**
     * @dev Testing that the pricing contract checks effectively if the NFTcontract
     * is actually an ERC721. If it is not, then it will revert with custom error.
     * @notice currently not supporting ERC1155.
     */
    function testPricing_ERC721Pricing_SettingSingleNFTPrice_InvalidContract() public {
        bytes4 selector = bytes4(keccak256("NotAnNFTContract(address)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 0xBABE));
        openOcean.setSingleNFTPrice(address(0xBABE), 1, 5000 * (10 ** 18));
    }

    /// Testing that the pricing contract won't allow price setting to anyone but the owner
    function testPricing_ERC721Pricing_SettingSingleNFTPrice_NotOwner() public endWithStopPrank {
        vm.startPrank(bob);
        vm.expectRevert("Ownable: caller is not the owner");
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
    }
}

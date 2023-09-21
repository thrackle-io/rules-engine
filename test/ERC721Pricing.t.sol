// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;
import "../src/example/pricing/ApplicationERC721Pricing.sol";
import "../src/example/ERC721/not-upgradeable/ApplicationERC721AdminOrOwnerMint.sol";
import "../src/example/ApplicationAppManager.sol";
import "../src/example/application/ApplicationHandler.sol";
import "./DiamondTestUtil.sol";
import "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title Test For The NFTPricing Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests setting a price for a single NFT, for a whole collection
 * and getting the right amount when asked for the price. It also checks the enforcement
 * of the contract being an ERC721 contract before setting a price for an NFT
 * @notice It simulates an NFT-marketplace price source.
 */
contract ERC721PricingTest is DiamondTestUtil, RuleProcessorDiamondTestUtil {
    //storage variable declaration
    ApplicationERC721 boredWhaleNFT;
    ApplicationERC721 boredReptilianNFT;
    ApplicationERC721Pricing openOcean;
    RuleProcessorDiamond ruleProcessor;
    RuleStorageDiamond ruleStorageDiamond;
    ApplicationERC721Handler applicationNFTHandler;
    ApplicationERC721Handler applicationNFTHandler2;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    address bob = address(0xB0B);

    function setUp() public {
        vm.startPrank(superAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        /// Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        /// Deploy app manager
        appManager = new ApplicationAppManager(superAdmin, "Castlevania", false);
        applicationHandler = new ApplicationHandler(address(ruleProcessor), address(appManager));
        appManager.setNewApplicationHandlerAddress(address(applicationHandler));
        appManager.addAppAdministrator(appAdministrator);

        /// Set up the ApplicationERC721Handler
        boredWhaleNFT = new ApplicationERC721("Bored Whale Island Club", "BWYC", address(appManager), "https://SampleApp.io");
        applicationNFTHandler = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(boredWhaleNFT), false);
        boredWhaleNFT.connectHandlerToToken(address(applicationNFTHandler));
        boredReptilianNFT = new ApplicationERC721("Board Reptilian Spaceship Club", "BRSC", address(appManager), "https://SampleApp.io");
        applicationNFTHandler2 = new ApplicationERC721Handler(address(ruleProcessor), address(appManager), address(boredReptilianNFT), false);
        boredReptilianNFT.connectHandlerToToken(address(applicationNFTHandler2));

        /// Deploy the pricing contract
        openOcean = new ApplicationERC721Pricing();
    }

    function testERC721PricerVersion() public {
        string memory version = openOcean.version();
        assertEq(version, "1.1.0");
    }

    /// Testing setting the price for a single NFT under the right conditions
    function testSettingSingleNFTPrice() public {
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 5000 * (10 ** 18));
        openOcean.setSingleNFTPrice(address(boredReptilianNFT), 1, 666 * (10 ** 16));
        assertEq(openOcean.getNFTPrice(address(boredReptilianNFT), 1), 666 * (10 ** 16));
    }

    /// Testing setting the price for a whole NFT contract under the right conditions
    function testSettingNFTCollectionPrice() public {
        openOcean.setNFTCollectionPrice(address(boredWhaleNFT), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 1000 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(boredReptilianNFT), 6669 * (10 ** 16));
        assertEq(openOcean.getNFTPrice(address(boredReptilianNFT), 1), 6669 * (10 ** 16));
    }

    /// Testing that single-NFT price will prevail over contract price
    function testNFTPricePriority() public {
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(boredWhaleNFT), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 2), 1000 * (10 ** 18));
        assertEq(openOcean.getNFTPrice(address(boredWhaleNFT), 1), 5000 * (10 ** 18));
    }

    /**
     * @dev Testing that the pricing contract checks effectively if the NFTcontract
     * is actually an ERC721. If it is not, then it will revert with costum error.
     * @notice currently not supporting ERC1155.
     */
    function testSettingPriceFailingForInvalidContract() public {
        //vm.expectRevert("0x930bba61000000000000000000000000000000000000000000000000000000000000babe");
        vm.expectRevert();
        openOcean.setSingleNFTPrice(address(0xBABE), 1, 5000 * (10 ** 18));
    }

    /// Testing that the pricing contract won't allow price setting to anyone but the owner
    function testSettingPriceFailingForNotOwner() public {
        vm.stopPrank();
        vm.startPrank(bob);
        vm.expectRevert();
        openOcean.setSingleNFTPrice(address(boredWhaleNFT), 1, 5000 * (10 ** 18));
    }
}

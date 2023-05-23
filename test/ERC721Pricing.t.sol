// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "../src/example/pricing/ApplicationERC721Pricing.sol";
import "../src/example/ApplicationERC721.sol";
import "../src/example/ApplicationAppManager.sol";
import "./DiamondTestUtil.sol";
import "../src/economic/TokenRuleRouter.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import "../src/example/ApplicationERC721Handler.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import {TaggedRuleProcessorDiamondTestUtil} from "./TaggedRuleProcessorDiamondTestUtil.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";

/**
 * @title Test For The NFTPricing Contract
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev this contract tests setting a price for a single NFT, for a whole collection
 * and getting the right amount when asked for the price. It also checks the enforcement
 * of the contract being an ERC721 contract before setting a price for an NFT
 * @notice It simulates an NFT-marketplace price source.
 */
contract ERC721PricingTest is TaggedRuleProcessorDiamondTestUtil, DiamondTestUtil, RuleProcessorDiamondTestUtil {
    //storage variable declaration
    ApplicationERC721 boredWhaleNFT;
    ApplicationERC721 boredReptilianNFT;
    ApplicationERC721Pricing openOcean;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    RuleStorageDiamond ruleStorageDiamond;
    TokenRuleRouter tokenRuleRouter;
    ApplicationERC721Handler applicationNFTHandler;
    TokenRuleRouterProxy ruleRouterProxy;
    ApplicationAppManager appManager;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    address bob = address(0xB0B);

    function setUp() public {
        vm.startPrank(defaultAdmin);
        /// Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        /// Deploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        /// Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        /// Diploy the token rule processor diamond
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        ///connect data diamond with Tagged Rule Processor diamond
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleRouter = new TokenRuleRouter();
        //deploy and initialize Proxy to TokenRuleRouter
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));
        /// add the DEAD address as a application defaultAdmin
        /// Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", address(ruleRouterProxy), false);
        appManager.addAppAdministrator(appAdministrator);

        /// Set up the ApplicationERC721Handler
        applicationNFTHandler = new ApplicationERC721Handler(address(tokenRuleRouter), address(appManager));

        /// Deploy 2 NFT contracts
        boredWhaleNFT = new ApplicationERC721("Bored Whale Island Club", "BWYC", address(appManager), address(applicationNFTHandler), "https://SampleApp.io");
        boredReptilianNFT = new ApplicationERC721("Board Reptilian Spaceship Club", "BRSC", address(appManager), address(applicationNFTHandler), "https://SampleApp.io");

        /// Deploy the pricing contract
        openOcean = new ApplicationERC721Pricing();
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

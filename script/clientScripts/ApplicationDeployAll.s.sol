// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ERC20/ApplicationERC20Handler.sol";
import {ApplicationERC721Handler} from "src/example/ERC721/ApplicationERC721Handler.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationERC721} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "src/example/application/ApplicationHandler.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleAllowed.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";

/**
 * @title Application Deploy All Script
 * @dev This script will deploy all application contracts needed to test the protocol interactions.
 * @notice Deploys the application App Manager, AppManager, ERC20, ERC721, and associated handlers, pricing and oracle contracts.
 */
contract ApplicationDeployAllScript is Script {
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationERC721Handler applicationNFTHandler;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
    uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
    address[] applicationNFTAddresses;
    uint256 PERIOD_BETWEEN_TX_BATCHES_MS = 36_000; // 36 seconds ~2.4 blocks

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", false);
        ApplicationHandler applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
        vm.sleep(PERIOD_BETWEEN_TX_BATCHES_MS); // example of new cheat codes
        /// create ERC20 token 1
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1), false);
        coin1.connectHandlerToToken(address(applicationCoinHandler));
        
        /// create ERC20 token 2
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2), false);
        coin2.connectHandlerToToken(address(applicationCoinHandler2));
        
        /// oracle
        new OracleAllowed();
        new OracleDenied();
        
        /// create NFT
        ApplicationERC721 nft1 = new ApplicationERC721("Frankenstein", "FRANKPIC", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));
        

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationAppManager.registerToken("Frankenstein Picture", address(nft1));
        
        /// Set the token's prices
        ApplicationERC721Pricing openOcean = new ApplicationERC721Pricing();
        ApplicationERC20Pricing exchange = new ApplicationERC20Pricing();
        exchange.setSingleTokenPrice(address(coin1), 1 * (10 ** 18));
        exchange.setSingleTokenPrice(address(coin2), 1 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(nft1), 5 * (10 ** 18));
        
        /// Link the pricing module to the Franks ApplicationERC20Handler
        applicationCoinHandler.setERC20PricingAddress(address(exchange));
        applicationCoinHandler.setNFTPricingAddress(address(openOcean));
        applicationCoinHandler2.setERC20PricingAddress(address(exchange));
        applicationCoinHandler2.setNFTPricingAddress(address(openOcean));
        applicationNFTHandler.setERC20PricingAddress(address(exchange));
        applicationNFTHandler.setNFTPricingAddress(address(openOcean));
        

        /// register the coin treasury
        applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));
        
        /// This is a new app manager used for upgrade testing
        new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", true);
        new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1), true);
        
        /// Admin set up:
        /// Quorra sets Kevin as app admin
        applicationAppManager.addAppAdministrator(vm.envAddress("KEVIN"));

        /**
         * Kevin as App admin sets:
         * Clu = Rule admin
         * Clu = Rule Bypass account 
         * Gem = Access Tier admin
         * Sam = Risk admin
         */
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("KEVIN_PRIVATE_KEY"));
        applicationAppManager.addRuleAdministrator(vm.envAddress("CLU"));
        applicationAppManager.addAccessTier(vm.envAddress("GEM"));
        applicationAppManager.addRiskAdmin(vm.envAddress("CLU"));
        applicationAppManager.addRuleBypassAccount(vm.envAddress("CLU"));
        vm.stopBroadcast();
    }
}

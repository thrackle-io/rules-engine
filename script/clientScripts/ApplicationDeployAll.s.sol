// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationERC721AdminOrOwnerMint} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleApproved.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";
import "./DeployBase.s.sol";
import {VersionFacet} from "src/protocol/diamond/VersionFacet.sol";
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";

/**
 * @title Application Deploy All Script
 * @dev This script will deploy all application contracts needed to test the protocol interactions.
 * @notice Deploys the application App Manager, AppManager, ERC20, ERC721, and associated handlers, pricing and oracle contracts.
 */
contract ApplicationDeployAllScript is Script, DeployBase {
    ApplicationAppManager applicationAppManager;
    ApplicationHandler applicationHandler;
    HandlerDiamond applicationCoinHandlerDiamond;
    HandlerDiamond applicationCoinHandlerDiamond2;
    HandlerDiamond applicationNFTHandlerDiamond;
    ApplicationERC20 coin1;
    ApplicationERC20 coin2;
    ApplicationERC721AdminOrOwnerMint nft1;
    ApplicationERC721Pricing openOcean;
    ApplicationERC20Pricing exchange;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];
    uint128[7] yieldPerTimeUnitArray2 = [2, 120, 7_200, 172_800, 1_209_600, 5_184_000, 63_072_000];
    address[] applicationNFTAddresses;
    uint256 PERIOD_BETWEEN_TX_BATCHES_MS = 36_000; // 36 seconds ~2.4 blocks

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY"));
        applicationAppManager = new ApplicationAppManager(vm.envAddress("LOCAL_DEPLOYMENT_OWNER"), "Castlevania", false);
        applicationAppManager.addAppAdministrator(vm.envAddress("QUORRA"));
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
        vm.sleep(PERIOD_BETWEEN_TX_BATCHES_MS); // example of new cheat codes
        applicationAppManager.addRuleAdministrator(vm.envAddress("QUORRA"));
        /// create ERC20 token 1
        coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandlerDiamond = createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1));
        coin1.connectHandlerToToken(address(applicationCoinHandlerDiamond));

    
        
        /// create ERC20 token 2
        coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager));
        
        applicationCoinHandlerDiamond2 = createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond2)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2));
        coin2.connectHandlerToToken(address(applicationCoinHandlerDiamond2));

        /// oracle
        new OracleApproved();
        new OracleDenied();
        
        /// create NFT
        nft1 = new ApplicationERC721AdminOrOwnerMint("Frankenstein", "FRANKPIC", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandlerDiamond = createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(applicationNFTHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1));
        nft1.connectHandlerToToken(address(applicationNFTHandlerDiamond));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationAppManager.registerToken("Frankenstein Picture", address(nft1));
        
        /// Set the token's prices
        openOcean = new ApplicationERC721Pricing();
        exchange = new ApplicationERC20Pricing();
        exchange.setSingleTokenPrice(address(coin1), 1 * (10 ** 18));
        exchange.setSingleTokenPrice(address(coin2), 1 * (10 ** 18));
        openOcean.setNFTCollectionPrice(address(nft1), 5 * (10 ** 18));
        
        applicationAppManager.addRuleAdministrator(vm.envAddress("QUORRA"));

        /// Link the pricing module to the Application Handler
        applicationHandler.setERC20PricingAddress(address(exchange));
        applicationHandler.setNFTPricingAddress(address(openOcean));

        /// register the coin treasury
        applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));
        
        /// This is a new app manager used for upgrade testing
        new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", true);
        HandlerDiamond newApplicationNFTHandlerDiamond = createERC721HandlerDiamond();
        ERC721HandlerMainFacet(address(newApplicationNFTHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1));
        
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY"));

        /// Admin set up:
        /// Quorra sets Kevin as app admin
        applicationAppManager.addAppAdministrator(vm.envAddress("KEVIN"));

        /**
         * Kevin as App admin sets:
         * Clu = Rule admin
         * Clu = Rule Bypass account 
         * Gem = Access Level admin
         * Sam = Risk admin
         */
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("KEVIN_PRIVATE_KEY"));
        applicationAppManager.addRuleAdministrator(vm.envAddress("CLU"));
        applicationAppManager.addAccessLevelAdmin(vm.envAddress("GEM"));
        applicationAppManager.addRiskAdmin(vm.envAddress("CLU"));
        applicationAppManager.addRuleBypassAccount(vm.envAddress("CLU"));
        vm.stopBroadcast();

        // Verify Installation------------------------------------------------------------------
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        verifyAppManager();
        verifyERC20(true);
        verifyERC20(false);
        verifyERC721();
        vm.stopBroadcast();
        // --------------------------------------------------------------------------------------
    }

    function verifyAppManager() public view {
        // Checking to make sure AppManager is deployed, if not calling a public function on it will revert.
        applicationAppManager.version();

        // Checking to make sure the AppHandler has been deployed, if not calling a public function on it will revert.
        applicationHandler.version();

        // Checking to make sure the handler is connected back to the AppManager
        if(applicationHandler.appManagerAddress() != address(applicationAppManager)) {
            revert("Application Handler not correctly connected to the App Manager");
        }

        if(address(applicationAppManager.applicationHandler()) != address(applicationHandler)) {
            revert("Application Handler not correctly connected to the App Manager");
        }
    }

    function verifyERC721() public view {
        // Make sure the ERC721 Contract has been deployed, if not calling a public function on it will revert.
        nft1.getHandlerAddress();

       // Make sure the ERC721 Handler Contract has been deployed, if not calling a public function on it will revert.
       VersionFacet(address(applicationNFTHandlerDiamond)).version();

       // Make sure the ERC20 Pricing Module Contract has been deployed, if not calling a public function on it will revert.
       openOcean.version();

        // Checking to make sure ERC721 has a handler
        if(nft1.getHandlerAddress() != address(applicationNFTHandlerDiamond)) {
            revert("ERC721 not correctly connected to its handler");
        }

        // Checking to make sure the handler is connected to the ERC721
        if(ERC173Facet(address(applicationNFTHandlerDiamond)).owner() != address(nft1)) {
            revert("Handler is not connected properly to the ERC721");
        }

        // Checking to make sure the pricing modules are set within the ERC721's Handler
        if(applicationHandler.nftPricingAddress() != address(openOcean)) {
            revert("Pricing Module not correctly set in the Handler");
        }

        // Checking to make sure the ERC721 is registered with the AppManager
        if(nft1.getAppManagerAddress() != address(applicationAppManager)) {
            revert("ERC721 not properly registered with the AppManager");
        }

        if(keccak256(abi.encodePacked(applicationAppManager.getTokenID(address(nft1)))) != keccak256(abi.encodePacked("Frankenstein Picture"))) {
            revert("ERC721 not properly registered with the AppManager");
        }

        // Checking to make sure the ERC721's Handler is registered with the AppManager
        if(!applicationAppManager.isRegisteredHandler(address(applicationNFTHandlerDiamond))) {
            revert("ERC721 Handler not properly registered with the AppManager");
        }
    }

    function verifyERC20(bool isCoin1) public view {
       // Make sure the ERC20 Contract has been deployed, if not calling a public function on it will revert.
       isCoin1 ? coin1.getHandlerAddress() : coin2.getHandlerAddress();

       // Make sure the ERC20 Handler Contract has been deployed, if not calling a public function on it will revert.
       isCoin1 ? VersionFacet(address(applicationCoinHandlerDiamond)).version() :  VersionFacet(address(applicationCoinHandlerDiamond2)).version();

       // Make sure the ERC20 Pricing Module Contract has been deployed, if not calling a public function on it will revert.
        VersionFacet(address(exchange)).version();

        // Checking to make sure ERC20 has a handler
        if(isCoin1) {
            if( coin1.getHandlerAddress() != address(applicationCoinHandlerDiamond)) {
                revert("Frankenstein Coin not correctly connected to its handler");
            }
        } else {
            if( coin2.getHandlerAddress() != address(applicationCoinHandlerDiamond2)) {
                revert("Dracula Coin not correctly connected to its handler");
            }
        }

        // Checking to make sure the handler is connected to the ERC20
        if((isCoin1 ? ERC173Facet(address(applicationCoinHandlerDiamond)).owner() : ERC173Facet(address(applicationCoinHandlerDiamond2)).owner()) != address(isCoin1 ? coin1 : coin2)) {
            revert(isCoin1 ? "ERC20 Handlers owner should be the Frankenstein Coin" : "ERC20 Handlers owner should be the Dracula Coin");
        }

        // Checking to make sure the pricing modules are set within the ERC20's Handler
        if(applicationHandler.erc20PricingAddress() != address(exchange)) {
            revert("ERC20 Pricing module has not been set on the Handler");
        }

        // Checking to make sure the ERC20 is registered with the AppManager
        if( coin1.getAppManagerAddress() != address(applicationAppManager)) {
            revert("ERC20 not properly registered with the App Manager");
        }
        if(keccak256(abi.encodePacked(applicationAppManager.getTokenID(address(isCoin1 ? coin1 : coin2)))) != keccak256(abi.encodePacked(isCoin1 ? "Frankenstein Coin" : "Dracula Coin"))) {
            revert("ERC20 not properly registered with the App Manager");
        }

        // Checking to make sure the ERC20's Handler is registered with the AppManager
        if(!applicationAppManager.isRegisteredHandler(address(isCoin1 ? applicationCoinHandlerDiamond : applicationCoinHandlerDiamond2))) {
            revert("ERC20 Handler not registered with the App Manager");
        }
    }
}

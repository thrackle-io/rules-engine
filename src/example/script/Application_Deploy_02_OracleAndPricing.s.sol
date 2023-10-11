// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../application/ApplicationHandler.sol";
import "../ApplicationERC20Handler.sol";
import "../ApplicationERC20.sol";
import {ApplicationERC721Handler} from "../ApplicationERC721Handler.sol";
import {ApplicationERC721} from "../ERC721/not-upgradeable/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";
import "../OracleRestricted.sol";
import "../OracleAllowed.sol";
import "../pricing/ApplicationERC20Pricing.sol";
import "../pricing/ApplicationERC721Pricing.sol";

/**
 * @title Application Deploy All Script
 * @dev This script will deploy all application contracts needed to test the protocol interactions.
 * @notice Deploys the pricing and oracle contracts.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppMangerAndAssets.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_OracleAndPricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_04_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployOracleAndPricingScript is Script {
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve App Manager deployed from previous script 
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        ApplicationERC20Handler applicationCoinHandler = ApplicationERC20Handler(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS"));
        ApplicationERC20Handler applicationCoinHandler2 = ApplicationERC20Handler(vm.envAddress("APPLICATION_ERC20_HANDLER_ADDRESS_2"));
        ApplicationERC721Handler applicationNFTHandler = ApplicationERC721Handler(vm.envAddress("APPLICATION_ERC721_HANDLER"));
        
        /// Deploy Oracle Contracts 
        new OracleAllowed();
        new OracleRestricted();

        /// Set the token's prices
        ApplicationERC721Pricing openOcean = new ApplicationERC721Pricing();
        ApplicationERC20Pricing exchange = new ApplicationERC20Pricing();
        exchange.setSingleTokenPrice(vm.envAddress("APPLICATION_ERC20_ADDRESS"), 1 * (10 ** 18));
        exchange.setSingleTokenPrice(vm.envAddress("APPLICATION_ERC20_ADDRESS_2"), 1 * (10 ** 18));
        openOcean.setNFTCollectionPrice(vm.envAddress("APPLICATION_ERC721_ADDRESS_1"), 5 * (10 ** 18));
        /// Link the pricing module to the Asset Handlers
        applicationCoinHandler.setERC20PricingAddress(address(exchange));
        applicationCoinHandler.setNFTPricingAddress(address(openOcean));
        applicationCoinHandler2.setERC20PricingAddress(address(exchange));
        applicationCoinHandler2.setNFTPricingAddress(address(openOcean));
        applicationNFTHandler.setERC20PricingAddress(address(exchange));
        applicationNFTHandler.setNFTPricingAddress(address(openOcean));

        /// register the coin treasury
        applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));

        vm.stopBroadcast();
    }
}

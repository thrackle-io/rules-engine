// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import "src/example/ERC20/ApplicationERC20Handler.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationERC721Handler} from "src/example/ERC721/ApplicationERC721Handler.sol";
import {ApplicationERC721AdminOrOwnerMint} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "src/example/OracleDenied.sol";
import "src/example/OracleApproved.sol";
import "src/example/pricing/ApplicationERC20Pricing.sol";
import "src/example/pricing/ApplicationERC721Pricing.sol";

/**
 * @title Application Deploy 06 Pricing Script
 * @dev This script will deploy the pricing contracts and set dollar valuations for each deployed token.
 * @notice Deploys the pricing contracts.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script example/script/Application_Deploy_01_AppManger.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployPricingScript is Script {
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve App Manager deployed from previous script
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        ApplicationHandler applicationHandler = ApplicationHandler(vm.envAddress("APPLICATION_APP_HANDLER"));

        /// Set the token's prices
        ApplicationERC721Pricing openOcean = new ApplicationERC721Pricing();
        ApplicationERC20Pricing exchange = new ApplicationERC20Pricing();
        exchange.setSingleTokenPrice(vm.envAddress("APPLICATION_ERC20_ADDRESS"), 1 * (10 ** 18));
        exchange.setSingleTokenPrice(vm.envAddress("APPLICATION_ERC20_ADDRESS_2"), 1 * (10 ** 18));
        openOcean.setNFTCollectionPrice(vm.envAddress("APPLICATION_ERC721_ADDRESS_1"), 5 * (10 ** 18));
        /// Link the pricing module to the Asset Handlers
        applicationHandler.setERC20PricingAddress(address(exchange));
        applicationHandler.setNFTPricingAddress(address(openOcean));


        /// register the coin treasury
        applicationAppManager.registerTreasury(vm.envAddress("FEE_TREASURY"));

        vm.stopBroadcast();
    }
}

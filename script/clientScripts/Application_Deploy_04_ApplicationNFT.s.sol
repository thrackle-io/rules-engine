// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/application/ApplicationHandler.sol";
import {ApplicationERC721Handler} from "src/example/ERC721/ApplicationERC721Handler.sol";
import {ApplicationERC721AdminOrOwnerMint} from "src/example/ERC721/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";

/**
 * @title Application Deploy 04 Application Non-Fungible Token  Script
 * @dev This script will deploy an ERC721 non-fungible token and Handler.
 * @notice Deploys an application ERC721 non-fungible token and Handler..
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

contract ApplicationDeployNFTScript is Script {
    ApplicationERC721Handler applicationNFTHandler;
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve the App Manager from previous script
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));

        /// Create NFT
        ApplicationERC721AdminOrOwnerMint nft1 = new ApplicationERC721AdminOrOwnerMint("Clyde", "CLYDEPIC", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Clyde Picture", address(nft1));

        vm.stopBroadcast();
    }
}

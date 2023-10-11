// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../application/ApplicationHandler.sol";
import "../ApplicationERC20Handler.sol";
import "../ApplicationERC20.sol";
import {ApplicationERC721Handler} from "../ApplicationERC721Handler.sol";
import {ApplicationERC721} from "../ERC721/not-upgradeable/ApplicationERC721AdminOrOwnerMint.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";


/**
 * @title Application Deploy App Manager Script
 * @dev This script will deploy the App Manager, App Handler an ERC20 token and Handler and an ERC721 token and Handler Contract.
 * @notice Deploys the application App Manager, AppHandler, ERC20, ERC721, and associated handlers. 
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppMangerAndAssets.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_OracleAndPricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_04_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployAppManagerAndAssetsScript is Script {
    ApplicationERC20Handler applicationCoinHandler;
    ApplicationERC20Handler applicationCoinHandler2;
    ApplicationERC721Handler applicationNFTHandler;
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("DEPLOYMENT_OWNER"), "Castlevania", false);
        ApplicationHandler applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));

        /// Create ERC20 token 1
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1), false);
        coin1.connectHandlerToToken(address(applicationCoinHandler));

        /// Create ERC20 token 2
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager));
        applicationCoinHandler2 = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2), false);
        coin2.connectHandlerToToken(address(applicationCoinHandler2));

        /// Create NFT
        ApplicationERC721 nft1 = new ApplicationERC721("Clyde", "CLYDEPIC", address(applicationAppManager), vm.envString("APPLICATION_ERC721_URI_1"));
        applicationNFTHandler = new ApplicationERC721Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(nft1), false);
        nft1.connectHandlerToToken(address(applicationNFTHandler));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));
        applicationAppManager.registerToken("Dracula Coin", address(coin2));
        applicationAppManager.registerToken("Clyde Picture", address(nft1));

        vm.stopBroadcast();
    }
}

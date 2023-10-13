// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../application/ApplicationHandler.sol";
import "../ERC20/ApplicationERC20Handler.sol";
import "../ERC20/ApplicationERC20.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";

/**
 * @title Application Deploy 02 Application Fungible Token 1 Script
 * @dev This script will deploy an ERC20 fungible token and Handler.
 * @notice Deploys an application ERC20 and Handler.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppManger.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployFT1Script is Script {
    ApplicationERC20Handler applicationCoinHandler;
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve the App Manager from previous script
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));

        /// Create ERC20 token 1
        ApplicationERC20 coin1 = new ApplicationERC20("Frankenstein Coin", "FRANK", address(applicationAppManager));
        applicationCoinHandler = new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin1), false);
        coin1.connectHandlerToToken(address(applicationCoinHandler));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Frankenstein Coin", address(coin1));

        vm.stopBroadcast();
    }
}

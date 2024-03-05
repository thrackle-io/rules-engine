// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import "./Application_Deploy_02_ApplicationFT1.s.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "./DeployBase.s.sol";

/**
 * @title Application Deploy 03 Application Fungible Token 2 Script
 * @dev This script will deploy an ERC20 fungible token and Handler.
 * @notice Deploys an application ERC20 and Handler.
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script example/script/Application_Deploy_01_AppManager.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_02_ApplicationFT1.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_03_ApplicationFT2.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_04_ApplicationNFT.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_05_Oracle.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_06_Pricing.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * forge script example/script/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script example/script/Application_Deploy_08_UpgradeTesting.s.sol --ffi --rpc-url $RPC_URL --broadcast -vvvv
 */

contract ApplicationDeployFT2Script is Script, DeployBase {
    HandlerDiamond applicationCoinHandlerDiamond2;
    uint256 privateKey;
    address ownerAddress;
    uint256 appAdminKey;
    address appAdminAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        /// Retrieve the App Manager from previous script
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));

        /// Create ERC20 token 2
        ApplicationERC20 coin2 = new ApplicationERC20("Dracula Coin", "DRAC", address(applicationAppManager));
        applicationCoinHandlerDiamond2 = createERC20HandlerDiamond("Dracula Coin");
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond2)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), address(coin2));
        appAdminKey = vm.envUint("APP_ADMIN_PRIVATE_KEY_01");
        appAdminAddress = vm.envAddress("APP_ADMIN_01");
        vm.stopBroadcast();
        vm.startBroadcast(appAdminKey);
        coin2.connectHandlerToToken(address(applicationCoinHandlerDiamond2));

        /// Register the tokens with the application's app manager
        applicationAppManager.registerToken("Dracula Coin", address(coin2));

        vm.stopBroadcast();
    }
}

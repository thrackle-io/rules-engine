// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/ERC20/ApplicationERC20.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import {ApplicationHandler} from "src/example/application/ApplicationHandler.sol";
import "./DeployBase.s.sol";

/**
 * @title Application Deploy 08 App Manager For Upgrade Script
 * @dev This script will deploy the App Manager and an ERC20 token Handler.
 * @notice Deploys a new application App Manager and ERC20 handler. This is for upgrade testing only.
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

contract ApplicationDeployAppManagerForUpgradeScript is Script, DeployBase {
    uint256 privateKey;
    address ownerAddress;
    HandlerDiamond applicationCoinHandlerDiamond;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /// This is a new app manager used for upgrade testing
        new ApplicationAppManager(vm.envAddress("DEPLOYMENT_OWNER"), "Castlevania", true);
        applicationCoinHandlerDiamond = createERC20HandlerDiamond();
        ERC20HandlerMainFacet(address(applicationCoinHandlerDiamond)).initialize(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), vm.envAddress("APPLICATION_ERC20_ADDRESS"));
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../ApplicationERC20Handler.sol";
import "../ApplicationERC20.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";
import "../application/ApplicationHandler.sol";


/**
 * @title Application Deploy App Manager For Upgrade Script
 * @dev This script will deploy the App Manager and an ERC20 token Handler.
 * @notice Deploys a new application App Manager and ERC20 handler. This is for upgrade testing only.  
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppMangerAndAssets.s.sol --ffi --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_OracleAndPricing.s.sol --ffi --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationAdminRoles.s.sol --ffi --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_04_UpgradeTesting.s.sol --ffi --broadcast -vvvv
 */

contract ApplicationDeployAppManagerForUpgradeScript is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /// This is a new app manager used for upgrade testing
        new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", true);
        new ApplicationERC20Handler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager), vm.envAddress("APPLICATION_ERC20_ADDRESS"), true);
        vm.stopBroadcast();
    }
}
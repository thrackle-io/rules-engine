// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/example/application/ApplicationHandler.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";

/**
 * @title Application Deploy 07 Admin Roles Script
 * @dev This Script sets the admin roles for Application.
 * @notice This Script sets the admin roles for Application.
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

contract ApplicationAdminRolesScript is Script {
    uint256 appAdminKey;
    address appAdminAddress;

    function setUp() public {}

    function run() public {
        appAdminKey = vm.envUint("APP_ADMIN_PRIVATE_KEY_01");
        appAdminAddress = vm.envAddress("APP_ADMIN_01");
        vm.startBroadcast(appAdminKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /**
         * Admin set up:
         * SuperAdmin sets app admin
         * AppAdmin sets:
         * RULE_ADMIN = Rule admin
         * ACCESS_LEVEL_ADMIN = Access Level admin
         * RISK_ADMIN = Risk admin
         * RULE_BYPASS_ACCOUNT = rule bypass account 
         */
        if (vm.envAddress("LOCAL_RULE_ADMIN") != address(0x0)) {
            applicationAppManager.addRuleAdministrator(vm.envAddress("LOCAL_RULE_ADMIN"));
        }
        
        if (vm.envAddress("ACCESS_LEVEL_ADMIN") != address(0x0)) {
            applicationAppManager.addAccessLevelAdmin(vm.envAddress("ACCESS_LEVEL_ADMIN"));
        }

        if (vm.envAddress("RISK_ADMIN") != address(0x0)) {
            applicationAppManager.addRiskAdmin(vm.envAddress("RISK_ADMIN"));
        }
        if (vm.envAddress("RULE_BYPASS_ACCOUNT") != address(0x0)) {
            applicationAppManager.addRuleBypassAccount(vm.envAddress("RULE_BYPASS_ACCOUNT"));
        }
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/application/ApplicationHandler.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";

/**
 * @title Application Deploy 07 Admin Roles Script
 * @dev This Script sets the admin roles for Application.
 * @notice This Script sets the admin roles for Application.
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

contract ApplicationAdminRolesScript is Script {
    uint256 privateKey;
    address ownerAddress;

    function setUp() public {}

    function run() public {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /**
         * Admin set up:
         * SuperAdmin sets app admin
         * AppAdmin sets:
         * RULE_ADMIN = Rule admin
         * ACCESS_TIER_ADMIN = Access Tier admin
         * RISK_ADMIN = Risk admin
         */
        applicationAppManager.addAppAdministrator(vm.envAddress("APP_ADMIN"));
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("APP_ADMIN_PRIVATE_KEY"));
        applicationAppManager.addRuleAdministrator(vm.envAddress("RULE_ADMIN"));
        applicationAppManager.addAccessTier(vm.envAddress("ACCESS_TIER_ADMIN"));
        applicationAppManager.addRiskAdmin(vm.envAddress("RISK_ADMIN"));
        vm.stopBroadcast();
    }
}

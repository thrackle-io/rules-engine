// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../application/ApplicationHandler.sol";
import {ApplicationAppManager} from "../ApplicationAppManager.sol";


/**
 * @title Application Admin Roles Script
 * @dev This Script sets the admin roles for Application. 
 * @notice This Script sets the admin roles for Application. 
 * ** Requires .env variables to be set with correct addresses and Protocol Diamond addresses **
 * Deploy Scripts:
 * forge script src/example/script/Application_Deploy_01_AppMangerAndAssets.s.sol --ffi --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_02_OracleAndPricing.s.sol --ffi --broadcast -vvvv
 * forge script src/example/script/Application_Deploy_03_ApplicationAdminRoles.s.sol --ffi --broadcast -vvvv
 * <<<OPTIONAL>>>
 * forge script src/example/script/Application_Deploy_04_UpgradeTesting.s.sol --ffi --broadcast -vvvv
 */

contract ApplicationAdminRolesScript is Script {

    function setUp() public {}
    
    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        ApplicationAppManager applicationAppManager = ApplicationAppManager(vm.envAddress("APPLICATION_APP_MANAGER"));
        /** 
        * Admin set up: 
        * Quorra sets Kevin as app admin
        * Kevin as App admin sets:
        * Clu = Rule admin 
        * Gem = Access Tier admin 
        * Sam = Risk admin 
        */ 
        applicationAppManager.addAppAdministrator(vm.envAddress("KEVIN"));
        vm.stopBroadcast();
        vm.startBroadcast(vm.envUint("KEVIN_PRIVATE_KEY"));
        applicationAppManager.addRuleAdministrator(vm.envAddress("CLU"));
        applicationAppManager.addAccessTier(vm.envAddress("GEM"));
        applicationAppManager.addRiskAdmin(vm.envAddress("CLU"));
        vm.stopBroadcast();
    }
}
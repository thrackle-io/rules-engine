// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {ApplicationAppManager} from "src/example/application/ApplicationAppManager.sol";
import "src/example/application/ApplicationHandler.sol";

/**
 * @title App Manager Deployment Script
 * @notice This is the deployment script for the App Manager.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application App Manager.
 */
contract AppManagerScript is Script {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));
        ApplicationAppManager applicationAppManager = new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", false);
        ApplicationHandler applicationHandler = new ApplicationHandler(vm.envAddress("RULE_PROCESSOR_DIAMOND"), address(applicationAppManager));
        applicationAppManager.setNewApplicationHandlerAddress(address(applicationHandler));
        vm.stopBroadcast();
    }
}

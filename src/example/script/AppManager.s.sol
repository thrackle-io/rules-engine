// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import {ApplicationAppManager} from "src/example/ApplicationAppManager.sol";

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
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        new ApplicationAppManager(vm.envAddress("QUORRA"), "Castlevania", vm.envAddress("TOKEN_RULE_ROUTER_PROXY_CONTRACT"), false);
        vm.stopBroadcast();
    }
}

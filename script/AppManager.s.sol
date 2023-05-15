// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import {AppManager} from "src/application/AppManager.sol";

/// DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED
/**
 * @title AppManagerScript
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice Contract for deploy app manager functions. This deploys both the AppManager and the AccessControlServer
 * NOTE: THIS IS NO LONGER DEPLOYED BECAUSE THE ApplicationAppManager takes its place
 */
contract AppManagerScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY_01");

        vm.startBroadcast(privateKey);
        new AppManager(vm.envAddress("ADDRESS_01"), "Castlevania", false);

        vm.stopBroadcast();
    }
}

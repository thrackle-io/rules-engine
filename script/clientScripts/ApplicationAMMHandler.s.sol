// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/liquidity/ApplicationAMMHandler.sol";

/**
 * @title This is the deployment script for the Application AMM Handler.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application AMM Handler.
 */

contract ApplicationAMMHandlerScript is Script {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));
        new ApplicationAMMHandler(vm.envAddress("APP_MANAGER"), vm.envAddress("RULE_PROCESSOR_DIAMOND"), vm.envAddress("APPLICATION_AMM"), false);

        vm.stopBroadcast();
    }
}

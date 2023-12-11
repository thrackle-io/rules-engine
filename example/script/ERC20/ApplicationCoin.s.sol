// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../../ERC20/ApplicationERC20.sol";
import "../src/client/tokenapplication/IAppManager.sol";

/**
 * @title This is the deployment script for the Application Coin ERC20.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Application Coin ERC20.
 */

contract ApplicationERC20Script is Script {
    function setUp() public {}

    /**
     * @dev This function runs the script
     */
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));

        new ApplicationERC20("Frankenstein Coin", "FRANK", vm.envAddress("APPLICATION_APP_MANAGER"));
        // Register the token with the application's app manager
        IAppManager(vm.envAddress("APPLICATION_APP_MANAGER")).registerToken("Frankenstein Coin", address(this));
        vm.stopBroadcast();
    }
}

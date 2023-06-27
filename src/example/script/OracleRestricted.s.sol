// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/OracleRestricted.sol";

/**
 * @title Create the Restricted Oracle
 * @notice This creates the Restricted Oracle
 * @dev As basic as create scripts get with the exception of needing all the setup addresses.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract OracleRestrictedScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER"));
        new OracleRestricted();
        vm.stopBroadcast();
    }
}

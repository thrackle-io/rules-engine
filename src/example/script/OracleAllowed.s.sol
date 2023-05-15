// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/OracleAllowed.sol";

/**
 * @title Create the Allow Oracle
 * @notice This creates the Allow Oracle
 * @dev As basic as create scripts get with the exception of needing all the setup addresses.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract OracleAllowedScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        new OracleAllowed();
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/liquidity/ApplicationAMMCalcCP.sol";

/**
 * @title Create the AMM Constant Product Calculator
 * @notice This creates the AMM Constant Product Calculator
 * @dev As basic as create scripts get.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMCalcCPScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));

        new ApplicationAMMCalcCP();
        vm.stopBroadcast();
    }
}

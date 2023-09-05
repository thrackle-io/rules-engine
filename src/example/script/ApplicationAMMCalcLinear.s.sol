// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/example/liquidity/ApplicationAMMCalcLinear.sol";

/**
 * @title Create the AMM Linear Calculator
 * @notice This creates the AMM Linear Calculator
 * @dev As basic as create scripts get.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMCalcLinearScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER_KEY"));

        new ApplicationAMMCalcLinear();
        vm.stopBroadcast();
    }
}

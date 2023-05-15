// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/liquidity/ApplicationAMM.sol";

/**
 * @title Create the AMM
 * @notice This creates the AMM
 * @dev As basic as create scripts get with the exception of needing all the setup addresses.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ApplicationAMMScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));

        new ApplicationAMM(
            vm.envAddress("APPLICATION_ERC20_ADDRESS"),
            vm.envAddress("APPLICATION_ERC20_ADDRESS_2"),
            vm.envAddress("APPLICATION_APP_MANAGER"),
            vm.envAddress("APPLICATION_AMM_LINEAR_CALCULATOR_ADDRESS"),
            vm.envAddress("APPLICATION_AMM_HANDLER")
        );
        vm.stopBroadcast();
    }
}

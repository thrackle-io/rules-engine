// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../staking/ERC20Staking.sol";

/**
 * @title Create a ERC20 Staking Contract
 * @dev creates a staking contracts with APPLICATION_ERC20_ADDRESS as the
 * staking token and APPLICATION_ERC20_ADDRESS_2 as rewards token
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC20StakingContractScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER"));
        new ERC20Staking(vm.envAddress("APPLICATION_ERC20_ADDRESS_2"), vm.envAddress("APPLICATION_ERC20_ADDRESS"), vm.envAddress("APPLICATION_APP_MANAGER"));
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/staking/ERC20AutoMintStaking.sol";

/**
 * @title Create a ERC20 Auto Mint Staking Contract
 * @dev creates a staking contracts with APPLICATION_ERC20_ADDRESS as the
 * staking token and APPLICATION_ERC20_ADDRESS_2 as rewards token which is
 * automatically minted during rewardsClaim by the staking contract.
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC20AutoMintStakingDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("QUORRA_PRIVATE_KEY"));
        new ERC20AutoMintStaking(vm.envAddress("APPLICATION_ERC20_ADDRESS_2"), vm.envAddress("APPLICATION_ERC20_ADDRESS"), vm.envAddress("APPLICATION_APP_MANAGER"));
        vm.stopBroadcast();
    }
}

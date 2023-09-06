// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "src/example/staking/ERC721Staking.sol";

/**
 * @title Create a ERC721 Staking Contract
 * @dev creates a staking contracts with APPLICATION_ERC20_ADDRESS_2 as rewards token and APPLICATION_ERC721_ADDRESS_1 as stakeable NFT
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 */
contract ERC721StakingContractScript is Script {
    address[] applicationTokenAddressArray;
    uint128[7] yieldPerTimeUnitArray = [1, 60, 3_600, 86_400, 604_800, 2_592_000, 31_536_000];

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYMENT_OWNER"));
        applicationTokenAddressArray = [vm.envAddress("APPLICATION_ERC721_ADDRESS_1")];

        uint128[7][] memory rewardsPerAddress = new uint128[7][](2);
        rewardsPerAddress[0] = yieldPerTimeUnitArray;
        new ERC721Staking(vm.envAddress("APPLICATION_ERC20_ADDRESS_2"), applicationTokenAddressArray, rewardsPerAddress, vm.envAddress("APPLICATION_APP_MANAGER"));
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import {ApplicationERC20Pricing} from "../src/example/pricing/ApplicationERC20Pricing.sol";

/**
 * @title ERC20Pricing Deployment Script
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev Contract for deploying the ERC20Pricing contract. You can think of this contract as a dummy
 * Coinbase that is only useful to assign value to ERC20's, but no trading operation can be made.
 */
contract ERC20PricingScript is Script {
    function setUp() public {}

    function run() public {
        vm.setEnv("PRIVATE_KEY", "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        new ApplicationERC20Pricing();
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import {TokenRuleRouter} from "../src/economic/TokenRuleRouter.sol";

/// DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED
/**
 * @title TokenRuleRouterScript
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice Contract for deploy token rule router functions. This deploys both the AppManager and the AccessControlServer
 * NOTE: THIS IS NO LONGER DEPLOYED BECAUSE THE ApplicationAppManager takes its place
 */
contract TokenRuleRouterScript is Script {
    function setUp() public {}

    function run() public {
        vm.setEnv("PRIVATE_KEY", "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
        vm.setEnv("OWNER_ADDRESS", "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        new TokenRuleRouter();
        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "src/protocol/economic/ruleProcessor/RuleApplicationValidationFacet.sol";
import "script/EnabledActionPerRuleArray.sol";

/**
 * @title The Post Deployment Configuration Step For The Protocol
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @notice This contract sets the enabled actions per rule
 */

contract DeployAllModulesPt4Script is Script, EnabledActionPerRuleArray {
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        setEnabledActionsPerRule();

        vm.stopBroadcast();
    }

    /**
     * @dev set the enabled actions per rule according to the official list in EnabledActionPerRuleArray
     */
    function setEnabledActionsPerRule() internal {
        address ruleProcessorAddress = vm.envAddress("RULE_PROCESSOR_DIAMOND");
        for (uint i; i < enabledActionPerRuleArray.length; ++i) {
            RuleApplicationValidationFacet(ruleProcessorAddress).enabledActionsInRule(enabledActionPerRuleArray[i].ruleName, enabledActionPerRuleArray[i].enabledActions);
            console.log("setup enabled actions for", string(abi.encodePacked(enabledActionPerRuleArray[i].ruleName)));
        }
        console.log("Done! setup all enabled actions");
    }
}

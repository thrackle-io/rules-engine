// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
// import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
// import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
// import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
// import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
// import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
// import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
// import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
// import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
// import {DiamondScriptUtil} from "./DiamondScriptUtil.sol";
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
        privateKey = vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        setEnabledActionsPerRule();

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the set of facets
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

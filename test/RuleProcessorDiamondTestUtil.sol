// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "./helpers/GenerateSelectors.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import "diamond-std/core/DiamondCut/FacetCut.sol";
import "./RuleStorageDiamondTestUtil.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "../src/economic/ruleStorage/RuleStorageDiamond.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "../src/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {RuleDataFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {INonTaggedRules as NonTaggedRules} from "../src/economic/ruleStorage/RuleDataInterfaces.sol";

contract RuleProcessorDiamondTestUtil is GenerateSelectors, RuleStorageDiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _RuleProcessorFacetCuts;

    function getRuleProcessorDiamond() public returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[11] memory facets = [
            // Native facets,
            "ProtocolNativeFacet",
            // Raw implementation facets.
            "ProtocolRawFacet",
            // Protocol facets.
            //rule processor facets
            "ERC721RuleProcessorFacet",
            "ERC20RuleProcessorFacet",
            "FeeRuleProcessorFacet",
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet",
            //TaggedRuleFacets:
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RiskTaggedRuleProcessorFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        // Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            // Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            // Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            // Create the FacetCut struct for this facet.
            _RuleProcessorFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        // Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new RuleProcessorDiamond(_RuleProcessorFacetCuts, diamondArgs);
    }
}

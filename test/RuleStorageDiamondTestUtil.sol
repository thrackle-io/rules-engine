// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "./helpers/GenerateSelectors.sol";
import "../src/diamond/core/DiamondCut/FacetCut.sol";
import {IDiamondInit} from "../src/diamond/initializers/IDiamondInit.sol";
import {DiamondInit} from "../src/diamond/initializers/DiamondInit.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "../src/economic/ruleStorage/RuleStorageDiamond.sol";
import {RuleDataFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {IDiamondCut} from "../src/diamond/core/DiamondCut/IDiamondCut.sol";

contract RuleStorageDiamondTestUtil is GenerateSelectors {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _econFacetCuts;

    function getRuleStorageDiamond() public returns (RuleStorageDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[8] memory facets = [
            // Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            // Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            // Protocol facets.
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "FeeRuleDataFacet",
            "AppRuleDataFacet"
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
            _econFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        // Build the DiamondArgs.
        RuleStorageDiamondArgs memory diamondArgs = RuleStorageDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new RuleStorageDiamond(_econFacetCuts, diamondArgs);
    }
}

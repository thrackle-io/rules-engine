// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "./helpers/GenerateSelectors.sol";
import {IDiamondInit} from "../src/diamond/initializers/IDiamondInit.sol";
import {DiamondInit} from "../src/diamond/initializers/DiamondInit.sol";

import {FacetCut, FacetCutAction} from "../src/diamond/core/DiamondCut/DiamondCutLib.sol";

import {ApplicationRuleProcessorDiamond, DiamondArgs} from "../src/economic/ruleProcessor/application/ApplicationRuleProcessorDiamond.sol";
// import {AppManager} from "../src/application/AppManager.sol";
import {ApplicationPauseProcessorFacet} from "../src/economic/ruleProcessor/application/ApplicationPauseProcessorFacet.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {IDiamondCut} from "../src/diamond/core/DiamondCut/IDiamondCut.sol";

contract DiamondTestUtil is GenerateSelectors {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _facetCuts;
    ApplicationRuleProcessorDiamond applicationRuleProcessorDiamond;
    address defaultAdmin = address(0xDEFAD);
    address appAdminstrator = address(0xAAA);
    address AccessTier = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);

    function getApplicationProcessorDiamond() public returns (ApplicationRuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[7] memory facets = [
            // Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            // Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            // Protocol facets.
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet"
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
            _facetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        // Build the DiamondArgs.
        DiamondArgs memory diamondArgs = DiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new ApplicationRuleProcessorDiamond(_facetCuts, diamondArgs);
    }
}

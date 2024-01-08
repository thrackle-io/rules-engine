// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";

/**
 * @title The initial deployment script for the Protocol. It deploys the first group of facets.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @notice This contract deploys the first group of facets
 * @dev This script will set contract addresses needed by protocol interaction in connectAndSetUpAll()
 */

contract DeployAllModulesPt1Script is Script {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    FacetCut[] private _facetCutsRuleProcessor;
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;

    RuleProcessorDiamond ruleProcessorDiamond;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        privateKey = vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        deployFirstSetOfFacets();

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the Meta Controls Diamond
     */
    function deployFirstSetOfFacets() internal {

        /// Register all facets.
        string[9] memory facets = [
            // diamond version
            "VersionFacet",
            /// Native facets,
            "ProtocolNativeFacet",
            /// Raw implementation facets.
            "ProtocolRawFacet",
            /// Protocol facets.
            "ERC20RuleProcessorFacet",
            "ERC721RuleProcessorFacet",
            "FeeRuleProcessorFacet",
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(facet, ".sol"));
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }
        }
    }
}
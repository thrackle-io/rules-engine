// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "../src/economic/ruleStorage/RuleStorageDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";

/**
 * @title The first deployment script for the Protocol. It deploys the storage diamond only.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @notice This contract deploys All Contracts for the Protocol
 * @dev This script will only deploy the storage diamond and all of its facets. This script was broken up to reduce the CUPS during deployment
 * and to make deployment issues easier to track down.
 */

contract DeployAllModulesScript is Script {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    FacetCut[] private _facetCutsData;
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;

    RuleStorageDiamond ruleDataDiamond;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        vm.startBroadcast(privateKey);

        ruleDataDiamond = deployRuleDataDiamond();

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the Economic Rules Diamond
     * @return RuleStorageDiamond address once deployed
     */

    function deployRuleDataDiamond() internal returns (RuleStorageDiamond) {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[6] memory facets = [
            /// Native facets,
            "ProtocolNativeFacet",
            /// Raw implementation facets.
            "ProtocolRawFacet",
            /// Protocol facets.
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "AppRuleDataFacet",
            "FeeRuleDataFacet"
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

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsData.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        RuleStorageDiamondArgs memory diamondArgs = RuleStorageDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });
        /// Deploy the diamond.
        RuleStorageDiamond diamond = new RuleStorageDiamond(_facetCutsData, diamondArgs);

        return diamond;
    }
}

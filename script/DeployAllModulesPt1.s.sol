// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import {DiamondScriptUtil} from "./DiamondScriptUtil.sol";

/**
 * @title The initial deployment script for the Protocol. It deploys the rule processor diamond and the initial set of facets.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @notice This contract deploys the rule processor diamond and the initial set of facets
 * @dev This script will set contract addresses needed by protocol interaction in connectAndSetUpAll()
 */

contract DeployAllModulesPt1Script is Script, DiamondScriptUtil {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    FacetCut[] private _facetCutsRuleProcessor;
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;
    bool recordAllChains;

    RuleProcessorDiamond ruleProcessorDiamond;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("DEPLOYMENT_OWNER");
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        vm.startBroadcast(privateKey);

        ruleProcessorDiamond = deployRuleProcessorDiamond();

        vm.stopBroadcast();
    }

    /**
     * @dev Deploy the Meta Controls Diamond
     * @return RuleProcessorDiamond address once deployed
     */
    function deployRuleProcessorDiamond() internal returns (RuleProcessorDiamond) {
        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[5] memory facets = [
            // diamond version
            "VersionFacet",
            /// Native facets,
            "ProtocolNativeFacet",
            /// Raw implementation facets.
            "ProtocolRawFacet",
            /// Protocol facets.
            "ERC20RuleProcessorFacet",
            "ERC721RuleProcessorFacet"
        ];

        string[5] memory directories = [
            "./out/VersionFacet.sol/",
            "./out/ProtocolNativeFacet.sol/",
            "./out/ProtocolRawFacet.sol/",
            "./out/ERC20RuleProcessorFacet.sol/",
            "./out/ERC721RuleProcessorFacet.sol/"
        ];

        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";

        /// Loop on each facet, deploy them and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            string memory directory = directories[facetIndex];

            /// Deploy the facet.
            bytes memory bytecode = vm.getCode(string.concat(directory, string.concat(facet, ".json")));
        
            address facetAddress;
            assembly {
                facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            }

            /// Get the facet selectors.
            getSelectorsInput[2] = facet;
            bytes memory res = vm.ffi(getSelectorsInput);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsRuleProcessor.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
            recordFacet("ProtocolProcessorDiamond", facet, facetAddress, recordAllChains);
        }

        /// Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Deploy the diamond.
        RuleProcessorDiamond ruleProcessorDiamondDiamond = new RuleProcessorDiamond(_facetCutsRuleProcessor, diamondArgs);

        /// record the diamond address
        recordFacet("ProtocolProcessorDiamond", "diamond", address(ruleProcessorDiamondDiamond), recordAllChains);

        /// we update the value of the RULE_PROCESSOR_DIAMOND in the env file
        setENVVariable("RULE_PROCESSOR_DIAMOND", vm.toString(address(ruleProcessorDiamondDiamond)));

        console.log("Deployed Rule Processor diamond at", address(ruleProcessorDiamondDiamond));
        return ruleProcessorDiamondDiamond;
    }
}

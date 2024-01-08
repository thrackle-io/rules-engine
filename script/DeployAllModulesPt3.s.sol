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
import {ERC20RuleProcessorFacet} from "src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";

/**
 * @title The final deployment script for the Protocol. It deploys the Rule Processor Diamond.
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @notice This contract deploys the Rule Processor Diamond.
 * @dev This script will set contract addresses needed by protocol interaction in connectAndSetUpAll()
 */

contract DeployAllModulesPt3Script is Script {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    /// address and private key used to for deployment
    uint256 privateKey;
    address ownerAddress;
    RuleProcessorDiamond ruleProcessorDiamond;
    FacetCut[] private _facetCutsRuleProcessor;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {
        privateKey = vm.envUint("LOCAL_DEPLOYMENT_OWNER_KEY");
        ownerAddress = vm.envAddress("LOCAL_DEPLOYMENT_OWNER");
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
        string[17] memory facets = [
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
            "ApplicationPauseProcessorFacet",
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RiskTaggedRuleProcessorFacet",
            "RuleApplicationValidationFacet",
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "AppRuleDataFacet",
            "FeeRuleDataFacet"
        ];

        string[17] memory facetAddresses = [
            "VERSION_FACET",
            "PROTOCOL_NATIVE_FACET",
            "PROTOCOL_RAW_FACET",
            "ERC20_RULE_PROCESSOR",
            "ERC721_RULE_PROCESSOR",
            "FEE_RULE_PROCESSOR",
            "APPLICATION_RISK_PROCESSOR",
            "APPLICATION_ACCESS_LEVEL_PROCESSOR",
            "APPLICATION_PAUSE_PROCESSOR",
            "ERC20_TAGGED_RULE_PROCESSOR",
            "ERC721_TAGGED_RULE_PROCESSOR",
            "RISK_TAGGED_RULE_PROCESSOR",
            "RULE_APPLICATION_VALIDATION",
            "RULE_DATA",
            "TAGGED_RULE_DATA",
            "APP_RULE_DATA",
            "FEE_RULE_DATA"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors.py";

        /// Loop on each facet, grab the address from the appropriate env variable, and create the FacetCut.
        for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
            string memory facet = facets[facetIndex];
            //Retrieve the address
            address facetAddress = vm.envAddress(facetAddresses[facetIndex]);

            /// Get the facet selectors.
            inputs[2] = facet;
            bytes memory res = vm.ffi(inputs);
            bytes4[] memory selectors = abi.decode(res, (bytes4[]));

            /// Create the FacetCut struct for this facet.
            _facetCutsRuleProcessor.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // /// Deploy the diamond.
        RuleProcessorDiamond ruleProcessorDiamondDiamond = new RuleProcessorDiamond(_facetCutsRuleProcessor, diamondArgs);

        return ruleProcessorDiamondDiamond;

    }

}
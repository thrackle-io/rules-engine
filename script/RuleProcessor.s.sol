// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {IDiamondInit} from "../src/diamond/initializers/IDiamondInit.sol";
import {DiamondInit} from "../src/diamond/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "../src/diamond/core/DiamondCut/DiamondCutLib.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "../src/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {IDiamondCut} from "../src/diamond/core/DiamondCut/IDiamondCut.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";

/**
 * @title Rule Processor Diamond Deploy Script
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract deploys the Rule Processor Diamond
 */
contract RuleProcessorModuleScript is Test {
    /// Store the FacetCut struct for each facet that is being deployed.
    /// NOTE: using storage array to easily "push" new FacetCut as we
    /// process the facets.
    FacetCut[] private _facetCuts;

    function run() external {
        vm.setEnv("PRIVATE_KEY", "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
        vm.setEnv("OWNER_ADDRESS", "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
        vm.setEnv("GLOBAL_ACTION", "GLOBAL_ACTION");

        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        RuleProcessorDiamond tokenRuleProcessorsDiamond;

        /// Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        /// Register all facets.
        string[13] memory facets = [
            /// Native facets,
            "DiamondCutFacet",
            "DiamondLoupeFacet",
            /// Raw implementation facets.
            "ERC165Facet",
            "ERC173Facet",
            /// Protocol facets.
            ///ruleProcessor (Rules setters and getters)
            "ERC20RuleProcessorFacet",
            "ERC721RuleProcessorFacet",
            "FeeRuleProcessorFacet",
            "ApplicationRiskProcessorFacet",
            "ApplicationAccessLevelProcessorFacet",
            "ApplicationPauseProcessorFacet",
            "ERC20TaggedRuleProcessorFacet",
            "ERC721TaggedRuleProcessorFacet",
            "RiskTaggedRuleProcessorFacet"
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
            _facetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        }

        /// Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            /// NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        /// Deploy the diamond.
        tokenRuleProcessorsDiamond = new RuleProcessorDiamond(_facetCuts, diamondArgs);

        vm.stopBroadcast();
    }
}

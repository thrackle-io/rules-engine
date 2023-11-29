// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
// diamond contracts
import {RuleProcessorDiamond, RuleProcessorDiamondArgs} from "src/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
// diamond facets
// storage facets
import "src/diamond/VersionFacet.sol";
import "src/diamond/ProtocolNativeFacet.sol";
import "src/diamond/ProtocolRawFacet.sol";
import "src/economic/ruleProcessor/FeeRuleDataFacet.sol";
import "src/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import "src/economic/ruleProcessor/RuleDataFacet.sol";
import "src/economic/ruleProcessor/AppRuleDataFacet.sol";
import "src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import "src/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol";
import "src/economic/ruleProcessor/ApplicationRiskProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC721RuleProcessorFacet.sol";
import "src/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/FeeRuleProcessorFacet.sol";
import "src/economic/ruleProcessor/RuleApplicationValidationFacet.sol";
import "src/economic/ruleProcessor/RiskTaggedRuleProcessorFacet.sol";

abstract contract TestCommonRuleProcessorDiamond is Test {
    FacetCut[] _ruleProcessorFacetCuts;
    FacetCut[] _ruleStorageFacetCuts;

    string[] inputs = ["python3", "script/python/get_selectors.py", ""];

    /**
     * @dev Deploy and set up the Rules Storage Diamond
     * @return diamond fully configured storage diamond
     */
    function _createRuleProcessorDiamond() internal returns (RuleProcessorDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Deploy the facet.
        address facetAddress;
        bytes4[] memory selectors;

        // VersionFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(VersionFacet).creationCode, "VersionFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ProtocolNativeFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(ProtocolNativeFacet).creationCode, "ProtocolNativeFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ProtocolRawFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(ProtocolRawFacet).creationCode, "ProtocolRawFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // RuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(RuleDataFacet).creationCode, "RuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // TaggedRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(TaggedRuleDataFacet).creationCode, "TaggedRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // AppRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(AppRuleDataFacet).creationCode, "AppRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // FeeRuleDataFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "FeeRuleDataFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ERC721RuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ERC721RuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ERC20RuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ERC20RuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // FeeRuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "FeeRuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ApplicationRiskProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ApplicationRiskProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ApplicationAccessLevelProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ApplicationAccessLevelProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ApplicationPauseProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ApplicationPauseProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ERC20TaggedRuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ERC20TaggedRuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // ERC721TaggedRuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "ERC721TaggedRuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // RiskTaggedRuleProcessorFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "RiskTaggedRuleProcessorFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));

        // RuleApplicationValidationFacet
        (facetAddress, selectors) = _deployFacetAndGetSelectors(type(FeeRuleDataFacet).creationCode, "RuleApplicationValidationFacet");
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));


        // Build the DiamondArgs.
        RuleProcessorDiamondArgs memory diamondArgs = RuleProcessorDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new RuleProcessorDiamond(_ruleStorageFacetCuts, diamondArgs);
    }

    /**
     * @dev deploy a facet and return its address
     */
    function _deployFacetAndGetSelectors(bytes memory _bytecode, string memory _facetName) internal returns (address _facetAddress, bytes4[] memory _selectors) {
        // deploy the facet
        assembly {
            _facetAddress := create(0, add(_bytecode, 0x20), mload(_bytecode))
        }

        // Get the facet selectors.
        inputs[2] = _facetName;
        bytes memory res = vm.ffi(inputs);
        _selectors = abi.decode(res, (bytes4[]));
        return (_facetAddress, _selectors);
    }
}

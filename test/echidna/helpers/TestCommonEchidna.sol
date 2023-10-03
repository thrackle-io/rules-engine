// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/example/ApplicationAppManager.sol";
import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {RuleStorageDiamond, RuleStorageDiamondArgs} from "src/economic/ruleStorage/RuleStorageDiamond.sol";
import "src/diamond/VersionFacet.sol";

abstract contract TestCommonEchidna is Test {
    // common addresses
    address superAdmin = address(0xDaBEEF);
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address accessLevelAdmin = address(0xBBB);
    address riskAdmin = address(0xCCC);
    address user = address(0xDDD);
    address priorAddress;
    event Log(string desc, bytes ffiBytes);

    // common block time
    uint64 Blocktime = 1769924800;

    // shared objects
    ApplicationAppManager applicationAppManager;
    FacetCut[] _ruleStorageFacetCuts;

    /**
     * @dev Deploy and set up the Rules Storage Diamond
     * @return diamond fully configured storage diamond
     */
    function _createRuleStorageDiamond() internal returns (RuleStorageDiamond diamond) {
        // Start by deploying the DiamonInit contract.
        DiamondInit diamondInit = new DiamondInit();

        // Register all facets.
        string[7] memory facets = [
            // diamond version
            "VersionFacet",
            // Native facets,
            "ProtocolNativeFacet",
            // Raw implementation facets.
            "ProtocolRawFacet",
            // Protocol facets.
            "RuleDataFacet",
            "TaggedRuleDataFacet",
            "FeeRuleDataFacet",
            "AppRuleDataFacet"
        ];

        string[] memory inputs = new string[](3);
        inputs[0] = "python3";
        inputs[1] = "script/python/get_selectors_echidna.py";

        // Loop on each facet, deploy them and create the FacetCut.
        // for (uint256 facetIndex = 0; facetIndex < facets.length; facetIndex++) {
        string memory facet = facets[0];

        // Deploy the facet.
        bytes memory bytecode = type(VersionFacet).creationCode;
        address facetAddress;
        assembly {
            facetAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        // Get the facet selectors.
        inputs[2] = facet;
        bytes memory res = vm.ffi(inputs);
        emit Log("LOOK HERE!!!!", res);
        bytes4[] memory selectors = abi.decode(res, (bytes4[]));

        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: facetAddress, action: FacetCutAction.Add, functionSelectors: selectors}));
        // }

        // Build the DiamondArgs.
        RuleStorageDiamondArgs memory diamondArgs = RuleStorageDiamondArgs({
            init: address(diamondInit),
            // NOTE: "interfaceId" can be used since "init" is the only function in IDiamondInit.
            initCalldata: abi.encode(type(IDiamondInit).interfaceId)
        });

        // Deploy the diamond.
        return new RuleStorageDiamond(_ruleStorageFacetCuts, diamondArgs);
    }

    /**
     * @dev Deploy and set up an AppManager
     * @param _owner _owner the address to own the app manager
     * @return _appManager fully configured app manager
     */
    function _createAppManager(address _owner) public returns (ApplicationAppManager _appManager) {
        _appManager = new ApplicationAppManager(_owner, "Castlevania", false);
        return _appManager;
    }
}

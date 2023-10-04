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
import "src/diamond/ProtocolNativeFacet.sol";
import "src/diamond/ProtocolRawFacet.sol";
import "src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import "src/economic/ruleStorage/FeeRuleDataFacet.sol";
import "src/economic/ruleStorage/AppRuleDataFacet.sol";
import "src/economic/ruleStorage/RuleDataFacet.sol";

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

        // facet variable creation
        // VersionFacet = versionFacet;
        // ProtocolNativeFacet = protocolNativeFacet;
        // ProtocolRawFacet = protocolRawFacet;
        // RuleDataFacet = ruleDataFacet;
        // TaggedRuleDataFacet = taggedRuleDataFacet;
        // FeeRuleDataFacet = feeRuleDataFacet;
        // AppRuleDataFacet = appRuleDataFacet;

        /**
        [(VersionFacet, 0, [0x7240f9af, 0x54fd4d50]), (ProtocolNativeFacet, 0, [0x1f931c1c, 0xcdffacc6, 0x52ef6b2c, 0xadfca15e, 0x7a0ed627]), (ProtocolRawFacet, 0, [0x8da5cb5b, 0x01ffc9a7, 0xf2fde38b]), (RuleDataFacet, 0, [0x533bdbdd, 0x544e1925, 0xa95cd8d6, 0xaf682b30, 0x0a93913a, 0xe323230f, 0xc1f33c35, 0xd7dc52b7, 0x082639b0, 0xcc716708, 0xeb05e556, 0x264f146f, 0x3b72a921, 0x7fe4e919, 0x72204214, 0x7565fb1a, 0x74c285ea, 0x5243bd1c, 0xcbdc1a47, 0xcf28c7b2, 0xf2bfba88, 0x821e6d87, 0x03d4e11b, 0x22a65479, 0x6dc6cc4e, 0xdcf93def, 0x75e5bfb6]), (TaggedRuleDataFacet, 0, [0x42682fad, 0xb7827c0b, 0x975b0ff4, 0xdfaf0cda, 0x8680ba12, 0xe43ecfc4, 0x693fb42d, 0xbc30df39, 0x64955c2a, 0xb3d5a70a, 0xcffdaff4, 0xfbe53234, 0x812fe11b, 0x2e169722, 0xa1e99c5e, 0x2d014ea7, 0x3532c660, 0xb07cccd0, 0xf1eb1e62, 0x628014c7, 0x366a73a4]), (AppRuleDataFacet, 0, [0x6580f653, 0x6e119fe0, 0x576a3a62, 0x74bf3050, 0x208e9610, 0x16ea2065, 0x01ab3a1a, 0xfcb2e84b, 0x9ca69a1b, 0x64a78c33, 0x1cbc74ca, 0x62228418]), (FeeRuleDataFacet, 0, [0x834bc653, 0xd87952f7, 0x7253e0ac])]
         */

        {// VersionFacet
        // Deploy the facet.
        bytes memory versionFacetBytecode = type(VersionFacet).creationCode;
        address versionFacetAddress;
        assembly {
            versionFacetAddress := create(0, add(versionFacetBytecode, 0x20), mload(versionFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory versionFacetSelectors = new bytes4[](2);
        versionFacetSelectors[0] =  0x7240f9af;
        versionFacetSelectors[1] =  0x54fd4d50;
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: versionFacetAddress, action: FacetCutAction.Add, functionSelectors: versionFacetSelectors}));
        }
        {
        // ProtocolNativeFacet
        // Deploy the facet.
        bytes memory protocolNativeFacetBytecode = type(ProtocolNativeFacet).creationCode;
        address protocolNativeFacetAddress;
        assembly {
            protocolNativeFacetAddress := create(0, add(protocolNativeFacetBytecode, 0x20), mload(protocolNativeFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory protocolNativeFacetSelectors = new bytes4[](5);
        protocolNativeFacetSelectors[0] =  0x1f931c1c;
        protocolNativeFacetSelectors[1] =  0xcdffacc6;
        protocolNativeFacetSelectors[2] =  0x52ef6b2c;
        protocolNativeFacetSelectors[3] =  0xadfca15e;
        protocolNativeFacetSelectors[4] =  0x7a0ed627;
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: protocolNativeFacetAddress, action: FacetCutAction.Add, functionSelectors: protocolNativeFacetSelectors}));
        }
        {
        // ProtocolRawFacet
        // Deploy the facet.
        bytes memory protocolRawFacetBytecode = type(ProtocolRawFacet).creationCode;
        address protocolRawFacetAddress;
        assembly {
            protocolRawFacetAddress := create(0, add(protocolRawFacetBytecode, 0x20), mload(protocolRawFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory protocolRawFacetSelectors = new bytes4[](3); 
        protocolRawFacetSelectors[0] =  0x8da5cb5b;
        protocolRawFacetSelectors[1] =  0x01ffc9a7;
        protocolRawFacetSelectors[2] =  0xf2fde38b;
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: protocolRawFacetAddress, action: FacetCutAction.Add, functionSelectors: protocolRawFacetSelectors}));
        }
        {
        // RuleDataFacet
        // Deploy the facet.
        bytes memory ruleDataFacetBytecode = type(RuleDataFacet).creationCode;
        address ruleDataFacetAddress;
        assembly {
            ruleDataFacetAddress := create(0, add(ruleDataFacetBytecode, 0x20), mload(ruleDataFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory ruleDataFacetSelectors = new bytes4[](27);
        ruleDataFacetSelectors[0] =  0x533bdbdd;
        ruleDataFacetSelectors[1] =  0x544e1925;
        ruleDataFacetSelectors[2] =  0xa95cd8d6;
        ruleDataFacetSelectors[3] =  0xaf682b30;
        ruleDataFacetSelectors[4] =  0x0a93913a;
        ruleDataFacetSelectors[5] =  0xe323230f;
        ruleDataFacetSelectors[6] =  0xc1f33c35;
        ruleDataFacetSelectors[7] =  0xd7dc52b7;
        ruleDataFacetSelectors[8] =  0x082639b0;
        ruleDataFacetSelectors[9] =  0x75e5bfb6;
        ruleDataFacetSelectors[10] =  0xcc716708;
        ruleDataFacetSelectors[11] =  0xeb05e556;
        ruleDataFacetSelectors[12] =  0x264f146f;
        ruleDataFacetSelectors[13] =  0x3b72a921;
        ruleDataFacetSelectors[14] =  0x7fe4e919;
        ruleDataFacetSelectors[15] =  0x72204214;
        ruleDataFacetSelectors[16] =  0x7565fb1a;
        ruleDataFacetSelectors[17] =  0x74c285ea;
        ruleDataFacetSelectors[18] =  0x5243bd1c;
        ruleDataFacetSelectors[19] =  0xcbdc1a47;
        ruleDataFacetSelectors[20] =  0xcf28c7b2;
        ruleDataFacetSelectors[21] =  0xf2bfba88;
        ruleDataFacetSelectors[22] =  0x821e6d87;
        ruleDataFacetSelectors[23] =  0x03d4e11b;
        ruleDataFacetSelectors[24] =  0x22a65479;
        ruleDataFacetSelectors[25] =  0x6dc6cc4e;
        ruleDataFacetSelectors[26] =  0xdcf93def;

        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: ruleDataFacetAddress, action: FacetCutAction.Add, functionSelectors: ruleDataFacetSelectors}));
        }
        {
        // TaggedRuleDataFacet
        // Deploy the facet.
        bytes memory taggedRuleDataFacetBytecode = type(TaggedRuleDataFacet).creationCode;
        address taggedRuleDataFacetAddress;
        assembly {
            taggedRuleDataFacetAddress := create(0, add(taggedRuleDataFacetBytecode, 0x20), mload(taggedRuleDataFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory taggedRuleDataFacetSelectors = new bytes4[](21); 
        taggedRuleDataFacetSelectors[0] =  0x42682fad;
        taggedRuleDataFacetSelectors[1] =  0xb7827c0b;
        taggedRuleDataFacetSelectors[2] =  0x975b0ff4;
        taggedRuleDataFacetSelectors[3] =  0x366a73a4;
        taggedRuleDataFacetSelectors[4] =  0xdfaf0cda;
        taggedRuleDataFacetSelectors[5] =  0x8680ba12;
        taggedRuleDataFacetSelectors[6] =  0xe43ecfc4;
        taggedRuleDataFacetSelectors[7] =  0x693fb42d;
        taggedRuleDataFacetSelectors[8] =  0xbc30df39;
        taggedRuleDataFacetSelectors[9] =  0x64955c2a;
        taggedRuleDataFacetSelectors[10] =  0xb3d5a70a;
        taggedRuleDataFacetSelectors[11] =  0xcffdaff4;
        taggedRuleDataFacetSelectors[12] =  0xfbe53234;
        taggedRuleDataFacetSelectors[13] =  0x812fe11b;
        taggedRuleDataFacetSelectors[14] =  0x2e169722;
        taggedRuleDataFacetSelectors[15] =  0xa1e99c5e;
        taggedRuleDataFacetSelectors[16] =  0x2d014ea7;
        taggedRuleDataFacetSelectors[17] =  0x3532c660;
        taggedRuleDataFacetSelectors[18] =  0xb07cccd0;
        taggedRuleDataFacetSelectors[19] =  0xf1eb1e62;
        taggedRuleDataFacetSelectors[20] =  0x628014c7;
              
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: taggedRuleDataFacetAddress, action: FacetCutAction.Add, functionSelectors: taggedRuleDataFacetSelectors}));
        }
        {
        // AppRuleDataFacet
        // Deploy the facet.
        bytes memory appRuleDataFacetBytecode = type(AppRuleDataFacet).creationCode;
        address appRuleDataFacetAddress;
        assembly {
            appRuleDataFacetAddress := create(0, add(appRuleDataFacetBytecode, 0x20), mload(appRuleDataFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory appRuleDataFacetFacetSelectors = new bytes4[](12);
        appRuleDataFacetFacetSelectors[0] =  0x6580f653;
        appRuleDataFacetFacetSelectors[1] =  0x6e119fe0;
        appRuleDataFacetFacetSelectors[2] =  0x576a3a62;
        appRuleDataFacetFacetSelectors[3] =  0x74bf3050;
        appRuleDataFacetFacetSelectors[4] =  0x208e9610;
        appRuleDataFacetFacetSelectors[5] =  0x16ea2065;
        appRuleDataFacetFacetSelectors[6] =  0x01ab3a1a;
        appRuleDataFacetFacetSelectors[7] =  0xfcb2e84b;
        appRuleDataFacetFacetSelectors[8] =  0x9ca69a1b;
        appRuleDataFacetFacetSelectors[9] =  0x64a78c33;
        appRuleDataFacetFacetSelectors[10] =  0x1cbc74ca;
        appRuleDataFacetFacetSelectors[11] =  0x62228418;     
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: appRuleDataFacetAddress, action: FacetCutAction.Add, functionSelectors: appRuleDataFacetFacetSelectors}));
        }
       {
        // FeeRuleDataFacet
        // Deploy the facet.
        bytes memory feeRuleDataFacetBytecode = type(FeeRuleDataFacet).creationCode;
        address feeRuleDataFacetAddress;
        assembly {
            feeRuleDataFacetAddress := create(0, add(feeRuleDataFacetBytecode, 0x20), mload(feeRuleDataFacetBytecode))
        }
        // Get the facet selectors.
        bytes4[] memory feeRuleDataFacetSelectors = new bytes4[](3);
        feeRuleDataFacetSelectors[0] =  0x834bc653;
        feeRuleDataFacetSelectors[1] =  0xd87952f7;
        feeRuleDataFacetSelectors[2] =  0x7253e0ac; 
        // Create the FacetCut struct for this facet.
        _ruleStorageFacetCuts.push(FacetCut({facetAddress: feeRuleDataFacetAddress, action: FacetCutAction.Add, functionSelectors: feeRuleDataFacetSelectors}));
       }
        
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

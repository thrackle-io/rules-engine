// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {IDiamondInit} from "diamond-std/initializers/IDiamondInit.sol";
import {IDiamondLoupe} from "diamond-std/core/DiamondLoupe/IDiamondLoupe.sol";
import {DiamondInit} from "diamond-std/initializers/DiamondInit.sol";
import {FacetCut, FacetCutAction} from "diamond-std/core/DiamondCut/DiamondCutLib.sol";
import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {IDiamondCut} from "diamond-std/core/DiamondCut/IDiamondCut.sol";
import {TaggedRuleDataFacet} from "src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import "./clientScripts/DeployBase.s.sol";

/**
 * @title Revert A Facet Upgrade
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @notice This script takes the configuration variables from the root .env file and reverts 
 * a faulty upgrade of a diamond. It also relies in the recorded deployments.
 * @dev This contract removes a faulty facet, and updates the diamond to point to a previous one.
 */

contract RevertAFacetupgrade is Script, DeployBase {


    /// NOTE these values must be configured in the local env file
    uint256 privateKey;
    string facetNameToRevert;
    string diamond;
    address revertToFacetAddress;
    bool recordAllChains;

    /**
     * @dev This is the main function that gets called by the Makefile or CLI
     */
    function run() external {

        privateKey = vm.envUint("DEPLOYMENT_OWNER_KEY");
        recordAllChains = vm.envBool("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS");
        facetNameToRevert = vm.envString("FACET_NAME_TO_REVERT");
        validateFacetNameToRevert(facetNameToRevert);
        diamond = vm.envString("DIAMOND_TO_UPGRADE");
        validateDiamondToUpgrade(diamond);
        revertToFacetAddress = vm.envAddress("REVERT_TO_FACET_ADDRESS");
        validateRevertToFacetAddress(revertToFacetAddress);
        vm.startBroadcast(privateKey);
        (address facetAddress, address diamondAddress) = getFacetAddressAndDiamond();
        removeFaultySelectors(diamondAddress, getFacetSelectors(facetAddress, diamondAddress));
        putBackOriginalFacet(diamondAddress);
        vm.stopBroadcast();
    }

    function getFacetAddressAndDiamond() internal returns(address facetAddress, address diamondAddress){
        string[] memory getFacetAddressInput = new string[](6);
        getFacetAddressInput[0] = "python3";
        getFacetAddressInput[1] = "script/python/get_latest_facet_address.py";
        getFacetAddressInput[2] = diamond;
        getFacetAddressInput[3] = facetNameToRevert;
        getFacetAddressInput[4] = vm.toString(block.chainid);
        getFacetAddressInput[5] = vm.toString(block.timestamp);
        bytes memory res = vm.ffi(getFacetAddressInput);
        address[2] memory addresses = abi.decode(res, (address[2]));
        facetAddress = addresses[0]; 
        diamondAddress = addresses[1];
    }

    function getFacetSelectors(address facetAddress, address diamondAddres ) internal view returns(bytes4[] memory selectors){
        selectors =  IDiamondLoupe(diamondAddres).facetFunctionSelectors(facetAddress);
    }

    function removeFaultySelectors(address diamondAddres, bytes4[] memory selectors) internal {
        FacetCut[] memory facetCutRemove = new FacetCut[](1);
        facetCutRemove[0] = FacetCut({facetAddress: address(0), action: FacetCutAction.Remove, functionSelectors: selectors});
        IDiamondCut(diamondAddres).diamondCut(facetCutRemove, address(0x0), "");
        
        /// verify that the old facet has been removed
        for(uint i; i < selectors.length; i++){
            try IDiamondLoupe(diamondAddres).facetAddress(selectors[i]) returns (address _facet){
                if(_facet != address(0))
                    revert("not removed");
            }catch{ }
        }
        console.log("Verified old selectors are removed from the diamond. ");
    }

    function putBackOriginalFacet(address diamondAddres) internal {

        string[] memory getSelectorsInput = new string[](3);
        getSelectorsInput[0] = "python3";
        getSelectorsInput[1] = "script/python/get_selectors.py";
        getSelectorsInput[2] = facetNameToRevert;
        /// Get the facet selectors.
        bytes memory res = vm.ffi(getSelectorsInput);
        bytes4[] memory newSelectors = abi.decode(res, (bytes4[]));

        FacetCut[] memory facetCutAdd = new FacetCut[](1); 
        facetCutAdd[0] = FacetCut({facetAddress: revertToFacetAddress, action: FacetCutAction.Add, functionSelectors: newSelectors});
        IDiamondCut(diamondAddres).diamondCut(facetCutAdd, address(0x0), "");
        // we verify that the upgrade was successfull
        bytes4[] memory verifiedSelectors =  IDiamondLoupe(diamondAddres).facetFunctionSelectors(revertToFacetAddress);
        
        for(uint i; i < newSelectors.length; i++){
            assert(revertToFacetAddress == IDiamondLoupe(diamondAddres).facetAddress(newSelectors[i]));
        }
        console.log("Verified all new selectors use the new facet address.");

        for(uint i; i < newSelectors.length; i++){
            assert(newSelectors[i] == verifiedSelectors[i]);
        }
        console.log("Verified new selectors are in the blockchain");

        /// we can now update the deployment record with the facet
        recordFacet(diamond, facetNameToRevert, revertToFacetAddress, recordAllChains);

        /// we clear the env
        setENVVariable("FACET_NAME_TO_REVERT", "");
        setENVVariable("DIAMOND_TO_UPGRADE", "");
        setENVVariable("REVERT_TO_FACET_ADDRESS", "");
        setENVVariable("RECORD_DEPLOYMENTS_FOR_ALL_CHAINS", "false");
        console.log("env file cleared for future safe deployments.");

    }
    
}

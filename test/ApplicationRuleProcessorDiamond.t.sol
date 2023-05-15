// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./DiamondTestUtil.sol";
import {IDiamondInit} from "../src/diamond/initializers/IDiamondInit.sol";
import {DiamondInit} from "../src/diamond/initializers/DiamondInit.sol";

import {FacetCut, FacetCutAction} from "../src/diamond/core/DiamondCut/DiamondCutLib.sol";

import {ApplicationRuleProcessorDiamond, DiamondArgs} from "../src/economic/ruleProcessor/application/ApplicationRuleProcessorDiamond.sol";
// import {AppManager} from "../src/application/AppManager.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {IDiamondCut} from "../src/diamond/core/DiamondCut/IDiamondCut.sol";

contract ApplicationRuleProcessorDiamondTest is Test, DiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _facetCuts;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the diamond.
        applicationRuleProcessorDiamond = getApplicationProcessorDiamond();
    }

    /// Test to make sure that the Diamond will upgrade
    function testUpgrade() public {
        SampleFacet sampleFacet = new SampleFacet();
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](1);
        console.log("before generate selectors");
        cut[0] = (FacetCut({facetAddress: address(sampleFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("SampleFacet")}));
        console.log("after generate selectors");
        //upgrade diamond
        IDiamondCut(address(applicationRuleProcessorDiamond)).diamondCut(cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(applicationRuleProcessorDiamond)).owner());
        //console.log("TestFacet owner: ");
        //console.log(SampleFacet(address(applicationRuleProcessorDiamond)).getOwner());
        ERC173Facet(address(applicationRuleProcessorDiamond)).transferOwnership(defaultAdmin);

        // call a function
        assertEq("good", SampleFacet(address(applicationRuleProcessorDiamond)).sampleFunction());
    }
}

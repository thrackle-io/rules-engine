// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidnaV2.sol";
import "src/economic/ruleStorage/RuleStorageDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {FeeRuleProcessorFacet} from "src/economic/ruleProcessor/FeeRuleProcessorFacet.sol"; // for upgrade test only

/**
 * @title TestRuleStorageDiamond Internal Echidna Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the internal tests for RuleStorageDiamond
 */
contract TestRuleStorageDiamond is TestCommonEchidna {
    RuleStorageDiamond ruleStorageDiamond;

    constructor() {}

    /* ------------------------------ INVARIANTS -------------------------------- */
    /// Test the Default Admin roles
    function testGood() public {
        vm.startPrank(superAdmin);
        ruleStorageDiamond = _createRuleStorageDiamond();
        assert(true);
        
        SampleFacet sampleFacet = new SampleFacet();
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](1);
        console.log("before generate selectors");
        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = 0x25d4b981; // bytes4(keccak256(bytes('sampleFunction()'))); 
        cut[0] = (FacetCut({facetAddress: address(sampleFacet), action: FacetCutAction.Add, functionSelectors: selectors}));
        console.log("after generate selectors");
        //upgrade diamond
        IDiamondCut(address(ruleStorageDiamond)).diamondCut(cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(ruleStorageDiamond)).owner());

        // call a function
        assertEq("good", SampleFacet(address(ruleStorageDiamond)).sampleFunction());

        /// test transfer ownership
        address newOwner = address(0xB00B);
        ERC173Facet(address(ruleStorageDiamond)).transferOwnership(newOwner);
        address retrievedOwner = ERC173Facet(address(ruleStorageDiamond)).owner();
        assertEq(retrievedOwner, newOwner);

        /// test that an onlyOwner function will fail when called by not the owner
        vm.expectRevert("UNAUTHORIZED");
        SampleFacet(address(ruleStorageDiamond)).sampleFunction();

        FeeRuleProcessorFacet testFacet = new FeeRuleProcessorFacet();
        //build new cut struct
        console.log("before generate selectors");
        selectors[0] = 0xeb7012f4; // bytes4(keccak256(bytes('madeUpFunction()'))); 
        cut[0] = (FacetCut({facetAddress: address(testFacet), action: FacetCutAction.Add, functionSelectors: selectors}));
        console.log("after generate selectors");

        // test that account that isn't the owner cannot upgrade
        vm.stopPrank();
        vm.startPrank(superAdmin);
        //upgrade diamond
        vm.expectRevert("UNAUTHORIZED");
        IDiamondCut(address(ruleStorageDiamond)).diamondCut(cut, address(0x0), "");

        //test that the newOwner can upgrade
        vm.stopPrank();
        vm.startPrank(newOwner);
        IDiamondCut(address(ruleStorageDiamond)).diamondCut(cut, address(0x0), "");
        retrievedOwner = ERC173Facet(address(ruleStorageDiamond)).owner();
        assertEq(retrievedOwner, newOwner);

        // call a function
        assertEq("good", SampleFacet(address(ruleStorageDiamond)).sampleFunction());
    }
}

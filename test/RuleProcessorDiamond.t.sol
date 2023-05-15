// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import "../src/economic/ruleProcessor/nontagged/ERC20RuleProcessorFacet.sol";
import "../src/application/AppManager.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";

contract RuleProcessorDiamondTest is Test, RuleProcessorDiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    AppManager public appManager;
    address defaultAdmin = address(0xAD);
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address appAdminstrator = address(0xDEAD);
    address ac;

    RuleStorageDiamond ruleStorageDiamond;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Diploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Deploy app manager
        appManager = new AppManager(defaultAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdminstrator);
        ac = address(appManager);
    }

    /// Test to make sure that the Diamond will upgrade
    function testUpgrade() public {
        SampleFacet _sampleFacet = new SampleFacet();
        //build _cut struct
        FacetCut[] memory _cut = new FacetCut[](1);
        _cut[0] = (FacetCut({facetAddress: address(_sampleFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("SampleFacet")}));
        IDiamondCut(address(tokenRuleProcessorsDiamond)).diamondCut(_cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(tokenRuleProcessorsDiamond)).owner());
        ERC173Facet(address(tokenRuleProcessorsDiamond)).transferOwnership(defaultAdmin);

        // call a function
        assertEq("good", SampleFacet(address(tokenRuleProcessorsDiamond)).sampleFunction());
    }

    function testAddMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        assertEq(RuleDataFacet(address(ruleStorageDiamond)).getMinimumTransferRule(index), 1000);
    }

    function testFailAddMinTransferRuleByNonAdmin() public {
        vm.stopPrank();
        vm.startPrank(address(0xDEADA55));
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
    }

    function testPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 2222);

        ERC20RuleProcessorFacet(address(tokenRuleProcessorsDiamond)).checkMinTransferPasses(index, 2222);
    }

    function testNotPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 420);
        vm.expectRevert(0x70311aa2);
        ERC20RuleProcessorFacet(address(tokenRuleProcessorsDiamond)).checkMinTransferPasses(index, 400);
    }

    function testCheckingAgainstAnInexistentRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 69);
        vm.expectRevert(0x4bdf3b46);
        ERC20RuleProcessorFacet(address(tokenRuleProcessorsDiamond)).checkMinTransferPasses(index + 1, 70);
    }
}

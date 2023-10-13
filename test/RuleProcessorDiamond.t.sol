// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import {ERC20RuleProcessorFacet} from "../src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "../src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import "../src/application/AppManager.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {VersionFacet} from "../src/diamond/VersionFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";

import "../src/example/ERC20/ApplicationERC20Handler.sol";
import {ApplicationERC20} from "../src/example/ERC20/ApplicationERC20.sol";

contract RuleProcessorDiamondTest is Test, RuleProcessorDiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    AppManager public appManager;
    address superAdmin = address(0xDaBEEF);
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address appAdministrator = address(0xDEAD);
    address ruleAdmin = address(0xACDC);
    address ac;
    ApplicationERC20 public applicationCoin;
    RuleProcessorDiamond public ruleProcessor;
    ApplicationERC20Handler applicationCoinHandler;
    RuleStorageDiamond ruleStorageDiamond;

    function setUp() public {
        vm.startPrank(superAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Diploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();
        // Connect the ruleProcessor into the ruleStorageDiamond
        ruleProcessor.setRuleDataDiamond(address(ruleStorageDiamond));

        // Deploy app manager
        appManager = new AppManager(superAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        // add the ACDC address as a rule administrator
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addRuleAdministrator(ruleAdmin);
        ac = address(appManager);

        applicationCoin = new ApplicationERC20("application", "GMC", address(appManager));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleProcessor), address(appManager), address(applicationCoin), false);
        applicationCoin.connectHandlerToToken(address(applicationCoinHandler));
        applicationCoin.mint(superAdmin, 10000000000000000000000);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
    }

    /// Test to make sure that the Diamond will upgrade
    function testUpgradeRuleProcessor() public {
        // must be the owner for upgrade
        vm.stopPrank();
        vm.startPrank(superAdmin);
        SampleFacet _sampleFacet = new SampleFacet();
        //build cut struct
        FacetCut[] memory cut = new FacetCut[](1);
        cut[0] = (FacetCut({facetAddress: address(_sampleFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("SampleFacet")}));
        //upgrade diamond
        IDiamondCut(address(ruleProcessor)).diamondCut(cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(ruleProcessor)).owner());

        // call a function
        assertEq("good", SampleFacet(address(ruleProcessor)).sampleFunction());

        /// test transfer ownership
        address newOwner = address(0xB00B);
        ERC173Facet(address(ruleProcessor)).transferOwnership(newOwner);
        address retrievedOwner = ERC173Facet(address(ruleProcessor)).owner();
        assertEq(retrievedOwner, newOwner);

        /// test that an onlyOwner function will fail when called by not the owner
        vm.expectRevert("UNAUTHORIZED");
        SampleFacet(address(ruleProcessor)).sampleFunction();

        AppRuleDataFacet testFacet = new AppRuleDataFacet();
        //build new cut struct
        console.log("before generate selectors");
        cut[0] = (FacetCut({facetAddress: address(testFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("AppRuleDataFacet")}));
        console.log("after generate selectors");

        // test that account that isn't the owner cannot upgrade
        vm.stopPrank();
        vm.startPrank(superAdmin);
        //upgrade diamond
        vm.expectRevert("UNAUTHORIZED");
        IDiamondCut(address(ruleProcessor)).diamondCut(cut, address(0x0), "");

        //test that the newOwner can upgrade
        vm.stopPrank();
        vm.startPrank(newOwner);
        IDiamondCut(address(ruleProcessor)).diamondCut(cut, address(0x0), "");
        retrievedOwner = ERC173Facet(address(ruleProcessor)).owner();
        assertEq(retrievedOwner, newOwner);

        // call a function
        assertEq("good", SampleFacet(address(ruleProcessor)).sampleFunction());
    }

    function testAddMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        assertEq(RuleDataFacet(address(ruleStorageDiamond)).getMinimumTransferRule(index).minTransferAmount, 1000);
    }

    function testRuleProcessorVersion() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        // update version
        VersionFacet(address(ruleProcessor)).updateVersion("1,0,0"); // commas are used here to avoid upgrade_version-script replacements
        string memory version = VersionFacet(address(ruleProcessor)).version();
        console.log(version);
        assertEq(version, "1,0,0");
        // update version again
        VersionFacet(address(ruleProcessor)).updateVersion("1.1.0"); // upgrade_version script will replace this version
        version = VersionFacet(address(ruleProcessor)).version();
        console.log(version);
        assertEq(version, "1.1.0");
        // test that no other than the owner can update the version
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        vm.expectRevert("UNAUTHORIZED");
        VersionFacet(address(ruleProcessor)).updateVersion("6,6,6"); // this is done to avoid upgrade_version-script replace this version
        version = VersionFacet(address(ruleProcessor)).version();
        console.log(version);
        // make sure that the version didn't change
        assertEq(version, "1.1.0");
    }

    function testFailAddMinTransferRuleByNonAdmin() public {
        vm.stopPrank();
        vm.startPrank(address(0xDEADA55));
        RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 1000);
        vm.stopPrank();
        vm.startPrank(superAdmin);
    }

    function testPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 2222);

        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 2222);
    }

    function testNotPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 420);
        vm.expectRevert(0x70311aa2);
        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 400);
    }

    function testMinAccountBalanceCheck() public {
        bytes32[] memory accs = new bytes32[](3);
        uint256[] memory min = new uint256[](3);
        uint256[] memory max = new uint256[](3);

        // add the actual rule

        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(10);
        min[1] = uint256(20);
        min[2] = uint256(30);
        max[0] = uint256(10000000000000000000000000);
        max[1] = uint256(10000000000000000000000000000);
        max[2] = uint256(1000000000000000000000000000000);
        // add empty rule at ruleId 0
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testMaxTagEnforcementThroughMinAccountBalanceCheck() public {
        bytes32[] memory accs = new bytes32[](3);
        uint256[] memory min = new uint256[](3);
        uint256[] memory max = new uint256[](3);

        // add the actual rule

        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(10);
        min[1] = uint256(20);
        min[2] = uint256(30);
        max[0] = uint256(10000000000000000000000000);
        max[1] = uint256(10000000000000000000000000000);
        max[2] = uint256(1000000000000000000000000000000);
        // add empty rule at ruleId 0
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        for (uint i = 1; i < 11; i++) {
            appManager.addGeneralTag(superAdmin, bytes32(i)); //add tag
        }
        vm.expectRevert(0xa3afb2e2);
        appManager.addGeneralTag(superAdmin, "xtra tag"); //add tag should fail
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = new bytes32[](11);
        for (uint i = 1; i < 12; i++) {
            tags[i - 1] = bytes32(i); //add tag
        }
        console.log(uint(tags[10]));
        vm.expectRevert(0xa3afb2e2);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(10000000000000000000000, tags, amount, ruleId);
    }

    function testFailsMinAccountBalanceCheck() public {
        // add empty rule at ruleId 0
        bytes32[] memory accs = new bytes32[](3);
        uint256[] memory min = new uint256[](3);
        uint256[] memory max = new uint256[](3);

        // add the actual rule
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(10);
        min[1] = uint256(20);
        min[2] = uint256(30);
        max[0] = uint256(10000000000000000000000000);
        max[1] = uint256(10000000000000000000000000000);
        max[2] = uint256(1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(superAdmin);

        //vm.expectRevert(0xf1737570);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testMaxAccountBalanceCheck() public {
        // add empty rule at ruleId 0
        bytes32[] memory accs = new bytes32[](3);
        uint256[] memory min = new uint256[](3);
        uint256[] memory max = new uint256[](3);

        // add the actual rule
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(10);
        min[1] = uint256(20);
        min[2] = uint256(30);
        max[0] = uint256(10000000000000000000000000);
        max[1] = uint256(10000000000000000000000000000);
        max[2] = uint256(1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 999;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testFailsMaxAccountBalanceCheck() public {
        // add empty rule at ruleId 0
        bytes32[] memory accs = new bytes32[](3);
        uint256[] memory min = new uint256[](3);
        uint256[] memory max = new uint256[](3);

        // add the actual rule
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(10);
        min[1] = uint256(20);
        min[2] = uint256(30);
        max[0] = uint256(10000000000000000000000000);
        max[1] = uint256(10000000000000000000000000000);
        max[2] = uint256(1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        appManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(superAdmin);

        //vm.expectRevert(0x24691f6b);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }
}

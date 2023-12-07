// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "src/application/AppManager.sol";
import "src/example/ERC20/ApplicationERC20Handler.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {SampleUpgradeFacet} from "src/diamond/SampleUpgradeFacet.sol";
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";
import {VersionFacet} from "src/diamond/VersionFacet.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules} from "src/economic/ruleProcessor/RuleDataInterfaces.sol";
import {ERC20RuleProcessorFacet} from "src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "src/economic/ruleProcessor/ERC20TaggedRuleProcessorFacet.sol";
import {ERC721TaggedRuleProcessorFacet} from "src/economic/ruleProcessor/ERC721TaggedRuleProcessorFacet.sol";
import {ApplicationAccessLevelProcessorFacet} from "src/economic/ruleProcessor/ApplicationAccessLevelProcessorFacet.sol";
import {TaggedRuleDataFacet} from "src/economic/ruleProcessor/TaggedRuleDataFacet.sol";
import {RuleDataFacet as Facet} from "src/economic/ruleProcessor/RuleDataFacet.sol";
import {AppRuleDataFacet} from "src/economic/ruleProcessor/AppRuleDataFacet.sol";
import {ApplicationERC20} from "src/example/ERC20/ApplicationERC20.sol";

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
    uint256 totalSupply = 100_000_000_000;
    uint32 startTime = 12;
    uint64 Blocktime = 1675723152;
    ApplicationERC20 public applicationCoin;
    RuleProcessorDiamond public ruleProcessor;
    ApplicationERC20Handler applicationCoinHandler;

    function setUp() public {
        vm.startPrank(superAdmin);
        // Deploy the token rule processor diamond
        ruleProcessor = getRuleProcessorDiamond();

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
        vm.warp(Blocktime);
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

        SampleUpgradeFacet testFacet = new SampleUpgradeFacet();
        //build new cut struct
        console.log("before generate selectors");
        cut[0] = (FacetCut({facetAddress: address(testFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("SampleUpgradeFacet")}));
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
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(ac, 1000);
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(index).minTransferAmount, 1000);
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
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(ac, 1000);
        vm.stopPrank();
        vm.startPrank(superAdmin);
    }

    function testPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(ac, 2222);

        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 2222);
    }

    function testNotPassingMinTransferRule() public {
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(ac, 420);
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
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
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
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
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
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
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
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
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
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
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

    /***************** Test Setters and Getters Rule Storage *****************/

    /*********************** Purchase *******************/
    /// Simple setting and getting
    function testSettingPurchaseStorage() public {
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory pAmounts = new uint256[](3);
        pAmounts[0] = uint256(1000);
        pAmounts[1] = uint256(2000);
        pAmounts[2] = uint256(3000);
        uint16[] memory pPeriods = new uint16[](3);
        pPeriods[0] = uint16(100);
        pPeriods[1] = uint16(101);
        pPeriods[2] = uint16(102);
        uint64[] memory sTimes = new uint64[](3);
        sTimes[0] = uint64(8);
        sTimes[1] = uint64(12);
        sTimes[2] = uint64(16);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        // assertEq(_index, 0);
        /// Uncomment lines after merge into internal

        // TaggedRules.PurchaseRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getPurchaseRule(_index, "Oscar");
        // assertEq(rule.purchaseAmount, 1000);
        // assertEq(rule.purchasePeriod, 100);

        // accs[1] = bytes32("Tayler");
        // pAmounts[1] = uint192(20000000);
        // pPeriods[1] = uint16(2);
        // sTimes[1] = uint8(23);

        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        // assertEq(_index, 1);
        // rule = TaggedRuleDataFacet(address(ruleProcessor)).getPurchaseRule(_index, "Tayler");
        // assertEq(rule.purchaseAmount, 20000000);
        // assertEq(rule.purchasePeriod, 2);

        /// test zero address check
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(0), accs, pAmounts, pPeriods, sTimes);
    }

    /// testing only appAdministrators can add Purchase Rule
    function testSettingPurchaseRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory pAmounts = new uint256[](3);
        pAmounts[0] = uint256(1000);
        pAmounts[1] = uint256(2000);
        pAmounts[2] = uint256(3000);
        uint16[] memory pPeriods = new uint16[](3);
        pPeriods[0] = uint16(100);
        pPeriods[1] = uint16(101);
        pPeriods[2] = uint16(102);
        uint64[] memory sTimes = new uint64[](3);
        sTimes[0] = uint64(10);
        sTimes[1] = uint64(12);
        sTimes[2] = uint64(16);
        // set user to the super admin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(ruleAdmin); //interact as the rule admin
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingPurchaseWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Tayler");
        uint256[] memory pAmounts = new uint256[](3);
        pAmounts[0] = uint256(1000);
        pAmounts[1] = uint256(2000);
        pAmounts[2] = uint256(3000);
        uint16[] memory pPeriods = new uint16[](3);
        pPeriods[0] = uint16(100);
        pPeriods[1] = uint16(101);
        pPeriods[2] = uint16(102);
        uint64[] memory sTimes = new uint64[](2);
        sTimes[0] = uint64(24);
        sTimes[1] = uint64(36);

        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
    }

    /// test total rules
    function testTotalRulesOnPurchase() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint256[] memory pAmounts = new uint256[](1);
        pAmounts[0] = uint192(1000);
        uint16[] memory pPeriods = new uint16[](1);
        pPeriods[0] = uint16(100);
        uint64[] memory sTimes = new uint64[](1);
        sTimes[0] = uint32(12);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        }
        /// Uncomment lines after merge to internal 
        //assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalPurchaseRule(), _indexes.length);
    }

    /************************ Sell *************************/
    /// Simple setting and getting
    function testSettingSell() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint192[] memory sAmounts = new uint192[](3);
        sAmounts[0] = uint192(1000);
        sAmounts[1] = uint192(2000);
        sAmounts[2] = uint192(3000);
        uint16[] memory sPeriod = new uint16[](3);
        sPeriod[0] = uint16(24);
        sPeriod[1] = uint16(36);
        sPeriod[2] = uint16(48);
        uint64[] memory sTimes = new uint64[](3);
        sTimes[0] = Blocktime;
        sTimes[1] = Blocktime;
        sTimes[2] = Blocktime;

        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);

        ///Uncomment lines after merge to internal
        // TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, "Oscar");
        // assertEq(rule.sellAmount, 1000);
        // assertEq(rule.sellPeriod, 24);

        // accs[0] = bytes32("Oscar");
        // accs[1] = bytes32("Tayler");
        // accs[2] = bytes32("Shane");
        // sAmounts[0] = uint192(100000000);
        // sAmounts[1] = uint192(20000000);
        // sAmounts[2] = uint192(3000000);
        // sPeriod[0] = uint16(11);
        // sPeriod[1] = uint16(22);
        // sPeriod[2] = uint16(33);
        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        // assertEq(_index, 1);
        // rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, "Tayler");
        // assertEq(rule.sellAmount, 20000000);
        // assertEq(rule.sellPeriod, 22);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(0), accs, sAmounts, sPeriod, sTimes);
    }

    /// testing only appAdministrators can add Purchase Rule
    function testSettingSellRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint192[] memory sAmounts = new uint192[](3);
        sAmounts[0] = uint192(1000);
        sAmounts[1] = uint192(2000);
        sAmounts[2] = uint192(3000);
        uint16[] memory sPeriod = new uint16[](3);
        sPeriod[0] = uint16(24);
        sPeriod[1] = uint16(36);
        sPeriod[2] = uint16(48);
        uint64[] memory sTimes = new uint64[](3);
        sTimes[0] = Blocktime;
        sTimes[1] = Blocktime;
        sTimes[2] = Blocktime;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingSellWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](2);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        uint192[] memory sAmounts = new uint192[](3);
        sAmounts[0] = uint192(1000);
        sAmounts[1] = uint192(2000);
        sAmounts[2] = uint192(3000);
        uint16[] memory sPeriod = new uint16[](3);
        sPeriod[0] = uint16(24);
        sPeriod[1] = uint16(36);
        sPeriod[2] = uint16(48);
        uint64[] memory sTimes = new uint64[](3);
        sTimes[0] = Blocktime;
        sTimes[1] = Blocktime;
        sTimes[2] = Blocktime;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
    }

    /// test total rules
    function testTotalRulesOnSell() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint192[] memory sAmounts = new uint192[](1);
        sAmounts[0] = uint192(1000);
        uint32[] memory pPeriods = new uint32[](1);
        pPeriods[0] = uint32(100);
        uint16[] memory sPeriod = new uint16[](1);
        sPeriod[0] = uint16(24);
        uint64[] memory sTimes = new uint64[](1);
        sTimes[0] = uint64(Blocktime);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        }
        ///Uncomment lines after merge to internal
        // assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalSellRule(), _indexes.length);
    }

    /************************ Token Purchase Fee By Volume Percentage **********************/
    /// Simple setting and getting
    function testSettingPurchaseFeeByVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = Facet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
        assertEq(rule.rateIncreased, 100);

        _index = Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 10000000000000000000000000000000000, 200);
        assertEq(_index, 1);

        ///Uncomment lines after merge to internal
        // rule = Facet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
        // assertEq(rule.volume, 10000000000000000000000000000000000);
        // assertEq(rule.rateIncreased, 200);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingPurchaseFeeVolumeRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);

        _index = Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnPurchaseFeeByVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(ac, 500 + i, 1 + i);
        }

        ///Uncomment lines after merge to internal
        // assertEq(Facet(address(ruleProcessor)).getTotalTokenPurchaseFeeByVolumeRules(), _indexes.length);
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting
    function testSettingTokenVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000, 60, 12, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.TokenVolatilityRule memory rule = Facet(address(ruleProcessor)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 12);

        _index = Facet(address(ruleProcessor)).addVolatilityRule(ac, 666, 100, 16, totalSupply);
        assertEq(_index, 1);
        rule = Facet(address(ruleProcessor)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 16);
        assertEq(rule.maxVolatility, 666);
        assertEq(rule.period, 100);
        vm.expectRevert();
        Facet(address(ruleProcessor)).addVolatilityRule(address(0), 666, 100, 16, totalSupply);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolatilityRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        assertEq(_index, 0);

        _index = Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTokenVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addVolatilityRule(ac, 5000 + i, 60 + i, 24 + i, totalSupply);
        }
        assertEq(Facet(address(ruleProcessor)).getTotalVolatilityRules(), _indexes.length);
    }

    /*********************** Token Transfer Volume ************************/
    /// Simple setting and getting
    function testSettingTransferVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 1000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.startTime, Blocktime);

        _index = Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 1);
        assertEq(rule.startTime, 12);
        assertEq(rule.totalSupply, 1_000_000_000_000_000 * 10 ** 18);
        vm.expectRevert();
        Facet(address(ruleProcessor)).addTransferVolumeRule(address(0), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolumeRuleWithoutappAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        assertEq(_index, 0);

        _index = Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTransferVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addTransferVolumeRule(ac, 5000 + i, 60 + i, Blocktime, 0);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTransferVolumeRules(), _indexes.length);
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting
    function testSettingMinTransfer() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 0);
        NonTaggedRules.TokenMinimumTransferRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
        assertEq(rule.minTransferAmount, 500000000000000);

        _index = Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 300000000000000);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
        assertEq(rule.minTransferAmount, 300000000000000);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingMinTransferRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 500000000000000);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 500000000000000);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 0);
        _index = Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnMinTransfer() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addMinimumTransferRule(ac, 5000 + i);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalMinimumTransferRules(), _indexes.length);
    }

    /*********************** Min Max Balance Rule Limits *******************/
    /// Simple setting and getting
    function testSettingMinMaxBalanceRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory min = new uint256[](3);
        min[0] = uint256(1000);
        min[1] = uint256(2000);
        min[2] = uint256(3000);
        uint256[] memory max = new uint256[](3);
        max[0] = uint256(10000000000000000000000000000000000000);
        max[1] = uint256(100000000000000000000000000000000000000000);
        max[2] = uint256(100000000000000000000000000000000000000000000000000000000000000000000000000);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        assertEq(_index, 0);
        TaggedRules.MinMaxBalanceRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinMaxBalanceRule(_index, "Oscar");
        assertEq(rule.minimum, 1000);
        assertEq(rule.maximum, 10000000000000000000000000000000000000);

        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        min[0] = uint256(100000000);
        min[1] = uint256(20000000);
        min[2] = uint256(3000000);
        max[0] = uint256(100000000000000000000000000000000000000000000000000000000000000000000000000);
        max[1] = uint256(20000000000000000000000000000000000000);
        max[2] = uint256(900000000000000000000000000000000000000000000000000000000000000000000000000);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        assertEq(_index, 1);
        rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinMaxBalanceRule(_index, "Tayler");
        assertEq(rule.minimum, 20000000);
        assertEq(rule.maximum, 20000000000000000000000000000000000000);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(0), accs, min, max);
    }

    /// testing only appAdministrators can add Balance Limit Rule
    function testSettingMinMaxBalanceRuleWithoutAppAdministratorAccount() public {
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory min = new uint256[](3);
        min[0] = uint256(1000);
        min[1] = uint256(2000);
        min[2] = uint256(3000);
        uint256[] memory max = new uint256[](3);
        max[0] = uint256(10000000000000000000000000000000000000);
        max[1] = uint256(100000000000000000000000000000000000000000);
        max[2] = uint256(100000000000000000000000000000000000000000000000000000000000000000000000000);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        assertEq(_index, 0);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        assertEq(_index, 1);
    }

    /// testing check on input arrays with different sizes
    function testSettingBalanceLimitsWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory min = new uint256[](2);
        min[0] = uint256(1000);
        min[1] = uint256(3000);
        uint256[] memory max = new uint256[](3);
        max[0] = uint256(10000000000000000000000000000000000000);
        max[1] = uint256(100000000000000000000000000000000000000000);
        max[2] = uint256(100000000000000000000000000000000000000000000000000000000000000000000000000);
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
    }

    /// testing inverted limits
    function testAddBalanceLimitsWithInvertedLimits() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint256[] memory min = new uint256[](1);
        min[0] = uint256(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory max = new uint256[](1);
        max[0] = uint256(100);
        vm.expectRevert(0xeeb9d4f7);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
    }

    /// test total rules
    function testTotalRulesOnBalanceLimits() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint256[] memory min = new uint256[](1);
        min[0] = uint256(1000);
        uint256[] memory max = new uint256[](1);
        max[0] = uint256(999999000000000000000000000000000000000000000000000000000000000000000000000);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(ac, accs, min, max);
        }
        assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalMinMaxBalanceRules(), _indexes.length);
    }

    /*********************** Supply Volatility ************************/
    /// Simple setting and getting
    function testSettingSupplyVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.SupplyVolatilityRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);

        _index = Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 5000, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingSupplyRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        _index = Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnSupplyVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addSupplyVolatilityRule(ac, 6500 + i, 24 + i, 12, totalSupply);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalSupplyVolatilityRules(), _indexes.length);
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting
    function testOracle() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addOracleRule(ac, 0, address(69));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(69));
        _index = Facet(address(ruleProcessor)).addOracleRule(ac, 1, address(79));
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
    }

    /// testing only appAdministrators can add Oracle Rule
    function testSettingOracleRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addOracleRule(ac, 0, address(69));
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        Facet(address(ruleProcessor)).addOracleRule(ac, 0, address(69));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = Facet(address(ruleProcessor)).addOracleRule(ac, 0, address(69));
        assertEq(_index, 0);

        _index = Facet(address(ruleProcessor)).addOracleRule(ac, 1, address(79));
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnOracle() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = Facet(address(ruleProcessor)).addOracleRule(ac, 0, address(69));
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalOracleRules(), _indexes.length);
    }

    /*********************** NFT Trade Counter ************************/
    /// Simple setting and getting
    function testNFTTransferCounterRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[1]);
        assertEq(rule.tradesAllowedPerDay, 5);
    }

    /// testing only appAdministrators can add NFT Trade Counter Rule
    function testSettingNFTCounterRuleWithoutAppAdministratorAccount() public {
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnNFTCounter() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        }
        assertEq(ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalNFTTransferCounterRules(), _indexes.length);
    }

    /**************** Tagged Withdrawal Rule Testing  ****************/
    //Test Adding Withdrawal Rule
    function testSettingWithdrawalRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = uint256(1000);
        amounts[1] = uint256(5000);
        amounts[2] = uint256(9000);
        uint256[] memory releaseDate = new uint256[](3);
        releaseDate[0] = uint256(block.timestamp + 222);
        releaseDate[1] = uint256(block.timestamp + 444);
        releaseDate[2] = uint256(block.timestamp + 888);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        assertEq(_index, 0);

        /// Withdrawal rule getter no longer exists until rule is written 
        // TaggedRules.WithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getWithdrawalRule(_index, "Tayler");
        // assertEq(rule.amount, 5000);
        // assertEq(rule.releaseDate, block.timestamp + 444);

        // accs[0] = bytes32("Oscar");
        // accs[1] = bytes32("Tayler");
        // accs[2] = bytes32("Shane");
        // amounts[0] = uint256(500);
        // amounts[1] = uint256(1500);
        // amounts[2] = uint256(3000);
        // releaseDate[0] = uint256(block.timestamp + 10000);
        // releaseDate[1] = uint256(block.timestamp + 888);
        // releaseDate[2] = uint256(block.timestamp + 666);
        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        // assertEq(_index, 1);
        // rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getWithdrawalRule(_index, "Oscar");
        // assertEq(rule.amount, 500);
        // assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    //Test Get Withdrawal Rule
    function testGetWithdrawalRuleUpdate() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        //Set Rule
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Shane");
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = uint256(1000);
        uint256[] memory releaseDate = new uint256[](1);
        releaseDate[0] = uint256(block.timestamp + 10000);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        assertEq(_index, 0);
        // TaggedRules.WithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getWithdrawalRule(_index, "Shane");
        // assertEq(rule.amount, 1000);
        // assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    //Test Get Total Withdrawal Rules
    function testGetTotalWithdrawalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[3] memory _indexes;
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = uint256(1000);
        amounts[1] = uint256(5000);
        amounts[2] = uint256(9000);
        uint256[] memory releaseDate = new uint256[](3);
        releaseDate[0] = uint256(block.timestamp + 222);
        releaseDate[1] = uint256(block.timestamp + 444);
        releaseDate[2] = uint256(block.timestamp + 888);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        }
        /// Withdrawal getter no longer exists until rule is written 
        //assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalWithdrawalRule(), _indexes.length);
    }

    /**************** Balance by AccessLevel Rule Testing  ****************/

    /// Test Adding Balance by AccessLevel Rule
    function testBalanceByAccessLevelRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 10;
        balanceAmounts[1] = 100;
        balanceAmounts[2] = 500;
        balanceAmounts[3] = 1000;
        balanceAmounts[4] = 10000;
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(ac, balanceAmounts);
        uint256 testBalance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccessLevelBalanceRule(_index, 2);
        assertEq(testBalance, 500);
    }

    function testAddBalanceByAccessLevelRulenotAdmin() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint48[] memory balanceAmounts;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(ac, balanceAmounts);
    }

    ///Get Total Balance by AccessLevel Rules
    function testTotalBalanceByAccessLevelRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 10;
        balanceAmounts[1] = 100;
        balanceAmounts[2] = 500;
        balanceAmounts[3] = 1000;
        balanceAmounts[4] = 10000;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(ac, balanceAmounts);
        }
        uint256 result = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccessLevelBalanceRules();
        assertEq(result, _indexes.length);
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: block.timestamp + 10000
    function testAddAdminWithdrawalRuleAppAdministratorStorage() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        appManager.addAppAdministrator(address(22));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        assertEq(appManager.isAppAdministrator(address(22)), true);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(ac, 5000, block.timestamp + 10000);
        TaggedRules.AdminWithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminWithdrawalRule(_index);
        assertEq(rule.amount, 5000);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    function testFailAddAdminWithdrawalRulenotAdmin() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        TaggedRuleDataFacet(superAdmin).addAdminWithdrawalRule(ac, 6500, 1669748600);
    }

    ///Get Total Admin Withdrawal Rules
    function testTotalAdminWithdrawalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        uint256 amount = 1000;
        uint256 releaseDate = block.timestamp + 10000;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(ac, amount, releaseDate);
        }
        uint256 result;
        result = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAdminWithdrawalRules();
        assertEq(result, _indexes.length);
    }

    /*********************** Minimum Balance By Date *******************/
    /// Simple setting and getting
    function testSettingMinBalByDate() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = uint256(1000);
        holdAmounts[1] = uint256(2000);
        holdAmounts[2] = uint256(3000);
        uint16[] memory holdPeriods = new uint16[](3);
        holdPeriods[0] = uint16(100);
        holdPeriods[1] = uint16(101);
        holdPeriods[2] = uint16(102);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        (TaggedRules.MinBalByDateRule memory rule, uint64 startTimestamp) = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinBalByDateRule(_index, "Oscar");
        assertEq(rule.holdAmount, 1000);
        assertEq(rule.holdPeriod, 100);

        accs[1] = bytes32("Tayler");
        holdAmounts[1] = uint192(20000000);
        holdPeriods[1] = uint16(2);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 1);
        (rule, startTimestamp) = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinBalByDateRule(_index, "Tayler");
        assertEq(rule.holdAmount, 20000000);
        assertEq(rule.holdPeriod, 2);
    }

    function testSettingMinBalByDateNotAdmin() public {
        vm.warp(Blocktime);
        vm.stopPrank();
        vm.startPrank(address(0xDEAD));
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = uint256(1000);
        holdAmounts[1] = uint256(2000);
        holdAmounts[2] = uint256(3000);
        uint16[] memory holdPeriods = new uint16[](3);
        holdPeriods[0] = uint16(100);
        holdPeriods[1] = uint16(101);
        holdPeriods[2] = uint16(102);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, uint64(Blocktime));
    }

    /// Test for proper array size mismatch error
    function testSettingMinBalByDateSizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = new bytes32[](3);
        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        uint256[] memory holdAmounts = new uint256[](3);
        holdAmounts[0] = uint256(1000);
        holdAmounts[1] = uint256(2000);
        holdAmounts[2] = uint256(3000);
        uint16[] memory holdPeriods = new uint16[](2);
        holdPeriods[0] = uint16(100);
        holdPeriods[1] = uint16(101);
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, uint64(Blocktime));
    }
}

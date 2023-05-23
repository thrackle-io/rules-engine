// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/application/AppManager.sol";
import "./TaggedRuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import "./RuleProcessorDiamondTestUtil.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import {TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {RuleDataFacet as Facet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {ERC20TaggedRuleProcessorFacet} from "../src/economic/ruleProcessor/tagged/ERC20TaggedRuleProcessorFacet.sol";
import {TokenRuleRouter} from "../src/economic/TokenRuleRouter.sol";
import "../src/example/ApplicationERC20Handler.sol";
//import {RuleProcessorDiamondArgs, RuleProcessorDiamond} from "../src/economic/ruleProcessor/nontagged/RuleProcessorDiamond.sol";
import {ApplicationERC20} from "../src/example/ApplicationERC20.sol";

contract TaggedRuleProcessorDiamondTest is Test, TaggedRuleProcessorDiamondTestUtil, RuleProcessorDiamondTestUtil {
    // Store the FacetCut struct for each facet that is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    AppManager public appManager;
    ApplicationERC20 public applicationCoin;
    TokenRuleRouter public tokenRuleRouter;
    ApplicationERC20Handler applicationCoinHandler;
    TokenRuleRouterProxy ruleRouterProxy;
    RuleProcessorDiamond public tokenRuleProcessorsDiamond;
    RuleStorageDiamond ruleStorageDiamond;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address ac;
    address eac;
    address defaultAdmin = address(0xAD);
    address appAdministrator = address(2);
    address AccessTier = address(3);
    address riskAdmin = address(4);
    address user = address(5);

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the token rule processor diamond
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Diploy the token rule processor diamond
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        //connect data diamond with Tagged Rule Processor diamond
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleRouter = new TokenRuleRouter();

        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        // Deploy app manager
        appManager = new AppManager(defaultAdmin, "Castlevania", address(ruleRouterProxy), false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);

        ac = address(appManager);
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));
        // Set up the ApplicationERC20Handler
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleRouterProxy), ac, false);

        applicationCoin = new ApplicationERC20("application", "GMC", address(appManager), address(applicationCoinHandler));
        applicationCoin.mint(defaultAdmin, 10000000000000000000000);
    }

    /// Test to make sure that the Diamond will upgrade
    function testUpgrade() public {
        SampleFacet _sampleFacet = new SampleFacet();
        //build _cut struct
        FacetCut[] memory _cut = new FacetCut[](1);
        _cut[0] = (FacetCut({facetAddress: address(_sampleFacet), action: FacetCutAction.Add, functionSelectors: generateSelectors("SampleFacet")}));
        IDiamondCut(address(taggedRuleProcessorDiamond)).diamondCut(_cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(taggedRuleProcessorDiamond)).owner());
        ERC173Facet(address(taggedRuleProcessorDiamond)).transferOwnership(defaultAdmin);

        // call a function
        assertEq("good", SampleFacet(address(taggedRuleProcessorDiamond)).sampleFunction());
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
        appManager.addGeneralTag(defaultAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(defaultAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(defaultAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(defaultAdmin);

        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).minAccountBalanceCheck(applicationCoin.balanceOf(defaultAdmin), tags, amount, ruleId);
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
        appManager.addGeneralTag(defaultAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(defaultAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(defaultAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(defaultAdmin);

        //vm.expectRevert(0xf1737570);
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).minAccountBalanceCheck(applicationCoin.balanceOf(defaultAdmin), tags, amount, ruleId);
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
        appManager.addGeneralTag(defaultAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(defaultAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 amount = 999;
        assertEq(applicationCoin.balanceOf(defaultAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(defaultAdmin);

        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).maxAccountBalanceCheck(applicationCoin.balanceOf(defaultAdmin), tags, amount, ruleId);
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
        appManager.addGeneralTag(defaultAdmin, "Oscar"); //add tag
        assertTrue(appManager.hasTag(defaultAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(defaultAdmin);
        uint256 amount = 10000000000000000000000000;
        assertEq(applicationCoin.balanceOf(defaultAdmin), 10000000000000000000000);
        bytes32[] memory tags = appManager.getAllTags(defaultAdmin);

        //vm.expectRevert(0x24691f6b);
        ERC20TaggedRuleProcessorFacet(address(taggedRuleProcessorDiamond)).maxAccountBalanceCheck(applicationCoin.balanceOf(defaultAdmin), tags, amount, ruleId);
    }
}

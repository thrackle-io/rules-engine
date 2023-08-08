// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/application/AppManager.sol";
import "./RuleStorageDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import {TaggedRuleDataFacet as TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules} from "../src/economic/ruleStorage/RuleDataInterfaces.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {RuleDataFacet as NonTaggedRuleFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {AppRuleDataFacet} from "../src/economic/ruleStorage/AppRuleDataFacet.sol";
import {ERC173Facet} from "diamond-std/implementations/ERC173/ERC173Facet.sol";

contract RuleStorageDiamondTest is Test, RuleStorageDiamondTestUtil {
    // Store the FacetCut struct for each NonTaggedRuleFacetthat is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _facetCuts;
    AppManager public appManager;
    RuleStorageDiamond ruleStorageDiamond;
    address defaultAdmin = address(0xAD);
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    address appAdministrator = address(0xB0B);
    address ac;
    uint256 totalSupply = 100_000_000_000;
    uint32 startTime = 12;
    uint64 Blocktime = 1675723152;

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy app manager
        appManager = new AppManager(defaultAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdministrator);
        ac = address(appManager);
        vm.warp(Blocktime);
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
        IDiamondCut(address(ruleStorageDiamond)).diamondCut(cut, address(0x0), "");
        console.log("ERC173Facet owner: ");
        console.log(ERC173Facet(address(ruleStorageDiamond)).owner());
        //console.log("TestFacet owner: ");
        //console.log(SampleFacet(address(ruleStorageDiamond)).getOwner());
        ERC173Facet(address(ruleStorageDiamond)).transferOwnership(defaultAdmin);

        // call a function
        assertEq("good", SampleFacet(address(ruleStorageDiamond)).sampleFunction());
    }

    /***************** Test Setters and Getters *****************/

    /*********************** Purchase *******************/
    /// Simple setting and getting
    function testSettingPurchase() public {
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
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        assertEq(_index, 0);
        TaggedRules.PurchaseRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getPurchaseRule(_index, "Oscar");
        assertEq(rule.purchaseAmount, 1000);
        assertEq(rule.purchasePeriod, 100);

        accs[1] = bytes32("Tayler");
        pAmounts[1] = uint192(20000000);
        pPeriods[1] = uint16(2);
        sTimes[1] = uint8(23);

        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        assertEq(_index, 1);
        rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getPurchaseRule(_index, "Tayler");
        assertEq(rule.purchaseAmount, 20000000);
        assertEq(rule.purchasePeriod, 2);

        /// test zero address check
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(address(0), accs, pAmounts, pPeriods, sTimes);
    }

    /// testing only appAdministrators can add Purchase Rule
    function testSettingPurchaseRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        vm.stopPrank(); //stop interacting as the default admin
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
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as a different user
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingPurchaseWithArraySizeMismatch() public {
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
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
    }

    /// test total rules
    function testTotalRulesOnPurchase() public {
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
            _indexes[i] = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, sTimes);
        }
        assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalPurchaseRule(), _indexes.length);
    }

    /************************ Sell *************************/
    /// Simple setting and getting
    function testSettingSell() public {
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

        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);
        TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getSellRuleByIndex(_index, "Oscar");
        assertEq(rule.sellAmount, 1000);
        assertEq(rule.sellPeriod, 24);

        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        sAmounts[0] = uint192(100000000);
        sAmounts[1] = uint192(20000000);
        sAmounts[2] = uint192(3000000);
        sPeriod[0] = uint16(11);
        sPeriod[1] = uint16(22);
        sPeriod[2] = uint16(33);
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 1);
        rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getSellRuleByIndex(_index, "Tayler");
        assertEq(rule.sellAmount, 20000000);
        assertEq(rule.sellPeriod, 22);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(address(0), accs, sAmounts, sPeriod, sTimes);
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
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(appAdministrator); //interact as a different user
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingSellWithArraySizeMismatch() public {
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
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
    }

    /// test total rules
    function testTotalRulesOnSell() public {
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
            _indexes[i] = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSellRule(ac, accs, sAmounts, sPeriod, sTimes);
        }
        assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalSellRule(), _indexes.length);
    }

    /************************ Token Purchase Fee By Volume Percentage **********************/
    /// Simple setting and getting
    function testSettingPurchaseFeeByVolume() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPurchaseFeeByVolumeRule(_index);
        assertEq(rule.rateIncreased, 100);

        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 10000000000000000000000000000000000, 200);
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPurchaseFeeByVolumeRule(_index);
        assertEq(rule.volume, 10000000000000000000000000000000000);
        assertEq(rule.rateIncreased, 200);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingPurchaseFeeVolumeRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 5000000000000000000000000000000000, 100);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnPurchaseFeeByVolume() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 500 + i, 1 + i);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalTokenPurchaseFeeByVolumeRules(), _indexes.length);
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting
    function testSettingTokenVolatility() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000, 60, 12, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.TokenVolatilityRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 12);

        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 666, 100, 16, totalSupply);
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 16);
        assertEq(rule.maxVolatility, 666);
        assertEq(rule.period, 100);
        vm.expectRevert();
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(address(0), 666, 100, 16, totalSupply);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolatilityRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000, 60, 24, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTokenVolatility() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 5000 + i, 60 + i, 24 + i, totalSupply);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalVolatilityRules(), _indexes.length);
    }

    /*********************** Token Transfer Volume ************************/
    /// Simple setting and getting
    function testSettingTransferVolume() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 1000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.startTime, Blocktime);

        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 1);
        assertEq(rule.startTime, 12);
        assertEq(rule.totalSupply, 1_000_000_000_000_000 * 10 ** 18);
        vm.expectRevert();
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(address(0), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolumeRuleWithoutappAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 4000, 2, 23, 0);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTransferVolume() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTransferVolumeRule(ac, 5000 + i, 60 + i, Blocktime, 0);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalTransferVolumeRules(), _indexes.length);
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting
    function testSettingMinTransfer() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 0);
        uint256 rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getMinimumTransferRule(_index);
        assertEq(rule, 500000000000000);

        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 300000000000000);
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getMinimumTransferRule(_index);
        assertEq(rule, 300000000000000);
        vm.expectRevert();
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(address(0), 300000000000000);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingMinTransferRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 500000000000000);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 500000000000000);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 500000000000000);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnMinTransfer() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 5000 + i);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalMinimumTransferRules(), _indexes.length);
    }

    /*********************** BalanceLimits *******************/
    /// Simple setting and getting
    function testSettingBalanceLimits() public {
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
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        assertEq(_index, 0);
        TaggedRules.BalanceLimitRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getBalanceLimitRule(_index, "Oscar");
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
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        assertEq(_index, 1);
        rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getBalanceLimitRule(_index, "Tayler");
        assertEq(rule.minimum, 20000000);
        assertEq(rule.maximum, 20000000000000000000000000000000000000);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(address(0), accs, min, max);
    }

    /// testing only appAdministrators can add Balance Limit Rule
    function testSettingBalanceLimitRuleWithoutAppAdministratorAccount() public {
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
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        assertEq(_index, 1);
    }

    /// testing check on input arrays with different sizes
    function testSettingBalanceLimitsWithArraySizeMismatch() public {
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
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
    }

    /// testing inverted limits
    function testAddBalanceLimitsWithInvertedLimits() public {
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint256[] memory min = new uint256[](1);
        min[0] = uint256(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory max = new uint256[](1);
        max[0] = uint256(100);
        vm.expectRevert(0xeeb9d4f7);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
    }

    /// test total rules
    function testTotalRulesOnBalanceLimits() public {
        uint256[101] memory _indexes;
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Oscar");
        uint256[] memory min = new uint256[](1);
        min[0] = uint256(1000);
        uint256[] memory max = new uint256[](1);
        max[0] = uint256(999999000000000000000000000000000000000000000000000000000000000000000000000);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        }
        assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalBalanceLimitRules(), _indexes.length);
    }

    /*********************** Supply Volatility ************************/
    /// Simple setting and getting
    function testSettingSupplyVolatility() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.SupplyVolatilityRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);

        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 5000, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingSupplyRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnSupplyVolatility() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 6500 + i, 24 + i, 12, totalSupply);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalSupplyVolatilityRules(), _indexes.length);
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting
    function testOracle() public {
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(69));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(69));
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(79));
        assertEq(_index, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
    }

    /// testing only appAdministrators can add Oracle Rule
    function testSettingOracleRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(69));
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(69));
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(69));
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(79));
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnOracle() public {
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(69));
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalOracleRules(), _indexes.length);
    }

    /*********************** NFT Trade Counter ************************/
    /// Simple setting and getting
    function testNFTTransferCounterRule() public {
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        NonTaggedRules.NFTTradeCounterRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getNFTTransferCounterRule(_index, nftTags[1]);
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
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(appAdministrator)); //interact as a different user
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(defaultAdmin)); //interact as a different user
        _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnNFTCounter() public {
        bytes32[] memory nftTags = new bytes32[](2);
        nftTags[0] = bytes32("BoredGrape");
        nftTags[1] = bytes32("DiscoPunk");
        uint8[] memory tradesAllowed = new uint8[](2);
        tradesAllowed[0] = 1;
        tradesAllowed[1] = 5;
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = NonTaggedRuleFacet(address(ruleStorageDiamond)).addNFTTransferCounterRule(ac, nftTags, tradesAllowed, Blocktime);
        }
        assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalNFTTransferCounterRules(), _indexes.length);
    }

    /**************** Tagged Withdrawal Rule Testing  ****************/
    //Test Adding Withdrawal Rule
    function testSettingWithdrawalRule() public {
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
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        assertEq(_index, 0);
        TaggedRules.WithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getWithdrawalRule(_index, "Tayler");
        assertEq(rule.amount, 5000);
        assertEq(rule.releaseDate, block.timestamp + 444);

        accs[0] = bytes32("Oscar");
        accs[1] = bytes32("Tayler");
        accs[2] = bytes32("Shane");
        amounts[0] = uint256(500);
        amounts[1] = uint256(1500);
        amounts[2] = uint256(3000);
        releaseDate[0] = uint256(block.timestamp + 10000);
        releaseDate[1] = uint256(block.timestamp + 888);
        releaseDate[2] = uint256(block.timestamp + 666);
        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        assertEq(_index, 1);
        rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getWithdrawalRule(_index, "Oscar");
        assertEq(rule.amount, 500);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    //Test Get Withdrawal Rule
    function testGetWithdrawalRuleUpdate() public {
        //Set Rule
        bytes32[] memory accs = new bytes32[](1);
        accs[0] = bytes32("Shane");
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = uint256(1000);
        uint256[] memory releaseDate = new uint256[](1);
        releaseDate[0] = uint256(block.timestamp + 10000);
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        assertEq(_index, 0);
        TaggedRules.WithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getWithdrawalRule(_index, "Shane");
        assertEq(rule.amount, 1000);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    //Test Get Total Withdrawal Rules
    function testGetTotalWithdrawalRules() public {
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
            _indexes[i] = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        }
        assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalWithdrawalRule(), _indexes.length);
    }

    /**************** Balance by AccessLevel Rule Testing  ****************/

    /// Test Adding Balance by AccessLevel Rule
    function testBalanceByAccessLevelRule() public {
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 10;
        balanceAmounts[1] = 100;
        balanceAmounts[2] = 500;
        balanceAmounts[3] = 1000;
        balanceAmounts[4] = 10000;
        uint32 _index = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(ac, balanceAmounts);
        uint256 testBalance = AppRuleDataFacet(address(ruleStorageDiamond)).getAccessLevelBalanceRule(_index, 2);
        assertEq(testBalance, 500);
    }

    function testAddBalanceByAccessLevelRulenotAdmin() public {
        uint48[] memory balanceAmounts;
        vm.stopPrank(); //stop interacting as the default admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xba80c9e5);
        AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(ac, balanceAmounts);
    }

    ///Get Total Balance by AccessLevel Rules
    function testTotalBalanceByAccessLevelRules() public {
        uint256[101] memory _indexes;
        uint48[] memory balanceAmounts = new uint48[](5);
        balanceAmounts[0] = 10;
        balanceAmounts[1] = 100;
        balanceAmounts[2] = 500;
        balanceAmounts[3] = 1000;
        balanceAmounts[4] = 10000;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = AppRuleDataFacet(address(ruleStorageDiamond)).addAccessLevelBalanceRule(ac, balanceAmounts);
        }
        uint256 result = AppRuleDataFacet(address(ruleStorageDiamond)).getTotalAccessLevelBalanceRules();
        assertEq(result, _indexes.length);
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: block.timestamp + 10000
    function testAddAdminWithdrawalRuleAppAdministrator() public {
        appManager.addAppAdministrator(address(ruleStorageDiamond));
        assertEq(appManager.isAppAdministrator(address(ruleStorageDiamond)), true);
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(ac, 5000, block.timestamp + 10000);
        TaggedRules.AdminWithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getAdminWithdrawalRule(_index);
        assertEq(rule.amount, 5000);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    function testFailAddAdminWithdrawalRulenotAdmin() public {
        TaggedRuleDataFacet(defaultAdmin).addAdminWithdrawalRule(ac, 6500, 1669748600);
    }

    ///Get Total Admin Withdrawal Rules
    function testTotalAdminWithdrawalRules() public {
        uint256[101] memory _indexes;
        uint256 amount = 1000;
        uint256 releaseDate = block.timestamp + 10000;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(ac, amount, releaseDate);
        }
        uint256 result;
        result = TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalAdminWithdrawalRules();
        assertEq(result, _indexes.length);
    }

    /*********************** Minimum Balance By Date *******************/
    /// Simple setting and getting
    function testSettingMinBalByDate() public {
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
        uint64[] memory holdTimestamps = new uint64[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, holdTimestamps);
        assertEq(_index, 0);
        TaggedRules.MinBalByDateRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getMinBalByDateRule(_index, "Oscar");
        assertEq(rule.holdAmount, 1000);
        assertEq(rule.holdPeriod, 100);

        accs[1] = bytes32("Tayler");
        holdAmounts[1] = uint192(20000000);
        holdPeriods[1] = uint16(2);

        _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, holdTimestamps);
        assertEq(_index, 1);
        rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getMinBalByDateRule(_index, "Tayler");
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
        uint64[] memory holdTimestamps = new uint64[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        vm.expectRevert(0xba80c9e5);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, holdTimestamps);
    }

    /// Test for proper array size mismatch error
    function testSettingMinBalByDateSizeMismatch() public {
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
        uint64[] memory holdTimestamps = new uint64[](3);
        holdTimestamps[0] = Blocktime;
        holdTimestamps[1] = Blocktime;
        holdTimestamps[2] = Blocktime;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleStorageDiamond)).addMinBalByDateRule(ac, accs, holdAmounts, holdPeriods, holdTimestamps);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import {TaggedRuleDataFacet as TaggedRuleDataFacet} from "../src/economic/ruleStorage/TaggedRuleDataFacet.sol";
import "./RuleStorageDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import {INonTaggedRules as NonTaggedRules, ITaggedRules as TaggedRules} from "../src/economic/ruleStorage/RuleDataInterfaces.sol";
import {SampleFacet} from "../src/diamond/core/test/SampleFacet.sol";
import {ERC173Facet} from "../src/diamond/implementations/ERC173/ERC173Facet.sol";
import {RuleDataFacet as NonTaggedRuleFacet} from "../src/economic/ruleStorage/RuleDataFacet.sol";
import {TokenRuleRouter} from "../src/economic/TokenRuleRouter.sol";
import "../src/application/AppManager.sol";

import "./RuleProcessorDiamondTestUtil.sol";
import "./TaggedRuleProcessorDiamondTestUtil.sol";
import "../src/application/AppManager.sol";
import "../src/application/AppManager.sol";
import "../src/economic/TokenRuleRouterProxy.sol";
import "../src/example/OracleRestricted.sol";
import "../src/example/OracleAllowed.sol";
import "../src/example/ApplicationERC20Handler.sol";
import "../src/example/ApplicationAppManager.sol";
import "./DiamondTestUtil.sol";
import "../src/example/pricing/ApplicationERC20Pricing.sol";
import "../src/example/pricing/ApplicationERC721Pricing.sol";

contract RuleProcessorModuleFuzzTest is DiamondTestUtil, RuleProcessorDiamondTestUtil, TaggedRuleProcessorDiamondTestUtil {
    // Store the FacetCut struct for each NonTaggedRuleFacetthat is being deployed.
    // NOTE: using storage array to easily "push" new FacetCut as we
    // process the facets.
    FacetCut[] private _facetCuts;
    //AppManager public appManager;
    RuleStorageDiamond ruleStorageDiamond;
    RuleProcessorDiamond tokenRuleProcessorsDiamond;
    TaggedRuleProcessorDiamond taggedRuleProcessorDiamond;
    TokenRuleRouter tokenRuleRouter;
    ApplicationERC20Handler applicationCoinHandler;
    TokenRuleRouterProxy ruleRouterProxy;
    OracleRestricted oracleRestricted;
    OracleAllowed oracleAllowed;
    ApplicationAppManager appManager;
    ApplicationHandler public applicationHandler;
    ApplicationERC20Pricing erc20Pricer;
    ApplicationERC721Pricing nftPricer;
    //address defaultAdmin = address(0xDEFAD);
    bytes32 public constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
    //address appAdminstrator = address(0xB0B);
    address ac;
    address[] badBoys;
    address[] goodBoys;
    uint256 Blocktime = 1675723152;
    address[] ADDRESSES = [defaultAdmin, appAdminstrator, address(0xAAA), address(0xBBB), address(0xCCC), address(0xBEEF), address(0xC0FFEE), address(0xF00D)];

    function setUp() public {
        vm.startPrank(defaultAdmin);
        // Deploy the Rule Storage Diamond.
        ruleStorageDiamond = getRuleStorageDiamond();
        // Deploy the rule processor diamonds
        tokenRuleProcessorsDiamond = getRuleProcessorDiamond();
        taggedRuleProcessorDiamond = getTaggedRuleProcessorDiamond();
        taggedRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // Connect the tokenRuleProcessorsDiamond into the ruleStorageDiamond
        tokenRuleProcessorsDiamond.setRuleDataDiamond(address(ruleStorageDiamond));

        // Deploy app manager
        appManager = new ApplicationAppManager(defaultAdmin, "Castlevania", false);
        // add the DEAD address as a app administrator
        appManager.addAppAdministrator(appAdminstrator);
        ac = address(appManager);
        // deploy the TokenRuleRouter
        tokenRuleRouter = new TokenRuleRouter();
        //deploy and initialize Proxy to TokenRuleRouter
        ruleRouterProxy = new TokenRuleRouterProxy(address(tokenRuleRouter));
        TokenRuleRouter(address(ruleRouterProxy)).initialize(payable(address(tokenRuleProcessorsDiamond)), payable(address(taggedRuleProcessorDiamond)));
        applicationCoinHandler = new ApplicationERC20Handler(address(ruleRouterProxy), address(appManager), false);
        // connect the diamond to the Access Action
        ApplicationRuleProcessorDiamond applicationRuleProcessorDiamond = getApplicationProcessorDiamond();
        applicationHandler = appManager.applicationHandler();
        //connect applicationHandler with rule diamond
        applicationRuleProcessorDiamond.setRuleDataDiamond(address(ruleStorageDiamond));
        // connect applicationHandler with its diamond
        applicationHandler.setApplicationRuleProcessorDiamondAddress(address(applicationRuleProcessorDiamond));
        // create the oracles
        oracleAllowed = new OracleAllowed();
        oracleRestricted = new OracleRestricted();

        /// set the token pricer address
        erc20Pricer = new ApplicationERC20Pricing();
        applicationCoinHandler.setERC20PricingAddress(address(erc20Pricer));
        /// testing the creation of rules
        // for(uint256 i; i < 900000;){
        //     NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, i+1);
        //     unchecked{ ++i;}
        // }
    }

    /***************** Test Setters and Getters *****************/

    /*********************** Purchase *******************/
    /// Simple setting and getting (REFACTOR WITH NEW PURCHASE RULE FORMAT)
    // function testSettingPurchaseFuzz(uint8 addressIndex, uint192 amountA, uint192 amountB,
    //     uint32 pPeriodA, uint32 pPeriodB, uint32 fPeriodA, uint32 fPeriodB)
    //     public
    //     {
    //     vm.warp(Blocktime);
    //     vm.stopPrank();
    //     address sender = ADDRESSES[addressIndex%ADDRESSES.length];
    //     vm.startPrank(sender);
    //     /// manual tag necessary because of memory issue.
    //     bytes32[] memory accs = new bytes32[](2);
    //     accs[0] = "tagA";
    //     accs[1] = "tagB";
    //     uint256[] memory pAmounts = new uint256[](2);
    //     pAmounts[0] = amountA;
    //     pAmounts[1] = amountB;
    //     uint32[] memory pPeriods = new uint32[](2);
    //     pPeriods[0] = pPeriodA;
    //     pPeriods[1] = pPeriodB;
    //     uint32[] memory fPeriods = new uint32[](2);
    //     fPeriods[0] = fPeriodA;
    //     fPeriods[1] = fPeriodB;
    //     if((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || amountB == 0 ||
    //         pPeriodA == 0 || pPeriodB == 0 || fPeriodA == 0 || fPeriodB == 0)
    //         vm.expectRevert();
    //     uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, fPeriods);
    //     if((sender == defaultAdmin || sender == appAdminstrator)  &&  amountA > 0 && amountB > 0 &&
    //         pPeriodA > 0 && pPeriodB > 0 && fPeriodA > 0 && fPeriodB > 0) {
    //         assertEq(_index, 0);
    //         TaggedRules.PurchaseRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getPurchaseRule(_index, "tagA");
    //         assertEq(rule.purchaseAmount, amountA);
    //         assertEq(rule.startTime, fPeriodA);
    //         assertEq(rule.purchasePeriod, pPeriodA);

    //         /// testing different input sized
    //         bytes32[] memory invalidAccs = new bytes32[](3);
    //         invalidAccs[0] = "A";
    //         invalidAccs[1] = "B";
    //         invalidAccs[2] = "c";

    //         vm.expectRevert();
    //         _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, invalidAccs, pAmounts, pPeriods, fPeriods);

    //         /// testing adding a second rule
    //         // _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addPurchaseRule(ac, accs, pAmounts, pPeriods, fPeriods);
    //         // assertEq(_index, 1);
    //         // rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getPurchaseRule(_index, "tagB");
    //         // assertEq(rule.purchaseAmount, amountB);
    //         // assertEq(rule.startTime, fPeriodB);
    //         // assertEq(rule.purchasePeriod, pPeriodB);

    //         /// testing total rules
    //         //assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalPurchaseRule(), 2);

    //     }

    // }

    // /************************ Sell *************************/
    // /// Simple setting and getting

    // function testSettingSell(uint8 addressIndex, uint192 amountA, uint192 amountB,
    //                     uint32 dFrozenA, uint32 dFrozenB, bytes32 accA, bytes32 accB) public {
    //     vm.warp(Blocktime);
    //     vm.assume(accA != accB);
    //     vm.assume(accA != bytes32("") && accB != bytes32("") );
    //     vm.stopPrank();
    //     address sender = ADDRESSES[addressIndex%ADDRESSES.length];
    //     vm.startPrank(sender);
    //     bytes32[] memory accs = new bytes32[](2);
    //     accs[0] = accA;
    //     accs[1] = accB;
    //     uint192[] memory sAmounts = new uint192[](2);
    //     sAmounts[0] = amountA;
    //     sAmounts[1] = amountB;
    //     uint32[] memory dFrozen = new uint32[](2);
    //     dFrozen[0] = dFrozenA;
    //     dFrozen[1] = dFrozenB;
    //     uint32[] memory startTimes = new uint32[](2);
    //     startTimes[0] = dFrozenA;
    //     startTimes[1] = dFrozenB;

    //     if((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || amountB == 0 ||
    //         dFrozenA == 0 || dFrozenB == 0 ) vm.expectRevert();
    //     uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSetOfSellRule(ac, accs, sAmounts, dFrozen, startTimes);
    //     if((sender == defaultAdmin || sender == appAdminstrator) && amountA > 0 && amountB > 0 &&
    //         dFrozenA > 0 && dFrozenB > 0) {
    //         assertEq(_index, 0);
    //         TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getSellRuleByIndex(_index, accA);
    //         assertEq(rule.sellAmount, amountA);
    //         assertEq(rule.sellPeriod, dFrozenA);

    //         /// testing different input sized
    //         bytes32[] memory invalidAccs = new bytes32[](3);
    //         invalidAccs[0] = "A";
    //         invalidAccs[1] = "B";
    //         invalidAccs[2] = "c";

    //         vm.expectRevert();
    //         _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSetOfSellRule(ac, invalidAccs, sAmounts, dFrozen, startTimes);

    //         /// testing adding a second rule
    //         _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addSetOfSellRule(ac, accs, sAmounts, dFrozen, startTimes);
    //         assertEq(_index, 1);
    //         rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getSellRuleByIndex(_index, accB);
    //         assertEq(rule.sellAmount, amountB);
    //         assertEq(rule.sellPeriod, dFrozenB);

    //         /// testing total rules
    //         assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalSellRule(), 2);
    //     }
    // }

    /************************ Token Purchase Percentage **********************/
    /// Simple setting and getting

    function testSettingPurchasePercentage(uint8 addressIndex, uint16 pct, uint32 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// test only admin can add rule, and values are within acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || pct > 9999 || pct == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(ac, pct, hFrozen);
        if ((sender == defaultAdmin || sender == appAdminstrator) && pct <= 9999 && hFrozen > 0 && pct > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenPercentagePurchaseRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPctPurchaseRule(_index);
            assertEq(rule.hoursFrozen, hFrozen);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPercentagePurchaseRule(ac, 666, 14);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPctPurchaseRule(_index);
            assertEq(rule.tokenPercentage, 666);
            assertEq(rule.hoursFrozen, 14);

            /// test total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalPctPurchaseRule(), 2);
        }
    }

    /************************ Token Sell Percentage **********************/
    /// Simple setting and getting

    function testSettingSellPercentage(uint8 addressIndex, uint16 pct, uint32 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || pct > 9999 || hFrozen == 0 || pct == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPercentageSellRule(ac, pct, hFrozen);
        if ((sender == defaultAdmin || sender == appAdminstrator) && pct <= 9999 && hFrozen > 0 && pct > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenPercentageSellRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPctSellRule(_index);
            assertEq(rule.hoursFrozen, hFrozen);
            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPercentageSellRule(ac, 666, 14);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPctSellRule(_index);
            assertEq(rule.tokenPercentage, 666);
            assertEq(rule.hoursFrozen, 14);

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalPctSellRule(), 2);
        }
    }

    /************************ Token Purchase Fee By Volume Percentage **********************/
    /// Simple setting and getting

    function testSettingPurchaseFeeByVolume(uint8 addressIndex, uint256 volume, uint16 rate) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || volume == 0 || rate == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, volume, rate);
        if ((sender == defaultAdmin || sender == appAdminstrator) && volume > 0 && rate > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenPurchaseFeeByVolume memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.rateIncreased, rate);
            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addPurchaseFeeByVolumeRule(ac, 10000000000000000000000000000000000, 200);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.volume, 10000000000000000000000000000000000);
            assertEq(rule.rateIncreased, 200);

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalTokenPurchaseFeeByVolumeRules(), 2);
        }
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting

    function testSettingTokenVolatility(uint8 addressIndex, uint16 maxVolatility, uint8 blocks, uint8 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || maxVolatility == 0 || blocks == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, maxVolatility, blocks, hFrozen);
        if ((sender == defaultAdmin || sender == appAdminstrator) && maxVolatility > 0 && blocks > 0 && hFrozen > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenVolatilityRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getVolatilityRule(_index);
            assertEq(rule.hoursFrozen, hFrozen);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addVolatilityRule(ac, 666, 100, 16);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getVolatilityRule(_index);
            assertEq(rule.hoursFrozen, 16);
            assertEq(rule.maxVolatility, 666);
            assertEq(rule.blocksPerPeriod, 100);

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalVolatilityRules(), 2);
        }
    }

    /*********************** Token Trading Volume ************************/
    /// Simple setting and getting

    function testSettingTradingVolume(uint8 addressIndex, uint256 maxVolume, uint8 hPeriod, uint8 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || maxVolume == 0 || hPeriod == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTradingVolumeRule(ac, maxVolume, hPeriod, hFrozen);
        if ((sender == defaultAdmin || sender == appAdminstrator) && maxVolume > 0 && hPeriod > 0 && hFrozen > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenTradingVolumeRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getTradingVolumeRule(_index);
            assertEq(rule.hoursFrozen, hFrozen);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addTradingVolumeRule(ac, 200000000000000000000000000, 1, 36);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getTradingVolumeRule(_index);
            assertEq(rule.maxVolume, 200000000000000000000000000);
            assertEq(rule.hoursPerPeriod, 1);
            assertEq(rule.hoursFrozen, 36);

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalTradingVolumeRules(), 2);
        }
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting

    function testSettingMinTransfer(uint8 addressIndex, uint256 min) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != defaultAdmin && sender != appAdminstrator) || min == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, min);
        if ((sender == defaultAdmin || sender == appAdminstrator) && min > 0) {
            assertEq(_index, 0);
            uint256 rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getMinimumTransferRule(_index);
            assertEq(rule, min);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, 300000000000000);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getMinimumTransferRule(_index);
            assertEq(rule, 300000000000000);

            /// testing getting total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalMinimumTransferRules(), 2);
        }
    }

    // function testMaxRules()  public {
    //     /// testing creating max rules
    //     /// vm.pauseGasMetering();
    //     uint startFrom = NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalMinimumTransferRules();
    //         for(uint256 i=startFrom; i < 0x1ffffffff;){
    //             if(i >= 0xffffffff) vm.expectRevert();
    //             NonTaggedRuleFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, i+1);
    //             vm.warp(i*10);
    //             unchecked{ ++i;}
    //         }
    // }

    /*********************** BalanceLimits *******************/
    /// Simple setting and getting

    function testSettingBalanceLimitsFuzz(uint8 addressIndex, uint256 minA, uint256 minB, uint256 maxA, uint256 maxB, bytes32 accA, bytes32 accB) public {
        vm.assume(accA != accB);
        vm.assume(accA != bytes32("") && accB != bytes32(""));
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        bytes32[] memory accs = new bytes32[](2);
        accs[0] = accA;
        accs[1] = accB;
        uint256[] memory min = new uint256[](2);
        min[0] = minA;
        min[1] = minB;
        uint256[] memory max = new uint256[](2);
        max[0] = maxA;
        max[1] = maxB;
        if ((sender != defaultAdmin && sender != appAdminstrator) || minA == 0 || minB == 0 || maxA == 0 || maxB == 0 || minA > maxA || minB > maxB) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs, min, max);
        if ((sender == defaultAdmin || sender == appAdminstrator) && minA > 0 && minB > 0 && maxA > 0 && maxB > 0 && !(minA > maxA || minB > maxB)) {
            assertEq(_index, 0);
            TaggedRules.BalanceLimitRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getBalanceLimitRule(_index, accA);
            assertEq(rule.minimum, minA);
            assertEq(rule.maximum, maxA);

            /// testing different sizes
            bytes32[] memory invalidAccs = new bytes32[](3);
            vm.expectRevert();
            TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, invalidAccs, min, max);

            /// testing adding a second rule
            bytes32[] memory accs2 = new bytes32[](3);
            uint256[] memory min2 = new uint256[](3);
            uint256[] memory max2 = new uint256[](3);
            accs2[0] = bytes32("Oscar");
            accs2[1] = bytes32("Tayler");
            accs2[2] = bytes32("Shane");
            min2[0] = uint256(100000000);
            min2[1] = uint256(20000000);
            min2[2] = uint256(3000000);
            max2[0] = uint256(100000000000000000000000000000000000000000000000000000000000000000000000000);
            max2[1] = uint256(20000000000000000000000000000000000000);
            max2[2] = uint256(900000000000000000000000000000000000000000000000000000000000000000000000000);
            _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, accs2, min2, max2);
            assertEq(_index, 1);
            rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getBalanceLimitRule(_index, "Tayler");
            assertEq(rule.minimum, min2[1]);
            assertEq(rule.maximum, max2[1]);

            /// testing getting total rules
            assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalBalanceLimitRules(), 2);
        }
    }

    /*********************** Supply Volatility ************************/
    /// Simple setting and getting

    function testSettingSupplyVolatility(uint8 addressIndex, uint16 maxChange, uint8 hPeriod, uint8 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        if ((sender != defaultAdmin && sender != appAdminstrator) || maxChange == 0 || hPeriod == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, maxChange, hPeriod, hFrozen);
        if (!((sender != defaultAdmin && sender != appAdminstrator) || maxChange == 0 || hPeriod == 0 || hFrozen == 0)) {
            assertEq(_index, 0);
            NonTaggedRules.SupplyVolatilityRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getSupplyVolatilityRule(_index);
            assertEq(rule.hoursFrozen, hFrozen);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addSupplyVolatilityRule(ac, 5000, 100, 26);
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getSupplyVolatilityRule(_index);
            assertEq(rule.hoursFrozen, 26);

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalSupplyVolatilityRules(), 2);
        }
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting

    function testOracle(uint8 addressIndex, uint8 _type, address _oracleAddress) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        if ((sender != defaultAdmin && sender != appAdminstrator) || _oracleAddress == address(0)) vm.expectRevert();
        uint32 _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, _type, _oracleAddress);
        if (!((sender != defaultAdmin && sender != appAdminstrator) || _oracleAddress == address(0))) {
            assertEq(_index, 0);
            NonTaggedRules.OracleRule memory rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getOracleRule(_index);
            assertEq(rule.oracleType, _type);
            assertEq(rule.oracleAddress, _oracleAddress);

            /// testing adding a second rule
            _index = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(69));
            assertEq(_index, 1);
            rule = NonTaggedRuleFacet(address(ruleStorageDiamond)).getOracleRule(_index);
            assertEq(rule.oracleType, 1);
            assertEq(rule.oracleAddress, address(69));

            /// testing total rules
            assertEq(NonTaggedRuleFacet(address(ruleStorageDiamond)).getTotalOracleRules(), 2);
        }
    }

    /**************** Tagged Withdrawal Rule Testing  ****************/
    //Test Adding Withdrawal Rule

    function testSettingWithdrawalRuleFuzz(uint8 addressIndex, uint256 amountA, uint256 amountB, uint256 dateA, uint256 dateB, bytes32 accA, bytes32 accB, uint forward) public {
        /// avoiding arithmetic overflow when adding dateA and 1000 for second-rule test
        vm.assume(forward < uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
        vm.assume(accA != accB);
        vm.assume(accA != bytes32("") && accB != bytes32(""));

        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        bytes32[] memory accs = new bytes32[](2);
        accs[0] = accA;
        accs[1] = accB;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = amountA;
        amounts[1] = amountB;
        uint256[] memory releaseDate = new uint256[](2);
        releaseDate[0] = dateA;
        releaseDate[1] = dateB;

        vm.warp(forward);
        if ((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || amountB == 0 || dateA <= block.timestamp || dateB <= block.timestamp) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs, amounts, releaseDate);
        if (!((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || amountB == 0 || dateA <= block.timestamp || dateB <= block.timestamp)) {
            assertEq(_index, 0);
            TaggedRules.WithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getWithdrawalRule(_index, accA);
            assertEq(rule.amount, amountA);
            assertEq(rule.releaseDate, dateA);

            /// we create other parameters for next tests
            bytes32[] memory accs2 = new bytes32[](3);
            uint256[] memory amounts2 = new uint256[](3);
            uint256[] memory releaseDate2 = new uint256[](3);
            accs2[0] = bytes32("Oscar");
            accs2[1] = bytes32("Tayler");
            accs2[2] = bytes32("Shane");
            amounts2[0] = uint256(500);
            amounts2[1] = uint256(1500);
            amounts2[2] = uint256(3000);
            releaseDate2[0] = uint256(block.timestamp + 1100);
            releaseDate2[1] = uint256(block.timestamp + 2200);
            releaseDate2[2] = uint256(block.timestamp + 3300);

            /// testing wrong size of patameters
            vm.expectRevert();
            _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs2, amounts, releaseDate);

            /// testing adding a new rule
            _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addWithdrawalRule(ac, accs2, amounts2, releaseDate2);
            assertEq(_index, 1);
            rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getWithdrawalRule(_index, "Oscar");
            assertEq(rule.amount, 500);
            assertEq(rule.releaseDate, block.timestamp + 1100);

            /// testing total rules
            assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalWithdrawalRule(), 2);
        }
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: 1669745700

    function testAddAdminWithdrawalRuleAppAdministratorFuzz(uint8 addressIndex, uint256 amountA, uint256 dateA, uint forward) public {
        /// avoiding arithmetic overflow when adding dateA and 1000 for second-rule test
        vm.assume(forward < uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
        appManager.addAppAdministrator(address(ruleStorageDiamond));
        assertEq(appManager.isAppAdministrator(address(ruleStorageDiamond)), true);

        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        vm.warp(forward);

        if ((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || dateA <= block.timestamp) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(ac, amountA, dateA);

        if (!((sender != defaultAdmin && sender != appAdminstrator) || amountA == 0 || dateA <= block.timestamp)) {
            assertEq(0, _index);
            TaggedRules.AdminWithdrawalRule memory rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getAdminWithdrawalRule(_index);
            assertEq(rule.amount, amountA);
            assertEq(rule.releaseDate, dateA);

            /// testing adding a second rule
            _index = TaggedRuleDataFacet(address(ruleStorageDiamond)).addAdminWithdrawalRule(ac, 666, block.timestamp + 1000);
            assertEq(1, _index);
            rule = TaggedRuleDataFacet(address(ruleStorageDiamond)).getAdminWithdrawalRule(_index);
            assertEq(rule.amount, 666);
            assertEq(rule.releaseDate, block.timestamp + 1000);

            /// testing total rules
            assertEq(TaggedRuleDataFacet(address(ruleStorageDiamond)).getTotalAdminWithdrawalRules(), 2);
        }
    }

    function testEconActionsFuzz(uint8 addressFrom, uint8 addressTo, uint128 min, bytes32 tag, uint128 bMin, uint128 bMax, uint128 transferAmount, uint128 balanceTo, uint128 balanceFrom) public {
        balanceTo;
        vm.assume(addressFrom % ADDRESSES.length != addressTo % ADDRESSES.length);
        vm.assume(tag != "");
        vm.assume(balanceFrom >= transferAmount);
        address from = ADDRESSES[addressFrom % ADDRESSES.length];
        address to = ADDRESSES[addressTo % ADDRESSES.length];

        /// the different code blocks "{}" are used to isolate computational processes and
        /// avoid the infamous too-many-variable Solidity issue.

        // add the minTransfer rule.
        {
            if (min == 0) vm.expectRevert();
            RuleDataFacet(address(ruleStorageDiamond)).addMinimumTransferRule(ac, min);
            /// if we added the rule in the protocol, then we add it in the application
            if (!(min == 0)) applicationCoinHandler.setMinTransferRuleId(0);
        }

        /// Prepearing for rule
        {
            appManager.addGeneralTag(from, tag); ///add tag
            appManager.addGeneralTag(to, tag); ///add tag
            /// add a minMaxBalance rule
            if (bMin == 0 || bMax == 0 || bMin > bMax) vm.expectRevert();
            bytes32[] memory _accountTypes = new bytes32[](1);
            uint256[] memory _minimum = new uint256[](1);
            uint256[] memory _maximum = new uint256[](1);

            // Set the rule data
            _accountTypes[0] = tag;
            /// we receive uint128 to avoid overflow, so we convert to uint256
            _minimum[0] = uint256(bMin);
            _maximum[0] = uint256(bMax);
            // add the rule.
            TaggedRuleDataFacet(address(ruleStorageDiamond)).addBalanceLimitRules(ac, _accountTypes, _minimum, _maximum);
            /// if we added the rule in the protocol, then we add it in the application
            if (!(bMin == 0 || bMax == 0 || bMin > bMax)) applicationCoinHandler.setMinMaxBalanceRuleId(0);
        }

        /// oracle rules
        {
            /// adding the banning oracle rule
            uint32 banOracle = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 0, address(oracleRestricted));
            /// adding the whitelisting oracle rule
            uint32 whitelistOracle = NonTaggedRuleFacet(address(ruleStorageDiamond)).addOracleRule(ac, 1, address(oracleAllowed));
            /// to simulate randomness in the oracle rule to pick, we grab the transferAmount%2
            if (transferAmount % 2 == 0) applicationCoinHandler.setOracleRuleId(banOracle);
            else applicationCoinHandler.setOracleRuleId(whitelistOracle);
        }

        {
            /// we add the user to both lists since we don't really know what list we will use
            badBoys.push(to);
            oracleRestricted.addToSanctionsList(badBoys);
            goodBoys.push(to);
            oracleAllowed.addToAllowList(goodBoys);
        }
    }
}

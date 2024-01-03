// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";


contract RuleProcessorDiamondTest is Test, TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        vm.warp(Blocktime);
        switchToRuleAdmin();
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
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 1000);
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
        vm.startPrank(address(0xDEADfff));
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 1000);
    }

    function testPassingMinTransferRule() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 2222);

        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 2222);
    }

    function testNotPassingMinTransferRule() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 420);
        vm.expectRevert(0x70311aa2);
        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 400);
    }

    function testMinAccountBalanceCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testMaxTagEnforcementThroughMinAccountBalanceCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        for (uint i = 1; i < 11; i++) {
            applicationAppManager.addGeneralTag(superAdmin, bytes32(i)); //add tag
        }
        vm.expectRevert(0xa3afb2e2);
        applicationAppManager.addGeneralTag(superAdmin, "xtra tag"); //add tag should fail
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = new bytes32[](11);
        for (uint i = 1; i < 12; i++) {
            tags[i - 1] = bytes32(i); //add tag
        }
        console.log(uint(tags[10]));
        vm.expectRevert(0xa3afb2e2);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(totalSupply, tags, amount, ruleId);
    }

    function testFailsMinAccountBalanceCheck() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        //vm.expectRevert(0xf1737570);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testMaxAccountBalanceCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 999;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    function testFailsMaxAccountBalanceCheck() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        //vm.expectRevert(0x24691f6b);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /***************** Test Setters and Getters Rule Storage *****************/

    /*********************** Purchase *******************/
    /// Simple setting and getting
    function testSettingPurchaseStorage() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64[] memory sTimes = createUint64Array(8, 12, 16);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
        // assertEq(_index, 0);
        /// Uncomment lines after merge into internal

        // TaggedRules.PurchaseRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getPurchaseRule(_index, "Oscar");
        // assertEq(rule.purchaseAmount, 1000);
        // assertEq(rule.purchasePeriod, 100);

        // accs[1] = bytes32("Tayler");
        // pAmounts[1] = uint192(20000000);
        // pPeriods[1] = uint16(2);
        // sTimes[1] = uint8(23);

        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
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
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64[] memory sTimes = createUint64Array(8, 12, 16);
        // set user to the super admin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(ruleAdmin); //interact as the rule admin
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingPurchaseWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64[] memory sTimes = createUint64Array(24, 36);

        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
    }

    /// test total rules
    function testTotalRulesOnPurchase() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");   
        uint256[] memory pAmounts = createUint256Array(1000);
        uint16[] memory pPeriods = createUint16Array(100);
        uint64[] memory sTimes = createUint64Array(12);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTimes);
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
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64[] memory sTimes = createUint64Array(Blocktime, Blocktime, Blocktime);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);

        ///Uncomment lines after merge to internal
        // TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, "Oscar");
        // assertEq(rule.sellAmount, 1000);
        // assertEq(rule.sellPeriod, 24);
        // bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        // uint192[] memory pAmounts = createUint192Array(100000000, 20000000, 3000000);
        // uint16[] memory pPeriods = createUint16Array(11, 22, 33);
        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
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
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64[] memory sTimes = createUint64Array(Blocktime, Blocktime, Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingSellWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64[] memory sTimes = createUint64Array(Blocktime, Blocktime, Blocktime);
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
    }

    /// test total rules
    function testTotalRulesOnSell() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint192[] memory sAmounts = createUint192Array(1000);
        uint16[] memory sPeriod = createUint16Array(24);
        uint64[] memory sTimes = createUint64Array(Blocktime);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTimes);
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
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
        assertEq(rule.rateIncreased, 100);

        _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 10000000000000000000000000000000000, 200);
        assertEq(_index, 1);

        ///Uncomment lines after merge to internal
        // rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
        // assertEq(rule.volume, 10000000000000000000000000000000000);
        // assertEq(rule.rateIncreased, 200);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingPurchaseFeeVolumeRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnPurchaseFeeByVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 500 + i, 1 + i);
        }

        ///Uncomment lines after merge to internal
        // assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenPurchaseFeeByVolumeRules(), _indexes.length);
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting
    function testSettingTokenVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 12, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.TokenVolatilityRule memory rule = RuleDataFacet(address(ruleProcessor)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 12);

        _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 666, 100, 16, totalSupply);
        assertEq(_index, 1);
        rule = RuleDataFacet(address(ruleProcessor)).getVolatilityRule(_index);
        assertEq(rule.hoursFrozen, 16);
        assertEq(rule.maxVolatility, 666);
        assertEq(rule.period, 100);
        vm.expectRevert();
        RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(0), 666, 100, 16, totalSupply);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolatilityRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTokenVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000 + i, 60 + i, 24 + i, totalSupply);
        }
        assertEq(RuleDataFacet(address(ruleProcessor)).getTotalVolatilityRules(), _indexes.length);
    }

    /*********************** Token Transfer Volume ************************/
    /// Simple setting and getting
    function testSettingTransferVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 1000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.startTime, Blocktime);

        _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
        assertEq(rule.maxVolume, 2000);
        assertEq(rule.period, 1);
        assertEq(rule.startTime, 12);
        assertEq(rule.totalSupply, 1_000_000_000_000_000 * 10 ** 18);
        vm.expectRevert();
        RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(0), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingVolumeRuleWithoutappAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTransferVolume() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 5000 + i, 60 + i, Blocktime, 0);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTransferVolumeRules(), _indexes.length);
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting
    function testSettingMinTransfer() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        assertEq(_index, 0);
        NonTaggedRules.TokenMinimumTransferRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
        assertEq(rule.minTransferAmount, 500000000000000);

        _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 300000000000000);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
        assertEq(rule.minTransferAmount, 300000000000000);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingMinTransferRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnMinTransfer() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 5000 + i);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalMinimumTransferRules(), _indexes.length);
    }

    /*********************** Min Max Balance Rule Limits *******************/
    /// Simple setting and getting
    function testSettingMinMaxBalanceRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(1000, 2000, 3000);
        uint256[] memory max = createUint256Array(
            10000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000000000000000000000000000000000000
            );
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        assertEq(_index, 0);
        TaggedRules.MinMaxBalanceRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinMaxBalanceRule(_index, "Oscar");
        assertEq(rule.minimum, 1000);
        assertEq(rule.maximum, 10000000000000000000000000000000000000);
        bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min2 = createUint256Array(100000000, 20000000, 3000000);
        uint256[] memory max2 = createUint256Array(
            100000000000000000000000000000000000000000000000000000000000000000000000000, 
            20000000000000000000000000000000000000, 
            900000000000000000000000000000000000000000000000000000000000000000000000000
            );
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs2, min2, max2);
        assertEq(_index, 1);
        rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinMaxBalanceRule(_index, "Tayler");
        assertEq(rule.minimum, 20000000);
        assertEq(rule.maximum, 20000000000000000000000000000000000000);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(0), accs, min, max);
    }

    /// testing only appAdministrators can add Balance Limit Rule
    function testSettingMinMaxBalanceRuleWithoutAppAdministratorAccount() public {
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(1000, 2000, 3000);
        uint256[] memory max = createUint256Array(
            10000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000000000000000000000000000000000000
            );
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        assertEq(_index, 0);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        assertEq(_index, 1);
    }

    /// testing check on input arrays with different sizes
    function testSettingBalanceLimitsWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(1000, 2000);
        uint256[] memory max = createUint256Array(
            10000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000000000000000000000000000000000000
            );
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
    }

    /// testing inverted limits
    function testAddBalanceLimitsWithInvertedLimits() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory max = createUint256Array(100);
        vm.expectRevert(0xeeb9d4f7);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
    }

    /// test total rules
    function testTotalRulesOnBalanceLimits() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory max = createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory min = createUint256Array(100);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        }
        assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalMinMaxBalanceRules(), _indexes.length);
    }

    /*********************** Supply Volatility ************************/
    /// Simple setting and getting
    function testSettingSupplyVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.SupplyVolatilityRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);

        _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 5000, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
        assertEq(rule.startingTime, Blocktime);
    }

    /// testing only appAdministrators can add Purchase Fee By Volume Percentage Rule
    function testSettingSupplyRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnSupplyVolatility() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500 + i, 24 + i, 12, totalSupply);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalSupplyVolatilityRules(), _indexes.length);
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting
    function testOracle() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(69));
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(79));
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 1);
    }

    /// testing only appAdministrators can add Oracle Rule
    function testSettingOracleRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(79));
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnOracle() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalOracleRules(), _indexes.length);
    }

    /*********************** NFT Trade Counter ************************/
    /// Simple setting and getting
    function testNFTTransferCounterRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[1]);
        assertEq(rule.tradesAllowedPerDay, 5);
    }

    /// testing only appAdministrators can add NFT Trade Counter Rule
    function testSettingNFTCounterRuleWithoutAppAdministratorAccount() public {
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnNFTCounter() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        }
        assertEq(ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalNFTTransferCounterRules(), _indexes.length);
    }
    

    /**************** Balance by AccessLevel Rule Testing  ****************/

    /// Test Adding Balance by AccessLevel Rule
    function testBalanceByAccessLevelRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
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
        AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
    }

    ///Get Total Balance by AccessLevel Rules
    function testTotalBalanceByAccessLevelRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        }
        uint256 result = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccessLevelBalanceRules();
        assertEq(result, _indexes.length);
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: block.timestamp + 10000
    function testAddAdminWithdrawalRuleAppAdministratorStorage() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(address(22));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        assertEq(applicationAppManager.isAppAdministrator(address(22)), true);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5000, block.timestamp + 10000);
        TaggedRules.AdminWithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminWithdrawalRule(_index);
        assertEq(rule.amount, 5000);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    function testFailAddAdminWithdrawalRulenotAdmin() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        TaggedRuleDataFacet(superAdmin).addAdminWithdrawalRule(address(applicationAppManager), 6500, 1669748600);
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
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), amount, releaseDate);
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
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory holdPeriods = createUint16Array(100, 101, 102);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
        assertEq(_index, 0);
        TaggedRules.MinBalByDateRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinBalByDateRule(_index, "Oscar");
        assertEq(rule.holdAmount, 1000);
        assertEq(rule.holdPeriod, 100);

        bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts2 = createUint256Array(1000, 20000000, 3000);
        uint16[] memory holdPeriods2 = createUint16Array(100, 2, 102);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs2, holdAmounts2, holdPeriods2, uint64(Blocktime));
        assertEq(_index, 1);
        rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinBalByDateRule(_index, "Tayler");
        assertEq(rule.holdAmount, 20000000);
        assertEq(rule.holdPeriod, 2);
    }

    function testSettingMinBalByDateNotAdmin() public {
        vm.warp(Blocktime);
        vm.stopPrank();
        vm.startPrank(address(0xDEAD));
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory holdPeriods = createUint16Array(100, 101, 102);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
    }

    /// Test for proper array size mismatch error
    function testSettingMinBalByDateSizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory holdPeriods = createUint16Array(100, 101);
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
    }
}

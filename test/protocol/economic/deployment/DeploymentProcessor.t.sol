// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

/**
 * @dev This test suite is for testing the deployed protocol via forking the desired network
 * The test will check if the addresses in the env are valid and then run the tests. If address is not added to the env these will be skkipped.
 * This test suite contains if checks that assume you have followed the deployment guide docs and have added an NFTTransferCounter and AccountBalanceByAccessLevel rule when testing forked contracts.
 */

contract RuleProcessorDiamondTest is Test, TestCommonFoundry {

    address ruleProcessorDiamondAddress;
    bool forkTest;

    function setUp() public {
        if (vm.envAddress("DEPLOYMENT_OWNER") != address(0x0)) {
            /// grab the deployed diamond addresses and set superAdmin and forkTest bool
            superAdmin = vm.envAddress("DEPLOYMENT_OWNER");
            ruleProcessor = RuleProcessorDiamond(payable(vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND")));
            ruleProcessorDiamondAddress = vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND");
            assertEq(ruleProcessorDiamondAddress, vm.envAddress("DEPLOYMENT_RULE_PROCESSOR_DIAMOND"));
            forkTest = true;
        } else {
            vm.warp(Blocktime);
            vm.startPrank(appAdministrator);
            setUpProtocolAndAppManagerAndTokens();
            switchToAppAdministrator();
            console.log("localProcessorDiamond", address(ruleProcessor));
            forkTest = false;
            vm.stopPrank();
        }
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
        switchToRuleAdmin();
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

    /***************** Test Setters and Getters Rule Storage *****************/

    /*********************** Purchase *******************/
    /// Simple setting and getting
    function testSettingPurchaseStorage() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64 sTime = 16;
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        // assertEq(_index, 0);
        /// Uncomment lines after merge into internal

        // TaggedRules.PurchaseRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getPurchaseRule(_index, "Oscar");
        // assertEq(rule.purchaseAmount, 1000);
        // assertEq(rule.purchasePeriod, 100);

        // accs[1] = bytes32("Tayler");
        // pAmounts[1] = uint192(20000000);
        // pPeriods[1] = uint16(2);
        // sTime[1] = uint8(23);

        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        // assertEq(_index, 1);
        // rule = TaggedRuleDataFacet(address(ruleProcessor)).getPurchaseRule(_index, "Tayler");
        // assertEq(rule.purchaseAmount, 20000000);
        // assertEq(rule.purchasePeriod, 2);

        /// test zero address check
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(0), accs, pAmounts, pPeriods, sTime);
    }

    /// testing only appAdministrators can add Purchase Rule
    function testSettingPurchaseRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64 sTime = 16;
        // set user to the super admin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        switchToRuleAdmin(); //interact as the rule admin
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingPurchaseWithArraySizeMismatch() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101);
        uint64 sTime = 16;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
    }

    /// test total rules
    function testTotalRulesOnPurchase() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");   
        uint256[] memory pAmounts = createUint256Array(1000);
        uint16[] memory pPeriods = createUint16Array(100);
        uint64 sTime = 12;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        }
        /// TODO Uncomment line after merge to internal
        /// assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalPurchaseRule(), _indexes.length);
    }

    /************************ Sell *************************/
    /// Simple setting and getting
    function testSettingSell() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        assertEq(_index, 0);

        ///Uncomment lines after merge to internal
        // TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, "Oscar");
        // assertEq(rule.sellAmount, 1000);
        // assertEq(rule.sellPeriod, 24);
        // bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        // uint192[] memory pAmounts = createUint192Array(100000000, 20000000, 3000000);
        // uint16[] memory pPeriods = createUint16Array(11, 22, 33);
        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        // assertEq(_index, 1);
        // rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, "Tayler");
        // assertEq(rule.sellAmount, 20000000);
        // assertEq(rule.sellPeriod, 22);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(0), accs, sAmounts, sPeriod, sTime);
    }

    /// testing only appAdministrators can add Purchase Rule
    function testSettingSellRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        assertEq(_index, 0);
    }

    /// testing check on input arrays with different sizes
    function testSettingSellWithArraySizeMismatch() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
    }

    /// test total rules
    function testTotalRulesOnSell() public {
        switchToRuleAdmin();
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint192[] memory sAmounts = createUint192Array(1000);
        uint16[] memory sPeriod = createUint16Array(24);
        uint64 sTime = Blocktime;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        }
        ///TODO Uncomment lines when merged into internal 
        // assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalSellRule(), _indexes.length);
    }

    /************************ Token Purchase Fee By Volume Percentage **********************/
    /// Simple setting and getting
    function testSettingPurchaseFeeByVolume() public {
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);
        NonTaggedRules.TokenPurchaseFeeByVolume memory rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
        assertEq(rule.rateIncreased, 100);

        _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 10000000000000000000000000000000000, 200);
        assertEq(_index, 1);
        ///TODO Uncomment lines when merged into internal 
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 5000000000000000000000000000000000, 100);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnPurchaseFeeByVolume() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 500 + i, 1 + i);
        }
        assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenPurchaseFeeByVolumeRules(), _indexes.length);
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting
    function testSettingTokenVolatility() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTokenVolatility() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 5000 + i, 60 + i, 24 + i, totalSupply);
        }
        assertEq(RuleDataFacet(address(ruleProcessor)).getTotalVolatilityRules(), _indexes.length);
    }

    /*********************** Token Transfer Volume ************************/
    /// Simple setting and getting
    function testSettingTransferVolume() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnTransferVolume() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 5000 + i, 60 + i, Blocktime, 0);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTransferVolumeRules(), _indexes.length);
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting
    function testSettingMinTransfer() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 500000000000000);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnMinTransfer() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 5000 + i);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalMinimumTransferRules(), _indexes.length);
    }

    /*********************** Min Max Balance Rule Limits *******************/
    /// Simple setting and getting
    function testSettingMinMaxBalances() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        assertEq(_index, 0);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        assertEq(_index, 1);
    }

    /// testing check on input arrays with different sizes
    function testSettingMinMaxBalanceRulesWithArraySizeMismatch() public {
        switchToRuleAdmin();
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
    function testAddMinMaxBalanceRuleWithInvertedLimits() public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory max = createUint256Array(100);
        vm.expectRevert(0xeeb9d4f7);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
    }

    /// test total rules
    function testTotalRulesOnMinMaxBalanceRule() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnSupplyVolatility() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 6500 + i, 24 + i, 12, totalSupply);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalSupplyVolatilityRules(), _indexes.length);
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting
    function testOracle() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(79));
        assertEq(_index, 1);
    }

    /// testing total rules
    function testTotalRulesOnOracle() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(69));
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalOracleRules(), _indexes.length);
    }

    /*********************** NFT Trade Counter ************************/
    function testNFTTransferCounterRule() public {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        if (forkTest == true) {
            assertEq(_index, 1);
            TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
            assertEq(rule.tradesAllowedPerDay, 1);
            rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[1]);
            assertEq(rule.tradesAllowedPerDay, 5);
        } else {
            assertEq(_index, 0);
            TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
            assertEq(rule.tradesAllowedPerDay, 1);
            rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[1]);
            assertEq(rule.tradesAllowedPerDay, 5);
        }
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
        switchToRuleAdmin();
        if (forkTest == true) {
            uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            assertEq(_index, 1);
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            assertEq(_index, 2);
        } else {
            uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            assertEq(_index, 0);
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
            assertEq(_index, 1);
        }
    }

    /// testing total rules
    function testTotalRulesOnNFTCounter() public {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        }
    }

    
    /**************** Balance by AccessLevel Rule Testing  ****************/

    /// Test Adding Balance by AccessLevel Rule
    function testBalanceByAccessLevelRule() public {
        switchToRuleAdmin();
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        /// account for already deployed contract that has AccessLevelBalanceRule added
        if (forkTest == true) {
            uint256 testBalance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccessLevelBalanceRule(0, 2);
            assertEq(testBalance, 100);
        } else {
            uint256 testBalance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccessLevelBalanceRule(_index, 2);
            assertEq(testBalance, 500);
        }
    }

    function testAddBalanceByAccessLevelRulenotAdmin() public {
        switchToRuleAdmin();
        uint48[] memory balanceAmounts;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
    }

    ///Get Total Balance by AccessLevel Rules
    function testTotalBalanceByAccessLevelRules() public {
        switchToRuleAdmin();
        uint256[101] memory _indexes;
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = AppRuleDataFacet(address(ruleProcessor)).addAccessLevelBalanceRule(address(applicationAppManager), balanceAmounts);
        }
        if (forkTest == true) {
            uint256 result = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccessLevelBalanceRules();
            assertEq(result, _indexes.length + 1);
        } else {
            uint256 result = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccessLevelBalanceRules();
            assertEq(result, _indexes.length);
        }
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: block.timestamp + 10000
    function testAddAdminWithdrawalRuleAppAdministratorStorage() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(address(22));
        switchToRuleAdmin();
        assertEq(applicationAppManager.isAppAdministrator(address(22)), true);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 5000, block.timestamp + 10000);
        TaggedRules.AdminWithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminWithdrawalRule(_index);
        assertEq(rule.amount, 5000);
        assertEq(rule.releaseDate, block.timestamp + 10000);
    }

    function testNotPassingAddAdminWithdrawalRulenotAdmin() public {
        switchToUser();
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 6500, 1669748600);
    }

    ///Get Total Admin Withdrawal Rules
    function testTotalAdminWithdrawalRules() public {
        switchToRuleAdmin();
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
        switchToRuleAdmin();
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
        switchToRuleAdmin();
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory holdAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory holdPeriods = createUint16Array(100, 101);
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addMinBalByDateRule(address(applicationAppManager), accs, holdAmounts, holdPeriods, uint64(Blocktime));
    }

    /***************** RULE PROCESSING *****************/

    function testNotPassingAddMinTransferRuleByNonAdmin() public {
        switchToUser();
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 1000);
    }

    function testPassingMinTransferRule() public {
        switchToRuleAdmin();
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 2222);
        switchToUser();
        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 2222);
    }

    function testNotPassingMinTransferRule() public {
        switchToRuleAdmin();
        uint32 index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 420);
        vm.expectRevert(0x70311aa2);
        ERC20RuleProcessorFacet(address(ruleProcessor)).checkMinTransferPasses(index, 400);
    }

    function testMinAccountBalanceCheck() public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(user1, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        switchToSuperAdmin();
        applicationCoin.mint(user1, 10000);
        uint256 amount = 10;
        bytes32[] memory tags = applicationAppManager.getAllTags(user1);
        switchToUser();
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(applicationCoin.balanceOf(user1), tags, amount, ruleId);
    }

    function testMaxTagEnforcementThroughMinAccountBalanceCheck() public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        for (uint i = 1; i < 11; i++) {
            applicationAppManager.addGeneralTag(user1, bytes32(i)); //add tag
        }
        vm.expectRevert(0xa3afb2e2);
        applicationAppManager.addGeneralTag(user1, "xtra tag"); //add tag should fail

        uint256 amount = 1;
        bytes32[] memory tags = new bytes32[](11);
        for (uint i = 1; i < 12; i++) {
            tags[i - 1] = bytes32(i); //add tag
        }
        console.log(uint(tags[10]));
        switchToUser();
        vm.expectRevert(0xa3afb2e2);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(10000000000000000000000, tags, amount, ruleId);
    }

    function testNotPassingMinAccountBalanceCheck() public {
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(user1, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        switchToSuperAdmin();
        applicationCoin.mint(user1, 10000000000000000000000);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(user1), 10000000000000000000000);
        bytes32[] memory tags = applicationAppManager.getAllTags(user1);
        uint256 balance = applicationCoin.balanceOf(user1);
        switchToUser();
        vm.expectRevert(0xf1737570);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).minAccountBalanceCheck(balance, tags, amount, ruleId);
    }

    function testMaxAccountBalanceCheck() public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(user1, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        switchToSuperAdmin();
        uint256 amount = 999;
        bytes32[] memory tags = applicationAppManager.getAllTags(user1);
        switchToUser();
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(applicationCoin.balanceOf(user1), tags, amount, ruleId);
    }

    function testNotPassingMaxAccountBalanceCheck() public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addGeneralTag(user1, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        switchToSuperAdmin();
        applicationCoin.mint(user1, 10000000000000000000000000);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(user1), 10000000000000000000000000);
        bytes32[] memory tags = applicationAppManager.getAllTags(user1);
        uint256 balance = applicationCoin.balanceOf(user1);
        switchToUser();
        vm.expectRevert(0x24691f6b);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).maxAccountBalanceCheck(balance, tags, amount, ruleId);
    }

    function testMinMaxAccountBalanceRuleNFT() public {
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// mint 6 NFTs to appAdministrator for transfer
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);
        applicationNFT.safeMint(appAdministrator);

        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(1);
        uint256[] memory max = createUint256Array(6);

        /// set up a non admin user with tokens
        switchToAppAdministrator();
        ///transfer tokenId 1 and 2 to rich_user
        applicationNFT.transferFrom(appAdministrator, rich_user, 0);
        applicationNFT.transferFrom(appAdministrator, rich_user, 1);
        assertEq(applicationNFT.balanceOf(rich_user), 2);

        ///transfer tokenId 3 and 4 to user1
        applicationNFT.transferFrom(appAdministrator, user1, 3);
        applicationNFT.transferFrom(appAdministrator, user1, 4);
        assertEq(applicationNFT.balanceOf(user1), 2);

        switchToRuleAdmin();
        TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        // add the actual rule
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        switchToAppAdministrator();
        ///Add GeneralTag to account
        applicationAppManager.addGeneralTag(user1, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user1, "Oscar"));
        applicationAppManager.addGeneralTag(user2, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user2, "Oscar"));
        applicationAppManager.addGeneralTag(user3, "Oscar"); ///add tag
        assertTrue(applicationAppManager.hasTag(user3, "Oscar"));
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 3);
        assertEq(applicationNFT.balanceOf(user2), 1);
        assertEq(applicationNFT.balanceOf(user1), 1);
        switchToRuleAdmin();
        ///update ruleId in application NFT handler
        ActionTypes[] memory actionTypes = new ActionTypes[](3);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.MINT;
        actionTypes[2] = ActionTypes.BURN;
        applicationNFTHandler.setMinMaxBalanceRuleId(actionTypes, ruleId);
        /// make sure the minimum rules fail results in revert
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0xf1737570);
        applicationNFT.transferFrom(user1, user3, 4);

        ///make sure the maximum rule fail results in revert
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        // user1 mints to 6 total (limit)
        applicationNFT.safeMint(user1); /// Id 6
        applicationNFT.safeMint(user1); /// Id 7
        applicationNFT.safeMint(user1); /// Id 8
        applicationNFT.safeMint(user1); /// Id 9
        applicationNFT.safeMint(user1); /// Id 10

        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationNFT.safeMint(user2);
        // transfer to user1 to exceed limit
        vm.stopPrank();
        vm.startPrank(user2);
        vm.expectRevert(0x24691f6b);
        applicationNFT.transferFrom(user2, user1, 3);

        /// test that burn works with rule
        applicationNFT.burn(3);
        vm.expectRevert(0xf1737570);
        applicationNFT.burn(11);
    }

    function testNFTOracle() public {
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);
        applicationNFT.safeMint(user1);

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        assertEq(_index, 0);
        NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(oracleDenied));
        // add a blocked address
        switchToAppAdministrator();
        badBoys.push(address(69));
        oracleDenied.addToDeniedList(badBoys);
        /// connect the rule to this handler
        switchToRuleAdmin();
        ActionTypes[] memory actionTypes = new ActionTypes[](3);
        actionTypes[0] = ActionTypes.P2P_TRANSFER;
        actionTypes[1] = ActionTypes.MINT;
        actionTypes[2] = ActionTypes.BURN;
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        // test that the oracle works
        // This one should pass
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        ///perform transfer that checks rule
        // This one should fail
        vm.expectRevert(0x2767bda4);
        applicationNFT.transferFrom(user1, address(69), 1);
        assertEq(applicationNFT.balanceOf(address(69)), 0);
        // check the allowed list type
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        /// connect the rule to this handler
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        // add an allowed address
        switchToAppAdministrator();
        goodBoys.push(address(59));
        oracleAllowed.addToAllowList(goodBoys);
        vm.stopPrank();
        vm.startPrank(user1);
        // This one should pass
        applicationNFT.transferFrom(user1, address(59), 2);
        // This one should fail
        vm.expectRevert(0x7304e213);
        applicationNFT.transferFrom(user1, address(88), 3);

        // Finally, check the invalid type
        switchToRuleAdmin();
        bytes4 selector = bytes4(keccak256("InvalidOracleType(uint8)"));
        vm.expectRevert(abi.encodeWithSelector(selector, 2));
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 2, address(oracleAllowed));

        /// set oracle back to allow and attempt to burn token
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        /// swap to user and burn
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.burn(4);
        /// set oracle to deny and add address(0) to list to deny burns
        switchToRuleAdmin();
        _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
        applicationNFTHandler.setOracleRuleId(actionTypes, _index);
        switchToAppAdministrator();
        badBoys.push(address(0));
        oracleDenied.addToDeniedList(badBoys);
        /// user attempts burn
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert(0x2767bda4);
        applicationNFT.burn(3);
    }

    function testNFTTradeRuleInNFT() public {
        vm.warp(Blocktime);
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        /// set up a non admin user an nft
        applicationNFT.safeMint(user1); // tokenId = 0
        applicationNFT.safeMint(user1); // tokenId = 1
        applicationNFT.safeMint(user1); // tokenId = 2
        applicationNFT.safeMint(user1); // tokenId = 3
        applicationNFT.safeMint(user1); // tokenId = 4

        assertEq(applicationNFT.balanceOf(user1), 5);

        // add the rule.
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        switchToRuleAdmin();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addNFTTransferCounterRule(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.NFTTradeCounterRule memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getNFTTransferCounterRule(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        // apply the rule to the ApplicationERC721Handler
        applicationNFTHandler.setTradeCounterRuleId(_createActionsArray(), _index);
        // tag the NFT collection
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag

        // ensure standard transfer works by transferring 1 to user2 and back(2 trades)
        ///perform transfer that checks rule
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 0);
        assertEq(applicationNFT.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        applicationNFT.transferFrom(user2, user1, 0);
        assertEq(applicationNFT.balanceOf(user2), 0);

        // set to a tag that only allows 1 transfer
        switchToAppAdministrator();
        applicationAppManager.removeGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        applicationAppManager.addGeneralTag(address(applicationNFT), "BoredGrape"); ///add tag
        // perform 1 transfer
        vm.stopPrank();
        vm.startPrank(user1);
        applicationNFT.transferFrom(user1, user2, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 1);
        // add a day to the time and it should pass
        vm.warp(block.timestamp + 1 days);
        applicationNFT.transferFrom(user2, user1, 1);
        assertEq(applicationNFT.balanceOf(user2), 0);

        // add the other tag and check to make sure that it still only allows 1 trade
        switchToAppAdministrator();
        applicationAppManager.addGeneralTag(address(applicationNFT), "DiscoPunk"); ///add tag
        vm.stopPrank();
        vm.startPrank(user1);
        // first one should pass
        applicationNFT.transferFrom(user1, user2, 2);
        vm.stopPrank();
        vm.startPrank(user2);
        // this one should fail because it is more than 1 in 24 hours
        vm.expectRevert(0x00b223e3);
        applicationNFT.transferFrom(user2, user1, 2);
    }
}

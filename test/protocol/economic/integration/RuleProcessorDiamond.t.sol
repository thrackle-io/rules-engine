// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";


contract RuleProcessorDiamondTest is Test, TestCommonFoundry, RuleCreation {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        vm.warp(Blocktime);
        switchToRuleAdmin();
    }

    /// Test Diamond upgrade
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

    /// Test Adding Token Min Transaction Size Rule 
    function testTokenMinTransactionSizeAdd() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 1000);
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(index).minSize, 1000);
    }

    /// Test Diamond Versioning 
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

    /// Test Adding Token Min Transaction Size Rule by Non admin 
    function testFailAddTokenMinTransactionSizeRuleByNonAdmin() public {
        vm.stopPrank();
        vm.startPrank(address(0xDEADfff));
        RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 1000);
    }

    /// Test Adding Token Min Transaction Size 
    function testPassingTokenMinTransactionSize() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 2222);

        ERC20RuleProcessorFacet(address(ruleProcessor)).checkTokenMinTxSize(index, 2222);
    }

    /// Test Adding Token Min Transaction Size Not Passing 
    function testTokenMinTransactionSizeNotPassing() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 420);
        vm.expectRevert(0x7a78c901);
        ERC20RuleProcessorFacet(address(ruleProcessor)).checkTokenMinTxSize(index, 400);
    }

    /// Test Account Min Max Token Balance 
    function testAccountMinMaxTokenBalanceCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        uint16[] memory empty;
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMinTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Token Balance Rule with Blank Tags 
    function testAccountMinMaxTokenBalanceBlankTagProcessCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(10000000000000000000000000);
        uint16[] memory empty;

        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 1;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMinTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Token Balance Rule with Blank Tags negative case 
    function testAccountMinMaxTokenBalanceBlankTagCreationCheckNegative() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("", "Shane");
        uint256[] memory min = createUint256Array(10,100);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000);
        uint16[] memory empty;
        // Can't add a blank and specific tag together
        vm.expectRevert(0x6bb35a99);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
    }

    /// Test Adding Account Min Max Token Balance Rule with Blank Tags 
    function testAccountMinMaxTokenBalanceBlankTagCreationCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar", "Shane");
        uint256[] memory min = createUint256Array(10,100);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000);
        uint16[] memory empty;
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
    }

    /// Test Account Min Max Token Balance Rule Max Tag Enforcement 
    function testAccountMinMaxTokenBalanceMaxTagEnforcement() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        uint16[] memory empty;
        // add rule at ruleId 0
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        for (uint i = 1; i < 11; i++) {
            applicationAppManager.addTag(superAdmin, bytes32(i)); //add tag
        }
        vm.expectRevert(0xa3afb2e2);
        applicationAppManager.addTag(superAdmin, "xtra tag"); //add tag should fail
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
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMinTokenBalance(totalSupply, tags, amount, ruleId);
    }

    /// Test Account Min Max Token Balance Rule Fail Scenario 
    function testFailsAccountMinMaxTokenBalanceCheck() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        uint16[] memory empty;
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        //vm.expectRevert(0x3e237976);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMinTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Token Balance 
    function testAccountMinMaxBalanceCheck() public {
        applicationCoin.mint(superAdmin, totalSupply);
        
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        uint16[] memory empty;
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 999;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMaxTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Balance Rule With Blank Tags 
    function testAccountMinMaxTokenBalanceBlankTagProcessChecks() public {
        applicationCoin.mint(superAdmin, totalSupply);
        
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(1000000000000000000000000000000);
        uint16[] memory empty;

        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 999;
        assertEq(applicationCoin.balanceOf(superAdmin), totalSupply);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMaxTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Balance Check Fail Scenario 
    function testFailsAccountMinMaxTokenBalanceChecks() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(10, 20, 30);
        uint256[] memory max = createUint256Array(10000000000000000000000000, 10000000000000000000000000000, 1000000000000000000000000000000);
        uint16[] memory empty;
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), 10000000000000000000000);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);

        //vm.expectRevert(0x1da56a44);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMaxTokenBalance(applicationCoin.balanceOf(superAdmin), tags, amount, ruleId);
    }

    /// Test Account Min Max Balance Rule With Blank Tag Negative Case 
    function tesAccountMinMaxTokenBalanceBlankTagCheckNegative() public {
        applicationCoin.mint(superAdmin, totalSupply);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        // add rule at ruleId 0
        bytes32[] memory accs = createBytes32Array("");
        uint256[] memory min = createUint256Array(10);
        uint256[] memory max = createUint256Array(10000);
        uint16[] memory empty;

        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank();
        vm.startPrank(appAdministrator);
        applicationAppManager.addTag(superAdmin, "Oscar"); //add tag
        assertTrue(applicationAppManager.hasTag(superAdmin, "Oscar"));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        uint256 amount = 10000000000000000000000000;
        assertEq(applicationCoin.balanceOf(superAdmin), 100000000000);
        bytes32[] memory tags = applicationAppManager.getAllTags(superAdmin);
        uint256 balance = applicationCoin.balanceOf(superAdmin);
        vm.expectRevert(0x1da56a44);
        ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).checkAccountMaxTokenBalance(balance, tags, amount, ruleId);
    }

    /***************** Test Setters and Getters Rule Storage *****************/

    /*********************** AccountMaxBuySize *******************/
    /// Simple setting and getting
    function testAccountMaxBuySizeSettingStorage() public {
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64 sTime = 16;
        vm.stopPrank();
        vm.startPrank(ruleAdmin);

        /// test zero address check
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(0), accs, pAmounts, pPeriods, sTime);
    }

    /// Test only ruleAdministrators can add AccountMaxBuySize Rule
    function testAccountMaxBuySizeSettingRuleWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101, 102);
        uint64 sTime = 16;
        // set user to the super admin
        vm.stopPrank();
        vm.startPrank(superAdmin);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(ruleAdmin); //interact as the rule admin
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        assertEq(_index, 0);
    }

    /// Test mismatched arrays sizes
    function testAccountMaxBuySizeSettingWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint256[] memory pAmounts = createUint256Array(1000, 2000, 3000);
        uint16[] memory pPeriods = createUint16Array(100, 101);
        uint64 sTime = 24;

        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
    }

    /// Test total rules
    function testAccountMaxBuySizeTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");   
        uint256[] memory pAmounts = createUint256Array(1000);
        uint16[] memory pPeriods = createUint16Array(100);
        uint64 sTime = 12;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, pAmounts, pPeriods, sTime);
        }
        /// Uncomment lines after merge to internal 
        //assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalAccountMaxBuySize(), _indexes.length);
    }

    /************************ AccountMaxSellSize *************************/
    /// Simple setting and getting
    function testAccountMaxSellSizeSetting() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        assertEq(_index, 0);

        ///Uncomment lines after merge to internal
        // TaggedRules.AccountMaxSellSize memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getAccountMaxSellSizeByIndex(_index, "Oscar");
        // assertEq(rule.maxValue, 1000);
        // assertEq(rule.period, 24);
        // bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        // uint192[] memory pAmounts = createUint192Array(100000000, 20000000, 3000000);
        // uint16[] memory pPeriods = createUint16Array(11, 22, 33);
        // _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        // assertEq(_index, 1);
        // rule = TaggedRuleDataFacet(address(ruleProcessor)).getAccountMaxSellSizeByIndex(_index, "Tayler");
        // assertEq(rule.maxValue, 20000000);
        // assertEq(rule.period, 22);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(0), accs, sAmounts, sPeriod, sTime);
    }

    /// Test only ruleAdministrators can add AccountMaxSellSize Rule
    function testAccountMaxSellSizeSettingWithoutAppAdministratorAccount() public {
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        assertEq(_index, 0);
    }

    /// Test mismatched arrays sizes
    function testAccountMaxSellSizeSettingWithArraySizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler");   
        uint192[] memory sAmounts = createUint192Array(1000, 2000, 3000);
        uint16[] memory sPeriod = createUint16Array(24, 36, 48);
        uint64 sTime = Blocktime;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
    }

    /// Test total rules
    function testAccountMaxSellSizeTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint192[] memory sAmounts = createUint192Array(1000);
        uint16[] memory sPeriod = createUint16Array(24);
        uint64 sTime = Blocktime;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, sAmounts, sPeriod, sTime);
        }
        ///Uncomment lines after merge to internal
        // assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalAccountMaxSellSize(), _indexes.length);
    }

    /************************ PurchaseFeeByVolumeRule **********************/
    /// Simple setting and getting
    function testPurchaseFeeByVolumeRuleSetting() public {
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

    /// Test only ruleAdministrators can add Purchase Fee By Volume Percentage Rule
    function testPurchaseFeeByVolumeRuleSettingWithoutAppAdministratorAccount() public {
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

    /// Test total rules
    function testPurchaseFeeByVolumeRuleTotalRules() public {
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

    /*********************** TokenMaxPriceVolatility ************************/
    /// Simple setting and getting
    function testTokenMaxPriceVolatilitySetting() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000, 60, 12, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.TokenMaxPriceVolatility memory rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);
        assertEq(rule.hoursFrozen, 12);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 666, 100, 16, totalSupply);
        assertEq(_index, 1);
        rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);
        assertEq(rule.hoursFrozen, 16);
        assertEq(rule.max, 666);
        assertEq(rule.period, 100);
        vm.expectRevert();
        RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(0), 666, 100, 16, totalSupply);
    }

    /// Test only ruleAdministrators can add TokenMaxPriceVolatility Rule
    function testTokenMaxPriceVolatilitySettingRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000, 60, 24, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000, 60, 24, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000, 60, 24, totalSupply);
        assertEq(_index, 1);
    }

    /// Test total rules
    function testTokenMaxPriceVolatilityTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 5000 + i, 60 + i, 24 + i, totalSupply);
        }
        assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenMaxPriceVolatility(), _indexes.length);
    }

    /*********************** Token Max Trading Volume Rule ************************/
    /// Simple setting and getting
    function testTokenMaxTradingVolumeRuleSetting() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 1000, 2, Blocktime, 0);
        assertEq(_index, 0);
        NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
        assertEq(rule.startTime, Blocktime);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
        assertEq(rule.max, 2000);
        assertEq(rule.period, 1);
        assertEq(rule.startTime, 12);
        assertEq(rule.totalSupply, 1_000_000_000_000_000 * 10 ** 18);
        vm.expectRevert();
        RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(0), 2000, 1, 12, 1_000_000_000_000_000 * 10 ** 18);
    }

    /// Test only ruleAdministrators can add Token Max Trading Volume Rule
    function testTransferVolumeRuleSettingWithoutappAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 4000, 2, 23, 0);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 4000, 2, 23, 0);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 4000, 2, 23, 0);
        assertEq(_index, 1);
    }

    /// Test total rules
    function testTransferVolumeRuleTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 5000 + i, 60 + i, Blocktime, 0);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume(), _indexes.length);
    }

    /*********************** TokenMinTransactionSize ************************/
    /// Simple setting and getting
    function testTokenMinTransactionSizeSetting() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 500000000000000);
        assertEq(_index, 0);
        NonTaggedRules.TokenMinTxSize memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
        assertEq(rule.minSize, 500000000000000);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 300000000000000);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
        assertEq(rule.minSize, 300000000000000);
    }

    /// Test only ruleAdministrators can add TokenMinTransactionSize Rule
    function testTokenMinTransactionSizeSettingRuleWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 500000000000000);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 500000000000000);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 500000000000000);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 500000000000000);
        assertEq(_index, 1);
    }

    /// Test total rules
    function testTokenMinTransactionSizeTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 5000 + i);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize(), _indexes.length);
    }

    /*********************** AccountMinMaxTokenBalance *******************/
    /// Simple setting and getting
    function testAccountMinMaxTokenBalanceSetting() public {
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
        uint16[] memory empty;
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        assertEq(_index, 0);
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Oscar");
        assertEq(rule.min, 1000);
        assertEq(rule.max, 10000000000000000000000000000000000000);
        bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min2 = createUint256Array(100000000, 20000000, 3000000);
        uint256[] memory max2 = createUint256Array(
            100000000000000000000000000000000000000000000000000000000000000000000000000, 
            20000000000000000000000000000000000000, 
            900000000000000000000000000000000000000000000000000000000000000000000000000
            );
        uint16[] memory empty2;
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs2, min2, max2, empty2, uint64(Blocktime));
        assertEq(_index, 1);
        rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Tayler");
        assertEq(rule.min, 20000000);
        assertEq(rule.max, 20000000000000000000000000000000000000);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(0), accs, min, max, empty, uint64(Blocktime));
    }

    /// Test only ruleAdministrators can add Account Min Max Balance Rule
    function testAccountMinMaxTokenBalanceSettingWithoutAppAdministratorAccount() public {
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory min = createUint256Array(1000, 2000, 3000);
        uint256[] memory max = createUint256Array(
            10000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000, 
            100000000000000000000000000000000000000000000000000000000000000000000000000
            );
        uint16[] memory empty;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        assertEq(_index, 0);
        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        assertEq(_index, 1);
    }

    /// Test mismatched array sizes
    function testAccountMinMaxTokenBalanceSettingWithArraySizeMismatch() public {
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
        uint16[] memory empty;
        vm.expectRevert(0x028a6c58);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
    }

    /// Test inverted limits
    function testAccountMinMaxTokenBalanceAddWithInvertedLimits() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory min = createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory max = createUint256Array(100);
        uint16[] memory empty;
        vm.expectRevert(0xeeb9d4f7);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
    }

    /// Test mixing Periodic and Non-Periodic cases
    function testAccountMinMaxTokenBalanceAddMixedPeriodicAndNonPeriodic() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory accs = createBytes32Array("Oscar", "Shane");
        uint256[] memory min = createUint256Array(10, 20);
        uint256[] memory max = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000, 
            999999000000000000000000000000000000000000000000000000000000000000000000000
            );
        uint16[] memory periods = createUint16Array(10, 0);
        vm.expectRevert(0xb75194a4);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, periods, uint64(Blocktime));
    }

    /// Test total rules
    function testAccountMinMaxTokenBalanceTotal() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        bytes32[] memory accs = createBytes32Array("Oscar");
        uint256[] memory max = createUint256Array(999999000000000000000000000000000000000000000000000000000000000000000000000);
        uint256[] memory min = createUint256Array(100);
        uint16[] memory empty;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        }
        assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMinMaxTokenBalances(), _indexes.length);
    }

    /// With Hold Periods

    /// Simple setting and getting
    function testAccountMinMaxTokenBalanceSetting2() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory minAmounts = createUint256Array(1000, 2000, 3000);
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        uint16[] memory periods = createUint16Array(100, 101, 102);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
        assertEq(_index, 0);
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Oscar");
        assertEq(rule.min, 1000);
        assertEq(rule.period, 100);

        bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory minAmounts2 = createUint256Array(1000, 20000000, 3000);
        uint256[] memory maxAmounts2 = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        uint16[] memory periods2 = createUint16Array(100, 2, 102);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs2, minAmounts2, maxAmounts2, periods2, uint64(Blocktime));
        assertEq(_index, 1);
        rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Tayler");
        assertEq(rule.min, 20000000);
        assertEq(rule.period, 2);
    }

    /// Test AccountMinMaxTokenBalance setting while not admin 
    function testAccountMinMaxTokenBalanceSettingNotAdmin() public {
        vm.warp(Blocktime);
        vm.stopPrank();
        vm.startPrank(address(0xDEAD));
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory minAmounts = createUint256Array(1000, 2000, 3000);
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        uint16[] memory periods = createUint16Array(100, 101, 102);
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
    }

    /// Test for array size mismatch error
    function testAccountMinMaxTokenBalanceSettingSizeMismatch() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        vm.warp(Blocktime);
        bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
        uint256[] memory minAmounts = createUint256Array(1000, 2000, 3000);
        uint256[] memory maxAmounts = createUint256Array(
            999999000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000,
            999990000000000000000000000000000000000000000000000000000000000000000000000
        );
        uint16[] memory periods = createUint16Array(100, 101);
        vm.expectRevert();
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, minAmounts, maxAmounts, periods, uint64(Blocktime));
    }

    /*********************** TokenMaxSupplyVolatility ************************/
    /// Simple setting and getting
    function testTokenMaxSupplyVolatilitySetting() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        NonTaggedRules.TokenMaxSupplyVolatility memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
        assertEq(rule.startTime, Blocktime);

        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 5000, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
        assertEq(rule.startTime, Blocktime);
    }

    /// Test only ruleAdministrators can add Token Max Supply Volatility Rule
    function testTokenMaxSupplyVolatilitySettingWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 0);
        _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500, 24, Blocktime, totalSupply);
        assertEq(_index, 1);
    }

    /// Test total rules
    function testTokenMaxSupplyVolatilityTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 6500 + i, 24 + i, 12, totalSupply);
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSupplyVolatility(), _indexes.length);
    }

    /*********************** AccountApproveDenyOracle ************************/
    /// Simple setting and getting
    function testAccountApproveDenyOracle() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(69));
        assertEq(_index, 0);
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 0);
        assertEq(rule.oracleAddress, address(69));
        _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(79));
        assertEq(_index, 1);
        rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
        assertEq(rule.oracleType, 1);
    }

    /// Test only ruleAdministrators can add AccountApproveDenyOracle Rule
    function testAccountApproveDenyOracleSettingWithoutAppAdministratorAccount() public {
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(69));
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(69));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(69));
        assertEq(_index, 0);

        _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(79));
        assertEq(_index, 1);
    }

    /// Test total rules
    function testAccountApproveDenyOracleTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(69));
        }
        assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalAccountApproveDenyOracle(), _indexes.length);
    }

    /*********************** TokenMaxDailyTrades ************************/
    /// Simple setting and getting
    function testTokenMaxDailyTradesRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
        rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[1]);
        assertEq(rule.tradesAllowedPerDay, 5);
    }

    /// Test Token Max Daily Trades Rule with Blank Tags
    function testTokenMaxDailyTradesRulesBlankTag() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array(""); 
        uint8[] memory tradesAllowed = createUint8Array(1);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, 1);
    }

    /// Test Token Max Daily Trades Rule with negative case
    function testTokenMaxDailyTradesRulesBlankTagNegative() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array("","BoredGrape"); 
        uint8[] memory tradesAllowed = createUint8Array(1,5);
        vm.expectRevert(0x6bb35a99);
        TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
    }

    /// testing only ruleAdministrators can add TokenMaxDailyTrades Rule
    function testTokenMaxDailyTradesSettingRuleWithoutAppAdministratorAccount() public {
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xC0FFEE)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 0);

        _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        assertEq(_index, 1);
    }

    /// Test total rules
    function testTokenMaxDailyTradesTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        bytes32[] memory nftTags = createBytes32Array("BoredGrape", "DiscoPunk"); 
        uint8[] memory tradesAllowed = createUint8Array(1, 5);
        uint256[101] memory _indexes;
        for (uint8 i = 0; i < 101; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        }
        assertEq(ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxDailyTrades(), _indexes.length);
    }
    

    /**************** AccountMaxValueByAccessLevel Rule Testing  ****************/

    /// Test Adding AccountMaxValueByAccessLevel Rule
    function testAccountMaxValueByAccessLevelRule() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        uint256 testBalance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueByAccessLevel(_index, 2);
        assertEq(testBalance, 500);
    }

    /// Test Account Max Value By Access Level add while not admin 
    function testAccountMaxValueByAccessLevelAddRulenotAdmin() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint48[] memory balanceAmounts;
        vm.stopPrank(); //stop interacting as the super admin
        vm.startPrank(address(0xDEAD)); //interact as a different user
        vm.expectRevert(0xd66c3008);
        AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
    }

    /// Test Get Total AccountMaxValueByAccessLevel Rules
    function testAccountMaxValueByAccessLevelTotalRules() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        uint48[] memory balanceAmounts = createUint48Array(10, 100, 500, 1000, 1000);
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        }
        uint256 result = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueByAccessLevel();
        assertEq(result, _indexes.length);
    }

    /**************** AdminMinTokenBalance Rule Testing  ****************/

    /// Test Adding AdminMinTokenBalance Rule endTime: block.timestamp + 10000
    function testAdminMinTokenBalanceAddStorage() public {
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(address(22));
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        assertEq(applicationAppManager.isAppAdministrator(address(22)), true);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 5000, block.timestamp + 10000);
        TaggedRules.AdminMinTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(_index);
        assertEq(rule.amount, 5000);
        assertEq(rule.endTime, block.timestamp + 10000);
    }

    /// Test Admin Min Token Balance adding while not admin 
    function testFailAdminMinTokenBalanceAddNotAdmin() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        TaggedRuleDataFacet(superAdmin).addAdminMinTokenBalance(address(applicationAppManager), 6500, 1669748600);
    }

    /// Test Get Total AdminMinTokenBalance Rules
    function testAdminMinTokenBalanceTotal() public {
        // set user to the rule admin
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        uint256[101] memory _indexes;
        uint256 amount = 1000;
        uint256 endTime = block.timestamp + 10000;
        for (uint8 i = 0; i < _indexes.length; i++) {
            _indexes[i] = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), amount, endTime);
        }
        uint256 result;
        result = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAdminMinTokenBalance();
        assertEq(result, _indexes.length);
    }
}

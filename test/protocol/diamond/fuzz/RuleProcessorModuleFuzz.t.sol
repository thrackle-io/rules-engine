// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";

contract RuleProcessorModuleFuzzTest is TestCommonFoundry {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProtocolAndAppManagerAndTokens();
        vm.warp(Blocktime);
        switchToRuleAdmin();
    }

    /***************** Test Setters and Getters *****************/
    /************************ Token Purchase Fee By Volume Percentage **********************/
    /// Simple setting and getting

    function testSettingPurchaseFeeByVolume(uint8 addressIndex, uint256 volume, uint16 rate) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || volume == 0 || rate == 0 || rate > 10000) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), volume, rate);
        if ((sender == ruleAdmin) && volume > 0 && rate > 0 && rate <= 10000) {
            assertEq(_index, 0);
            NonTaggedRules.TokenPurchaseFeeByVolume memory rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.rateIncreased, rate);
            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 10000000000000000000000000000000000, 200);
            assertEq(_index, 1);
            rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.volume, 10000000000000000000000000000000000);
            assertEq(rule.rateIncreased, 200);

            /// testing total rules
            assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenPurchaseFeeByVolumeRules(), 2);
        }
    }

    /*********************** Token Volatility ************************/
    /// Simple setting and getting

    function testSettingTokenVolatility(uint8 addressIndex, uint16 maxVolatility, uint8 blocks, uint8 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || maxVolatility == 0 || maxVolatility > 100000 || blocks == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), maxVolatility, blocks, hFrozen, totalSupply);
        if ((sender == ruleAdmin) && maxVolatility > 0 && maxVolatility <= 100000 && blocks > 0 && hFrozen > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenVolatilityRule memory rule = RuleDataFacet(address(ruleProcessor)).getVolatilityRule(_index);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addVolatilityRule(address(applicationAppManager), 666, 100, 12, totalSupply);
            assertEq(_index, 1);
            rule = RuleDataFacet(address(ruleProcessor)).getVolatilityRule(_index);
            assertEq(rule.hoursFrozen, 12);
            assertEq(rule.maxVolatility, 666);
            assertEq(rule.period, 100);

            /// testing total rules
            assertEq(RuleDataFacet(address(ruleProcessor)).getTotalVolatilityRules(), 2);
        }
    }

    /*********************** Token Transfer Volume ************************/
    /// Simple setting and getting

    function testSettingTransferVolumeFuzz(uint8 addressIndex, uint16 maxVolume, uint8 hPeriod, uint64 _startTime) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || maxVolume == 0 || maxVolume > 100000 || hPeriod == 0 || _startTime == 0 || _startTime > (block.timestamp + (52 * 1 weeks))) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), maxVolume, hPeriod, _startTime, 0);
        if ((sender == ruleAdmin) && maxVolume > 0 && maxVolume <= 100000 && hPeriod > 0 && _startTime > 0 && _startTime < 24) {
            assertEq(_index, 0);
            NonTaggedRules.TokenTransferVolumeRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
            assertEq(rule.startTime, _startTime);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTransferVolumeRule(address(applicationAppManager), 2000, 1, Blocktime, 0);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTransferVolumeRule(_index);
            assertEq(rule.maxVolume, 2000);
            assertEq(rule.period, 1);
            assertEq(rule.startTime, Blocktime);

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTransferVolumeRules(), 2);
        }
    }

    /*********************** Minimum Transfer ************************/
    /// Simple setting and getting

    function testSettingMinTransfer(uint8 addressIndex, uint256 min) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || min == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), min);
        if ((sender == ruleAdmin) && min > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMinimumTransferRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
            assertEq(rule.minTransferAmount, min);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), 300000000000000);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getMinimumTransferRule(_index);
            assertEq(rule.minTransferAmount, 300000000000000);

            /// testing getting total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalMinimumTransferRules(), 2);
        }
    }

    // function testMaxRules()  public {
    //     /// testing creating max rules
    //     /// vm.pauseGasMetering();
    //     uint startFrom = RuleDataFacet(address(ruleProcessor)).getTotalMinimumTransferRules();
    //         for(uint256 i=startFrom; i < 0x1ffffffff;){
    //             if(i >= 0xffffffff) vm.expectRevert();
    //             RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), i+1);
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

        bytes32[] memory accs = createBytes32Array(accA, accB);
        uint256[] memory min = createUint256Array(minA, minB);
        uint256[] memory max = createUint256Array(maxA, maxB);
        if ((sender != ruleAdmin) || minA == 0 || minB == 0 || maxA == 0 || maxB == 0 || minA > maxA || minB > maxB) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), accs, min, max);
        if ((sender == ruleAdmin) && minA > 0 && minB > 0 && maxA > 0 && maxB > 0 && !(minA > maxA || minB > maxB)) {
            assertEq(_index, 0);
            TaggedRules.MinMaxBalanceRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getMinMaxBalanceRule(_index, accA);
            assertEq(rule.minimum, minA);
            assertEq(rule.maximum, maxA);

            /// testing different sizes
            bytes32[] memory invalidAccs = new bytes32[](3);
            vm.expectRevert();
            TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), invalidAccs, min, max);

            /// testing adding a second rule
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
            assertEq(rule.minimum, min2[1]);
            assertEq(rule.maximum, max2[1]);

            /// testing getting total rules
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalMinMaxBalanceRules(), 2);
        }
    }

    /*********************** Supply Volatility ************************/
    /// Simple setting and getting

    function testSettingSupplyVolatilityFuzz(uint8 addressIndex, uint16 maxChange, uint8 hPeriod, uint64 _startTimestamp) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        vm.assume(maxChange < 9999 && maxChange > 0);
        if (maxChange < 100) maxChange = 100;
        if (_startTimestamp > (block.timestamp + (52 * 1 weeks))) _startTimestamp = uint64(block.timestamp + (52 * 1 weeks));
        if (hPeriod > 23) hPeriod = 23;
        if ((sender != ruleAdmin) || maxChange == 0 || hPeriod == 0 || _startTimestamp == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), maxChange, hPeriod, _startTimestamp, totalSupply);
        if (!((sender != ruleAdmin) || maxChange == 0 || hPeriod == 0 || _startTimestamp == 0)) {
            assertEq(_index, 0);
            NonTaggedRules.SupplyVolatilityRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
            assertEq(rule.startingTime, _startTimestamp);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addSupplyVolatilityRule(address(applicationAppManager), 5000, 23, Blocktime, totalSupply);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getSupplyVolatilityRule(_index);
            assertEq(rule.startingTime, Blocktime);

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalSupplyVolatilityRules(), 2);
        }
    }

    /*********************** Oracle ************************/
    /// Simple setting and getting

    function testOracle(uint8 addressIndex, uint8 _type, address _oracleAddress) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        uint32 _index;
        if ((sender != ruleAdmin) || _oracleAddress == address(0) || _type > 1) {
            vm.expectRevert();
            _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), _type, _oracleAddress);
        } else {
            _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), _type, _oracleAddress);
            assertEq(_index, 0);
            NonTaggedRules.OracleRule memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
            assertEq(rule.oracleType, _type);
            assertEq(rule.oracleAddress, _oracleAddress);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(69));
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getOracleRule(_index);
            assertEq(rule.oracleType, 1);
            assertEq(rule.oracleAddress, address(69));

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalOracleRules(), 2);
        }
    }

    /**************** Tagged Admin Withdrawal Rule Testing  ****************/

    /// Test Adding Admin Withdrawal Rule releaseDate: 1669745700

    function testAddAdminWithdrawalRuleAppAdministratorFuzz(uint8 addressIndex, uint256 amountA, uint256 dateA, uint forward) public {
        /// avoiding arithmetic overflow when adding dateA and 1000 for second-rule test
        vm.assume(forward < uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
        vm.stopPrank();
        vm.startPrank(superAdmin);
        applicationAppManager.addAppAdministrator(address(ruleProcessor));
        assertEq(applicationAppManager.isAppAdministrator(address(ruleProcessor)), true);

        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        vm.warp(forward);

        if ((sender != ruleAdmin) || amountA == 0 || dateA <= block.timestamp) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), amountA, dateA);

        if (!((sender != ruleAdmin) || amountA == 0 || dateA <= block.timestamp)) {
            assertEq(0, _index);
            TaggedRules.AdminWithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminWithdrawalRule(_index);
            assertEq(rule.amount, amountA);
            assertEq(rule.releaseDate, dateA);

            /// testing adding a second rule
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminWithdrawalRule(address(applicationAppManager), 666, block.timestamp + 1000);
            assertEq(1, _index);
            rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminWithdrawalRule(_index);
            assertEq(rule.amount, 666);
            assertEq(rule.releaseDate, block.timestamp + 1000);

            /// testing total rules
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAdminWithdrawalRules(), 2);
        }
    }

    function testEconActionsFuzz(
        uint8 addressFrom,
        uint8 addressTo,
        uint128 min,
        bytes32 tagFrom,
        bytes32 tagTo,
        uint128 bMin,
        uint128 bMax,
        uint128 transferAmount,
        uint128 balanceTo,
        uint128 balanceFrom
    ) public {
        balanceTo;
        vm.assume(addressFrom % ADDRESSES.length != addressTo % ADDRESSES.length);
        vm.assume(tagFrom != "");
        vm.assume(tagTo != "");
        vm.assume(tagFrom != tagTo && tagTo != tagFrom);
        vm.assume(balanceFrom >= transferAmount);
        address from = ADDRESSES[addressFrom % ADDRESSES.length];
        address to = ADDRESSES[addressTo % ADDRESSES.length];

        /// the different code blocks "{}" are used to isolate computational processes and
        /// avoid the infamous too-many-variable Solidity issue.

        // add the minTransfer rule.
        {
            if (min == 0) vm.expectRevert();
            RuleDataFacet(address(ruleProcessor)).addMinimumTransferRule(address(applicationAppManager), min);
            /// if we added the rule in the protocol, then we add it in the application
            if (!(min == 0)) applicationCoinHandler.setMinTransferRuleId(0);
        }

        /// Prepearing for rule
        {
            vm.stopPrank();
            vm.startPrank(superAdmin);
            applicationAppManager.addGeneralTag(from, tagFrom); ///add tag
            applicationAppManager.addGeneralTag(to, tagTo); ///add tag
            /// add a minMaxBalance rule
            if (bMin == 0 || bMax == 0 || bMin > bMax) vm.expectRevert();
            bytes32[] memory _accountTypes = createBytes32Array(tagTo);
            /// we receive uint128 to avoid overflow, so we convert to uint256
            uint256[] memory _minimum = createUint256Array(uint256(bMin));
            uint256[] memory _maximum = createUint256Array(uint256(bMax));
            // add the rule.
            vm.stopPrank();
            vm.startPrank(ruleAdmin);
            TaggedRuleDataFacet(address(ruleProcessor)).addMinMaxBalanceRule(address(applicationAppManager), _accountTypes, _minimum, _maximum);
            /// if we added the rule in the protocol, then we add it in the application
            if (!(bMin == 0 || bMax == 0 || bMin > bMax)) applicationCoinHandler.setMinMaxBalanceRuleId(0);
        }

        /// oracle rules
        {
            /// adding the banning oracle rule
            uint32 banOracle = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 0, address(oracleDenied));
            /// adding the whitelisting oracle rule
            uint32 whitelistOracle = RuleDataFacet(address(ruleProcessor)).addOracleRule(address(applicationAppManager), 1, address(oracleAllowed));
            /// to simulate randomness in the oracle rule to pick, we grab the transferAmount%2
            if (transferAmount % 2 == 0) applicationCoinHandler.setOracleRuleId(banOracle);
            else applicationCoinHandler.setOracleRuleId(whitelistOracle);
        }
    }

        /*********************** Purchase *******************/
    /** Purchase and sell + percentage Purchase and percentage sell rules are commented out uintil merge to internal as getters no longer exist until rules are written
    TODO Uncomment after internal
    /// Simple setting and getting
    function testSettingPurchaseFuzz(uint8 addressIndex, uint192 amountA, uint192 amountB, uint16 pPeriodA, uint16 pPeriodB) public {
        vm.warp(Blocktime);
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// manual tag necessary because of memory issue.
        bytes32[] memory accs = createBytes32Array("tagA", "tagB");
        uint256[] memory pAmounts = createUint256Array(amountA, amountB);
        uint16[] memory pPeriods = createUint16Array(pPeriodA, pPeriodB);
        uint64[] memory startTimes = createUint64Array(Blocktime, Blocktime);
        if ((sender != ruleAdmin) || amountA == 0 || amountB == 0 || pPeriodA == 0 || pPeriodB == 0) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, startTimes);
        if ((sender == ruleAdmin) && amountA > 0 && amountB > 0 && pPeriodA > 0 && pPeriodB > 0) {
            assertEq(_index, 0);
            TaggedRules.PurchaseRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getPurchaseRule(_index, "tagA");
            assertEq(rule.purchaseAmount, amountA);
            assertEq(rule.purchasePeriod, pPeriodA);

            /// testing different input sized
            bytes32[] memory invalidAccs = new bytes32[](3);
            invalidAccs[0] = "A";
            invalidAccs[1] = "B";
            invalidAccs[2] = "c";

            vm.expectRevert();
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), invalidAccs, pAmounts, pPeriods, startTimes);

            /// testing adding a second rule
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addPurchaseRule(address(applicationAppManager), accs, pAmounts, pPeriods, startTimes);
            assertEq(_index, 1);
            rule = TaggedRuleDataFacet(address(ruleProcessor)).getPurchaseRule(_index, "tagB");
            assertEq(rule.purchaseAmount, amountB);
            assertEq(rule.purchasePeriod, pPeriodB);

            /// testing total rules
            assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalPurchaseRule(), 2);
        }
    }
    
    /** Purchase, sell, percentage Purchase, percentage sell and withdrawal rules are commented out uintil merge to internal 
        Getters no longer exist until rules are written. The rule getters are in the processing facet for that rule. 
        TODO Uncomment after internal merge and rules are updated with new architecture. 
     */
    // /************************ Sell *************************/
    /// Simple setting and getting
    /** 
    function testSettingSellFuzz(uint8 addressIndex, uint192 amountA, uint192 amountB, uint16 dFrozenA, uint16 dFrozenB, uint32 sTimeA, uint32 sTimeB, bytes32 accA, bytes32 accB) public {
        vm.warp(Blocktime);
        vm.assume(accA != accB);
        vm.assume(accA != bytes32("") && accB != bytes32(""));
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        bytes32[] memory accs = createBytes32Array("tagA", "tagB");
        uint192[] memory sAmounts = createUint192Array(amountA, amountB);
        uint16[] memory dFrozen = createUint16Array(dFrozenA, dFrozenB);
        uint64[] memory startTimes = createUint64Array(sTimeA, sTimeB);
        uint32 _index;
        if (
            (sender != ruleAdmin) ||
            amountA == 0 ||
            amountB == 0 ||
            dFrozenA == 0 ||
            dFrozenB == 0 ||
            sTimeA == 0 ||
            sTimeB == 0 ||
            sTimeA > (block.timestamp + (52 * 1 weeks)) ||
            sTimeB > (block.timestamp + (52 * 1 weeks))
        ) {
            vm.expectRevert();
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, dFrozen, startTimes);
        } else {
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, dFrozen, startTimes);
            assertEq(_index, 0);
            TaggedRules.SellRule memory rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, accA);
            assertEq(rule.sellPeriod, dFrozenA);

            /// testing different input sized
            bytes32[] memory invalidAccs = new bytes32[](3);
            invalidAccs[0] = "A";
            invalidAccs[1] = "B";
            invalidAccs[2] = "c";

            vm.expectRevert();
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), invalidAccs, sAmounts, dFrozen, startTimes);

            /// testing adding a second rule
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addSellRule(address(applicationAppManager), accs, sAmounts, dFrozen, startTimes);
            assertEq(_index, 1);
            rule = TaggedRuleDataFacet(address(ruleProcessor)).getSellRuleByIndex(_index, accB);
            assertEq(rule.sellPeriod, dFrozenB);

            /// testing total rules
            assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalSellRule(), 2);
        }
    }
    */

    /**************** Tagged Withdrawal Rule Testing  ****************/
    //Test Adding Withdrawal Rule
    /// Withdrawal rule getter does not exist until rule is written
    // function testSettingWithdrawalRuleFuzz(uint8 addressIndex, uint256 amountA, uint256 amountB, uint256 dateA, uint256 dateB, bytes32 accA, bytes32 accB, uint forward) public {
    //     /// avoiding arithmetic overflow when adding dateA and 1000 for second-rule test
    //     vm.assume(forward < uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
    //     vm.assume(accA != accB);
    //     vm.assume(accA != bytes32("") && accB != bytes32(""));

    //     vm.stopPrank();
    //     address sender = ADDRESSES[addressIndex % ADDRESSES.length];
    //     vm.startPrank(sender);

    //     bytes32[] memory accs = createBytes32Array(accA, accB);
    //     uint256[] memory amounts = createUint256Array(amountA, amountB);
    //     uint256[] memory releaseDate = createUint256Array(dateA, dateB);

    //     vm.warp(forward);
    //     if ((sender != ruleAdmin) || amountA == 0 || amountB == 0 || dateA <= block.timestamp || dateB <= block.timestamp) vm.expectRevert();
    //     uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(address(applicationAppManager), accs, amounts, releaseDate);
    //     if (!((sender != ruleAdmin) || amountA == 0 || amountB == 0 || dateA <= block.timestamp || dateB <= block.timestamp)) {
    //         assertEq(_index, 0);
    //         TaggedRules.WithdrawalRule memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getWithdrawalRule(_index, accA);
    //         assertEq(rule.amount, amountA);
    //         assertEq(rule.releaseDate, dateA);

    //         /// we create other parameters for next tests
    //         bytes32[] memory accs2 = bytes32[] memory accs = createBytes32Array("Oscar","Tayler","Shane");
    //         uint256[] memory amounts2 = createUint256Array(500, 1500, 3000);
    //         uint256[] memory releaseDate2 = createUint256Array((block.timestamp + 1100), (block.timestamp + 2200), (block.timestamp + 3300));
    //         /// testing wrong size of patameters
    //         vm.expectRevert();
    //         _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(address(applicationAppManager), accs2, amounts, releaseDate);

    //         /// testing adding a new rule
    //         _index = TaggedRuleDataFacet(address(ruleProcessor)).addWithdrawalRule(address(applicationAppManager), accs2, amounts2, releaseDate2);
    //         assertEq(_index, 1);

    //         /// Withdrawal rule getter does not exist until rule is written
    //         rule = TaggedRuleDataFacet(address(ruleProcessor)).getWithdrawalRule(_index, "Oscar");
    //         assertEq(rule.amount, 500);
    //         assertEq(rule.releaseDate, block.timestamp + 1100);

    //         /// testing total rules
    //         assertEq(TaggedRuleDataFacet(address(ruleProcessor)).getTotalWithdrawalRule(), 2);
    //     }
    // }
    
}

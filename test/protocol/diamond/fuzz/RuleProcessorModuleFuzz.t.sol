// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";

contract RuleProcessorModuleFuzzTest is TestCommonFoundry, RuleCreation {

    function setUp() public {
        vm.startPrank(superAdmin);
        setUpProcotolAndCreateERC20AndDiamondHandler();
        vm.warp(Blocktime);
        switchToRuleAdmin();
    }

    /***************** Test Setters and Getters *****************/
    /************************ PurchaseFeeByVolumeRule **********************/

    /// Simple setting and getting
    function testPurchaseFeeByVolumeRuleSetting(uint8 addressIndex, uint256 volume, uint16 rate) public {
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

    /*********************** TokenMaxPriceVolatility ************************/
    /// Simple setting and getting
    function testTokenMaxPriceVolatilitySetting(uint8 addressIndex, uint16 max, uint8 blocks, uint8 hFrozen) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || max == 0 || max > 100000 || blocks == 0 || hFrozen == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), max, blocks, hFrozen, totalSupply);
        if ((sender == ruleAdmin) && max > 0 && max <= 100000 && blocks > 0 && hFrozen > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxPriceVolatility memory rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 666, 100, 12, totalSupply);
            assertEq(_index, 1);
            rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);
            assertEq(rule.hoursFrozen, 12);
            assertEq(rule.max, 666);
            assertEq(rule.period, 100);

            /// testing total rules
            assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenMaxPriceVolatility(), 2);
        }
    }

    /*********************** TokenMaxTradingVolume Rule ************************/
    /// Simple setting and getting
    function testTokenMaxTradingVolumeRuleSetting(uint8 addressIndex, uint16 max, uint8 hPeriod, uint64 _startTime) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || max == 0 || max > 100000 || hPeriod == 0 || _startTime == 0 || _startTime > (block.timestamp + (52 * 1 weeks))) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), max, hPeriod, _startTime, 0);
        if ((sender == ruleAdmin) && max > 0 && max <= 100000 && hPeriod > 0 && _startTime > 0 && _startTime < 24) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
            assertEq(rule.startTime, _startTime);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 2000, 1, Blocktime, 0);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
            assertEq(rule.max, 2000);
            assertEq(rule.period, 1);
            assertEq(rule.startTime, Blocktime);

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume(), 2);
        }
    }

    /*********************** TokenMinTransactionSize ************************/
    /// Simple setting and getting

    function testTokenMinTransactionSizeSetting(uint8 addressIndex, uint256 min) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        /// test only admin can add rule, and values are withing acceptable range
        if ((sender != ruleAdmin) || min == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), min);
        if ((sender == ruleAdmin) && min > 0) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMinTxSize memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
            assertEq(rule.minSize, min);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 300000000000000);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
            assertEq(rule.minSize, 300000000000000);

            /// testing getting total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize(), 2);
        }
    }

    /*********************** AccountMinMaxTokenBalance *******************/
    /// Simple setting and getting
    function testAccountMinMaxTokenBalanceSettingFuzz(uint8 addressIndex, uint256 minA, uint256 minB, uint256 maxA, uint256 maxB, bytes32 accA, bytes32 accB) public {
        vm.assume(accA != accB);
        vm.assume(accA != bytes32("") && accB != bytes32(""));
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);

        bytes32[] memory accs = createBytes32Array(accA, accB);
        uint256[] memory min = createUint256Array(minA, minB);
        uint256[] memory max = createUint256Array(maxA, maxB);
        uint16[] memory empty;
        if ((sender != ruleAdmin) || minA == 0 || minB == 0 || maxA == 0 || maxB == 0 || minA > maxA || minB > maxB) vm.expectRevert();
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        if ((sender == ruleAdmin) && minA > 0 && minB > 0 && maxA > 0 && maxB > 0 && !(minA > maxA || minB > maxB)) {
            assertEq(_index, 0);
            TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, accA);
            assertEq(rule.min, minA);
            assertEq(rule.max, maxA);

            /// testing different sizes
            bytes32[] memory invalidAccs = new bytes32[](3);
            vm.expectRevert();
            TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), invalidAccs, min, max, empty, uint64(Blocktime));

            /// testing adding a second rule
            bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
            uint256[] memory min2 = createUint256Array(100000000, 20000000, 3000000);
            uint256[] memory max2 = createUint256Array(
                100000000000000000000000000000000000000000000000000000000000000000000000000, 
                20000000000000000000000000000000000000, 
                900000000000000000000000000000000000000000000000000000000000000000000000000
                );
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs2, min2, max2, empty, uint64(Blocktime));
            assertEq(_index, 1);
            rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Tayler");
            assertEq(rule.min, min2[1]);
            assertEq(rule.max, max2[1]);

            /// testing getting total rules
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMinMaxTokenBalances(), 2);
        }
    }

    /*********************** TokenMaxSupplyVolatility ************************/
    /// Simple setting and getting
    function testTokenMaxSupplyVolatilitySettingFuzz(uint8 addressIndex, uint16 max, uint8 hPeriod, uint64 _startTime) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        vm.assume(max < 9999 && max > 0);
        if (max < 100) max = 100;
        if (_startTime > (block.timestamp + (52 * 1 weeks))) _startTime = uint64(block.timestamp + (52 * 1 weeks));
        if (hPeriod > 23) hPeriod = 23;
        if ((sender != ruleAdmin) || max == 0 || hPeriod == 0 || _startTime == 0) vm.expectRevert();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), max, hPeriod, _startTime, totalSupply);
        if (!((sender != ruleAdmin) || max == 0 || hPeriod == 0 || _startTime == 0)) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxSupplyVolatility memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
            assertEq(rule.startTime, _startTime);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 5000, 23, Blocktime, totalSupply);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
            assertEq(rule.startTime, Blocktime);

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSupplyVolatility(), 2);
        }
    }

    /*********************** AccountApproveDenyOracle ************************/
    /// Simple setting and getting
    function testAccountApproveDenyOracle(uint8 addressIndex, uint8 _type, address _oracleAddress) public {
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        uint32 _index;
        if ((sender != ruleAdmin) || _oracleAddress == address(0) || _type > 1) {
            vm.expectRevert();
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), _type, _oracleAddress);
        } else {
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), _type, _oracleAddress);
            assertEq(_index, 0);
            NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
            assertEq(rule.oracleType, _type);
            assertEq(rule.oracleAddress, _oracleAddress);

            /// testing adding a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(69));
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
            assertEq(rule.oracleType, 1);
            assertEq(rule.oracleAddress, address(69));

            /// testing total rules
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalAccountApproveDenyOracle(), 2);
        }
    }

    /**************** AdminMinTokenBalance Rule Testing  ****************/

    /// Test AdminMinTokenBalance Rule endTime: 1669745700
    function testAdminMinTokenBalanceAddFuzz(uint8 addressIndex, uint256 amountA, uint256 dateA, uint forward) public {
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
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), amountA, dateA);

        if (!((sender != ruleAdmin) || amountA == 0 || dateA <= block.timestamp)) {
            assertEq(0, _index);
            TaggedRules.AdminMinTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(_index);
            assertEq(rule.amount, amountA);
            assertEq(rule.endTime, dateA);

            /// testing adding a second rule
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 666, block.timestamp + 1000);
            assertEq(1, _index);
            rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(_index);
            assertEq(rule.amount, 666);
            assertEq(rule.endTime, block.timestamp + 1000);

            /// testing total rules
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAdminMinTokenBalance(), 2);
        }
    }

    /// Test Economic Actions 
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

        // add the TokenMinTransactionSize rule.
        {
            if (min == 0) vm.expectRevert();
            RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), min);
            /// if we added the rule in the protocol, then we add it in the application
            if (!(min == 0)) ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMinTxSizeId(_createActionsArray(), 0);
        }

        /// Preparing for rule
        {
            switchToAppAdministrator();
            applicationAppManager.addTag(from, tagFrom); ///add tag
            applicationAppManager.addTag(to, tagTo); ///add tag
            /// add a accountMinMaxTokenBalance rule
            if (bMin == 0 || bMax == 0 || bMin > bMax) vm.expectRevert();
            bytes32[] memory _accountTypes = createBytes32Array(tagTo);
            /// we receive uint128 to avoid overflow, so we convert to uint256
            uint256[] memory _min = createUint256Array(uint256(bMin));
            uint256[] memory _max = createUint256Array(uint256(bMax));
            uint16[] memory empty;
            // add the rule.
            vm.stopPrank();
            vm.startPrank(ruleAdmin);            
            TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), _accountTypes, _min, _max, empty, uint64(Blocktime));
            /// if we added the rule in the protocol, then we add it in the application
            if (!(bMin == 0 || bMax == 0 || bMin > bMax)) ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(_createActionsArray(),0);
        }

        /// AccountApproveDenyOracle rules
        {
            /// adding the banning oracle rule
            uint32 banOracle = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
            /// adding the whitelisting oracle rule
            uint32 whitelistOracle = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
            /// to simulate randomness in the oracle rule to pick, we grab the transferAmount%2
            if (transferAmount % 2 == 0) ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), banOracle);
            else ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), whitelistOracle);
        }
    }

}

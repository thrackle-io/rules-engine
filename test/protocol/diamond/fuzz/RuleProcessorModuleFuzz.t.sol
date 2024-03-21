// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "test/util/TestCommonFoundry.sol";
import "test/util/RuleCreation.sol";

contract RuleProcessorModuleFuzzTest is TestCommonFoundry, RuleCreation {

    function setUp() public {
        setUpProcotolAndCreateERC20AndDiamondHandler();
        vm.warp(Blocktime);
    }

    /***************** Test Setters and Getters *****************/
    /************************ PurchaseFeeByVolumeRule **********************/

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_PurchaseFeeByVolumeRuleSetting(uint8 addressIndex, uint256 volume, uint256 rate) public endWithStopPrank() {
        volume = bound(volume, 1, 1**30); 
        uint256 rateValue = (rate = bound(rate, 1, 10000));
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// test only admin can add rule, and values are within acceptable range
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), volume, uint16(rateValue));
        if (sender == ruleAdmin) {
            assertEq(_index, 0);
            NonTaggedRules.TokenPurchaseFeeByVolume memory rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.rateIncreased, rate);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addPurchaseFeeByVolumeRule(address(applicationAppManager), 10000000000000000000000000000000000, 200);
            assertEq(_index, 1);
            rule = RuleDataFacet(address(ruleProcessor)).getPurchaseFeeByVolumeRule(_index);
            assertEq(rule.volume, 10000000000000000000000000000000000);
            assertEq(rule.rateIncreased, 200);
            /// Ensure both rules are added 
            assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenPurchaseFeeByVolumeRules(), 2);
        }
    }

    /*********************** TokenMaxPriceVolatility ************************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_TokenMaxPriceVolatilitySetting(uint8 addressIndex, uint256 max, uint8 blocks, uint256 hFrozen) public endWithStopPrank() {
        max = bound(max, 1, 10000); 
        hFrozen = bound(hFrozen, 1, 100000);
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// test only admin can add rule, and values are withing acceptable range
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), uint16(max), blocks, uint8(hFrozen), totalSupply);
        if (sender == ruleAdmin) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxPriceVolatility memory rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxPriceVolatility(address(applicationAppManager), 666, 100, 12, totalSupply);
            assertEq(_index, 1);
            rule = RuleDataFacet(address(ruleProcessor)).getTokenMaxPriceVolatility(_index);
            assertEq(rule.hoursFrozen, 12);
            assertEq(rule.max, 666);
            assertEq(rule.period, 100);
            /// Ensure both rules are added
            assertEq(RuleDataFacet(address(ruleProcessor)).getTotalTokenMaxPriceVolatility(), 2);
        }
    }

    /*********************** TokenMaxTradingVolume Rule ************************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_TokenMaxTradingVolumeRuleSetting(uint8 addressIndex, uint256 max, uint256 hPeriod, uint256 _startTime) public endWithStopPrank() {
        max = bound(max, 1, 100000); 
        hPeriod = bound(hPeriod, 1, 1000000); 
        _startTime = bound(_startTime, 1, block.timestamp + (52 * 1 weeks)); 
        
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// test only admin can add rule, and values are withing acceptable range
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), uint16(max), uint8(hPeriod), uint64(_startTime), 0);
        if (sender == ruleAdmin) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
            assertEq(rule.startTime, _startTime);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 2000, 1, Blocktime, 0);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
            assertEq(rule.max, 2000);
            assertEq(rule.period, 1);
            assertEq(rule.startTime, Blocktime);
            /// Ensure both rules are added
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume(), 2);
        }
    }

    /*********************** TokenMinTransactionSize ************************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_TokenMinTransactionSizeSetting(uint8 addressIndex, uint256 min) public endWithStopPrank() {
        min = bound(min, 1, 1**30); 
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        /// test only admin can add rule, and values are withing acceptable range
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), min);
        if (sender == ruleAdmin ) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMinTxSize memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
            assertEq(rule.minSize, min);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 300000000000000);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(_index);
            assertEq(rule.minSize, 300000000000000);
            /// Ensure both rules are added
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize(), 2);
        }
    }

    /*********************** AccountMinMaxTokenBalance *******************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_AccountMinMaxTokenBalanceSettingFuzz(uint8 addressIndex, uint256 minA, uint256 minB, uint256 maxA, uint256 maxB, bytes32 accA, bytes32 accB) public endWithStopPrank() {
        vm.assume(accA != accB);
        vm.assume(accA != bytes32("") && accB != bytes32(""));
        minA = bound(minA, 1, 10 * ATTO); 
        minB = bound(minB, 1, 10 * ATTO);
        maxA = bound(maxA, 1, 10 * ATTO);
        maxB = bound(maxB, 1, 10 * ATTO);
        vm.assume(minA > maxA && minB > maxB);

        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        bytes32[] memory accs = createBytes32Array(accA, accB);
        uint256[] memory min = createUint256Array(minA, minB);
        uint256[] memory max = createUint256Array(maxA, maxB);
        uint16[] memory empty;
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, empty, uint64(Blocktime));
        if (sender == ruleAdmin) {
            assertEq(_index, 0);
            TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, accA);
            assertEq(rule.min, minA);
            assertEq(rule.max, maxA);
            /// add a second rule
            bytes32[] memory accs2 = createBytes32Array("Oscar","Tayler","Shane");
            uint256[] memory min2 = createUint256Array(100000000, 20000000, 3000000);
            uint256[] memory max2 = createUint256Array(10000 * BIGNUMBER, 20000000000000000000 * ATTO, 9000 * BIGNUMBER);
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs2, min2, max2, empty, uint64(Blocktime));
            assertEq(_index, 1);
            rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(_index, "Tayler");
            assertEq(rule.min, min2[1]);
            assertEq(rule.max, max2[1]);
            /// Ensure both rules are added
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMinMaxTokenBalances(), 2);
        }
    }

    /*********************** TokenMaxSupplyVolatility ************************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_TokenMaxSupplyVolatilitySettingFuzz(uint8 addressIndex, uint256 max, uint256 hPeriod, uint256 _startTime) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        max = bound(max, 100, 9999); 
        _startTime = bound(_startTime, 1, block.timestamp + (52 * 1 weeks));
        hPeriod = bound(hPeriod, 1, 23);

        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), uint16(max), uint8(hPeriod), uint64(_startTime), totalSupply);
        if (sender == ruleAdmin) {
            assertEq(_index, 0);
            NonTaggedRules.TokenMaxSupplyVolatility memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
            assertEq(rule.startTime, _startTime);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), 5000, 23, Blocktime, totalSupply);
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
            assertEq(rule.startTime, Blocktime);
            /// Ensure both rules are added
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSupplyVolatility(), 2);
        }
    }

    /*********************** AccountApproveDenyOracle ************************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_AccountApproveDenyOracle(uint8 addressIndex, address _oracleAddress) public endWithStopPrank() {
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.assume(_oracleAddress != address(0x00)); 
        vm.startPrank(sender);
        uint32 _index;
        if ((sender != ruleAdmin)) {
            vm.expectRevert(0xd66c3008);
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, _oracleAddress);
        } else {
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, _oracleAddress);
            assertEq(_index, 0);
            NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
            assertEq(rule.oracleType, 0);
            assertEq(rule.oracleAddress, _oracleAddress);
            /// add a second rule
            _index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(69));
            assertEq(_index, 1);
            rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(_index);
            assertEq(rule.oracleType, 1);
            assertEq(rule.oracleAddress, address(69));
            /// Ensure both rules are added
            assertEq(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalAccountApproveDenyOracle(), 2);
        }
    }

    /**************** AdminMinTokenBalance Rule Testing  ****************/
    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that only a rule admin role can set a rule within the protocol, Non zero params result in reversion and Zero params result in reversion 
     * When Sender is rule admin role: add two rules to the protocol and ensure the rule params match provided params 
     * Postconditions: If sender was rule admin, RuleProcessor has two rules added for the rule type.
     */
    function testProtocol_RuleProcessorModuleFuzz_AdminMinTokenBalanceAddFuzz(uint8 addressIndex, uint256 amountA, uint256 dateA, uint forward) public endWithStopPrank() {
        /// avoiding arithmetic overflow when adding dateA and 1000 for second-rule test
        forward = bound(forward, 1, uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
        amountA = bound(amountA, 1, uint256(0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000));
        dateA = bound(dateA, 1, block.timestamp); 

        switchToSuperAdmin();
        applicationAppManager.addAppAdministrator(address(ruleProcessor));
        assertEq(applicationAppManager.isAppAdministrator(address(ruleProcessor)), true);
        vm.stopPrank();
        address sender = ADDRESSES[addressIndex % ADDRESSES.length];
        vm.startPrank(sender);
        vm.warp(forward);
        if (sender != ruleAdmin) vm.expectRevert(0xd66c3008);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), amountA, dateA);
        if (sender == ruleAdmin) {
            assertEq(0, _index);
            TaggedRules.AdminMinTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(_index);
            assertEq(rule.amount, amountA);
            assertEq(rule.endTime, dateA);
            /// add a second rule
            _index = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), 666, block.timestamp + 1000);
            assertEq(1, _index);
            rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(_index);
            assertEq(rule.amount, 666);
            assertEq(rule.endTime, block.timestamp + 1000);
            /// Ensure both rules are added
            assertEq(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAdminMinTokenBalance(), 2);
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that the rule is added to the Rule Processor Diamond, then that the rule is set in the token handler  
     * Postconditions: RuleProcessor has new rule added for the rule type. Token Handler has rule active for the rule type
     */
    function testProtocol_RuleProcessorModuleFuzz_AddTokenMinTxSizeToTokenHandlerFuzz(
        uint128 min,
        bytes32 tagFrom,
        bytes32 tagTo
    ) public endWithStopPrank() {
        vm.assume(tagFrom != "");
        vm.assume(tagTo != "");
        vm.assume(tagFrom != tagTo && tagTo != tagFrom);
        switchToRuleAdmin();
        // add the TokenMinTransactionSize rule.
        if (min == 0) vm.expectRevert(0x454f1bd4);
        RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), min);
        if (!(min == 0)) {
            ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMinTxSizeId(_createActionsArray(), 0);
            assertTrue(ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).isTokenMinTxSizeActive(ActionTypes.P2P_TRANSFER));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that the rule is added to the Rule Processor Diamond, then that the rule is set in the token handler  
     * Postconditions: RuleProcessor has new rule added for the rule type. Token Handler has rule active for the rule type
     */
    function testProtocol_RuleProcessorModuleFuzz_AddMinTokenBalanceToTokenHandlerFuzz(bytes32 tag, uint128 bMin, uint128 bMax) public endWithStopPrank() {
        switchToRuleAdmin();
        vm.assume(tag != "" && bMin > 0 && bMax > 0);
        
        if (bMin > bMax) vm.expectRevert(0xeeb9d4f7);
        bytes32[] memory _accountTypes = createBytes32Array(tag);
        /// we receive uint128 to avoid overflow, so we convert to uint256
        uint256[] memory _min = createUint256Array(uint256(bMin));
        uint256[] memory _max = createUint256Array(uint256(bMax));
        uint16[] memory empty;
        // add the rule.           
        TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), _accountTypes, _min, _max, empty, uint64(Blocktime));
        /// if we added the rule in the protocol, then we add it in the application
        if (bMin < bMax) {
            ERC20TaggedRuleFacet(address(applicationCoinHandler)).setAccountMinMaxTokenBalanceId(_createActionsArray(),0);
            assertTrue(ERC20TaggedRuleFacet(address(applicationCoinHandler)).isAccountMinMaxTokenBalanceActive(ActionTypes.P2P_TRANSFER));
        }
    }

    /** 
     * Preconditions: Rule Processor Diamond, App Manager, App Handler, ERC20 Token and Handler Deployed and connected. 
     * Super Admin role is set at contruction, App Admin and Rule Admins are set during test set up. 
     * Test first that the rule is added to the Rule Processor Diamond, then that the rule is set in the token handler  
     * Postconditions: RuleProcessor has new rule added for the rule type. Token Handler has rule active for the rule type
     */
    function testProtocol_RuleProcessorModuleFuzz_EconActionsFuzz(uint128 transferAmount) public endWithStopPrank() {
        switchToRuleAdmin();
        /// adding the deny oracle rule
        uint32 banOracle = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 0, address(oracleDenied));
        /// adding the approved oracle rule
        uint32 approveOracle = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), 1, address(oracleApproved));
        /// to simulate randomness in the oracle rule to pick, we grab the transferAmount%2
        if (transferAmount % 2 == 0) {
            ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), banOracle);
            assertTrue(ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).isAccountApproveDenyOracleActive(ActionTypes.P2P_TRANSFER,0));
        } else {
            ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setAccountApproveDenyOracleId(_createActionsArray(), approveOracle);
            assertTrue(ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).isAccountApproveDenyOracleActive(ActionTypes.P2P_TRANSFER,1));
        }
    }

}

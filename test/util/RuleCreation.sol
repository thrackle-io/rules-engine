// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./TestCommonFoundry.sol";

/**
 * @title Rule Creation Functions
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev This contract is an abstract template to be reused by all the tests.
 * This contract holds the functions for adding a protocol rule for tests.
 */

abstract contract RuleCreation is TestCommonFoundry {
    /** 
    Rule List: 
    AccountApproveDenyOracle
    AccountDenyForNoAccessLevel 
    AccountMaxBuySize
    AccountMaxSellSize
    AccountMaxTxValueByRisk
    AccountMaxValueByAccessLevel
    AccountMaxValueByRisk
    AccountMaxValueOutByAccessLevel
    AccountMin/MaxTokenBalanceRule
    AdminMinTokenBalance
    TokenMaxBuyVolume
    TokenMaxDailyTradesRule
    TokenMaxSellVolume
    TokenMaxSupplyVolatilityRule
    TokenMaxTradingVolume
    TokenMinimumTransaction
    */

    /// Handler Types (0 == ERC20 Handler, 1 == ERC721 Handler)

    /**
     * @dev Each rule creation function holds everything needed to call and set the rule within the handler.
     * Each function starts by creating and using an rule admin account.
     * Each function creates and sets the rule.
     * Each function ends by switching back to the original user of the test prior to function being called.
     * Some functions are duplicated with additional parameters to test rules with parameter optionality.
     * Tests should inherit this contract then call the function needed for the rule being tested.
     */

    function createAccountApproveDenyOracleRule(uint8 oracleType) public returns (uint32) {
        if (oracleType > 1) revert("Oracle Type Invalid");
        switchToRuleAdmin();
        uint32 ruleId;
        if (oracleType == 0) {
            ruleId = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), oracleType, address(oracleDenied));
        } else {
            ruleId = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), oracleType, address(oracleApproved));
        }
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(ruleId);
        assertEq(rule.oracleType, oracleType);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountDenyForNoAccessLevelRule() public endWithStopPrank {
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(true);
        assertTrue(applicationHandler.isAccountDenyForNoAccessLevelActive());
    }

    function createAccountMaxBuySizeRule(bytes32 tagForRule, uint256 maxBuySize, uint16 _period) public returns (uint32) {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(tagForRule);
        uint256[] memory maxBuySizes = createUint256Array(maxBuySize);
        uint16[] memory period = createUint16Array(_period);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, maxBuySizes, period, uint64(Blocktime));
        TaggedRules.AccountMaxBuySize memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxBuySize(ruleId, tagForRule);
        assertEq(rule.maxSize, maxBuySize);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxSellSizeRule(bytes32 tagForRule, uint192 maxSellSize, uint16 _period) public returns (uint32) {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(tagForRule);
        uint192[] memory amounts = createUint192Array(maxSellSize);
        uint16[] memory period = createUint16Array(_period);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, amounts, period, uint64(Blocktime));
        TaggedRules.AccountMaxSellSize memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxSellSize(ruleId, tagForRule);
        assertEq(rule.maxSize, maxSellSize);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxTxValueByRiskRule(uint8[] memory riskScores, uint48[] memory txnLimits, uint8 period) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, period, uint64(block.timestamp));
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(ruleId);
        assertEq(rule.maxValue[0], txnLimits[0]);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxTxValueByRiskRule(uint8[] memory riskScores, uint48[] memory txnLimits) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(ruleId);
        assertEq(rule.maxValue[0], txnLimits[0]);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxValueByAccessLevelRule(uint48 balanceAmounts1, uint48 balanceAmounts2, uint48 balanceAmounts3, uint48 balanceAmounts4, uint48 balanceAmounts5) public returns (uint32) {
        switchToRuleAdmin();
        uint48[] memory balanceAmounts = createUint48Array(balanceAmounts1, balanceAmounts2, balanceAmounts3, balanceAmounts4, balanceAmounts5);
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueByAccessLevel(ruleId, 2);
        assertEq(balance, balanceAmounts3);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxValueByRiskRule(uint8[] memory riskScores, uint48[] memory txnLimits) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        AppRules.AccountMaxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(ruleId);
        assertEq(rule.maxValue[0], txnLimits[0]);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMaxValueOutByAccessLevelRule(
        uint48 withdrawalLimits1,
        uint48 withdrawalLimits2,
        uint48 withdrawalLimits3,
        uint48 withdrawalLimits4,
        uint48 withdrawalLimits5
    ) public returns (uint32) {
        switchToRuleAdmin();
        uint48[] memory withdrawalLimits = createUint48Array(withdrawalLimits1, withdrawalLimits2, withdrawalLimits3, withdrawalLimits4, withdrawalLimits5);
        uint32 ruleId = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setAccountMaxValueOutByAccessLevelId(ruleId);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(ruleId, 2);
        assertEq(balance, withdrawalLimits3);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMinMaxTokenBalanceRule(bytes32[] memory ruleTags, uint256[] memory minAmounts, uint256[] memory maxAmounts) public returns (uint32) {
        switchToRuleAdmin();
        uint16[] memory periods;
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), ruleTags, minAmounts, maxAmounts, periods, uint64(Blocktime));
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(ruleId, ruleTags[0]);
        assertEq(rule.max, maxAmounts[0]);
        vm.stopPrank();
        return ruleId;
    }

    function createAccountMinMaxTokenBalanceRule(bytes32[] memory ruleTags, uint256[] memory minAmounts, uint256[] memory maxAmounts, uint16[] memory periods) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), ruleTags, minAmounts, maxAmounts, periods, uint64(Blocktime));
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(ruleId, ruleTags[0]);
        assertEq(rule.max, maxAmounts[0]);
        vm.stopPrank();
        return ruleId;
    }

    function createAdminMinTokenBalanceRule(uint256 adminWithdrawalTotal, uint64 period) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), adminWithdrawalTotal, period);
        TaggedRules.AdminMinTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(ruleId);
        assertEq(rule.amount, adminWithdrawalTotal);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxBuyVolumeRule(uint16 tokenPercentage, uint16 period, uint256 _totalSupply, uint64 ruleStartTime) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        NonTaggedRules.TokenMaxBuyVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxBuyVolume(ruleId);
        assertEq(rule.tokenPercentage, tokenPercentage);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxDailyTradesRule(bytes32 tag1, uint8 dailyTradeMax1) public returns (uint32) {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array(tag1);
        uint8[] memory tradesAllowed = createUint8Array(dailyTradeMax1);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(ruleId, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, dailyTradeMax1);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxDailyTradesRule(bytes32 tag1, bytes32 tag2, uint8 dailyTradeMax1, uint8 dailyTradeMax2) public returns (uint32) {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array(tag1, tag2);
        uint8[] memory tradesAllowed = createUint8Array(dailyTradeMax1, dailyTradeMax2);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(ruleId, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, dailyTradeMax1);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxSellVolumeRule(uint16 tokenPercentage, uint16 period, uint256 _totalSupply, uint64 ruleStartTime) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxSellVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        NonTaggedRules.TokenMaxSellVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSellVolume(ruleId);
        assertEq(rule.tokenPercentage, tokenPercentage);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxSupplyVolatilityRule(uint16 volatilityLimit, uint8 rulePeriod, uint64 startTime, uint256 tokenSupply) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), volatilityLimit, rulePeriod, startTime, tokenSupply);
        NonTaggedRules.TokenMaxSupplyVolatility memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(ruleId);
        assertEq(rule.max, volatilityLimit);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMaxTradingVolumeRule(uint24 max, uint16 period, uint64 startTime, uint256 totalSupply) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), max, period, startTime, totalSupply);
        NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(ruleId);
        assertEq(rule.max, max);
        assertEq(rule.period, period);
        assertEq(rule.startTime, startTime);
        vm.stopPrank();
        return ruleId;
    }

    function createTokenMinimumTransactionRule(uint256 tokenMinTxSize) public returns (uint32) {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), tokenMinTxSize);
        NonTaggedRules.TokenMinTxSize memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(ruleId);
        assertEq(rule.minSize, tokenMinTxSize);
        vm.stopPrank();
        return ruleId;
    }
}

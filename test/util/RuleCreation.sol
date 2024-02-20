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

    
    function createAccountApproveDenyOracleRule(uint8 oracleType, address assetHandler, uint8 handlerType) public {
        if (oracleType > 1) revert("Oracle Type Invalid");
        switchToRuleAdmin();
        uint32 index ;
        if (oracleType == 0){
            index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), oracleType, address(oracleDenied));
        } else {
            index = RuleDataFacet(address(ruleProcessor)).addAccountApproveDenyOracle(address(applicationAppManager), oracleType, address(oracleApproved));
        }
        NonTaggedRules.AccountApproveDenyOracle memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getAccountApproveDenyOracle(index);
        assertEq(rule.oracleType, oracleType);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.BURN, ActionTypes.MINT);
        if(handlerType == 0){
            ERC20NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleId(actionTypes, index);
        } else if(handlerType == 1) {
            ERC721NonTaggedRuleFacet(address(assetHandler)).setAccountApproveDenyOracleId(actionTypes, index);
        } 
        switchToOriginalUser();
    }

    function createAccountDenyForNoAccessLevelRule() public {
        switchToRuleAdmin();
        applicationHandler.activateAccountDenyForNoAccessLevelRule(true);
        assertTrue(applicationHandler.isAccountDenyForNoAccessLevelActive());
        switchToOriginalUser();

    }

    function createAccountMaxBuySizeRule(bytes32 tagForRule, uint256 maxBuySize, uint16 _period, address assetHandler) public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(tagForRule);
        uint256[] memory maxBuySizes = createUint256Array(maxBuySize);
        uint16[] memory period = createUint16Array(_period);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), accs, maxBuySizes, period, uint64(Blocktime));
        TradingRuleFacet(address(assetHandler)).setAccountMaxBuySizeId(ruleId);
        TaggedRules.AccountMaxBuySize memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxBuySize(ruleId, tagForRule); 
        assertEq(rule.maxSize, maxBuySize);
        switchToOriginalUser();
    }

    function createAccountMaxSellSizeRule(bytes32 tagForRule, uint192 maxSellSize, uint16 _period, address assetHandler) public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(tagForRule);
        uint192[] memory amounts = createUint192Array(maxSellSize);
        uint16[] memory period = createUint16Array(_period);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), accs, amounts, period, uint64(Blocktime));
        TradingRuleFacet(address(assetHandler)).setAccountMaxSellSizeId(ruleId);
        TaggedRules.AccountMaxSellSize memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxSellSizeByIndex(ruleId, tagForRule); 
        assertEq(rule.maxSize, maxSellSize);
        switchToOriginalUser();
    }

    function createAccountMaxTxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint48 txnLimits1, uint48 txnLimits2, uint48 txnLimits3) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3);
        uint48[] memory txnLimits = createUint48Array(txnLimits1, txnLimits2, txnLimits3);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], txnLimits1);
        switchToOriginalUser();
    }

    function createAccountMaxTxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint8 riskScores4, uint48 txnLimits1, uint48 txnLimits2, uint48 txnLimits3, uint48 txnLimits4) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3, riskScores4);
        uint48[] memory txnLimits = createUint48Array(txnLimits1, txnLimits2, txnLimits3, txnLimits4);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], txnLimits1);
        switchToOriginalUser();
    }

    function createAccountMaxTxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint8 riskScores4, uint8 riskScores5, uint48 txnLimits1, uint48 txnLimits2, uint48 txnLimits3, uint48 txnLimits4, uint48 txnLimits5) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3, riskScores4, riskScores5);
        uint48[] memory txnLimits = createUint48Array(txnLimits1, txnLimits2, txnLimits3, txnLimits4, txnLimits5);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, 0, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], txnLimits1);
        switchToOriginalUser();
    }

    function createAccountMaxTxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint48 txnLimits1, uint48 txnLimits2, uint48 txnLimits3, uint8 period) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3);
        uint48[] memory txnLimits = createUint48Array(txnLimits1, txnLimits2, txnLimits3);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, period, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], txnLimits1);
        switchToOriginalUser();
    }
    
    function createAccountMaxTxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint8 riskScores4, uint48 txnLimits1, uint48 txnLimits2, uint48 txnLimits3, uint48 txnLimits4, uint8 period ) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3, riskScores4);
        uint48[] memory txnLimits = createUint48Array(txnLimits1, txnLimits2, txnLimits3, txnLimits4);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), txnLimits, riskScores, period, uint64(block.timestamp));
        applicationHandler.setAccountMaxTxValueByRiskScoreId(index);
        AppRules.AccountMaxTxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], txnLimits1);
        switchToOriginalUser();
    }

    function createAccountMaxValueByAccessLevelRule(uint48 balanceAmounts1, uint48 balanceAmounts2, uint48 balanceAmounts3, uint48 balanceAmounts4, uint48 balanceAmounts5) public {
        switchToRuleAdmin();
        uint48[] memory balanceAmounts = createUint48Array(balanceAmounts1, balanceAmounts2, balanceAmounts3, balanceAmounts4, balanceAmounts5);
        uint32 _index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByAccessLevel(address(applicationAppManager), balanceAmounts);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueByAccessLevel(_index, 2);
        assertEq(balance, balanceAmounts3);
        applicationHandler.setAccountMaxValueByAccessLevelId(_index);
        switchToOriginalUser();
    }

    function createAccountMaxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint48 maxSize1, uint48 maxSize2, uint48 maxSize3) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3);
        uint48[] memory txnLimits = createUint48Array(maxSize1, maxSize2, maxSize3);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        applicationHandler.setAccountMaxValueByRiskScoreId(index);
        AppRules.AccountMaxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], maxSize1);
        switchToOriginalUser();
    }

    function createAccountMaxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint8 riskScores4, uint48 maxSize1, uint48 maxSize2, uint48 maxSize3, uint48 maxSize4) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3, riskScores4);
        uint48[] memory txnLimits = createUint48Array(maxSize1, maxSize2, maxSize3, maxSize4);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        applicationHandler.setAccountMaxValueByRiskScoreId(index);
        AppRules.AccountMaxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], maxSize1);
        switchToOriginalUser();
    }

    function createAccountMaxValueByRiskRule(uint8 riskScores1, uint8 riskScores2, uint8 riskScores3, uint8 riskScores4, uint8 riskScores5, uint48 maxSize1, uint48 maxSize2, uint48 maxSize3, uint48 maxSize4, uint48 maxSize5) public {
        switchToRuleAdmin();
        uint8[] memory riskScores = createUint8Array(riskScores1, riskScores2, riskScores3, riskScores4, riskScores5);
        uint48[] memory txnLimits = createUint48Array(maxSize1, maxSize2, maxSize3, maxSize4, maxSize5);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), riskScores, txnLimits);
        applicationHandler.setAccountMaxValueByRiskScoreId(index);
        AppRules.AccountMaxValueByRiskScore memory rule = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(index); 
        assertEq(rule.maxValue[0], maxSize1);
        switchToOriginalUser();
    }

    function createAccountMaxValueOutByAccessLevelRule(uint48 withdrawalLimits1, uint48 withdrawalLimits2, uint48 withdrawalLimits3, uint48 withdrawalLimits4, uint48 withdrawalLimits5) public {
        switchToRuleAdmin();
        uint48[] memory withdrawalLimits = createUint48Array(withdrawalLimits1, withdrawalLimits2, withdrawalLimits3, withdrawalLimits4, withdrawalLimits5);
        uint32 index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), withdrawalLimits);
        applicationHandler.setAccountMaxValueOutByAccessLevelId(index);
        uint256 balance = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 2);
        assertEq(balance, withdrawalLimits3);
        switchToOriginalUser();
    }

    function createAccountMinMaxTokenBalanceRuleRule(bytes32 ruleTag, uint256 minAmounts, uint256 maxAmounts, address assetHandler, uint8 handlerType) public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(ruleTag);
        uint256[] memory min = createUint256Array(minAmounts);
        uint256[] memory max = createUint256Array(maxAmounts);
        uint16[] memory period;
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, period, uint64(Blocktime));
        if (handlerType == 0) {
            ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT);
            ERC20TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        } else if (handlerType == 1) {
            ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.MINT, ActionTypes.BURN);
            ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        }
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(ruleId, ruleTag);
        assertEq(rule.min, minAmounts);
        assertEq(rule.max, maxAmounts);
        switchToOriginalUser();
    }

    function createAccountMinMaxTokenBalanceRuleRule(bytes32 ruleTag, uint256 minAmounts, uint256 maxAmounts, uint16 period, address assetHandler, uint8 handlerType) public {
        switchToRuleAdmin();
        bytes32[] memory accs = createBytes32Array(ruleTag);
        uint256[] memory min = createUint256Array(minAmounts);
        uint256[] memory max = createUint256Array(maxAmounts);
        uint16[] memory rulePeriod = createUint16Array(period);
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), accs, min, max, rulePeriod, uint64(Blocktime));
        if (handlerType == 0) {
            ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT);
            ERC20TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        } else if (handlerType == 1) {
            ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.MINT, ActionTypes.BURN);
            ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        }
        TaggedRules.AccountMinMaxTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMinMaxTokenBalance(ruleId, ruleTag);
        assertEq(rule.min, minAmounts);
        assertEq(rule.max, maxAmounts);
        switchToOriginalUser();
    }

    function createAccountMinMaxTokenBalanceRuleRule(
        bytes32[] memory ruleTags, 
        uint256[] memory minAmounts, 
        uint256[] memory maxAmounts,
        uint16[] memory periods,
        address assetHandler, uint8 handlerType
        ) public {
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMinMaxTokenBalance(address(applicationAppManager), ruleTags, minAmounts, maxAmounts, periods, uint64(Blocktime));
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER, ActionTypes.SELL, ActionTypes.MINT);
        if (handlerType == 0) {
            ERC20TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        } else if (handlerType == 1) {
            ERC721TaggedRuleFacet(address(assetHandler)).setAccountMinMaxTokenBalanceId(actionTypes, ruleId);
        }
        uint32 ruleTotal = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMinMaxTokenBalances();
        assertEq(ruleTotal, 1);
        switchToOriginalUser();
    }

    function createAdminMinTokenBalanceRule(uint256 adminWithdrawalTotal, uint64 period, address assetHandler, uint8 handlerType) public {
        switchToRuleAdmin();
        uint32 ruleId = TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(address(applicationAppManager), adminWithdrawalTotal, period);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        if (handlerType == 0) {
            ERC20HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceId(actionTypes, ruleId);
        } else if (handlerType == 1) {
            ERC721HandlerMainFacet(address(assetHandler)).setAdminMinTokenBalanceId(actionTypes, ruleId);
        }
        TaggedRules.AdminMinTokenBalance memory rule = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAdminMinTokenBalance(ruleId);
        assertEq(rule.amount, adminWithdrawalTotal);
        switchToOriginalUser();
    }

    function createTokenMaxBuyVolumeRule(uint16 tokenPercentage, uint16 period, uint256 _totalSupply, uint64 ruleStartTime, address assetHandler) public {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        TradingRuleFacet(address(assetHandler)).setTokenMaxBuyVolumeId(ruleId);
        NonTaggedRules.TokenMaxBuyVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxBuyVolume(ruleId); 
        assertEq(rule.tokenPercentage, tokenPercentage);
        switchToOriginalUser();
    }

    function createTokenMaxDailyTradesRule(bytes32 tag1, uint8 dailyTradeMax1) public {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array(tag1); 
        uint8[] memory tradesAllowed = createUint8Array(dailyTradeMax1);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, dailyTradeMax1);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMaxDailyTradesId(actionTypes, _index);
        switchToOriginalUser();
    }

    function createTokenMaxDailyTradesRule(bytes32 tag1, bytes32 tag2, uint8 dailyTradeMax1, uint8 dailyTradeMax2) public {
        switchToRuleAdmin();
        bytes32[] memory nftTags = createBytes32Array(tag1, tag2); 
        uint8[] memory tradesAllowed = createUint8Array(dailyTradeMax1, dailyTradeMax2);
        uint32 _index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), nftTags, tradesAllowed, Blocktime);
        TaggedRules.TokenMaxDailyTrades memory rule = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(_index, nftTags[0]);
        assertEq(rule.tradesAllowedPerDay, dailyTradeMax1);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC721NonTaggedRuleFacet(address(applicationNFTHandler)).setTokenMaxDailyTradesId(actionTypes, _index);
        switchToOriginalUser();
    }

    function createTokenMaxSellVolumeRule(uint16 tokenPercentage, uint16 period, uint256 _totalSupply, uint64 ruleStartTime, address assetHandler) public {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMaxSellVolume(address(applicationAppManager), tokenPercentage, period, _totalSupply, ruleStartTime);
        TradingRuleFacet(address(assetHandler)).setTokenMaxSellVolumeId(ruleId);
        NonTaggedRules.TokenMaxSellVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSellVolume(ruleId); 
        assertEq(rule.tokenPercentage, tokenPercentage);
        switchToOriginalUser();
    }

    function createTokenMaxSupplyVolatilityRuleRule(uint16 volatilityLimit, uint8 rulePeriod, uint64 startTime, uint256 tokenSupply, address assetHandler, uint8 handlerType) public {
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(address(applicationAppManager), volatilityLimit, rulePeriod, startTime, tokenSupply);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.MINT, ActionTypes.BURN);
        if (handlerType == 0) {
            ERC20NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityId(actionTypes, _index);
        } else if (handlerType == 1) {
            ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxSupplyVolatilityId(actionTypes, _index);
        }
        NonTaggedRules.TokenMaxSupplyVolatility memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSupplyVolatility(_index);
        assertEq(rule.max, volatilityLimit);
        switchToOriginalUser();
    }

    function createTokenMaxTradingVolumeRule(uint24 max, uint16 period, uint64 startTime, uint256 totalSupply, address assetHandler, uint8 handlerType) public {
        switchToRuleAdmin();
        uint32 _index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), max, period, startTime, totalSupply);
        NonTaggedRules.TokenMaxTradingVolume memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(_index);
        assertEq(rule.max, max);
        assertEq(rule.period, period);
        assertEq(rule.startTime, startTime);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        if (handlerType == 0) {
            ERC20NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeId(actionTypes, _index);
        } else if (handlerType == 1) {
            ERC721NonTaggedRuleFacet(address(assetHandler)).setTokenMaxTradingVolumeId(actionTypes, _index);
        }
        switchToOriginalUser();
    }

    function createTokenMinimumTransactionRule(uint256 tokenMinTxSize) public {
        switchToRuleAdmin();
        uint32 ruleId = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), tokenMinTxSize);
        NonTaggedRules.TokenMinTxSize memory rule = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(ruleId);
        assertEq(rule.minSize, tokenMinTxSize);
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.P2P_TRANSFER);
        ERC20NonTaggedRuleFacet(address(applicationCoinHandler)).setTokenMinTxSizeId(actionTypes, ruleId);
        switchToOriginalUser();
    }



}
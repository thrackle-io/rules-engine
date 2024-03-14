// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "src/protocol/economic/ruleProcessor/RuleDataInterfaces.sol";
import "test/util/TestArrays.sol";

contract PredefinedRules is ITaggedRules, INonTaggedRules, IApplicationRules, TestArrays {
    AccountMaxBuySize public accountMaxBuySizeRuleA = AccountMaxBuySize(13 * 10 ** 18, 24);
    AccountMaxBuySize public accountMaxBuySizeRuleB = AccountMaxBuySize(20 * 10 ** 18, 24);

    AccountMaxSellSize public accountMaxSellSizeRuleA = AccountMaxSellSize(13 * 10 ** 18, 24);
    AccountMaxSellSize public accountMaxSellSizeRuleB = AccountMaxSellSize(20 * 10 ** 18, 24);

    TokenMaxBuyVolume public tokenMaxBuyVolumeRuleA = TokenMaxBuyVolume(10, 24, 0, 0);
    TokenMaxBuyVolume public tokenMaxBuyVolumeRuleB = TokenMaxBuyVolume(10, 24, 10_000 * 10 ** 18, 0);

    TokenMaxSellVolume public tokenMaxSellVolumeRuleA = TokenMaxSellVolume(10, 24, 0, 0);
    TokenMaxSellVolume public tokenMaxSellVolumeRuleB = TokenMaxSellVolume(10, 24, 10_000 * 10 ** 18, 0);

    AccountMaxTxValueByRiskScore public accountMaxTxValueByRiskScoreA =
        AccountMaxTxValueByRiskScore(createUint48Array(uint48(50), uint48(35), uint48(25)), createUint8Array(uint8(9), uint8(39), uint8(69)), 24, 0);

    uint48[] accountMaxValueOutByAccessLevel = createUint48Array(5, 20, 40, 100, 100_000);

    TokenMaxTradingVolume public tokenMaxTradingVolumeRuleA = TokenMaxTradingVolume(10, 24, 0, 0);
    TokenMaxTradingVolume public tokenMaxTradingVolumeRuleB = TokenMaxTradingVolume(10, 24, 0, 10_000 * 10 ** 18);

    TokenMaxSupplyVolatility public tokenMaxSupplyVolatilityRuleA = TokenMaxSupplyVolatility(10, 24, 0, 0);
    TokenMaxSupplyVolatility public tokenMaxSupplyVolatilityRuleB = TokenMaxSupplyVolatility(10, 24, 0, 10_000 * 10 ** 18);
}

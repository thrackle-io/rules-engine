// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingTokenMaxBuySellVolumeActor} from "./RuleProcessingTokenMaxBuySellVolumeActor.sol";
import "./RuleProcessingTokenMaxBuySellVolumeActorManager.sol";

/**
 * @title RuleProcessingTokenMaxBuySellVolumeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actorManagers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule
 * is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingTokenMaxBuySellVolumeMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingTokenMaxBuySellVolumeActorManager[] actorManagers;
    RuleProcessingTokenMaxBuySellVolumeActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;
    uint256 constant TOTAL_SUPPLY = 10_000 * ATTO;

    function setUp() public {
        (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = prepareTradingRuleProcessingInvariant();
        switchToRuleAdmin();
        uint32 index0 = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuySellVolume(
            address(applicationAppManager),
            tokenMaxBuySellVolumeRuleA.tokenPercentage,
            tokenMaxBuySellVolumeRuleA.period,
            tokenMaxBuySellVolumeRuleA.totalSupply,
            uint64(block.timestamp)
        );
        uint32 index1 = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuySellVolume(
            address(applicationAppManager),
            tokenMaxBuySellVolumeRuleB.tokenPercentage,
            tokenMaxBuySellVolumeRuleB.period,
            tokenMaxBuySellVolumeRuleB.totalSupply,
            uint64(block.timestamp)
        );
        for (uint j; j < AMOUNT_MANAGERS; j++) {
            (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, ApplicationERC20 testCoin, HandlerDiamond testCoinHandler) = deployFullApplicationWithCoin(
                j,
                coinPricer,
                nftPricer
            );
            switchToAppAdministrator();
            tokenHandlers.push(testCoinHandler);

            RuleProcessingTokenMaxBuySellVolumeActor[] memory tempActors = new RuleProcessingTokenMaxBuySellVolumeActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) tempActors[i] = new RuleProcessingTokenMaxBuySellVolumeActor(ruleProcessor);
            actors.push(tempActors);
            /// split loop to avoid stack too deep
            for (uint i; i < AMOUNT_ACTORS; i++) {
                switchToAppAdministrator();
                testCoin.mint(address(actors[j][i]), 1_000 * ATTO);
                vm.startPrank(address(actors[j][i]));
                testCoin.approve(address(amm), 1_000 * ATTO);
            }
            assertEq(testCoin.totalSupply(), TOTAL_SUPPLY);
            RuleProcessingTokenMaxBuySellVolumeActorManager actorManager = new RuleProcessingTokenMaxBuySellVolumeActorManager(tempActors, address(amm), address(testCoin));
            switchToRuleAdmin();
            HandlerTokenMaxBuySellVolume(address(testCoinHandler)).setTokenMaxBuySellVolumeId(createActionTypeArray(ActionTypes.SELL), j % 2 == 0 ? index0 : index1);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            (testAppManager, testAppHandler);
        }
    }

    /**
     * the cumulative amount of tokens sold in a defined period of time relative to the total supply at the beginning of the period can never
     * exceed the maximum of the TokenMaxBuySellVolume applied for the asset. The total supply can be given live or stored as a hard coded value
     * in the rule itself.
     */
    function invariant_amountSoldCanNeverExceedRulesMaxPctOfTotalSupply() public view {
        for (uint j; j < actors.length; j++) assertLe((actorManagers[j].totalSoldInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuySellVolumeRuleA.tokenPercentage);
    }

    /**
     * Deactivating a rule in one token, AMM or Application does not affect its application in others.
     */
    function invariant_deactivationIndependentPerAsset() public {
        switchToRuleAdmin();
        HandlerTokenMaxBuySellVolume(address(tokenHandlers[0])).activateTokenMaxBuySellVolume(createActionTypeArray(ActionTypes.SELL), false);
        for (uint j = 1; j < actors.length; j++) assertLe((actorManagers[j].totalSoldInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuySellVolumeRuleA.tokenPercentage);
    }

    /**
     * the cumulative amount of tokens purchased in a defined period of time relative to the total supply at the beginning of the period can never exceed the
     * maximum of the TokenMaxBuyVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.
     */
    function invariant_amountBoughtCanNeverExceedRulesMaxPctOfTotalSupply() public view {
        for (uint j; j < actors.length; j++) assertLe((actorManagers[j].totalBoughtInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuySellVolumeRuleA.tokenPercentage);
    }

    /**
     * Deactivating a rule in one token, AMM or Application does not affect its application in others.
     */
    function invariant_deactivationIndependentPerAssetBuy() public {
        switchToRuleAdmin();
        HandlerTokenMaxBuySellVolume(address(tokenHandlers[0])).activateTokenMaxBuySellVolume(createActionTypeArray(ActionTypes.BUY), false);
        for (uint j = 1; j < actors.length; j++) assertLe((actorManagers[j].totalBoughtInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuySellVolumeRuleA.tokenPercentage);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingTokenMaxBuyVolumeActor} from "./RuleProcessingTokenMaxBuyVolumeActor.sol";
import "./RuleProcessingTokenMaxBuyVolumeActorManager.sol";

/**
 * @title RuleProcessingTokenMaxBuyVolumeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule processing invariant test for multiple actorManagers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule
 * is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingTokenMaxBuyVolumeMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingTokenMaxBuyVolumeActorManager[] actorManagers;
    RuleProcessingTokenMaxBuyVolumeActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;
    uint256 constant TOTAL_SUPPLY = 10_000 * ATTO;

    function setUp() public {
        (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = prepareTradingRuleProcessingInvariant();
        switchToRuleAdmin();
        uint32 index0 = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(
            address(applicationAppManager),
            tokenMaxBuyVolumeRuleA.tokenPercentage,
            tokenMaxBuyVolumeRuleA.period,
            tokenMaxBuyVolumeRuleA.totalSupply,
            uint64(block.timestamp)
        );
        uint32 index1 = RuleDataFacet(address(ruleProcessor)).addTokenMaxBuyVolume(
            address(applicationAppManager),
            tokenMaxBuyVolumeRuleB.tokenPercentage,
            tokenMaxBuyVolumeRuleB.period,
            tokenMaxBuyVolumeRuleB.totalSupply,
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

            testCoin.mint(address(amm), TOTAL_SUPPLY);
            assertEq(testCoin.totalSupply(), TOTAL_SUPPLY);

            RuleProcessingTokenMaxBuyVolumeActor[] memory tempActors = new RuleProcessingTokenMaxBuyVolumeActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) tempActors[i] = new RuleProcessingTokenMaxBuyVolumeActor(ruleProcessor);
            actors.push(tempActors);
            RuleProcessingTokenMaxBuyVolumeActorManager actorManager = new RuleProcessingTokenMaxBuyVolumeActorManager(tempActors, address(amm), address(testCoin));
            switchToRuleAdmin();
            HandlerTokenMaxBuyVolume(address(testCoinHandler)).setTokenMaxBuyVolumeId(j % 2 == 0 ? index0 : index1);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            (testAppManager, testAppHandler);
        }
    }

    /**
     * the cumulative amount of tokens purchased in a defined period of time relative to the total supply at the beginning of the period can never exceed the
     * maximum of the TokenMaxBuyVolume applied for the asset. The total supply can be given live or stored as a hard coded value in the rule itself.
     */
    function invariant_amountBoughtCanNeverExceedRulesMaxPctOfTotalSupply() public view {
        for (uint j; j < actors.length; j++) assertLe((actorManagers[j].totalBoughtInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuyVolumeRuleA.tokenPercentage);
    }

    /**
     * Deactivating a rule in one token, AMM or Application does not affect its application in others.
     */
    function invariant_deactivationIndependentPerAsset() public {
        switchToRuleAdmin();
        HandlerTokenMaxBuyVolume(address(tokenHandlers[0])).activateTokenMaxBuyVolume(false);
        for (uint j = 1; j < actors.length; j++) assertLe((actorManagers[j].totalBoughtInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxBuyVolumeRuleA.tokenPercentage);
    }
}

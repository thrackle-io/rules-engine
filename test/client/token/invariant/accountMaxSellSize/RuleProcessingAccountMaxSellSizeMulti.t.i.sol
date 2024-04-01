// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingAccountMaxSellSizeActor} from "./RuleProcessingAccountMaxSellSizeActor.sol";
import "./RuleProcessingAccountMaxSellSizeActorManager.sol";

/**
 * @title RuleProcessingAccountMaxSellSizeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple managers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single
 * rule is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingAccountMaxSellSizeMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingAccountMaxSellSizeActorManager[] actorManagers;
    RuleProcessingAccountMaxSellSizeActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;

    function setUp() public {
        (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = prepareTradingRuleProcessingInvariant();
        switchToRuleAdmin();
        uint32 index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxTradeSize(
            address(applicationAppManager),
            createBytes32Array(bytes32("tagA"), bytes32("tagB")),
            createUint240Array(accountMaxTradeSizeRuleA.maxSize, accountMaxTradeSizeRuleB.maxSize),
            createUint16Array(accountMaxTradeSizeRuleA.period, accountMaxTradeSizeRuleB.period),
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

            RuleProcessingAccountMaxSellSizeActor[] memory tempActors = new RuleProcessingAccountMaxSellSizeActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) {
                RuleProcessingAccountMaxSellSizeActor actor = new RuleProcessingAccountMaxSellSizeActor(ruleProcessor);
                tempActors[i] = actor;
                switchToAppAdministrator();
                /// actors 0, 3, 6 and 9 will have TagA. actors 0,1,3,4,6,7,9 will have tagB
                /// Therefore, all actors that have tag A also have tagB. actors 2, 5, and 8 won't have any tag
                if (i % 3 == 0) testAppManager.addTag(address(actor), "tagA");
                if (i % 3 != 2) testAppManager.addTag(address(actor), "tagB");
                testCoin.mint(address(actor), 1_000_000 * ATTO);
                vm.startPrank(address(actor));
                testCoin.approve(address(amm), 1_000_000 * ATTO);
            }
            actors.push(tempActors);
            RuleProcessingAccountMaxSellSizeActorManager actorManager = new RuleProcessingAccountMaxSellSizeActorManager(tempActors, address(amm), address(testCoin));
            switchToRuleAdmin();
            HandlerAccountMaxTradeSize(address(testCoinHandler)).setAccountMaxTradeSizeId(createActionTypeArray(ActionTypes.SELL), index);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            testAppHandler;
        }
    }

    /**
     * the cumulative amount of tokens sold in a defined period of time can never exceed the maximum of the most restrictive tags of the
     * account found in the AccountMaxSellSize applied for the asset.
     */
    function invariant_amountSoldCanNeverExceedTheMostRestrictiveTag() public view {
        for (uint j; j < actors.length; j++) {
            for (uint i; i < actors[j].length; i++) {
                // the more restrictive tag
                if (i % 3 == 0)
                    assertLe(actors[j][i].totalSoldInPeriod(), accountMaxTradeSizeRuleA.maxSize);
                    // the less restrictive tag
                else if (i % 3 == 1) assertLe(actors[j][i].totalSoldInPeriod(), accountMaxTradeSizeRuleB.maxSize);
                // no tag, no limit to check.
            }
        }
    }

    /**
     * Deactivating a rule in one token, AMM or Application does not affect its application in others.
     */
    function invariant_deactivationIndependentPerAsset() public {
        for (uint j; j < actors.length; j++) {
            switchToRuleAdmin();
            if (j % 2 == 0) HandlerAccountMaxTradeSize(address(tokenHandlers[j])).activateAccountMaxTradeSize(createActionTypeArray(ActionTypes.SELL), false);
            for (uint i; i < actors[j].length; i++) {
                if (j % 2 == 1) {
                    // the more restrictive tag
                    if (i % 3 == 0)
                        assertLe(actors[j][i].totalSoldInPeriod(), accountMaxTradeSizeRuleA.maxSize);
                        // the less restrictive tag
                    else if (i % 3 == 1) assertLe(actors[j][i].totalSoldInPeriod(), accountMaxTradeSizeRuleB.maxSize);
                    // no tag, no limit to check.
                }
            }
        }
    }
}

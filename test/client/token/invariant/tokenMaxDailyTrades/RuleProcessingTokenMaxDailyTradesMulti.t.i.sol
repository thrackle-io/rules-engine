// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingTokenMaxDailyTradesActor} from "./RuleProcessingTokenMaxDailyTradesActor.sol";
import "./RuleProcessingTokenMaxDailyTradesActorManager.sol";

/**
 * @title RuleProcessingTokenMaxDailyTradesMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule processing invariant test for multiple actorManagers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule
 * is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingTokenMaxDailyTradesMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingTokenMaxDailyTradesActorManager[] actorManagers;
    RuleProcessingTokenMaxDailyTradesActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 2;
    uint8 constant AMOUNT_MANAGERS = 4;

    function setUp() public {
        prepRuleProcessingInvariant();
        (ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = deployPricers();
        switchToRuleAdmin();
        uint32 index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(
            address(applicationAppManager),
            createBytes32Array("TagA", "TagB"),
            createUint8Array(1, 2),
            uint64(block.timestamp)
        );

        for (uint j; j < AMOUNT_MANAGERS; j++) {
            (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, UtilApplicationERC721 testNFT, HandlerDiamond testNFTHandler) = deployFullApplicationWithNFT(
                j,
                coinPricer,
                nftPricer
            );
            switchToAppAdministrator();
            tokenHandlers.push(testNFTHandler);

            RuleProcessingTokenMaxDailyTradesActor[] memory tempActors = new RuleProcessingTokenMaxDailyTradesActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) {
                tempActors[i] = new RuleProcessingTokenMaxDailyTradesActor(ruleProcessor);
                if (i == 0) testNFT.safeMint(address(tempActors[i]));
            }
            actors.push(tempActors);
            RuleProcessingTokenMaxDailyTradesActorManager actorManager = new RuleProcessingTokenMaxDailyTradesActorManager(tempActors, address(testNFT));
            switchToAppAdministrator();
            testAppManager.addTag(address(testNFT), j % 2 == 0 ? bytes32("TagA") : bytes32("TagB"));
            switchToRuleAdmin();
            ActionTypes[] memory actions = new ActionTypes[](3);
            actions[0] = ActionTypes.BUY;
            actions[1] = ActionTypes.SELL;
            actions[2] = ActionTypes.P2P_TRANSFER;
            HandlerTokenMaxDailyTrades(address(testNFTHandler)).setTokenMaxDailyTradesId(actions, index);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            (testAppManager, testAppHandler);
        }
    }

    /**
     * the amount of times that a particular NFT is transferred during a fixed 24-hour period can never exceed the maximum defined by the most
     * restrictive tag of the NFT found in the TokenMaxDailyTrades applied to the token.
     */
    function invariant_amountOfTransfersOfAnNFTCanNeverExceedRulesMax() public view {
        for (uint j; j < actors.length; j++) {
            if (j % 2 == 0) assertLe(actorManagers[j].totalTxs(), 1);
            else assertLe(actorManagers[j].totalTxs(), 2);
        }
    }
}

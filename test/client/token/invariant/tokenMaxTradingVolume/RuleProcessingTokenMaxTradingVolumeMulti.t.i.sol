// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingTokenMaxTradingVolumeActor} from "./RuleProcessingTokenMaxTradingVolumeActor.sol";
import "./RuleProcessingTokenMaxTradingVolumeActorManager.sol";
import {InvariantUtils} from "test/client/token/invariant/util/InvariantUtils.sol";

/**
 * @title RuleProcessingTokenMaxTradingVolumeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule processing invariant test for multiple actorManagers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule
 * is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingTokenMaxTradingVolumeMultiTest is RuleProcessingInvariantCommon, InvariantUtils {
    RuleProcessingTokenMaxTradingVolumeActorManager[] actorManagers;
    RuleProcessingTokenMaxTradingVolumeActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;
    uint256 constant TOTAL_SUPPLY = 10_000 * ATTO;

    function setUp() public {
        (DummySingleTokenAMM amm, ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = prepareTradingRuleProcessingInvariant();
        switchToRuleAdmin();
        uint32 index0 = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(
            address(applicationAppManager),
            tokenMaxTradingVolumeRuleA.max,
            tokenMaxTradingVolumeRuleA.period,
            uint64(block.timestamp),
            tokenMaxTradingVolumeRuleA.totalSupply
        );
        uint32 index1 = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(
            address(applicationAppManager),
            tokenMaxTradingVolumeRuleB.max,
            tokenMaxTradingVolumeRuleB.period,
            uint64(block.timestamp),
            tokenMaxTradingVolumeRuleB.totalSupply
        );
        for (uint j; j < AMOUNT_MANAGERS; j++) {
            (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, UtilApplicationERC20 testCoin, HandlerDiamond testCoinHandler) = deployFullApplicationWithCoin(
                j,
                coinPricer,
                nftPricer
            );
            switchToAppAdministrator();
            tokenHandlers.push(testCoinHandler);

            testCoin.mint(address(amm), TOTAL_SUPPLY);
            assertEq(testCoin.totalSupply(), TOTAL_SUPPLY);

            RuleProcessingTokenMaxTradingVolumeActor[] memory tempActors = new RuleProcessingTokenMaxTradingVolumeActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) tempActors[i] = new RuleProcessingTokenMaxTradingVolumeActor(ruleProcessor);
            actors.push(tempActors);
            RuleProcessingTokenMaxTradingVolumeActorManager actorManager = new RuleProcessingTokenMaxTradingVolumeActorManager(tempActors, address(amm), address(testCoin));
            switchToRuleAdmin();
            ActionTypes[] memory actions = new ActionTypes[](1);
            actions[0] = ActionTypes.BUY;
            HandlerTokenMaxTradingVolume(address(testCoinHandler)).setTokenMaxTradingVolumeId(actions, j % 2 == 0 ? index0 : index1);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            (testAppManager, testAppHandler);
        }
    }

    /**
     * the cumulative amount of tokens transacted in a defined period of time relative to the total supply of the token
     * can never exceed the maximum of the TokenMaxTradingVolume applied for the asset. The total supply can be given
     * live or stored as a hard coded value in the rule itself.
     */
    function invariant_amountTransactedCanNeverExceedRulesPctOfTotalSupply() public view {
        for (uint j; j < actors.length; j++) assertLe((actorManagers[j].totalBoughtInPeriod() * 10000) / (TOTAL_SUPPLY), tokenMaxTradingVolumeRuleA.max);
    }
}

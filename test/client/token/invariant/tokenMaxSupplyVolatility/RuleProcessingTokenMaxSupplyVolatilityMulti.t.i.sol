// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/client/token/invariant/util/RuleProcessingInvariantCommon.sol";
import {RuleProcessingTokenMaxSupplyVolatilityActor} from "./RuleProcessingTokenMaxSupplyVolatilityActor.sol";
import "./RuleProcessingTokenMaxSupplyVolatilityActorManager.sol";

/**
 * @title RuleProcessingTokenMaxSupplyVolatilityMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule processing invariant test for multiple actorManagers. Each manager has its
 * own application and set of tokens which will be tested through their own set of actors. The same single rule
 * is shared by all the applications and tokens in this invariant test.
 */
contract RuleProcessingTokenMaxSupplyVolatilityMultiTest is RuleProcessingInvariantCommon {
    RuleProcessingTokenMaxSupplyVolatilityActorManager[] actorManagers;
    RuleProcessingTokenMaxSupplyVolatilityActor[][] actors;
    HandlerDiamond[] tokenHandlers;
    uint8 constant AMOUNT_ACTORS = 10;
    uint8 constant AMOUNT_MANAGERS = 4;
    uint256 constant TOTAL_SUPPLY = 10_000 * ATTO;

    function setUp() public {
        prepRuleProcessingInvariant();
        (ProtocolERC20Pricing coinPricer, ProtocolERC721Pricing nftPricer) = deployPricers();
        switchToRuleAdmin();
        uint32 index0 = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(
            address(applicationAppManager),
            tokenMaxSupplyVolatilityRuleA.max,
            tokenMaxSupplyVolatilityRuleA.period,
            uint64(block.timestamp),
            tokenMaxSupplyVolatilityRuleA.totalSupply
        );
        uint32 index1 = RuleDataFacet(address(ruleProcessor)).addTokenMaxSupplyVolatility(
            address(applicationAppManager),
            tokenMaxSupplyVolatilityRuleB.max,
            tokenMaxSupplyVolatilityRuleB.period,
            uint64(block.timestamp),
            tokenMaxSupplyVolatilityRuleB.totalSupply
        );
        for (uint j; j < AMOUNT_MANAGERS; j++) {
            (ApplicationAppManager testAppManager, ApplicationHandler testAppHandler, ApplicationERC20 testCoin, HandlerDiamond testCoinHandler) = deployFullApplicationWithCoin(
                j,
                coinPricer,
                nftPricer
            );
            switchToAppAdministrator();
            tokenHandlers.push(testCoinHandler);
            RuleProcessingTokenMaxSupplyVolatilityActor[] memory tempActors = new RuleProcessingTokenMaxSupplyVolatilityActor[](AMOUNT_ACTORS);
            // Load actors
            for (uint i; i < AMOUNT_ACTORS; i++) {
                tempActors[i] = new RuleProcessingTokenMaxSupplyVolatilityActor(ruleProcessor);
                testCoin.mint(address(tempActors[i]), TOTAL_SUPPLY / AMOUNT_ACTORS);
            }
            assertEq(testCoin.totalSupply(), TOTAL_SUPPLY);
            actors.push(tempActors);
            RuleProcessingTokenMaxSupplyVolatilityActorManager actorManager = new RuleProcessingTokenMaxSupplyVolatilityActorManager(tempActors, address(testCoin));
            switchToRuleAdmin();
            ActionTypes[] memory actions = new ActionTypes[](2);
            actions[0] = ActionTypes.BURN;
            actions[1] = ActionTypes.MINT;
            HandlerTokenMaxSupplyVolatility(address(testCoinHandler)).setTokenMaxSupplyVolatilityId(actions, j % 2 == 0 ? index0 : index1);
            targetContract(address(actorManager));
            actorManagers.push(actorManager);
            (testAppManager, testAppHandler);
        }
    }

    /**
     * the cumulative net amount of tokens minted or burned in a defined period of time relative to the total supply at the
     * beginning of the period can never exceed the maximum of the TokenMaxSupplyVolatility applied for the asset. The total
     * supply can be given live or stored as a hard coded value in the rule itself.
     */
    function invariant_supplyChangeInPeriodCanNeverExceedRulesMax() public view {
        for (uint j; j < actors.length; j++) {
            uint256 minted = actorManagers[j].totalMinted();
            uint256 burnt = actorManagers[j].totalBurnt();
            if (minted > burnt) assertLe(((minted - burnt) * 10000) / TOTAL_SUPPLY, tokenMaxSupplyVolatilityRuleA.max);
            else assertLe(((burnt - minted) * 10000) / TOTAL_SUPPLY, tokenMaxSupplyVolatilityRuleA.max);
        }
    }
}

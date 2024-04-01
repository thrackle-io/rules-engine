// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageTokenMaxDailyTradesActor} from "./RuleStorageTokenMaxDailyTradesActor.sol";
import "./RuleStorageTokenMaxDailyTradesActorManager.sol";

/**
 * @title RuleStorageTokenMaxDailyTradesMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageTokenMaxDailyTradesMultiTest is RuleStorageInvariantCommon {
    RuleStorageTokenMaxDailyTradesActorManager actorManager;
    RuleStorageTokenMaxDailyTradesActor[] actors;
    TaggedRules.TokenMaxDailyTrades ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageTokenMaxDailyTradesActor(ruleProcessor, actorAppManager));
            if (i % 2 == 0) {
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageTokenMaxDailyTradesActorManager(actors);
        switchToRuleAdmin();
        index = TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint8Array(222), uint64(block.timestamp));
        ruleBefore = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(index, "tag");
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalTokenMaxDailyTradesNeverDecreases() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index + 1, ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxDailyTrades());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalTokenMaxDailyTradesEqualsAppBalances() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxDailyTrades());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalTokenMaxDailyTradesLessThanMax() public view {
        assertLe(ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxDailyTrades(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalTokenMaxDailyTradesIncrementsByOne() public {
        uint256 previousTotal = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxDailyTrades();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(
            previousTotal,
            TaggedRuleDataFacet(address(ruleProcessor)).addTokenMaxDailyTrades(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint8Array(222), uint64(block.timestamp))
        );
    }

    // Rules can never be modified.
    function invariant_TokenMaxDailyTradesImmutable() public view {
        TaggedRules.TokenMaxDailyTrades memory ruleAfter = ERC721TaggedRuleProcessorFacet(address(ruleProcessor)).getTokenMaxDailyTrades(index, "tag");
        assertEq(ruleBefore.tradesAllowedPerDay, ruleAfter.tradesAllowedPerDay);
        assertEq(ruleBefore.startTime, ruleAfter.startTime);
    }
}

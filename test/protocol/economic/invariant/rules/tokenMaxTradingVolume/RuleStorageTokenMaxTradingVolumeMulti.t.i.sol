// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageTokenMaxTradingVolumeActor} from "./RuleStorageTokenMaxTradingVolumeActor.sol";
import "./RuleStorageTokenMaxTradingVolumeActorManager.sol";

/**
 * @title RuleStorageTokenMaxTradingVolumeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageTokenMaxTradingVolumeMultiTest is RuleStorageInvariantCommon {
    RuleStorageTokenMaxTradingVolumeActorManager actorManager;
    RuleStorageTokenMaxTradingVolumeActor[] actors;
    NonTaggedRules.TokenMaxTradingVolume ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageTokenMaxTradingVolumeActor(ruleProcessor, actorAppManager));
            if (i % 2 == 0) {
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageTokenMaxTradingVolumeActorManager(actors);
        switchToRuleAdmin();
        index = RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 666, 24, uint64(block.timestamp), 0);
        ruleBefore = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalTokenMaxTradingVolumeNeverDecreases() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index + 1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalTokenMaxTradingVolumeEqualsAppBalances() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalTokenMaxTradingVolumeLessThanMax() public view {
        assertLe(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalTokenMaxTradingVolumeIncrementsByOne() public {
        uint256 previousTotal = ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxTradingVolume();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, RuleDataFacet(address(ruleProcessor)).addTokenMaxTradingVolume(address(applicationAppManager), 666, 24, uint64(block.timestamp), 0));
    }

    // Rules can never be modified.
    function invariant_TokenMaxTradingVolumeImmutable() public view {
        NonTaggedRules.TokenMaxTradingVolume memory ruleAfter = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxTradingVolume(index);
        assertEq(ruleBefore.max, ruleAfter.max);
        assertEq(ruleBefore.period, ruleAfter.period);
        assertEq(ruleBefore.startTime, ruleAfter.startTime);
        assertEq(ruleBefore.totalSupply, ruleAfter.totalSupply);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMaxTxValueByRiskScoreActor} from "./RuleStorageAccountMaxTxValueByRiskScoreActor.sol";
import "./RuleStorageAccountMaxTxValueByRiskScoreActorManager.sol";

/**
 * @title RuleStorageAccountMaxTxValueByRiskScoreMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMaxTxValueByRiskScoreMultiTest is RuleStorageInvariantCommon {
    RuleStorageAccountMaxTxValueByRiskScoreActorManager actorManager;
    RuleStorageAccountMaxTxValueByRiskScoreActor[] actors;
    AppRules.AccountMaxTxValueByRiskScore ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageAccountMaxTxValueByRiskScoreActor(ruleProcessor, actorAppManager));
            if (i % 2 == 0) {
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageAccountMaxTxValueByRiskScoreActorManager(actors);
        switchToRuleAdmin();
        index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), createUint48Array(100), createUint8Array(50), 24, uint64(block.timestamp));
        ruleBefore = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMaxTxValueByRiskScoreNeverDecreases() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index + 1, ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxTxValueByRiskScore());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMaxTxValueByRiskScoreEqualsAppBalances() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxTxValueByRiskScore());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMaxTxValueByRiskScoreLessThanMax() public view {
        assertLe(ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxTxValueByRiskScore(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMaxTxValueByRiskScoreIncrementsByOne() public {
        uint256 previousTotal = ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxTxValueByRiskScore();
        // not incrementing previousTotal by one due to zero based ruleId
        switchToRuleAdmin();
        assertEq(
            previousTotal,
            AppRuleDataFacet(address(ruleProcessor)).addAccountMaxTxValueByRiskScore(address(applicationAppManager), createUint48Array(100), createUint8Array(50), 24, uint64(block.timestamp))
        );
    }

    // Rules can never be modified.
    function invariant_AccountMaxTxValueByRiskScoreImmutable() public view {
        AppRules.AccountMaxTxValueByRiskScore memory ruleAfter = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxTxValueByRiskScore(index);
        assertEq(ruleBefore.maxValue[0], ruleAfter.maxValue[0]);
        assertEq(ruleBefore.riskScore[0], ruleAfter.riskScore[0]);
        assertEq(ruleBefore.period, ruleAfter.period);
        assertEq(ruleBefore.startTime, ruleAfter.startTime);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMaxValueByRiskScoreActor} from "./RuleStorageAccountMaxValueByRiskScoreActor.sol";
import "./RuleStorageAccountMaxValueByRiskScoreActorManager.sol";

/**
 * @title RuleStorageAccountMaxValueByRiskScoreMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMaxValueByRiskScoreMultiTest is RuleStorageInvariantCommon {
    RuleStorageAccountMaxValueByRiskScoreActorManager actorManager;
    RuleStorageAccountMaxValueByRiskScoreActor[] actors;
    AppRules.AccountMaxValueByRiskScore ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageAccountMaxValueByRiskScoreActor(ruleProcessor, actorAppManager));
            if (i % 2 == 0) {
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageAccountMaxValueByRiskScoreActorManager(actors);
        switchToRuleAdmin();
        index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), createUint8Array(50), createUint48Array(100));
        ruleBefore = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMaxValueByRiskScoreNeverDecreases() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index + 1, ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueByRiskScore());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMaxValueByRiskScoreEqualsAppBalances() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueByRiskScore());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMaxValueByRiskScoreLessThanMax() public view {
        assertLe(ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueByRiskScore(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMaxValueByRiskScoreIncrementsByOne() public {
        uint256 previousTotal = ApplicationRiskProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueByRiskScore();
        // not incrementing previousTotal by one due to zero based ruleId
        switchToRuleAdmin();
        assertEq(previousTotal, AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueByRiskScore(address(applicationAppManager), createUint8Array(50), createUint48Array(100)));
    }

    // Rules can never be modified.
    function invariant_AccountMaxValueByRiskScoreImmutable() public view {
        AppRules.AccountMaxValueByRiskScore memory ruleAfter = ApplicationRiskProcessorFacet(address(ruleProcessor)).getAccountMaxValueByRiskScore(index);
        assertEq(ruleBefore.maxValue[0], ruleAfter.maxValue[0]);
        assertEq(ruleBefore.riskScore[0], ruleAfter.riskScore[0]);
    }
}

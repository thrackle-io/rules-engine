// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAdminMinTokenBalanceActor} from "./RuleStorageAdminMinTokenBalanceActor.sol";
import "./RuleStorageAdminMinTokenBalanceActorManager.sol";

/**
 * @title RuleStorageAdminMinTokenBalanceMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAdminMinTokenBalanceMultiTest is
    RuleStorageInvariantCommon
{
    RuleStorageAdminMinTokenBalanceActorManager actorManager;
    RuleStorageAdminMinTokenBalanceActor[] actors;
    TaggedRules.AdminMinTokenBalance ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(
                new RuleStorageAdminMinTokenBalanceActor(
                    ruleProcessor,
                    actorAppManager
                )
            );
            if (i % 2 == 0) {
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(
                    address(actors[actors.length - 1])
                );
            }
        }
        actorManager = new RuleStorageAdminMinTokenBalanceActorManager(actors);
        switchToRuleAdmin();
        index = TaggedRuleDataFacet(address(ruleProcessor))
            .addAdminMinTokenBalance(
                address(applicationAppManager),
                222,
                uint64(block.timestamp + 60 days)
            );
        ruleBefore = ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
            .getAdminMinTokenBalance(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalMinTxSizeNeverDecreases() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(
            index + 1,
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAdminMinTokenBalance()
        );
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalMinTxSizeEqualsAppBalances() public view {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAdminMinTokenBalance()
        );
        // adding 1 to total for the initial rule created in the setup function
        assertEq(
            total + 1,
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAdminMinTokenBalance()
        );
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalMinTxSizeLessThanMax() public view {
        assertLe(
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAdminMinTokenBalance(),
            maxRuleCount
        );
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalMinTxSizeIncrementsByOne() public {
        uint256 previousTotal = ERC20TaggedRuleProcessorFacet(
            address(ruleProcessor)
        ).getTotalAdminMinTokenBalance();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(
            previousTotal,
            TaggedRuleDataFacet(address(ruleProcessor)).addAdminMinTokenBalance(
                address(applicationAppManager),
                222,
                uint64(block.timestamp + 60 days)
            )
        );
    }

    // Rules can never be modified.
    function invariant_MinTxSizeImmutable() public view {
        TaggedRules.AdminMinTokenBalance
            memory ruleAfter = ERC20TaggedRuleProcessorFacet(
                address(ruleProcessor)
            ).getAdminMinTokenBalance(index);
        assertEq(ruleBefore.amount, ruleAfter.amount);
        assertEq(ruleBefore.endTime, ruleAfter.endTime);
    }
}

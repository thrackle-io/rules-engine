// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMinMaxTokenBalanceActor} from "./RuleStorageAccountMinMaxTokenBalanceActor.sol";
import "./RuleStorageAccountMinMaxTokenBalanceActorManager.sol";

/**
 * @title RuleStorageAccountMinMaxTokenBalanceMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMinMaxTokenBalanceMultiTest is
    RuleStorageInvariantCommon
{
    RuleStorageAccountMinMaxTokenBalanceActorManager actorManager;
    RuleStorageAccountMinMaxTokenBalanceActor[] actors;
    TaggedRules.AccountMinMaxTokenBalance ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for (uint i; i < 10; i++) {
            ApplicationAppManager actorAppManager = _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(
                new RuleStorageAccountMinMaxTokenBalanceActor(
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
        actorManager = new RuleStorageAccountMinMaxTokenBalanceActorManager(
            actors
        );
        switchToRuleAdmin();
        index = TaggedRuleDataFacet(address(ruleProcessor))
            .addAccountMinMaxTokenBalance(
                address(applicationAppManager),
                createBytes32Array(bytes32("tag")),
                createUint256Array(222),
                createUint256Array(0xffff),
                createUint16Array(24),
                uint64(block.timestamp)
            );
        ruleBefore = ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
            .getAccountMinMaxTokenBalance(index, "tag");
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMinMaxTokenBalanceNeverDecreases()
        public
        view
    {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(
            index + 1,
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAccountMinMaxTokenBalances()
        );
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMinMaxTokenBalanceEqualsAppBalances()
        public
        view
    {
        uint256 total;
        for (uint i; i < actors.length; i++) {
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAccountMinMaxTokenBalances()
        );
        // adding 1 to total for the initial rule created in the setup function
        assertEq(
            total + 1,
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAccountMinMaxTokenBalances()
        );
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMinMaxTokenBalanceLessThanMax()
        public
        view
    {
        assertLe(
            ERC20TaggedRuleProcessorFacet(address(ruleProcessor))
                .getTotalAccountMinMaxTokenBalances(),
            maxRuleCount
        );
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMinMaxTokenBalanceIncrementsByOne()
        public
    {
        uint256 previousTotal = ERC20TaggedRuleProcessorFacet(
            address(ruleProcessor)
        ).getTotalAccountMinMaxTokenBalances();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(
            previousTotal,
            TaggedRuleDataFacet(address(ruleProcessor))
                .addAccountMinMaxTokenBalance(
                    address(applicationAppManager),
                    createBytes32Array(bytes32("tag")),
                    createUint256Array(222),
                    createUint256Array(0xffff),
                    createUint16Array(24),
                    uint64(block.timestamp)
                )
        );
    }

    // Rules can never be modified.
    function invariant_AccountMinMaxTokenBalanceImmutable() public view {
        TaggedRules.AccountMinMaxTokenBalance
            memory ruleAfter = ERC20TaggedRuleProcessorFacet(
                address(ruleProcessor)
            ).getAccountMinMaxTokenBalance(index, "tag");
        assertEq(ruleBefore.min, ruleAfter.min);
        assertEq(ruleBefore.max, ruleAfter.max);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageTokenMinTxSizeActor} from "./RuleStorageTokenMinTxSizeActor.sol";
import "./RuleStorageTokenMinTxSizeActorManager.sol";

/**
 * @title RuleStorageTokenMinTxSizeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageTokenMinTxSizeMultiTest is RuleStorageInvariantCommon {
    
    RuleStorageTokenMinTxSizeActorManager actorManager;
    RuleStorageTokenMinTxSizeActor[] actors;
    NonTaggedRules.TokenMinTxSize ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for(uint i; i < 10; i++){
            actors.push(new RuleStorageTokenMinTxSizeActor(ruleProcessor, applicationAppManager));
        }
        actorManager = new RuleStorageTokenMinTxSizeActorManager(actors);
        switchToRuleAdmin();
        index = RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 1);
        ruleBefore = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalMinTxSizeNeverDecreases() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index+1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalMinTxSizeEqualsAppBalances() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize());
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalMinTxSizeLessThanMax() public {
        assertLe(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalMinTxSizeIncrementsByOne() public {
        uint256 previousTotal = ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMinTxSize();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, RuleDataFacet(address(ruleProcessor)).addTokenMinTxSize(address(applicationAppManager), 1));
    }
    // Rules can never be modified.
    function invariant_MinTxSizeImmutable() public {
        NonTaggedRules.TokenMinTxSize memory ruleAfter = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMinTxSize(index);
        assertEq(ruleBefore.minSize, ruleAfter.minSize);
    }
    
}

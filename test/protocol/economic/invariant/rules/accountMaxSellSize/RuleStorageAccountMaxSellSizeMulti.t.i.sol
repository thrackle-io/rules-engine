// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMaxSellSizeActor} from "./RuleStorageAccountMaxSellSizeActor.sol";
import "./RuleStorageAccountMaxSellSizeActorManager.sol";

/**
 * @title RuleStorageAccountMaxSellSizeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMaxSellSizeMultiTest is RuleStorageInvariantCommon {
    
    RuleStorageAccountMaxSellSizeActorManager actorManager;
    RuleStorageAccountMaxSellSizeActor[] actors;
    TaggedRules.AccountMaxSellSize ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for(uint i; i < 10; i++){
            ApplicationAppManager actorAppManager =  _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageAccountMaxSellSizeActor(ruleProcessor, actorAppManager));
            if(i % 2 == 0){
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageAccountMaxSellSizeActorManager(actors);
        switchToRuleAdmin();
        index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint192Array(223456789), createUint16Array(24), uint64(block.timestamp));
        ruleBefore = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxSellSize(index,"tag");
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMaxSellSizeNeverDecreases() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index+1, ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxSellSize());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMaxSellSizeEqualsAppBalances() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxSellSize());
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxSellSize());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMaxSellSizeLessThanMax() public {
        assertLe(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxSellSize(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMaxSellSizeIncrementsByOne() public {
        uint256 previousTotal = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxSellSize();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxSellSize(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint192Array(223456789), createUint16Array(24), uint64(block.timestamp)));
    }
    // Rules can never be modified.
    function invariant_AccountMaxSellSizeImmutable() public {
        TaggedRules.AccountMaxSellSize memory ruleAfter = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxSellSize(index,"tag");
        assertEq(ruleBefore.maxSize, ruleAfter.maxSize);
        assertEq(ruleBefore.period, ruleAfter.period);
    }
    
}

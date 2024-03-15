// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMaxBuySizeActor} from "./RuleStorageAccountMaxBuySizeActor.sol";
import "./RuleStorageAccountMaxBuySizeActorManager.sol";

/**
 * @title RuleStorageAccountMaxBuySizeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMaxBuySizeMultiTest is RuleStorageInvariantCommon {
    
    RuleStorageAccountMaxBuySizeActorManager actorManager;
    RuleStorageAccountMaxBuySizeActor[] actors;
    TaggedRules.AccountMaxBuySize ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for(uint i; i < 10; i++){
            ApplicationAppManager actorAppManager =  _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageAccountMaxBuySizeActor(ruleProcessor, actorAppManager));
            if(i % 2 == 0){
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageAccountMaxBuySizeActorManager(actors);
        switchToRuleAdmin();
        index = TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint256Array(223456789), createUint16Array(24), uint64(block.timestamp));
        ruleBefore = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxBuySize(index,"tag");
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMaxBuySizeNeverDecreases() public view {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index+1, ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxBuySize());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMaxBuySizeEqualsAppBalances() public view {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxBuySize());
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxBuySize());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMaxBuySizeLessThanMax() public view {
        assertLe(ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxBuySize(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMaxBuySizeIncrementsByOne() public {
        uint256 previousTotal = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getTotalAccountMaxBuySize();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, TaggedRuleDataFacet(address(ruleProcessor)).addAccountMaxBuySize(address(applicationAppManager), createBytes32Array(bytes32("tag")), createUint256Array(223456789), createUint16Array(24), uint64(block.timestamp)));
    }
    // Rules can never be modified.
    function invariant_AccountMaxBuySizeImmutable() public view {
        TaggedRules.AccountMaxBuySize memory ruleAfter = ERC20TaggedRuleProcessorFacet(address(ruleProcessor)).getAccountMaxBuySize(index,"tag");
        assertEq(ruleBefore.maxSize, ruleAfter.maxSize);
        assertEq(ruleBefore.period, ruleAfter.period);
    }
    
}

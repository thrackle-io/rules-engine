// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageAccountMaxValueOutByAccessLevelActor} from "./RuleStorageAccountMaxValueOutByAccessLevelActor.sol";
import "./RuleStorageAccountMaxValueOutByAccessLevelActorManager.sol";

/**
 * @title RuleStorageAccountMaxValueOutByAccessLevelMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageAccountMaxValueOutByAccessLevelMultiTest is RuleStorageInvariantCommon {
    
    RuleStorageAccountMaxValueOutByAccessLevelActorManager actorManager;
    RuleStorageAccountMaxValueOutByAccessLevelActor[] actors;
    uint48[] ruleBefore = new uint48[](5);

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for(uint i; i < 10; i++){
            ApplicationAppManager actorAppManager =  _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageAccountMaxValueOutByAccessLevelActor(ruleProcessor, actorAppManager));
            if(i % 2 == 0){
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageAccountMaxValueOutByAccessLevelActorManager(actors);
        switchToRuleAdmin();
        index = AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), createUint48Array(666, 667, 668, 669, 670));
        ruleBefore[0] = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index,0);
        ruleBefore[1] = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index,1);
        ruleBefore[2] = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index,2);
        ruleBefore[3] = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index,3);
        ruleBefore[4] = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index,4);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalAccountMaxValueOutByAccessLevelNeverDecreases() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index+1, ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueOutByAccessLevel());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalAccountMaxValueOutByAccessLevelEqualsAppBalances() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueOutByAccessLevel());
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueOutByAccessLevel());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalAccountMaxValueOutByAccessLevelLessThanMax() public {
        assertLe(ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueOutByAccessLevel(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalAccountMaxValueOutByAccessLevelIncrementsByOne() public {
        uint256 previousTotal = ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getTotalAccountMaxValueOutByAccessLevel();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, AppRuleDataFacet(address(ruleProcessor)).addAccountMaxValueOutByAccessLevel(address(applicationAppManager), createUint48Array(666, 667, 668, 669, 670)));
    }
    // Rules can never be modified.
    function invariant_AccountMaxValueOutByAccessLevelImmutable() public {
        assertEq(ruleBefore[0], ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 0));
        assertEq(ruleBefore[1], ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 1));
        assertEq(ruleBefore[2], ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 2));
        assertEq(ruleBefore[3], ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 3));
        assertEq(ruleBefore[4], ApplicationAccessLevelProcessorFacet(address(ruleProcessor)).getAccountMaxValueOutByAccessLevel(index, 4));
    }
}

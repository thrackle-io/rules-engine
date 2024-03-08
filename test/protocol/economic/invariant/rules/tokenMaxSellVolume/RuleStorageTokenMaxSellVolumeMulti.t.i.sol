// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/protocol/economic/invariant/rules/util/RuleStorageInvariantCommon.sol";
import {RuleStorageTokenMaxSellVolumeActor} from "./RuleStorageTokenMaxSellVolumeActor.sol";
import "./RuleStorageTokenMaxSellVolumeActorManager.sol";

/**
 * @title RuleStorageTokenMaxSellVolumeMultiTest
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the multi actor rule storage invariant test for multiple actors.
 */
contract RuleStorageTokenMaxSellVolumeMultiTest is RuleStorageInvariantCommon {
    
    RuleStorageTokenMaxSellVolumeActorManager actorManager;
    RuleStorageTokenMaxSellVolumeActor[] actors;
    NonTaggedRules.TokenMaxSellVolume ruleBefore;

    function setUp() public {
        prepRuleStorageInvariant();
        // Load 10 actors
        for(uint i; i < 10; i++){
            ApplicationAppManager actorAppManager =  _createAppManager();
            switchToSuperAdmin();
            actorAppManager.addAppAdministrator(appAdministrator);
            actors.push(new RuleStorageTokenMaxSellVolumeActor(ruleProcessor, actorAppManager));
            if(i % 2 == 0){
                vm.startPrank(appAdministrator);
                actorAppManager.addRuleAdministrator(address(actors[actors.length - 1]));
            }
        }
        actorManager = new RuleStorageTokenMaxSellVolumeActorManager(actors);
        switchToRuleAdmin();
        index = RuleDataFacet(address(ruleProcessor)).addTokenMaxSellVolume(address(applicationAppManager), 5000, 24, 0xffffffffffff, uint64(block.timestamp));
        ruleBefore = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSellVolume(index);
        targetContract(address(actorManager));
    }

    // The total amount of rules will never decrease.
    function invariant_rulesTotalTokenMaxSellVolumeNeverDecreases() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        // index must be incremented by one to account for 0 based array
        assertLe(index+1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSellVolume());
    }

    // The biggest ruleId in a rule type will always be the same as the total amount of rules registered in the protocol for that rule type - 1.
    function invariant_rulesTotalTokenMaxSellVolumeEqualsAppBalances() public {
        uint256 total;
        for(uint i; i < actors.length; i++){
            total += actors[i].totalRules();
        }
        console.log(total);
        console.log(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSellVolume());
        // adding 1 to total for the initial rule created in the setup function
        assertEq(total + 1, ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSellVolume());
    }

    // There can be only a total of 2**32 of each rule type.
    function invariant_rulesTotalTokenMaxSellVolumeLessThanMax() public {
        assertLe(ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSellVolume(), maxRuleCount);
    }

    /// The next ruleId created in a specific rule type will always be the same as the previous ruleId + 1.
    function invariant_rulesTotalTokenMaxSellVolumeIncrementsByOne() public {
        uint256 previousTotal = ERC20RuleProcessorFacet(address(ruleProcessor)).getTotalTokenMaxSellVolume();
        // not incrementing previousTotal by one due to zero based ruleId
        assertEq(previousTotal, RuleDataFacet(address(ruleProcessor)).addTokenMaxSellVolume(address(applicationAppManager), 5000, 24, 0xffffffffffff, uint64(block.timestamp)));
    }
    // Rules can never be modified.
    function invariant_TokenMaxSellVolumeImmutable() public {
        NonTaggedRules.TokenMaxSellVolume memory ruleAfter = ERC20RuleProcessorFacet(address(ruleProcessor)).getTokenMaxSellVolume(index);
        assertEq(ruleBefore.tokenPercentage, ruleAfter.tokenPercentage);
        assertEq(ruleBefore.period, ruleAfter.period);
        assertEq(ruleBefore.totalSupply, ruleAfter.totalSupply);
        assertEq(ruleBefore.startTime, ruleAfter.startTime);
    }
    
}

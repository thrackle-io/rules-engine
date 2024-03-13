// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageAccountMaxValueOutByAccessLevelActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the AccountMaxValueOutByAccessLevel rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageAccountMaxValueOutByAccessLevelActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addAccountMaxValueOutByAccessLevel(uint48 _withdrawalAmount) public returns (uint32 _ruleId){
        _ruleId = AppRuleDataFacet(address(processor)).
            addAccountMaxValueOutByAccessLevel(
                address(appManager), 
                createUint48Array(
                    _withdrawalAmount, 
                    _withdrawalAmount + 1, 
                    _withdrawalAmount + 2, 
                    _withdrawalAmount + 3, 
                    _withdrawalAmount + 4)
                );
        ++totalRules;
    }
}
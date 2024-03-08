// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageAccountMaxValueByAccessLevelActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the AccountMaxValueByAccessLevel rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageAccountMaxValueByAccessLevelActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addAccountMaxValueByAccessLevel(uint48 _maxValue) public returns (uint32 _ruleId){
        _ruleId = AppRuleDataFacet(address(processor)).addAccountMaxValueByAccessLevel(address(appManager), createUint48Array(_maxValue,_maxValue + 1, _maxValue + 2, _maxValue + 3, _maxValue + 4));
        ++totalRules;
    }
}
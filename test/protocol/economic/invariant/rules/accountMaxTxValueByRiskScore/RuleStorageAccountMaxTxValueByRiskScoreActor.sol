// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageAccountMaxTxValueByRiskScoreActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the AccountMaxTxValueByRiskScore rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageAccountMaxTxValueByRiskScoreActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addAccountMaxTxValueByRiskScore(uint48 _maxValue, uint8 _riskScore, uint16 _period) public returns (uint32 _ruleId){
        _ruleId = AppRuleDataFacet(address(processor)).addAccountMaxTxValueByRiskScore(address(appManager), createUint48Array(_maxValue), createUint8Array(_riskScore), _period, uint64(block.timestamp));
        ++totalRules;
    }
}
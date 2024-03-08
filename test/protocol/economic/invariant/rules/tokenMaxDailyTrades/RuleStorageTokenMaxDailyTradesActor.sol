// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMaxDailyTradesActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the TokenMaxDailyTrades rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageTokenMaxDailyTradesActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addTokenMaxDailyTrades(bytes32 _tag, uint8 _tradesAllowed) public returns (uint32 _ruleId){
        _ruleId = TaggedRuleDataFacet(address(processor)).addTokenMaxDailyTrades(
            address(appManager), createBytes32Array(_tag), createUint8Array(_tradesAllowed), uint64(block.timestamp));
        ++totalRules;
    }
}
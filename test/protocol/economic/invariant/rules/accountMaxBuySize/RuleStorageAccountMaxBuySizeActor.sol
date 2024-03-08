// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageAccountMaxBuySizeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the AccountMaxBuySize rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageAccountMaxBuySizeActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addAccountMaxBuySize(bytes32 _tag, uint256 _max, uint16 _period) public returns (uint32 _ruleId){
        _ruleId = TaggedRuleDataFacet(address(processor)).addAccountMaxBuySize(
            address(appManager), 
            createBytes32Array(_tag), 
            createUint256Array(_max), 
            createUint16Array(_period), 
            uint64(block.timestamp)
        );
        ++totalRules;
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMinTxSizeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the TokenMinTxSize rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageTokenMinTxSizeActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond using fuzzed values
     */
    function addTokenMinTxSize(uint256 _minSize) public returns (uint32 _ruleId){
        _ruleId = RuleDataFacet(address(processor)).addTokenMinTxSize(address(appManager), _minSize);
        ++totalRules;
    }
}
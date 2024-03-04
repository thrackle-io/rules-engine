// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantHandlerCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantHandlerCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMinTxSizeHandler
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the TokenMinTxSize rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageTokenMinTxSizeHandler is TestCommonFoundry, RuleStorageInvariantHandlerCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond using fuzzed values
     */
    function addTokenMinTxSize(uint256 _minSize) public returns (uint32 _ruleId){
        _minSize = bound(_minSize,1,type(uint256).max);
        vm.stopPrank();
        vm.startPrank(ruleAdmin);
        _ruleId = RuleDataFacet(address(processor)).addTokenMinTxSize(address(appManager), _minSize);
        ++totalRules;
        return _ruleId;
    }
    

}
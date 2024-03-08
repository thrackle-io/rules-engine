// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMaxSupplyVolatilityActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the TokenMaxSupplyVolatility rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageTokenMaxSupplyVolatilityActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addTokenMaxSupplyVolatility(uint16 _maxPercentage, uint16 _period, uint64 _startTime, uint256 _totalSupply) public returns (uint32 _ruleId){
        _ruleId = RuleDataFacet(address(processor)).addTokenMaxSupplyVolatility(address(appManager),  _maxPercentage, _period, _startTime, _totalSupply);
        ++totalRules;
    }
}
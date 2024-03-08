// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleStorageInvariantActorCommon} from "test/protocol/economic/invariant/rules/util/RuleStorageInvariantActorCommon.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleStorageTokenMaxSellVolumeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule storage handler for the TokenMaxSellVolume rule. It will create the rule in the diamond and keep a total of how many it adds.
 */
contract RuleStorageTokenMaxSellVolumeActor is TestCommonFoundry, RuleStorageInvariantActorCommon {

    constructor(RuleProcessorDiamond _processor, ApplicationAppManager _applicationAppManager){
        processor = _processor;
        appManager = _applicationAppManager;
    }

    /**
     * @dev add the rule to the diamond 
     */
    function addTokenMaxSellVolume(uint16 _supplyPercentage, uint16 _period, uint256 _totalSupply) public returns (uint32 _ruleId){
        _ruleId = RuleDataFacet(address(processor)).addTokenMaxSellVolume(
            address(appManager), 
            _supplyPercentage,
            _period,
            _totalSupply,
            uint64(block.timestamp)
        );
        ++totalRules;
    }
}
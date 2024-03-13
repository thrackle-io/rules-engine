// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageTokenMaxTradingVolumeActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageTokenMaxTradingVolumeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxTradingVolume rule. It will manage a variable number of invariant actors
 */
contract RuleStorageTokenMaxTradingVolumeActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageTokenMaxTradingVolumeActor[] actors;

    constructor(RuleStorageTokenMaxTradingVolumeActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addTokenMaxTradingVolume(uint8 _handlerIndex, uint16 _maxPercentage, uint16 _period, uint256 _totalSupply) public endWithStopPrank {
        _maxPercentage = uint16(bound(uint256(_maxPercentage),0,9999));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addTokenMaxTradingVolume(_maxPercentage, _period, uint64(block.timestamp), _totalSupply);
    }
}
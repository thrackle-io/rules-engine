// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageTokenMaxBuySellVolumeActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageTokenMaxBuySellVolumeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxBuySellVolume rule. It will manage a variable number of invariant actors
 */
contract RuleStorageTokenMaxBuySellVolumeActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageTokenMaxBuySellVolumeActor[] actors;

    constructor(RuleStorageTokenMaxBuySellVolumeActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addTokenMaxBuySellVolume(uint8 _handlerIndex, uint16 _supplyPercentage, uint16 _period, uint256 _totalSupply) public endWithStopPrank {
        _supplyPercentage = uint16(bound(uint256(_supplyPercentage),0,9999));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addTokenMaxBuySellVolume(_supplyPercentage, _period, _totalSupply);
    }
}
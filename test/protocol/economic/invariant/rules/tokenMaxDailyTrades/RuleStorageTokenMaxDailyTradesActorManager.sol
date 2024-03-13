// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageTokenMaxDailyTradesActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageTokenMaxDailyTradesActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxDailyTrades rule. It will manage a variable number of invariant actors
 */
contract RuleStorageTokenMaxDailyTradesActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageTokenMaxDailyTradesActor[] actors;

    constructor(RuleStorageTokenMaxDailyTradesActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addTokenMaxDailyTrades(uint8 _handlerIndex,  bytes32 _tag, uint8 _tradesAllowed) public endWithStopPrank {
        if(keccak256(abi.encodePacked(_tag)) == keccak256(abi.encodePacked(bytes32(""))))
            _tag = "tag";
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addTokenMaxDailyTrades(_tag, _tradesAllowed);
    }
}
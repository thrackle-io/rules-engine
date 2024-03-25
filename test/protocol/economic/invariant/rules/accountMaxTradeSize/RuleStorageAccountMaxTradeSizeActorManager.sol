// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMaxTradeSizeActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMaxTradeSizeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxTradeSize rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMaxTradeSizeActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMaxTradeSizeActor[] actors;

    constructor(RuleStorageAccountMaxTradeSizeActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMaxTradeSize(uint8 _handlerIndex,  bytes32 _tag, uint192 _max, uint16 _period) public endWithStopPrank {
        if(keccak256(abi.encodePacked(_tag)) == keccak256(abi.encodePacked(bytes32(""))))
            _tag = "tag";
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMaxTradeSize(_tag, _max, _period);
    }
}
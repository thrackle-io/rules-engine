// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMinMaxTokenBalanceActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMinMaxTokenBalanceActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMinMaxTokenBalance rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMinMaxTokenBalanceActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMinMaxTokenBalanceActor[] actors;

    constructor(RuleStorageAccountMinMaxTokenBalanceActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMinMaxTokenBalance(uint8 _handlerIndex,  bytes32 _tag, uint256 _min, uint256 _max, uint16 period) public endWithStopPrank {
        if(keccak256(abi.encodePacked(_tag)) == keccak256(abi.encodePacked(bytes32(""))))
            _tag = "tag";
        _min = bound(_min, 1, type(uint256).max - 1);
        _max = bound(_max, _min, type(uint256).max);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMinMaxTokenBalance(_tag, _min, _max, period);
    }
}
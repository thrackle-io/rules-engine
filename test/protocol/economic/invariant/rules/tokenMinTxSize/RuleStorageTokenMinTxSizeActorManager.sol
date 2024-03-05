// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageTokenMinTxSizeActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageTokenMinTxSizeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMinTxSize rule. It will manage a variable number of invariant actors
 */
contract RuleStorageTokenMinTxSizeActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageTokenMinTxSizeActor[] actors;
    uint256 public totalMinTx;

    constructor(RuleStorageTokenMinTxSizeActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addTokenMinTxSize(uint8 _handlerIndex, uint256 _minSize) public {
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        _minSize = bound(_minSize,1,type(uint256).max);
        actors[_handlerIndex].addTokenMinTxSize(_minSize);
        ++totalMinTx;
    }
 
}
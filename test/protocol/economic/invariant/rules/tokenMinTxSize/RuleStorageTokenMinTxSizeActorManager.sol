// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageTokenMinTxSizeHandler.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageTokenMinTxSizeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMinTxSize rule. It will manage a variable number of invariant handlers
 */
contract RuleStorageTokenMinTxSizeActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageTokenMinTxSizeHandler[] handlers;
    uint256 public totalMinTx;

    constructor(RuleStorageTokenMinTxSizeHandler[] memory _handlers){
        handlers = _handlers;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addTokenMinTxSize(uint8 _handlerIndex, uint256 _minSize) public {
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, handlers.length-1));
        _minSize = bound(_minSize,1,type(uint256).max);
        handlers[_handlerIndex].addTokenMinTxSize(_minSize);
        ++totalMinTx;
    }
 
}
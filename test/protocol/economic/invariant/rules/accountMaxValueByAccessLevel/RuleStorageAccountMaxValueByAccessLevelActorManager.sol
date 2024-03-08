// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMaxValueByAccessLevelActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMaxValueByAccessLevelActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxValueByAccessLevel rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMaxValueByAccessLevelActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMaxValueByAccessLevelActor[] actors;

    constructor(RuleStorageAccountMaxValueByAccessLevelActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMaxValueByAccessLevel(uint8 _handlerIndex, uint48 _maxValue) public endWithStopPrank {
        _maxValue = uint48(bound(uint256(_maxValue), 0, type(uint48).max - 4));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMaxValueByAccessLevel(_maxValue);
    }
}
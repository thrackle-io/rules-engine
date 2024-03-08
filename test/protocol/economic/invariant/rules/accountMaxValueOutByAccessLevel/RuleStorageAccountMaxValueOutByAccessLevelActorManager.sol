// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMaxValueOutByAccessLevelActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMaxValueOutByAccessLevelActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxValueOutByAccessLevel rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMaxValueOutByAccessLevelActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMaxValueOutByAccessLevelActor[] actors;

    constructor(RuleStorageAccountMaxValueOutByAccessLevelActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMaxValueOutByAccessLevel(uint8 _handlerIndex, uint48 _withdrawalAmount) public endWithStopPrank {
        _withdrawalAmount = uint48(bound(uint256(_withdrawalAmount), 0, type(uint48).max - 4));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMaxValueOutByAccessLevel(_withdrawalAmount);
    }
}
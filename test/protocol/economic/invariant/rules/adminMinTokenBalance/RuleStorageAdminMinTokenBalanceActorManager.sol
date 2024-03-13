// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAdminMinTokenBalanceActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAdminMinTokenBalanceActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AdminMinTokenBalance rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAdminMinTokenBalanceActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAdminMinTokenBalanceActor[] actors;

    constructor(RuleStorageAdminMinTokenBalanceActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAdminMinTokenBalance(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAdminMinTokenBalance(_amount, block.timestamp + 60 days);
    }
}
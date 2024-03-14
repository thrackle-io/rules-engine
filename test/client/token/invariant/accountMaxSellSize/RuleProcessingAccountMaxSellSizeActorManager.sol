// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingAccountMaxSellSizeActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingAccountMaxSellSizeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxSellSize rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingAccountMaxSellSizeActorManager is RuleProcessingInvariantActorManagerCommon {
    address amm;
    address token;
    RuleProcessingAccountMaxSellSizeActor[] actors;

    constructor(RuleProcessingAccountMaxSellSizeActor[] memory _actors, address _amm, address _token) {
        actors = _actors;
        amm = _amm;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkAccountMaxSellSize(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _amount = _amount % (10 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkAccountMaxSellSize(_amount, amm, token);
    }
}

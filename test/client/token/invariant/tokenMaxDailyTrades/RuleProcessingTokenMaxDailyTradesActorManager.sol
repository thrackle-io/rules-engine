// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingTokenMaxDailyTradesActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingTokenMaxDailyTradesActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxDailyTrades rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingTokenMaxDailyTradesActorManager is RuleProcessingInvariantActorManagerCommon {
    address token;
    RuleProcessingTokenMaxDailyTradesActor[] actors;
    uint8 public totalTxs;

    constructor(RuleProcessingTokenMaxDailyTradesActor[] memory _actors, address _token) {
        actors = _actors;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkTokenMaxDailyTrades(uint8 _handlerIndex) public endWithStopPrank {
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkTokenMaxDailyTrades(token, address(actors[(_handlerIndex + 1) % 1]));
        totalTxs++;
    }
}

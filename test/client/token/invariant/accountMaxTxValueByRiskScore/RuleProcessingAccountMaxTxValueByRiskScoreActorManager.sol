// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingAccountMaxTxValueByRiskScoreActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingAccountMaxTxValueByRiskScoreActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxTxValueByRiskScore rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingAccountMaxTxValueByRiskScoreActorManager is RuleProcessingInvariantActorManagerCommon {
    address token;
    RuleProcessingAccountMaxTxValueByRiskScoreActor[] actors;

    constructor(RuleProcessingAccountMaxTxValueByRiskScoreActor[] memory _actors, address _token) {
        actors = _actors;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkAccountMaxTxValueByRiskScore(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _amount = ((_amount % (25 * ATTO)) + 2 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkAccountMaxTxValueByRiskScore(_amount, token);
    }
}

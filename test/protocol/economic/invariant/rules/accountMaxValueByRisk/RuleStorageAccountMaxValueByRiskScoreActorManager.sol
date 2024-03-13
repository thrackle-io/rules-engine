// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMaxValueByRiskScoreActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMaxValueByRiskScoreActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxValueByRiskScore rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMaxValueByRiskScoreActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMaxValueByRiskScoreActor[] actors;

    constructor(RuleStorageAccountMaxValueByRiskScoreActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMaxValueByRiskScore(uint8 _handlerIndex, uint8 _riskScore, uint48 _maxValue) public endWithStopPrank {
        _riskScore = uint8(bound(uint256(_riskScore),0,100));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMaxValueByRiskScore(_riskScore, _maxValue);
    }
}
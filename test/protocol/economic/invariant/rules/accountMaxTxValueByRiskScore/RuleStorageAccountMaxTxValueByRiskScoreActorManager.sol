// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountMaxTxValueByRiskScoreActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountMaxTxValueByRiskScoreActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxTxValueByRiskScore rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountMaxTxValueByRiskScoreActorManager is RuleStorageInvariantActorManagerCommon {

    RuleStorageAccountMaxTxValueByRiskScoreActor[] actors;

    constructor(RuleStorageAccountMaxTxValueByRiskScoreActor[] memory _actors){
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountMaxTxValueByRiskScore(uint8 _handlerIndex, uint48 _maxValue, uint8 _riskScore, uint16 _period) public endWithStopPrank {
        _riskScore = uint8(bound(uint256(_riskScore),0,100));
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length-1));
        actors[_handlerIndex].addAccountMaxTxValueByRiskScore(_maxValue, _riskScore, _period);
    }
}
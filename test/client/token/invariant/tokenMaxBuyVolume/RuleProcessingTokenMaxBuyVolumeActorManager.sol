// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingTokenMaxBuyVolumeActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingTokenMaxBuyVolumeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxBuyVolume rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingTokenMaxBuyVolumeActorManager is RuleProcessingInvariantActorManagerCommon {
    address amm;
    address token;
    RuleProcessingTokenMaxBuyVolumeActor[] actors;
    uint256 public totalBoughtInPeriod;

    constructor(RuleProcessingTokenMaxBuyVolumeActor[] memory _actors, address _amm, address _token) {
        actors = _actors;
        amm = _amm;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkTokenMaxBuyVolume(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _amount = _amount % (10 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkTokenMaxBuyVolume(_amount, amm, token);
        totalBoughtInPeriod += _amount;
    }
}

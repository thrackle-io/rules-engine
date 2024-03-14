// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingTokenMaxSellVolumeActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingTokenMaxSellVolumeActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxSellVolume rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingTokenMaxSellVolumeActorManager is RuleProcessingInvariantActorManagerCommon {
    address amm;
    address token;
    RuleProcessingTokenMaxSellVolumeActor[] actors;
    uint256 public totalSoldInPeriod;

    constructor(RuleProcessingTokenMaxSellVolumeActor[] memory _actors, address _amm, address _token) {
        actors = _actors;
        amm = _amm;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkTokenMaxSellVolume(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _amount = _amount % (10 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkTokenMaxSellVolume(_amount, amm, token);
        totalSoldInPeriod += _amount;
    }
}

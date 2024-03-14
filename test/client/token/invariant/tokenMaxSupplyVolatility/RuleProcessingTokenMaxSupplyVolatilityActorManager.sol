// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingTokenMaxSupplyVolatilityActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingTokenMaxSupplyVolatilityActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the TokenMaxSupplyVolatility rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingTokenMaxSupplyVolatilityActorManager is RuleProcessingInvariantActorManagerCommon {
    address token;
    RuleProcessingTokenMaxSupplyVolatilityActor[] actors;
    uint256 public totalMinted;
    uint256 public totalBurnt;

    constructor(RuleProcessingTokenMaxSupplyVolatilityActor[] memory _actors, address _token) {
        actors = _actors;
        token = _token;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkTokenMaxSupplyVolatility(uint8 _handlerIndex, uint256 _amount, bool _minting) public endWithStopPrank {
        _amount = _amount % (50 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkTokenMaxSupplyVolatility(_amount, token, _minting);
        if (_minting) totalMinted += _amount;
        else totalBurnt += _amount;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleProcessingAccountMaxValueOutByAccessLevelActor.sol";
import "../util/RuleProcessingInvariantActorManagerCommon.sol";

/**
 * @title RuleProcessingAccountMaxValueOutByAccessLevelActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountMaxValueOutByAccessLevel rule. It will manage a variable number of invariant actors
 */
contract RuleProcessingAccountMaxValueOutByAccessLevelActorManager is RuleProcessingInvariantActorManagerCommon {
    address token;
    address amm;
    RuleProcessingAccountMaxValueOutByAccessLevelActor[] actors;

    constructor(RuleProcessingAccountMaxValueOutByAccessLevelActor[] memory _actors, address _token, address _amm) {
        actors = _actors;
        token = _token;
        amm = _amm;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose an actor and other fuzzed variables to test the rule
     */
    function checkAccountMaxValueOutByAccessLevel(uint8 _handlerIndex, uint256 _amount) public endWithStopPrank {
        _amount = ((_amount % (25 * ATTO)) + 2 * ATTO);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].checkAccountMaxValueOutByAccessLevel(_amount, token, amm);
    }
}

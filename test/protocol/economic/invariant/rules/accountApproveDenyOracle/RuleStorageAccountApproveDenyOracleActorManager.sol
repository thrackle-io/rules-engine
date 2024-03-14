// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./RuleStorageAccountApproveDenyOracleActor.sol";
import "../util/RuleStorageInvariantActorManagerCommon.sol";

/**
 * @title RuleStorageAccountApproveDenyOracleActorManager
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the actor manager for the AccountApproveDenyOracle rule. It will manage a variable number of invariant actors
 */
contract RuleStorageAccountApproveDenyOracleActorManager is RuleStorageInvariantActorManagerCommon {
    RuleStorageAccountApproveDenyOracleActor[] actors;

    constructor(RuleStorageAccountApproveDenyOracleActor[] memory _actors) {
        actors = _actors;
    }

    /**
     * @dev uses the fuzzed handler index to "randomly" choose a handler to add the rule
     */
    function addAccountApproveDenyOracle(uint8 _handlerIndex, address _oracleAddress, uint8 _type) public endWithStopPrank {
        _type = uint8(bound(uint256(_type), 0, 1));
        if (_oracleAddress == address(0)) _oracleAddress = address(0xaddafee);
        _handlerIndex = uint8(bound(uint256(_handlerIndex), 0, actors.length - 1));
        actors[_handlerIndex].addAccountApproveDenyOracle(_oracleAddress, _type);
    }
}

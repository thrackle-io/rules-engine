// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleProcessingAccountMaxTxValueByRiskScoreActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxTxValueByRiskScore rule.
 */
contract RuleProcessingAccountMaxTxValueByRiskScoreActor is TestCommonFoundry, RuleProcessingInvariantActorCommon {
    uint256 public totalTransactedInPeriod;

    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxTxValueByRiskScore(uint256 _amount, address _token) public {
        IERC20(_token).transfer(address(0xABBA), _amount);
        totalTransactedInPeriod += _amount;
    }
}

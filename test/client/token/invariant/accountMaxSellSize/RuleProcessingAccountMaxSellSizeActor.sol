// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleProcessingAccountMaxSellSizeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxSellSize rule.
 */
contract RuleProcessingAccountMaxSellSizeActor is TestCommonFoundry, RuleProcessingInvariantActorCommon {
    uint256 public totalSoldInPeriod;

    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxSellSize(uint256 _amount, address amm, address _token) public {
        DummySingleTokenAMM(amm).sell(_amount, _token);
        totalSoldInPeriod += _amount;
    }
}

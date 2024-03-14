// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleProcessingAccountMaxBuySizeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxBuySize rule.
 */
contract RuleProcessingAccountMaxBuySizeActor is TestCommonFoundry, RuleProcessingInvariantActorCommon {
    uint256 public totalBoughtInPeriod;

    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxBuySize(uint256 _amount, address amm, address _token) public {
        DummySingleTokenAMM(amm).buy(_amount, _token);
        totalBoughtInPeriod += _amount;
    }
}

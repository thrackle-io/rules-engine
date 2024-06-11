// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";
import {InvariantUtils} from "test/client/token/invariant/util/InvariantUtils.sol";

/**
 * @title RuleProcessingAccountMaxTxValueByRiskScoreActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxTxValueByRiskScore rule.
 */
contract RuleProcessingAccountMaxTxValueByRiskScoreActor is TestCommonFoundry, RuleProcessingInvariantActorCommon, InvariantUtils {
    uint256 public totalTransactedInPeriod;
    address public recipient;

    constructor(RuleProcessorDiamond _processor, address _recipient) {
        processor = _processor;
        recipient = _recipient;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxTxValueByRiskScore(uint256 _amount, address _token) public {
        address eoa = _convertActorAddressToEOA(address(this));
        vm.startPrank(eoa, eoa);
        IERC20(_token).transfer(recipient, _amount);
        totalTransactedInPeriod += _amount;
    }
}

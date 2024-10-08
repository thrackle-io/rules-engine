// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";
import {InvariantUtils} from "test/client/token/invariant/util/InvariantUtils.sol";

/**
 * @title RuleProcessingAccountMaxValueOutByAccessLevelActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxValueOutByAccessLevel rule.
 */
contract RuleProcessingAccountMaxValueOutByAccessLevelActor is TestCommonFoundry, RuleProcessingInvariantActorCommon, InvariantUtils {
    uint256 public totalOutInPeriod;

    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxValueOutByAccessLevel(uint256 _amount, address _token, address _amm) public {
        address eoa = _convertActorAddressToEOA(address(this));
        vm.startPrank(eoa, eoa);
        DummySingleTokenAMM(_amm).sell(_amount, _token);
        totalOutInPeriod += _amount;
    }
}

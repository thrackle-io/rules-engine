// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";
import {InvariantUtils} from "test/client/token/invariant/util/InvariantUtils.sol";

/**
 * @title RuleProcessingAccountTradeSizeActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the AccountMaxTradeSize rule.
 */
contract RuleProcessingAccountMaxTradeSizeActor is TestCommonFoundry, RuleProcessingInvariantActorCommon, InvariantUtils {
    uint256 public totalSoldInPeriod;
    uint256 public totalBoughtInPeriod;

    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxTradeSize(uint256 _amount, address amm, address _token) public endWithStopPrank {
        address eoa = _convertActorAddressToEOA(address(this));
        vm.startPrank(eoa, eoa);
        DummySingleTokenAMM(amm).sell(_amount, _token);
        totalSoldInPeriod += _amount;
    }

    /**
     * @dev test the rule
     */
    function checkAccountMaxBuySize(uint256 _amount, address amm, address _token) public endWithStopPrank {
        address eoa = _convertActorAddressToEOA(address(this));
        vm.startPrank(eoa, eoa);
        DummySingleTokenAMM(amm).buy(_amount, _token);
        totalBoughtInPeriod += _amount;
    }
}

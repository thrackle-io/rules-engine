// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleProcessingTokenMaxSupplyVolatilityActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the TokenMaxSupplyVolatility rule.
 */
contract RuleProcessingTokenMaxSupplyVolatilityActor is TestCommonFoundry, RuleProcessingInvariantActorCommon {
    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    /**
     * @dev test the rule
     */
    function checkTokenMaxSupplyVolatility(uint256 _amount, address _token, bool minting) public {
        bytes memory res;
        bool success;
        if (minting) {
            switchToAppAdministrator();
            (success, res) = _token.call(abi.encodeWithSignature("mint(address,uint256)", address(this), _amount));
        } else {
            (success, res) = _token.call(abi.encodeWithSignature("burn(uint256)", _amount));
        }
        if (!success) revert();
        (res);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessingInvariantActorCommon} from "test/client/token/invariant/util/RuleProcessingInvariantActorCommon.sol";
import "test/client/token/invariant/util/DummySingleTokenAMM.sol";
import "test/util/TestCommonFoundry.sol";

/**
 * @title RuleProcessingTokenMaxDailyTradesActor
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev This is the rule processing actor for the TokenMaxDailyTrades rule.
 */
contract RuleProcessingTokenMaxDailyTradesActor is TestCommonFoundry, RuleProcessingInvariantActorCommon {
    constructor(RuleProcessorDiamond _processor) {
        processor = _processor;
        testStartsAtTime = block.timestamp;
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external pure returns (bytes4) {
        _operator;
        _from;
        _tokenId;
        _data;
        return this.onERC721Received.selector;
    }

    /**
     * @dev test the rule
     */
    function checkTokenMaxDailyTrades(address _token, address _otherActor) public {
        IERC721(_token).transferFrom(address(this), _otherActor, 0);
    }
}

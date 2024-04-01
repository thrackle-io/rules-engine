// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Rule} from "src/client/token/handler/common/DataStructures.sol";
import {RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import "src/example/application/ApplicationAppManager.sol";

/**
 * @title RuleProcessingInvariantActorCommon
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev Stores common variables/imports used for rule storage invariant handlers
 */
abstract contract RuleProcessingInvariantActorCommon {
    RuleProcessorDiamond processor;
    uint256 public immutable testStartsAtTime;
}

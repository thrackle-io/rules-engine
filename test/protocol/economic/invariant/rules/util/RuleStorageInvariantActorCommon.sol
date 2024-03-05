// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {RuleProcessorDiamond} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamond.sol";
import "src/example/application/ApplicationAppManager.sol";

/**
 * @title RuleStorageInvariantActorCommon
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev Stores common variables/imports used for rule storage invariant handlers
 */
abstract contract RuleStorageInvariantActorCommon {
    uint256 public totalRules;
    RuleProcessorDiamond processor;
    ApplicationAppManager appManager;
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/CommonAddresses.sol";
import "forge-std/Test.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";
import "src/example/application/ApplicationAppManager.sol";
import "test/util/EndWithStopPrank.sol";

/**
 * @title RuleStorageInvariantActorManagerCommon
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev Stores common addresses/imports used for rule storage invariant actor managers
 */
abstract contract RuleStorageInvariantActorManagerCommon is Test, CommonAddresses, EndWithStopPrank{}
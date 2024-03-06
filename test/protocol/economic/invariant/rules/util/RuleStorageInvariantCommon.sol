// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/util/TestCommonFoundry.sol";
import "src/example/application/ApplicationAppManager.sol";
import {RuleDataFacet} from "src/protocol/economic/ruleProcessor/RuleDataFacet.sol";

/**
 * @title RuleStorageInvariantCommon
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55
 * @dev Stores common variables/imports used for rule storage invariant tests
 */
abstract contract RuleStorageInvariantCommon is TestCommonFoundry{
    
    uint32 index;
    uint256 constant maxRuleCount = 2**32;

    function prepRuleStorageInvariant() public {
        switchToSuperAdmin();
        setUpProtocolAndAppManager();
        vm.warp(Blocktime);        
    }
}
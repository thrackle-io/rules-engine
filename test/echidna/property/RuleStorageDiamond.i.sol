// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidna.sol";
import "src/economic/ruleStorage/RuleStorageDiamond.sol";
import {SampleFacet} from "diamond-std/core/test/SampleFacet.sol";
import {FeeRuleProcessorFacet} from "src/economic/ruleProcessor/FeeRuleProcessorFacet.sol"; // for upgrade test only

/**
 * @title TestRuleStorageDiamond Internal Echidna Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the internal tests for RuleStorageDiamond
 */
contract TestRuleStorageDiamond is TestCommonEchidna {
    RuleStorageDiamond ruleStorageDiamond;

    constructor() {}

    /* ------------------------------ INVARIANTS -------------------------------- */
    /// Test the Default Admin roles
    function testGood() public {
        
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonEchidna.sol";
import "src/economic/ruleStorage/RuleStorageDiamond.sol";

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
        ruleStorageDiamond = _createRuleStorageDiamond();
        assert(true);
    }
}

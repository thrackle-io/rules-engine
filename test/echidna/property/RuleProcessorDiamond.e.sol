// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonRuleProcessorDiamond.sol";
import {RuleProcessorDiamond} from "src/economic/ruleProcessor/RuleProcessorDiamond.sol";

/**
 * @title TestRuleProcessorDiamond Internal Echidna Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the internal tests for RuleProcessorDiamond
 */
contract TestRuleProcessorDiamond is TestCommonRuleProcessorDiamond {
    RuleProcessorDiamond ruleProcessorDiamond;

    constructor() {
        ruleProcessorDiamond = _createRuleProcessorDiamond();
        VersionFacet(address(ruleProcessorDiamond)).updateVersion("1,0,0");
    }

    /* ------------------------------ INVARIANTS -------------------------------- */
    /// Test the version
    function echidna_version_notblank() public view returns (bool) {
        return (bytes(VersionFacet(address(ruleProcessorDiamond)).version()).length != 0);
    }
}

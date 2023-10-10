// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "test/echidna/helpers/TestCommonRuleStorageDiamond.sol";
import {RuleStorageDiamond} from "src/economic/ruleStorage/RuleStorageDiamond.sol";

/**
 * @title TestRuleStorageDiamond Internal Echidna Test
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 * @dev This contract performs all the internal tests for RuleStorageDiamond
 */
contract TestRuleStorageDiamond is TestCommonRuleStorageDiamond {
    RuleStorageDiamond ruleStorageDiamond;

    constructor() {
        ruleStorageDiamond = _createRuleStorageDiamond();
        VersionFacet(address(ruleStorageDiamond)).updateVersion("1,0,0");
    }

    /* ------------------------------ INVARIANTS -------------------------------- */
    /// Test the version
    function echidna_version_notblank() public view returns (bool) {
        return (bytes(VersionFacet(address(ruleStorageDiamond)).version()).length != 0);
    }
}

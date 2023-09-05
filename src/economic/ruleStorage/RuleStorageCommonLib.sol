// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Rule Storage Common Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores common functions used throughout the protocol rule data storage
 */
library RuleStorageCommonLib {
    error InvalidTimestamp(uint64 _timestamp);
    error RuleDoesNotExist();

    /**
     * @dev validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid
     */
    function validateTimestamp(uint64 _startTimestamp) internal view {
        if (_startTimestamp == 0 || _startTimestamp > (block.timestamp + (52 * 1 weeks))) {
            revert InvalidTimestamp(_startTimestamp);
        }
    }

    /**
     * @dev generic function to check the existence of a rule
     * @param _ruleIndex index of the current rule
     * @param _ruleTotal total rules in existence for the rule type
     * @return _exists true if it exists, false if not
     */
    function checkRuleExistence(uint32 _ruleIndex, uint32 _ruleTotal) internal pure returns (bool) {
        if (_ruleTotal <= _ruleIndex) {
            revert RuleDoesNotExist();
        } else {
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Rule Storage Common Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores common functions used throughout the protocol rule data storage
 */
library RuleStorageCommonLib {
    error InvalidTimestamp(uint64 _timestamp);

    /**
     * @dev validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid
     */
    function validateTimestamp(uint64 _startTimestamp) internal view {
        if (_startTimestamp == 0 || _startTimestamp > (block.timestamp + (52 * 1 weeks))) {
            revert InvalidTimestamp(_startTimestamp);
        }
    }
}

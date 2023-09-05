// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Rule Processor Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores common functions used throughout the protocol rule checks
 */
library RuleProcessorCommonLib {
    error InvalidTimestamp(uint64 _timestamp);

    /**
     * @dev Determine is the rule is active. This is only for use in rules that are stored with activation timestamps.
     */
    function isRuleActive(uint64 _startTs) internal view returns (bool) {
        if (_startTs <= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev determine if transaction should be accumulated with the previous or it is a new period which requires reset of accumulators
     * @param _startTimestamp the timestamp the rule was enabled
     * @param _period amount of hours in the rule period
     * @param _lastTransferTs the last transfer timestamp
     * @return _withinPeriod returns true if current block time is within the rules period, else false.
     */
    function isWithinPeriod(uint64 _startTimestamp, uint32 _period, uint64 _lastTransferTs) internal view returns (bool) {
        /// if no transactions have happened in the past, it's new
        if (_lastTransferTs == 0) {
            return false;
        }
        // current timestamp subtracted by the remainder of seconds since the rule was active divided by period in seconds
        uint256 currentPeriodStart = block.timestamp - ((block.timestamp - _startTimestamp) % (_period * 1 hours));
        if (_lastTransferTs >= currentPeriodStart) {
            return true;
        } else {
            return false;
        }
    }
}

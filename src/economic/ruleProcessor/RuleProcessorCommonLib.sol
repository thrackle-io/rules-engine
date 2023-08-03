// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/**
 * @title Rule Processor Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores common functions used throughout the protocol rule checks
 */
library RuleProcessorCommonLib {
    error InvalidTimestamp(uint64 _timestamp);

    /**
     * @dev calculate the start time based upon the starting hour sent in. Essentially, get the start timestamp for the last time the clock was at the hour indicated.
     * @param _startingHour the starting hour from the rule
     * @return startingTimestamp the period starting timestamp
     */
    function calculateStartDate(uint8 _startingHour) internal view returns (uint64) {
        return uint64(block.timestamp - (block.timestamp % (1 days)) - 1 days + uint256(_startingHour) * (1 hours));
    }

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
        /// 1) Get the number of periods since the rule was enabled
        /// 2) Multiply the startTimestamp by the amount of hours in all the blocks since the rule was enabled. This gives the current periods startTimestamp
        uint256 secondsSinceStart = (block.timestamp - _startTimestamp);
        uint256 currentPeriodStart;
        // if the amount of time since rule activation is less than the period, it's in the first block so use the rule start timestamp
        if (secondsSinceStart < (_period * 1 hours)) {
            currentPeriodStart = _startTimestamp;
        } else {
            currentPeriodStart = _startTimestamp + (_period * ((secondsSinceStart / (_period * 1 hours)) * 1 hours));
        }
        if (_lastTransferTs >= currentPeriodStart) {
            return true;
        } else {
            return false;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Rule Processor Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev stores common functions used throughout the protocol rule checks
 */
library RuleProcessorCommonLib {
    error InvalidTimestamp(uint64 _timestamp);
    error MaxTagLimitReached();
    error RuleDoesNotExist();
    error TagListMustBeSingleBlankOrValueList();
    uint8 constant MAX_TAGS = 10;

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

    /**
     * @dev determine if the max tag number is reached
     * @param _tags tags associated with the rule
     */
    function checkMaxTags(bytes32[] memory _tags) internal pure {
        if (_tags.length > MAX_TAGS) revert MaxTagLimitReached();    
    }

    /**
     * @dev determine if the rule applies to all users
     * @param _tags the timestamp the rule was enabled
     * @param _isAll true if applies to all users
     */
    function isAllUsers(bytes32[] memory _tags) internal pure returns(bool _isAll){
        if (_tags.length == 1 && _tags[0] == bytes32("")) return true;
    }

    function retrieveRiskScoreMaxSize(uint8 _riskScore, uint8[] memory _riskLevels, uint48[] memory _maxSizes) internal pure returns(uint256){
        uint256 maxSize;
        for (uint256 i = 1; i < _riskLevels.length;) {
            if (_riskScore < _riskLevels[i]) {
                maxSize = uint(_maxSizes[i - 1]) * (10 ** 18); 
                return maxSize;
            } 
            unchecked {
                ++i;
            }
        }
        if (_riskScore >= _riskLevels[_riskLevels.length - 1]) {
            maxSize = uint(_maxSizes[_maxSizes.length - 1]) * (10 ** 18);
        }
        return maxSize; 
    }

     /**
     * @dev validate tags to ensure only a blank or valid tags were submitted.
     * @param _accountTags the timestamp the rule was enabled
     * @return _valid returns true if tag entry is valid
     */
    function areTagsValid(bytes32[] calldata _accountTags) internal pure returns (bool) {
        // If more than one tag, none can be blank.
        if (_accountTags.length > 1){
            for (uint256 i; i < _accountTags.length; ) {
                if (_accountTags[i] == bytes32("")) revert TagListMustBeSingleBlankOrValueList();
                unchecked {
                    ++i;
                }
            }
        }
        return true;
    } 
}

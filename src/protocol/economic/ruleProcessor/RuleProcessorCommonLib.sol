// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Rule Processor Library
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Stores common functions used throughout the protocol rule checks
 */
library RuleProcessorCommonLib {
    error InvalidTimestamp(uint64 _timestamp);
    error MaxTagLimitReached();
    error RuleDoesNotExist();
    error TagListMustBeSingleBlankOrValueList();
    uint8 constant MAX_TAGS = 10;

    /**
     * @dev Validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid
     */
    function validateTimestamp(uint64 _startTime) internal view {
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if (_startTime == 0 || _startTime > (block.timestamp + (52 * 1 weeks))) {
            revert InvalidTimestamp(_startTime);
        }
    }

    /**
     * @dev Generic function to check the existence of a rule
     * @param _ruleIndex index of the current rule
     * @param _ruleTotal total rules in existence for the rule type
     */
    function checkRuleExistence(uint32 _ruleIndex, uint32 _ruleTotal) internal pure {
        if (_ruleTotal <= _ruleIndex) {
            revert RuleDoesNotExist();
        }
    }

    /**
     * @dev Determine is the rule is active. This is only for use in rules that are stored with activation timestamps.
     */
    function isRuleActive(uint64 _startTime) internal view returns (bool) {
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        if (_startTime <= block.timestamp) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Determine if transaction should be accumulated with the previous or it is a new period which requires reset of accumulators
     * @param _startTime the timestamp the rule was enabled
     * @param _period amount of hours in the rule period
     * @param _lastTransferTime the last transfer timestamp
     * @return _withinPeriod returns true if current block time is within the rules period, else false.
     */
    //slither-disable-next-line weak-prng
    function isWithinPeriod(uint64 _startTime, uint32 _period, uint64 _lastTransferTime) internal view returns (bool) {
        /// if no transactions have happened in the past, it's new
        if (_lastTransferTime == 0) {
            return false;
        }
        /// current timestamp subtracted by the remainder of seconds since the rule was active divided by period in seconds
        // We are not using timestamps to generate a PRNG. and our period evaluation is adherent to the 15 second rule:
        // If the scale of your time-dependent event can vary by 15 seconds and maintain integrity, it is safe to use a block.timestamp
        // slither-disable-next-line timestamp
        uint256 currentPeriodStart = block.timestamp - ((block.timestamp - _startTime) % (_period * 1 hours));
        // slither-disable-next-line timestamp
        if (_lastTransferTime >= currentPeriodStart) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Determine if the max tag number is reached
     * @param _tags tags associated with the rule
     */
    function checkMaxTags(bytes32[] memory _tags) internal pure {
        if (_tags.length > MAX_TAGS) revert MaxTagLimitReached();
    }

    /**
     * @dev Determine if the rule applies to all users
     * @param _tags the timestamp the rule was enabled
     * @param _isAll true if applies to all users
     */
    function isApplicableToAllUsers(bytes32[] memory _tags) internal pure returns (bool _isAll) {
        if (_tags.length == 1 && _tags[0] == bytes32("")) return true;
    }

    /**
     * @dev Retrieve the max size of the risk rule for the risk score provided.
     * @param _riskScore risk score of the account
     * @param _riskScores array of risk scores for the rule
     * @param _maxValues array of max values from the rule
     * @return maxValue uint256 max value for the risk score for rule validation
     */
    function retrieveRiskScoreMaxSize(uint8 _riskScore, uint8[] memory _riskScores, uint48[] memory _maxValues) internal pure returns (uint256) {
        for (uint256 i = 1; i < _riskScores.length; ++i) {
            if (_riskScore < _riskScores[i]) {
                return uint(_maxValues[i - 1]) * (10 ** 18);
            }
        }
        if (_riskScore >= _riskScores[_riskScores.length - 1]) {
            return uint(_maxValues[_maxValues.length - 1]) * (10 ** 18);
        }
        return 0;
    }

    /**
     * @dev validate tags to ensure only a blank or valid tags were submitted.
     * @param _accountTags the timestamp the rule was enabled
     */
    function validateTags(bytes32[] calldata _accountTags) internal pure {
        /// If more than one tag, none can be blank.
        if (_accountTags.length > 1) {
            for (uint256 i; i < _accountTags.length; ++i) {
                if (_accountTags[i] == bytes32("")) revert TagListMustBeSingleBlankOrValueList();
            }
        }
    }

    /**
     * @dev Perform the common volatility function
     * @param _volumeTotalForPeriod total volume within the period
     * @param _volumeMultiplier volume muliplier
     * @param _totalSupply token total supply
     */
    function calculateVolatility(int256 _volumeTotalForPeriod, uint256 _volumeMultiplier, uint256 _totalSupply) internal pure returns (int256) {
        return ((_volumeTotalForPeriod * int(_volumeMultiplier)) / int(_totalSupply));
    }
}

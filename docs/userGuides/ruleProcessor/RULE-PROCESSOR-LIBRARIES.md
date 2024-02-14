# Protocol Rule Processor Diamond Libraries  

## Purpose

The Rule Processor Diamond Libraries store functions used by the diamond structure. The Rule Processor Diamond Lib contract holds the function to store rules when added to the protocol, the diamond cut function for upgrading the diamond and adding or removing functions from facets. The Rule Processor Common Lib holds functions used throughout the facets to validate rules and parameters passed to the rule check functions. 

Using these singular library contracts prevents data storage collision as functionality is added or removed from the protocol. Facets should always be removed through the diamond cut function in Rule Processor Diamond Lib.This prevents a situation where a facet may have been self destructed but the function selectors are still stored in the diamond. This could result in a "false posistive" successful transaction when attempting to add a rule and the rule is never added to the diamond. Protocol Rule Processor facets are never written with self destruct functionality. 


## Functions 

### Rule Processor Diamond Lib Functions 

The Rule Processor Diamond Lib follows ERC 2535 standards for storage and functions. 
#### *[ERC 2535: Diamond Proxies](https://eips.ethereum.org/EIPS/eip-2535)*

### Rule Processor Common Lib Functions  

The Rule Processor Common Lib holds the following validation functions: 

Timestamp validation: 

```c
/**
* @dev Validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid
*/
function validateTimestamp(uint64 _startTime) internal view {
    if (_startTime == 0 || _startTime > (block.timestamp + (52 * 1 weeks))) {
        revert InvalidTimestamp(_startTime);
    }
}
```

Rule existence validation: 

```c
/**
* @dev Generic function to check the existence of a rule
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
```

Is the rule active validation: 

```c
/**
* @dev Determine is the rule is active. This is only for use in rules that are stored with activation timestamps.
*/
function isRuleActive(uint64 _startTime) internal view returns (bool) {
    if (_startTime <= block.timestamp) {
        return true;
    } else {
        return false;
    }
}
```

Is the rule within the rule period validation: 

```c
/**
* @dev Determine if transaction should be accumulated with the previous or it is a new period which requires reset of accumulators
* @param _startTime the timestamp the rule was enabled
* @param _period amount of hours in the rule period
* @param _lastTransferTs the last transfer timestamp
* @return _withinPeriod returns true if current block time is within the rules period, else false.
*/
function isWithinPeriod(uint64 _startTime, uint32 _period, uint64 _lastTransferTs) internal view returns (bool) {
    /// if no transactions have happened in the past, it's new
    if (_lastTransferTs == 0) {
        return false;
    }
    /// current timestamp subtracted by the remainder of seconds since the rule was active divided by period in seconds
    uint256 currentPeriodStart = block.timestamp - ((block.timestamp - _startTime) % (_period * 1 hours));
    if (_lastTransferTs >= currentPeriodStart) {
        return true;
    } else {
        return false;
    }
}
```

Max tag limit validation: 

```c
/**
* @dev Determine if the max tag number is reached
* @param _tags tags associated with the rule
*/
function checkMaxTags(bytes32[] memory _tags) internal pure {
    if (_tags.length > MAX_TAGS) revert MaxTagLimitReached();    
}
```

Is the rule applicable to all users validation: 

```c
/**
* @dev Determine if the rule applies to all users
* @param _tags the timestamp the rule was enabled
* @param _isAll true if applies to all users
*/
function isApplicableToAllUsers(bytes32[] memory _tags) internal pure returns(bool _isAll){
    if (_tags.length == 1 && _tags[0] == bytes32("")) return true;
}
```

Retrieve the max size for the risk score provided: 

```c
/**
* @dev Retrieve the max size of the risk rule for the risk score provided. 
* @param _riskScore risk score of the account 
* @param _riskScores array of risk scores for the rule 
* @param _maxValues array of max values from the rule 
* @return maxValue uint256 max value for the risk score for rule validation
*/
function retrieveRiskScoreMaxSize(uint8 _riskScore, uint8[] memory _riskScores, uint48[] memory _maxValues) internal pure returns(uint256){
    uint256 maxValue;
    for (uint256 i = 1; i < _riskScores.length;) {
        if (_riskScore < _riskScores[i]) {
            maxValue = uint(_maxValues[i - 1]) * (10 ** 18); 
            return maxValue;
        } 
        unchecked {
            ++i;
        }
    }
    if (_riskScore >= _riskScores[_riskScores.length - 1]) {
        maxValue = uint(_maxValues[_maxValues.length - 1]) * (10 ** 18);
    }
    return maxValue; 
}
```

Tag validation: 

```c
/**
* @dev validate tags to ensure only a blank or valid tags were submitted.
* @param _accountTags the timestamp the rule was enabled
* @return _valid returns true if tag entry is valid
*/
function areTagsValid(bytes32[] calldata _accountTags) internal pure returns (bool) {
    /// If more than one tag, none can be blank.
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
```

These validation functions are utilized throughout the diamond facets in order to validate rules when added or checked via the check all rules function.  

## Data Structures 

The Rule Processor Diamond Lib stores the rules, the facet addresses and their function selectors. 

The facet addresses and selectors are stored in the struct: 

```c
struct FacetAddressAndSelectorPosition {
    address facetAddress;
    uint16 selectorPosition;
}
```

Those structs are then stored in a mapping: 

```c
struct RuleProcessorDiamondStorage {
    /// function selector => facet address and selector position in selectors array
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```

Rules are stored in the struct: 

```c
struct RuleDataStorage {
    address rules;
}
```

## Events 

- **event DiamondCut(_diamondCut, init, data)**: 
    - Emitted when: the Rule Processor Diamond has been upgraded.
    - Parameters:
        - _diamondCut: Facets Array
        - init: Address of the contract or facet to execute "data"
        - data: A function call, including function selector and arguments calldata is executed with delegatecall on "init"

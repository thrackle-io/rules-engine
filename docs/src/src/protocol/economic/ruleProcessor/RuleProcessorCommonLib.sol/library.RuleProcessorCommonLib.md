# RuleProcessorCommonLib
[Git Source](https://github.com/thrackle-io/rules-engine/blob/54db83a2c72adaf3bc2196e69cb3cf728347d98b/src/protocol/economic/ruleProcessor/RuleProcessorCommonLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*Stores common functions used throughout the protocol rule checks*


## State Variables
### MAX_TAGS

```solidity
uint8 constant MAX_TAGS = 10;
```


## Functions
### validateTimestamp

*Validate a user entered timestamp to ensure that it is valid. Validity depends on it being greater than UNIX epoch and not more than 1 year into the future. It reverts with custom error if invalid*


```solidity
function validateTimestamp(uint64 _startTime) internal view;
```

### checkRuleExistence

*Generic function to check the existence of a rule*


```solidity
function checkRuleExistence(uint32 _ruleIndex, uint32 _ruleTotal) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleIndex`|`uint32`|index of the current rule|
|`_ruleTotal`|`uint32`|total rules in existence for the rule type|


### isRuleActive

*Determine is the rule is active. This is only for use in rules that are stored with activation timestamps.*


```solidity
function isRuleActive(uint64 _startTime) internal view returns (bool);
```

### isWithinPeriod

*Determine if transaction should be accumulated with the previous or it is a new period which requires reset of accumulators*


```solidity
function isWithinPeriod(uint64 _startTime, uint32 _period, uint64 _lastTransferTime) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_startTime`|`uint64`|the timestamp the rule was enabled|
|`_period`|`uint32`|amount of hours in the rule period|
|`_lastTransferTime`|`uint64`|the last transfer timestamp|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_withinPeriod returns true if current block time is within the rules period, else false.|


### checkMaxTags

if no transactions have happened in the past, it's new
current timestamp subtracted by the remainder of seconds since the rule was active divided by period in seconds

*Determine if the max tag number is reached*


```solidity
function checkMaxTags(bytes32[] memory _tags) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tags`|`bytes32[]`|tags associated with the rule|


### isApplicableToAllUsers

*Determine if the rule applies to all users*


```solidity
function isApplicableToAllUsers(bytes32[] memory _tags) internal pure returns (bool _isAll);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tags`|`bytes32[]`|the timestamp the rule was enabled|


### retrieveRiskScoreMaxSize

*Retrieve the max size of the risk rule for the risk score provided.*


```solidity
function retrieveRiskScoreMaxSize(uint8 _riskScore, uint8[] memory _riskScores, uint48[] memory _maxValues)
    internal
    pure
    returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_riskScore`|`uint8`|risk score of the account|
|`_riskScores`|`uint8[]`|array of risk scores for the rule|
|`_maxValues`|`uint48[]`|array of max values from the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|maxValue uint256 max value for the risk score for rule validation|


### validateTags

*validate tags to ensure only a blank or valid tags were submitted.*


```solidity
function validateTags(bytes32[] calldata _accountTags) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTags`|`bytes32[]`|the timestamp the rule was enabled|


### calculateVolatility

If more than one tag, none can be blank.

*Perform the common volatility function*


```solidity
function calculateVolatility(int256 _volumeTotalForPeriod, uint256 _volumeMultiplier, uint256 _totalSupply)
    internal
    pure
    returns (int256 _volatility);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_volumeTotalForPeriod`|`int256`|total volume within the period|
|`_volumeMultiplier`|`uint256`|volume muliplier|
|`_totalSupply`|`uint256`|token total supply|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_volatility`|`int256`|calculated volatility|


## Errors
### InvalidTimestamp

```solidity
error InvalidTimestamp(uint64 _timestamp);
```

### MaxTagLimitReached

```solidity
error MaxTagLimitReached();
```

### RuleDoesNotExist

```solidity
error RuleDoesNotExist();
```

### TagListMustBeSingleBlankOrValueList

```solidity
error TagListMustBeSingleBlankOrValueList();
```


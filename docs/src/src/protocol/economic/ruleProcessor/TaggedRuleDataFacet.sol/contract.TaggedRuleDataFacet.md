# TaggedRuleDataFacet
[Git Source](https://github.com/thrackle-io/tron/blob/93fd74340f7444498e4353b2c758c1107038174a/src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/common/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [ITagInputErrors](/src/common/IErrors.sol/interface.ITagInputErrors.md), [ITagRuleInputErrors](/src/common/IErrors.sol/interface.ITagRuleInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.

*setters and getters for Tagged token specific rules*


## Functions
### addAccountMaxTradeSize

Account Max Trade Size **********************

*Function add an Account Max Trade Size rule*

*Function has RuleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addAccountMaxTradeSize(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint240[] calldata _maxSizes,
    uint16[] calldata _periods,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_maxSizes`|`uint240[]`|Allowed total purchase limits|
|`_periods`|`uint16[]`|Hours purhchases allowed|
|`_startTime`|`uint64`|timestamp period to start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addAccountMaxTradeSize

since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.

*Internal Function to avoid stack too deep error*


```solidity
function _addAccountMaxTradeSize(
    bytes32[] calldata _accountTypes,
    uint240[] calldata _maxSizes,
    uint16[] calldata _periods,
    uint64 _startTime
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_maxSizes`|`uint240[]`|Allowed total buy sizes|
|`_periods`|`uint16[]`|Amount of hours that define the periods|
|`_startTime`|`uint64`|timestamp for first period to start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addAccountMinMaxTokenBalance

Account Min Max Token Balance **********************

*Function adds Account Min Max Token Balance Rule*


```solidity
function addAccountMinMaxTokenBalance(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _min,
    uint256[] calldata _max,
    uint16[] calldata _periods,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|App Manager Address|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_min`|`uint256[]`|Minimum Balance allowed for tagged accounts|
|`_max`|`uint256[]`|Maximum Balance allowed for tagged accounts|
|`_periods`|`uint16[]`|Amount of hours that define the periods|
|`_startTime`|`uint64`|Timestamp that the check should start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_addAccountMinMaxTokenBalance which returns location of rule in array|


### _addAccountMinMaxTokenBalance

since all the arrays must have matching lengths, it is only necessary to check for one of them being empty.

*Internal Function to avoid stack too deep error*


```solidity
function _addAccountMinMaxTokenBalance(
    bytes32[] calldata _accountTypes,
    uint256[] calldata _min,
    uint256[] calldata _max,
    uint16[] calldata _periods,
    uint64 _startTime
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_min`|`uint256[]`|Minimum Balance allowed for tagged accounts|
|`_max`|`uint256[]`|Maximum Balance allowed for tagged accounts|
|`_periods`|`uint16[]`|Amount of hours that define the periods|
|`_startTime`|`uint64`|Timestamp that the check should start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addTokenMaxDailyTrades

Token Max Daily Trades **********

*Function adds Token Max Daily Trades Rule*


```solidity
function addTokenMaxDailyTrades(
    address _appManagerAddr,
    bytes32[] calldata _nftTags,
    uint8[] calldata _tradesAllowed,
    uint64 _startTime
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|App Manager Address|
|`_nftTags`|`bytes32[]`|Tags of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTime`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_nftTransferCounterRules which returns location of rule in array|


### _addTokenMaxDailyTrades

*Internal Function to avoid stack too deep error*


```solidity
function _addTokenMaxDailyTrades(bytes32[] calldata _nftTags, uint8[] calldata _tradesAllowed, uint64 _startTime)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nftTags`|`bytes32[]`|Tags of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTime`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|



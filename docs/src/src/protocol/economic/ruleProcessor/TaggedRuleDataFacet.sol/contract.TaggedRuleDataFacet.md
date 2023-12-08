# TaggedRuleDataFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/TaggedRuleDataFacet.sol)

**Inherits:**
Context, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IEconomicEvents](/src/common/IEvents.sol/interface.IEconomicEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRiskInputErrors](/src/common/IErrors.sol/interface.IRiskInputErrors.md), [ITagInputErrors](/src/common/IErrors.sol/interface.ITagInputErrors.md), [ITagRuleInputErrors](/src/common/IErrors.sol/interface.ITagRuleInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.

*setters and getters for Tagged token specific rules*


## Functions
### addPurchaseRule

Note that no update method is implemented. Since reutilization of
rules is encouraged, it is preferred to add an extra rule to the
set instead of modifying an existing one.
Purchase Getters/Setters **********************

*Function add a Token Purchase Percentage rule*

*Function has RuleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addPurchaseRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _purchaseAmounts,
    uint16[] calldata _purchasePeriods,
    uint64[] calldata _startTimes
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_purchaseAmounts`|`uint256[]`|Allowed total purchase limits|
|`_purchasePeriods`|`uint16[]`|Hours purhchases allowed|
|`_startTimes`|`uint64[]`|timestamp period to start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addPurchaseRule

*internal Function to avoid stack too deep error*


```solidity
function _addPurchaseRule(
    bytes32[] calldata _accountTypes,
    uint256[] calldata _purchaseAmounts,
    uint16[] calldata _purchasePeriods,
    uint64[] calldata _startTimes
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_purchaseAmounts`|`uint256[]`|Allowed total purchase limits|
|`_purchasePeriods`|`uint16[]`|Hours purhchases allowed|
|`_startTimes`|`uint64[]`|timestamps for first period to start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addSellRule

Sell Getters/Setters *********************

*Function to add set of sell rules*


```solidity
function addSellRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint192[] calldata _sellAmounts,
    uint16[] calldata _sellPeriod,
    uint64[] calldata _startTimes
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_sellAmounts`|`uint192[]`|Allowed total sell limits|
|`_sellPeriod`|`uint16[]`|Period for sales|
|`_startTimes`|`uint64[]`|rule starts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addSellRule

*internal Function to avoid stack too deep error*


```solidity
function _addSellRule(
    bytes32[] calldata _accountTypes,
    uint192[] calldata _sellAmounts,
    uint16[] calldata _sellPeriod,
    uint64[] calldata _startTimes
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_sellAmounts`|`uint192[]`|Allowed total sell limits|
|`_sellPeriod`|`uint16[]`|Period for sales|
|`_startTimes`|`uint64[]`|rule starts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addMinMaxBalanceRule

Balance Limit Getters/Setters **********************

*Function adds Balance Limit Rule*


```solidity
function addMinMaxBalanceRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _minimum,
    uint256[] calldata _maximum
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|App Manager Address|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_minimum`|`uint256[]`|Minimum Balance allowed for tagged accounts|
|`_maximum`|`uint256[]`|Maximum Balance allowed for tagged accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_addMinMaxBalanceRule which returns location of rule in array|


### _addMinMaxBalanceRule

*internal Function to avoid stack too deep error*


```solidity
function _addMinMaxBalanceRule(
    bytes32[] calldata _accountTypes,
    uint256[] calldata _minimum,
    uint256[] calldata _maximum
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_minimum`|`uint256[]`|Minimum Balance allowed for tagged accounts|
|`_maximum`|`uint256[]`|Maximum Balance allowed for tagged accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addWithdrawalRule

Account Withdrawal Getters/Setters **********

*Function adds Withdrawal Rule*


```solidity
function addWithdrawalRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _amount,
    uint256[] calldata _releaseDate
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_amount`|`uint256[]`|Transaction total|
|`_releaseDate`|`uint256[]`|Date of release|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_addWithdrawalRule which returns position of new rule in array|


### _addWithdrawalRule

*Internal function to avoid stack-too-deep error*


```solidity
function _addWithdrawalRule(
    bytes32[] calldata _accountTypes,
    uint256[] calldata _amount,
    uint256[] calldata _releaseDate
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_amount`|`uint256[]`|Transaction total|
|`_releaseDate`|`uint256[]`|Date of release|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addAdminWithdrawalRule

Admin Account Withdrawal Getters/Setters **********

*Function adds Withdrawal Rule for admins*


```solidity
function addAdminWithdrawalRule(address _appManagerAddr, uint256 _amount, uint256 _releaseDate)
    external
    ruleAdministratorOnly(_appManagerAddr)
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_amount`|`uint256`|Transaction total|
|`_releaseDate`|`uint256`|Date of release|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminWithdrawalRulesPerToken position of new rule in array|


### addTransactionLimitByRiskScore

_txnLimits size must be equal to _riskLevel The positioning of the arrays is ascendant in terms of risk levels,
and descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)

*Function to add new TransactionLimitByRiskScore Rules*

*Function has RuleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addTransactionLimitByRiskScore(
    address _appManagerAddr,
    uint8[] calldata _riskScores,
    uint48[] calldata _txnLimits
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_riskScores`|`uint8[]`|User Risk Level Array which defines the limits between ranges. The levels are inclusive as ceilings.|
|`_txnLimits`|`uint48[]`|Transaction Limit in whole USD for each score range. It corresponds to the _riskScores array and is +1 longer than _riskScores. A value of 1000 in this arrays will be interpreted as $1000.00 USD.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### _addTransactionLimitByRiskScore

*internal Function to avoid stack too deep error*


```solidity
function _addTransactionLimitByRiskScore(uint8[] calldata _riskScores, uint48[] calldata _txnLimits)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_riskScores`|`uint8[]`|Account Risk Level|
|`_txnLimits`|`uint48[]`|Transaction Limit for each Score. It corresponds to the _riskScores array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### addMinBalByDateRule

Minimum Account Balance By Date Getters/Setters **********************

*Function add a Minimum Account Balance By Date rule*

*Function has RuleAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addMinBalByDateRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTags,
    uint256[] calldata _holdAmounts,
    uint16[] calldata _holdPeriods,
    uint64[] calldata _startTimestamps
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTags`|`bytes32[]`|Types of Accounts|
|`_holdAmounts`|`uint256[]`|Allowed total purchase limits|
|`_holdPeriods`|`uint16[]`|Hours purchases allowed|
|`_startTimestamps`|`uint64[]`|Timestamp that the check should start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId of new rule in array|


### _addMinBalByDateRule

*internal Function to avoid stack too deep error*


```solidity
function _addMinBalByDateRule(
    bytes32[] calldata _accountTags,
    uint256[] calldata _holdAmounts,
    uint16[] calldata _holdPeriods,
    uint64[] memory _startTimestamps
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTags`|`bytes32[]`|Types of Accounts|
|`_holdAmounts`|`uint256[]`|Allowed total purchase limits|
|`_holdPeriods`|`uint16[]`|Hours purhchases allowed|
|`_startTimestamps`|`uint64[]`|Timestamp that the check should start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId of new rule in array|


### addNFTTransferCounterRule

if defaults sent for timestamp, start them with current block time
NFT Getters/Setters **********

*Function adds Balance Limit Rule*


```solidity
function addNFTTransferCounterRule(
    address _appManagerAddr,
    bytes32[] calldata _nftTypes,
    uint8[] calldata _tradesAllowed,
    uint64 _startTs
) external ruleAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|App Manager Address|
|`_nftTypes`|`bytes32[]`|Types of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTs`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|_nftTransferCounterRules which returns location of rule in array|


### _addNFTTransferCounterRule

*internal Function to avoid stack too deep error*


```solidity
function _addNFTTransferCounterRule(bytes32[] calldata _nftTypes, uint8[] calldata _tradesAllowed, uint64 _startTs)
    internal
    returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nftTypes`|`bytes32[]`|Types of NFTs|
|`_tradesAllowed`|`uint8[]`|Maximum trades allowed within 24 hours|
|`_startTs`|`uint64`|starting timestamp for the rule|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|



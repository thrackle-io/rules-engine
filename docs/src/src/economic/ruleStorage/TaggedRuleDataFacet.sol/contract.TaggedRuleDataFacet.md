# TaggedRuleDataFacet
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/economic/ruleStorage/TaggedRuleDataFacet.sol)

**Inherits:**
Context, [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [IEconomicEvents](/src/interfaces/IEvents.sol/interface.IEconomicEvents.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

This contract sets and gets the Tagged Rules for the protocol. Rules will be applied via General Tags to accounts.

*setters and getters for Tagged rules*


## Functions
### addPurchaseRule

Purchase Getters/Setters **********************

*Function add a Token Purchase Percentage rule*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addPurchaseRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _purchaseAmounts,
    uint32[] calldata _purchasePeriods,
    uint32[] calldata _startTimes
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_purchaseAmounts`|`uint256[]`|Allowed total purchase limits|
|`_purchasePeriods`|`uint32[]`|Hours purhchases allowed|
|`_startTimes`|`uint32[]`|Hours of the day in utc for first period to start|

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
    uint32[] calldata _purchasePeriods,
    uint32[] calldata _startTimes
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_purchaseAmounts`|`uint256[]`|Allowed total purchase limits|
|`_purchasePeriods`|`uint32[]`|Hours purhchases allowed|
|`_startTimes`|`uint32[]`|Hours of the day in utc for first period to start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getPurchaseRule

Low Rank Approximation

*Function get the purchase rule in the rule set that belongs to an account type*


```solidity
function getPurchaseRule(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.PurchaseRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.PurchaseRule`|PurchaseRule rule at index position|


### getTotalPurchaseRule

*Function to get total purchase rules*


```solidity
function getTotalPurchaseRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addSellRule

Sell Getters/Setters *********************

*Function to add set of sell rules*


```solidity
function addSellRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint192[] calldata _sellAmounts,
    uint32[] calldata _sellPeriod,
    uint32[] calldata _startTimes
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_sellAmounts`|`uint192[]`|Allowed total sell limits|
|`_sellPeriod`|`uint32[]`|Period for sales|
|`_startTimes`|`uint32[]`||

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
    uint32[] calldata _sellPeriod,
    uint32[] calldata _startTimes
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTypes`|`bytes32[]`|Types of Accounts|
|`_sellAmounts`|`uint192[]`|Allowed total sell limits|
|`_sellPeriod`|`uint32[]`|Period for sales|
|`_startTimes`|`uint32[]`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|position of new rule in array|


### getSellRuleByIndex

Low Rank Approximation

*Function to get Sell rule at index*


```solidity
function getSellRuleByIndex(uint32 _index, bytes32 _accountType) external view returns (TaggedRules.SellRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in array|
|`_accountType`|`bytes32`|Types of Accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.SellRule`|SellRule at position in array|


### getTotalSellRule

*Function to get total Sell rules*


```solidity
function getTotalSellRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addBalanceLimitRules

Balance Limit Getters/Setters **********************

*Function adds Balance Limit Rule*


```solidity
function addBalanceLimitRules(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _minimum,
    uint256[] calldata _maximum
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
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
|`<none>`|`uint32`|_addBalanceLimitRules which returns location of rule in array|


### _addBalanceLimitRules

*internal Function to avoid stack too deep error*


```solidity
function _addBalanceLimitRules(
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


### getBalanceLimitRule

*Function get the purchase rule in the rule set that belongs to an account type*


```solidity
function getBalanceLimitRule(uint32 _index, bytes32 _accountType)
    external
    view
    returns (TaggedRules.BalanceLimitRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of Accounts|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.BalanceLimitRule`|BalanceLimitRule at index location in array|


### getTotalBalanceLimitRules

*Function gets total Balance Limit rules*


```solidity
function getTotalBalanceLimitRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addWithdrawalRule

Account Withdrawal Getters/Setters **********

*Function adds Withdrawal Rule*


```solidity
function addWithdrawalRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTypes,
    uint256[] calldata _amount,
    uint256[] calldata _releaseDate
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
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


### getWithdrawalRule

*Function gets withdrawal rule at index*


```solidity
function getWithdrawalRule(uint32 _index, bytes32 _accountType)
    external
    view
    returns (TaggedRules.WithdrawalRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountType`|`bytes32`|Type of Account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.WithdrawalRule`|WithdrawalRule rule at indexed postion|


### getTotalWithdrawalRule

*Function to get total withdrawal rules*


```solidity
function getTotalWithdrawalRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|withdrawalRulesIndex total length of array|


### addAdminWithdrawalRule

Admin Account Withdrawal Getters/Setters **********

*Function adds Withdrawal Rule for admins*


```solidity
function addAdminWithdrawalRule(address _appManagerAddr, uint256 _amount, uint256 _releaseDate)
    external
    appAdministratorOnly(_appManagerAddr)
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


### getAdminWithdrawalRule

*Function gets Admin withdrawal rule at index*


```solidity
function getAdminWithdrawalRule(uint32 _index) external view returns (TaggedRules.AdminWithdrawalRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.AdminWithdrawalRule`|adminWithdrawalRulesPerToken rule at indexed postion|


### getTotalAdminWithdrawalRules

*Function to get total Admin withdrawal rules*


```solidity
function getTotalAdminWithdrawalRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminWithdrawalRulesPerToken total length of array|


### addTransactionLimitByRiskScore

_maxSize size must be equal to _riskLevel + 1 since the _maxSize must
specify the maximum tx size for anything between the highest risk score and 100
which should be specified in the last position of the _riskLevel. This also
means that the positioning of the arrays is ascendant in terms of risk levels, and
descendant in the size of transactions. (i.e. if highest risk level is 99, the last balanceLimit
will apply to all risk scores of 100.)

*Function to add new TransactionLimitByRiskScore Rules*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addTransactionLimitByRiskScore(
    address _appManagerAddr,
    uint8[] calldata _riskScores,
    uint48[] calldata _txnLimits
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
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


### getTransactionLimitByRiskRule

*Function to get the TransactionLimit in the rule set that belongs to an risk score*


```solidity
function getTransactionLimitByRiskRule(uint32 _index)
    external
    view
    returns (TaggedRules.TransactionSizeToRiskRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.TransactionSizeToRiskRule`|balanceAmount balance allowed for access levellevel|


### getTotalTransactionLimitByRiskRules

*Function to get total Transaction Limit by Risk Score rules*


```solidity
function getTotalTransactionLimitByRiskRules() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### addMinBalByDateRule

Minimum Account Balance By Date Getters/Setters **********************

*Function add a Minimum Account Balance By Date rule*

*Function has AppAdministratorOnly Modifier and takes AppManager Address Param*


```solidity
function addMinBalByDateRule(
    address _appManagerAddr,
    bytes32[] calldata _accountTags,
    uint256[] calldata _holdAmounts,
    uint256[] calldata _holdPeriods,
    uint256[] calldata _startTimestamps
) external appAdministratorOnly(_appManagerAddr) returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddr`|`address`|Address of App Manager|
|`_accountTags`|`bytes32[]`|Types of Accounts|
|`_holdAmounts`|`uint256[]`|Allowed total purchase limits|
|`_holdPeriods`|`uint256[]`|Hours purchases allowed|
|`_startTimestamps`|`uint256[]`|Timestamp that the check should start|

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
    uint256[] calldata _holdPeriods,
    uint256[] memory _startTimestamps
) internal returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accountTags`|`bytes32[]`|Types of Accounts|
|`_holdAmounts`|`uint256[]`|Allowed total purchase limits|
|`_holdPeriods`|`uint256[]`|Hours purhchases allowed|
|`_startTimestamps`|`uint256[]`|Timestamp that the check should start|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|ruleId of new rule in array|


### getMinBalByDateRule

if defaults sent for timestamp, start them with current block time

*Function get the minimum balance by date rule in the rule set that belongs to an account type*


```solidity
function getMinBalByDateRule(uint32 _index, bytes32 _accountTag)
    external
    view
    returns (TaggedRules.MinBalByDateRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|
|`_accountTag`|`bytes32`|Tag of account|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`TaggedRules.MinBalByDateRule`|PurchaseRule rule at index position|


### getTotalMinBalByDateRule

*Function to get total minimum balance by date rules*


```solidity
function getTotalMinBalByDateRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


## Errors
### InputArraysMustHaveSameLength
Note that no update method is implemented. Since reutilization of
rules is encouraged, it is preferred to add an extra rule to the
set instead of modifying an existing one.


```solidity
error InputArraysMustHaveSameLength();
```

### IndexOutOfRange

```solidity
error IndexOutOfRange();
```

### InvertedLimits

```solidity
error InvertedLimits();
```

### ZeroValueNotPermited

```solidity
error ZeroValueNotPermited();
```

### DateInThePast

```solidity
error DateInThePast(uint256 date);
```

### BlankTag

```solidity
error BlankTag();
```

### StartTimeNotValid

```solidity
error StartTimeNotValid();
```

### InputArraysSizesNotValid

```solidity
error InputArraysSizesNotValid();
```

### WrongArrayOrder

```solidity
error WrongArrayOrder();
```

### RiskLevelCannotExceed99

```solidity
error RiskLevelCannotExceed99();
```


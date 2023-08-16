# ProtocolERC20Handler
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/token/ProtocolERC20Handler.sol)

**Inherits:**
Ownable, [ProtocolHandlerCommon](/src/token/ProtocolHandlerCommon.sol/abstract.ProtocolHandlerCommon.md), [AppAdministratorOnly](/src/economic/AppAdministratorOnly.sol/contract.AppAdministratorOnly.md), [RuleAdministratorOnly](/src/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IAdminWithdrawalRuleCapable](/src/token/IAdminWithdrawalRuleCapable.sol/abstract.IAdminWithdrawalRuleCapable.md), ERC165

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

TODO Create a wizard that creates custom versions of this contract for each implementation.

Any rules may be updated by modifying this contract, redeploying, and pointing the ERC20 to the new version.

*This contract performs all rule checks related to the the ERC20 that implements it.*


## State Variables
### riskScoreTokenId
Functions added so far:
minTransfer
balanceLimits
oracle
Balance by AccessLevel
Balance Limit by Risk
Transaction Limit by Risk
AccessLevel Account balance
Risk Score Transaction Limit
Risk Score Account Balance Limit


```solidity
string private riskScoreTokenId;
```


### fees
Data contracts


```solidity
Fees fees;
```


### feeActive

```solidity
bool feeActive;
```


### minTransferRuleId
RuleIds


```solidity
uint32 private minTransferRuleId;
```


### oracleRuleId

```solidity
uint32 private oracleRuleId;
```


### minMaxBalanceRuleId

```solidity
uint32 private minMaxBalanceRuleId;
```


### transactionLimitByRiskRuleId

```solidity
uint32 private transactionLimitByRiskRuleId;
```


### adminWithdrawalRuleId

```solidity
uint32 private adminWithdrawalRuleId;
```


### minBalByDateRuleId

```solidity
uint32 private minBalByDateRuleId;
```


### tokenTransferVolumeRuleId

```solidity
uint32 private tokenTransferVolumeRuleId;
```


### totalSupplyVolatilityRuleId

```solidity
uint32 private totalSupplyVolatilityRuleId;
```


### minTransferRuleActive
on-off switches for rules


```solidity
bool private minTransferRuleActive;
```


### oracleRuleActive

```solidity
bool private oracleRuleActive;
```


### minMaxBalanceRuleActive

```solidity
bool private minMaxBalanceRuleActive;
```


### transactionLimitByRiskRuleActive

```solidity
bool private transactionLimitByRiskRuleActive;
```


### adminWithdrawalActive

```solidity
bool private adminWithdrawalActive;
```


### minBalByDateRuleActive

```solidity
bool private minBalByDateRuleActive;
```


### tokenTransferVolumeRuleActive

```solidity
bool private tokenTransferVolumeRuleActive;
```


### totalSupplyVolatilityRuleActive

```solidity
bool private totalSupplyVolatilityRuleActive;
```


### transferVolume
token level accumulators


```solidity
uint256 private transferVolume;
```


### lastTransferTs

```solidity
uint64 private lastTransferTs;
```


### lastSupplyUpdateTime

```solidity
uint64 private lastSupplyUpdateTime;
```


### volumeTotalForPeriod

```solidity
int256 private volumeTotalForPeriod;
```


### totalSupplyForPeriod

```solidity
uint256 private totalSupplyForPeriod;
```


## Functions
### constructor

*Constructor sets params*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|
|`_assetAddress`|`address`|address of the controlling asset.|
|`_upgradeMode`|`bool`|specifies whether this is a fresh CoinHandler or an upgrade replacement.|


### supportsInterface

*See {IERC165-supportsInterface}.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool);
```

### checkAllRules

*This function is the one called from the contract that implements this handler. It's the entry point.*


```solidity
function checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    uint256 amount,
    ActionTypes _action
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|token balance of sender address|
|`balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`amount`|`uint256`|number of tokens transferred|
|`_action`|`ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if all checks pass|


### _checkNonTaggedRules

standard rules do not apply when either to or from is an admin
If everything checks out, return true

*This function uses the protocol's ruleProcessorto perform the actual  rule checks.*


```solidity
function _checkNonTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|


### _checkTaggedRules

rule requires ruleID and either to or from address be zero address (mint/burn)

*This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.*


```solidity
function _checkTaggedRules(uint256 _balanceFrom, uint256 _balanceTo, address _from, address _to, uint256 _amount)
    internal
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|


### _checkTaggedIndividualRules

we only ask for price if we need it since this might cause the contract to require setting the pricing contracts when there is no need

*This function consolidates all the tagged rules that utilize account tags.*


```solidity
function _checkTaggedIndividualRules(
    address _from,
    address _to,
    uint256 _balanceFrom,
    uint256 _balanceTo,
    uint256 _amount
) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_amount`|`uint256`|number of tokens transferred|


### _checkRiskRules

*This function consolidates all the Risk rules that utilize tagged account Risk scores.*


```solidity
function _checkRiskRules(
    address _from,
    address _to,
    uint256 _balanceValuation,
    uint256 _transferValuation,
    uint256 _amount,
    uint256 _price
) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_balanceValuation`|`uint256`|address current balance in USD|
|`_transferValuation`|`uint256`|valuation of all tokens owned by the address in USD|
|`_amount`|`uint256`|number of tokens to be transferred|
|`_price`|`uint256`||


### addFee

*This function adds a fee to the token*


```solidity
function addFee(bytes32 _tag, uint256 _minBalance, uint256 _maxBalance, int24 _feePercentage, address _targetAccount)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|
|`_minBalance`|`uint256`|minimum balance for fee application|
|`_maxBalance`|`uint256`|maximum balance for fee application|
|`_feePercentage`|`int24`|fee percentage to assess|
|`_targetAccount`|`address`|target for the fee proceeds|


### removeFee

*This function adds a fee to the token*


```solidity
function removeFee(bytes32 _tag) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|


### getFee

*returns the full mapping of fees*


```solidity
function getFee(bytes32 _tag) external view returns (Fees.Fee memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tag`|`bytes32`|meta data tag for fee|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Fees.Fee`|fee struct containing fee data|


### getFeeTotal

*returns the full mapping of fees*


```solidity
function getFeeTotal() public view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|feeTotal total number of fees|


### setFeeActivation

*Turn fees on/off*


```solidity
function setFeeActivation(bool on_off) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`on_off`|`bool`|value for fee status|


### isFeeActive

*returns the full mapping of fees*


```solidity
function isFeeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|feeActive fee activation status|


### getApplicableFees

*Get all the fees/discounts for the transaction. This is assessed and returned as two separate arrays. This was necessary because the fees may go to
different target accounts. Since struct arrays cannot be function parameters for external functions, two separate arrays must be used.*


```solidity
function getApplicableFees(address _from, uint256 _balanceFrom)
    public
    view
    returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|originating address|
|`_balanceFrom`|`uint256`|Token balance of the sender address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`feeCollectorAccounts`|`address[]`|list of where the fees are sent|
|`feePercentages`|`int24[]`|list of all applicable fees/discounts|


### setMinMaxBalanceRuleId

loop through and accumulate the fee percentages based on tags
if an applicable discount(s) was found, then distribute it among all the fees
Rule Setters and Getters

that setting a rule will automatically activate it.

*Set the minMaxBalanceRuleId. Restricted to app administrators only.*


```solidity
function setMinMaxBalanceRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinMaxBalanceRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMinMaxBalanceRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getMinMaxBalanceRuleId

Get the minMaxBalanceRuleId.


```solidity
function getMinMaxBalanceRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minMaxBalance rule id.|


### isMinMaxBalanceActive

*Tells you if the MinMaxBalanceRule is active or not.*


```solidity
function isMinMaxBalanceActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setMinTransferRuleId

that setting a rule will automatically activate it.

*Set the minTransferRuleId. Restricted to app administrators only.*


```solidity
function setMinTransferRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinTransfereRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateMinTransfereRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getMinTransferRuleId

*Retrieve the minTransferRuleId*


```solidity
function getMinTransferRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minTransferRuleId|


### isMinTransferActive

*Tells you if the MinMaxBalanceRule is active or not.*


```solidity
function isMinTransferActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setOracleRuleId

that setting a rule will automatically activate it.

*Set the oracleRuleId. Restricted to app administrators only.*


```solidity
function setOracleRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateOracleRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateOracleRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getOracleRuleId

*Retrieve the oracle rule id*


```solidity
function getOracleRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|oracleRuleId|


### isOracleActive

*Tells you if the Oracle Rule is active or not.*


```solidity
function isOracleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getTransactionLimitByRiskRule

*Retrieve the transaction limit by risk rule id*


```solidity
function getTransactionLimitByRiskRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|transactionLimitByRiskRuleActive rule id|


### setTransactionLimitByRiskRuleId

that setting a rule will automatically activate it.

*Set the TransactionLimitByRiskRule. Restricted to app administrators only.*


```solidity
function setTransactionLimitByRiskRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTransactionLimitByRiskRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTransactionLimitByRiskRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isTransactionLimitByRiskActive

*Tells you if the transactionLimitByRiskRule is active or not.*


```solidity
function isTransactionLimitByRiskActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setAdminWithdrawalRuleId

that setting a rule will automatically activate it.

*Set the AdminWithdrawalRule. Restricted to app administrators only.*


```solidity
function setAdminWithdrawalRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### isAdminWithdrawalActiveAndApplicable

if the rule is currently active, we check that time for current ruleId is expired. Revert if not expired.
after time expired on current rule we set new ruleId and maintain true for adminRuleActive bool.

*This function is used by the app manager to determine if the AdminWithdrawal rule is active*


```solidity
function isAdminWithdrawalActiveAndApplicable() public view override returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|Success equals true if all checks pass|


### activateAdminWithdrawalRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAdminWithdrawalRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAdminWithdrawalActive

if the rule is currently active, we check that time for current ruleId is expired

*Tells you if the admin withdrawal rule is active or not.*


```solidity
function isAdminWithdrawalActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAdminWithdrawalRuleId

*Retrieve the admin withdrawal rule id*


```solidity
function getAdminWithdrawalRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|adminWithdrawalRuleId rule id|


### getMinBalByDateRule

*Retrieve the minimum balance by date rule id*


```solidity
function getMinBalByDateRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|minBalByDateRuleId rule id|


### setMinBalByDateRuleId

that setting a rule will automatically activate it.

*Set the minBalByDateRuleId. Restricted to app administrators only.*


```solidity
function setMinBalByDateRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateMinBalByDateRule

*Tells you if the min bal by date rule is active or not.*


```solidity
function activateMinBalByDateRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if the rule is active|


### isMinBalByDateActive

*Tells you if the minBalByDateRuleActive is active or not.*


```solidity
function isMinBalByDateActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getTokenTransferVolumeRule

*Retrieve the token transfer volume rule id*


```solidity
function getTokenTransferVolumeRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenTransferVolumeRuleId rule id|


### setTokenTransferVolumeRuleId

that setting a rule will automatically activate it.

*Set the tokenTransferVolumeRuleId. Restricted to game admins only.*


```solidity
function setTokenTransferVolumeRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTokenTransferVolumeRule

*Tells you if the token transfer volume rule is active or not.*


```solidity
function activateTokenTransferVolumeRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if the rule is active|


### isTokenTransferVolumeActive

*Tells you if the token transfer volume rule is active or not.*


```solidity
function isTokenTransferVolumeActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getTotalSupplyVolatilityRule

*Retrieve the total supply volatility rule id*


```solidity
function getTotalSupplyVolatilityRule() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|totalSupplyVolatilityRuleId rule id|


### setTotalSupplyVolatilityRuleId

that setting a rule will automatically activate it.

*Set the tokenTransferVolumeRuleId. Restricted to game admins only.*


```solidity
function setTotalSupplyVolatilityRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTotalSupplyVolatilityRule

*Tells you if the token total Supply Volatility rule is active or not.*


```solidity
function activateTotalSupplyVolatilityRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if the rule is active|


### isTotalSupplyVolatilityActive

*Tells you if the Total Supply Volatility is active or not.*


```solidity
function isTotalSupplyVolatilityActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### deployDataContract

-------------DATA CONTRACT DEPLOYMENT---------------

*Deploy all the child data contracts. Only called internally from the constructor.*


```solidity
function deployDataContract() private;
```

### getFeesDataAddress

*Getter for the fee rules data contract address*


```solidity
function getFeesDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|feesDataAddress|


### proposeDataContractMigration

*This function is used to propose the new owner for data contracts.*


```solidity
function proposeDataContractMigration(address _newOwner) external appAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|address of the new AppManager|


### confirmDataContractMigration

*This function is used to confirm this contract as the new owner for data contracts.*


```solidity
function confirmDataContractMigration(address _oldHandlerAddress) external appAdministratorOnly(appManagerAddress);
```


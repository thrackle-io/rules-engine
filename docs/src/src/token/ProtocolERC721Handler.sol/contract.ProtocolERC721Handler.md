# ProtocolERC721Handler
[Git Source](https://github.com/thrackle-io/tron/blob/c915f21b8dd526456aab7e2f9388d412d287d507/src/token/ProtocolERC721Handler.sol)

**Inherits:**
Ownable, [ProtocolHandlerCommon](/src/token/ProtocolHandlerCommon.sol/abstract.ProtocolHandlerCommon.md), [RuleAdministratorOnly](/src/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IAdminWithdrawalRuleCapable](/src/token/IAdminWithdrawalRuleCapable.sol/abstract.IAdminWithdrawalRuleCapable.md), ERC165

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

TODO Create a wizard that creates custom versions of this contract for each implementation.

This contract is the interaction point for the application ecosystem to the protocol

*This contract performs all rule checks related to the the ERC721 that implements it.
Any rule handlers may be updated by modifying this contract, redeploying, and pointing the ERC721 to the new version.*


## State Variables
### erc721Address
Functions added so far:
minAccountBalance
Min Max Balance
Oracle
Trade Counter
Balance By AccessLevel


```solidity
address public erc721Address;
```


### minMaxBalanceRuleId
RuleIds for implemented tagged rules of the ERC721


```solidity
uint32 private minMaxBalanceRuleId;
```


### minBalByDateRuleId

```solidity
uint32 private minBalByDateRuleId;
```


### minAccountRuleId

```solidity
uint32 private minAccountRuleId;
```


### oracleRuleId

```solidity
uint32 private oracleRuleId;
```


### tradeCounterRuleId

```solidity
uint32 private tradeCounterRuleId;
```


### transactionLimitByRiskRuleId

```solidity
uint32 private transactionLimitByRiskRuleId;
```


### adminWithdrawalRuleId

```solidity
uint32 private adminWithdrawalRuleId;
```


### tokenTransferVolumeRuleId

```solidity
uint32 private tokenTransferVolumeRuleId;
```


### totalSupplyVolatilityRuleId

```solidity
uint32 private totalSupplyVolatilityRuleId;
```


### oracleRuleActive
on-off switches for rules


```solidity
bool private oracleRuleActive;
```


### minMaxBalanceRuleActive

```solidity
bool private minMaxBalanceRuleActive;
```


### tradeCounterRuleActive

```solidity
bool private tradeCounterRuleActive;
```


### transactionLimitByRiskRuleActive

```solidity
bool private transactionLimitByRiskRuleActive;
```


### minBalByDateRuleActive

```solidity
bool private minBalByDateRuleActive;
```


### adminWithdrawalActive

```solidity
bool private adminWithdrawalActive;
```


### tokenTransferVolumeRuleActive

```solidity
bool private tokenTransferVolumeRuleActive;
```


### totalSupplyVolatilityRuleActive

```solidity
bool private totalSupplyVolatilityRuleActive;
```


### minimumHoldTimeRuleActive

```solidity
bool private minimumHoldTimeRuleActive;
```


### minimumHoldTimeHours
simple rule(with single parameter) variables


```solidity
uint32 private minimumHoldTimeHours;
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


### nftValuationLimit
NFT Collection Valuation Limit


```solidity
uint256 private nftValuationLimit = 100;
```


### tradesInPeriod
Trade Counter data


```solidity
mapping(uint256 => uint256) tradesInPeriod;
```


### lastTxDate

```solidity
mapping(uint256 => uint64) lastTxDate;
```


### ownershipStart
Minimum Hold time data


```solidity
mapping(uint256 => uint256) ownershipStart;
```


### MAX_HOLD_TIME_HOURS
Max Hold time hours


```solidity
uint16 constant MAX_HOLD_TIME_HOURS = 43830;
```


## Functions
### constructor

*Constructor sets the name, symbol and base URI of NFT along with the App Manager and Handler Address*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress, address _assetAddress, bool _upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of token rule router proxy|
|`_appManagerAddress`|`address`|Address of App Manager|
|`_assetAddress`|`address`|Address of the controlling address|
|`_upgradeMode`|`bool`|specifies whether this is a fresh CoinHandler or an upgrade replacement.|


### supportsInterface

*See {IERC165-supportsInterface}.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool);
```

### checkAllRules

*This function is the one called from the contract that implements this handler. It's the entry point to protocol.*


```solidity
function checkAllRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    uint256 _tokenId,
    ActionTypes _action
) external onlyOwner returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|sender address|
|`_to`|`address`|recipient address|
|`_amount`|`uint256`|number of tokens transferred|
|`_tokenId`|`uint256`|the token's specific ID|
|`_action`|`ActionTypes`|Action Type defined by ApplicationHandlerLib (Purchase, Sell, Trade, Inquire)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|_success equals true if all checks pass|


### _checkNonTaggedRules

standard tagged and non-tagged rules do not apply when either to or from is an admin
set the ownership start time for the token if the Minimum Hold time rule is active
If all rule checks pass, return true

*This function uses the protocol's ruleProcessor to perform the actual rule checks.*


```solidity
function _checkNonTaggedRules(address _from, address _to, uint256 _amount, uint256 tokenId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|
|`tokenId`|`uint256`|the token's specific ID|


### _checkTaggedRules

rule requires ruleID and either to or from address be zero address (mint/burn)

*This function uses the protocol's ruleProcessor to perform the actual tagged rule checks.*


```solidity
function _checkTaggedRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    uint256 tokenId
) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balanceFrom`|`uint256`|token balance of sender address|
|`_balanceTo`|`uint256`|token balance of recipient address|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|number of tokens transferred|
|`tokenId`|`uint256`||


### _checkTaggedIndividualRules

If more rules need these values, then this can be moved above.

*This function uses the protocol's ruleProcessor to perform the actual tagged non-risk rule checks.*


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

*This function uses the protocol's ruleProcessor to perform the risk rule checks.(Ones that require risk score values)*


```solidity
function _checkRiskRules(address _from, address _to, uint256 _thisNFTValuation) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_thisNFTValuation`|`uint256`|valuation of NFT in question|


### _checkSimpleRules

if rule is active check if the recipient is address(0) for burning tokens
if recipient is not address(0) check sender and recipient risk scores to ensure transaction limit is within rule limits

*This function uses the protocol's ruleProcessor to perform the simple rule checks.(Ones that have simple parameters and so are not stored in the rule storage diamond)*


```solidity
function _checkSimpleRules(uint256 _tokenId) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`uint256`|the specific token in question|


### setMinMaxBalanceRuleId

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

*Tells you if the oracle rule is active or not.*


```solidity
function isOracleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setTradeCounterRuleId

that setting a rule will automatically activate it.

*Set the tradeCounterRuleId. Restricted to app administrators only.*


```solidity
function setTradeCounterRuleId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateTradeCounterRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateTradeCounterRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### getTradeCounterRuleId

*Retrieve the trade counter rule id*


```solidity
function getTradeCounterRuleId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tradeCounterRuleId|


### isTradeCounterRuleActive

*Tells you if the tradeCounterRule is active or not.*


```solidity
function isTradeCounterRuleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setERC721Address

*Set the parent ERC721 address*


```solidity
function setERC721Address(address _address) public appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the ERC721|


### getTransactionLimitByRiskRule

*Retrieve the oracle rule id*


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


### activateMinimumHoldTimeRule

-------------SIMPLE RULE SETTERS and GETTERS---------------

*Tells you if the minimum hold time rule is active or not.*


```solidity
function activateMinimumHoldTimeRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if the rule is active|


### setMinimumHoldTimeHours

*Setter the minimum hold time rule hold hours*


```solidity
function setMinimumHoldTimeHours(uint32 _minimumHoldTimeHours) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_minimumHoldTimeHours`|`uint32`|minimum amount of time to hold the asset|


### getMinimumHoldTimeHours

*Get the minimum hold time rule hold hours*


```solidity
function getMinimumHoldTimeHours() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|minimumHoldTimeHours minimum amount of time to hold the asset|


### setNFTValuationLimit

*Set the NFT Valuation limit that will check collection price vs looping through each tokenId in collections*


```solidity
function setNFTValuationLimit(uint256 _newNFTValuationLimit) public appAdministratorOrOwnerOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newNFTValuationLimit`|`uint256`|set the number of NFTs in a wallet that will check for collection price vs individual token prices|


### getNFTValuationLimit

*Get the nftValuationLimit*


```solidity
function getNFTValuationLimit() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|nftValautionLimit number of NFTs in a wallet that will check for collection price vs individual token prices|



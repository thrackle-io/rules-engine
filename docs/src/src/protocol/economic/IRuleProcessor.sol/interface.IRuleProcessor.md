# IRuleProcessor
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/IRuleProcessor.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the Rule Processor for an efficient
import into the other contracts for calls to the checkAllRules function.
This is only used internally by the protocol.*


## Functions
### checkMinMaxAccountBalancePasses

*Check the minimum/maximum rule. This rule ensures that both the to and from accounts do not
exceed the max balance or go below the min balance.*


```solidity
function checkMinMaxAccountBalancePasses(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    uint256 amount,
    bytes32[] calldata toTags,
    bytes32[] calldata fromTags
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkTokenMinTransactionSize

*Check the minimum transfer rule. This rule ensures accounts cannot transfer less than
the specified amount.*


```solidity
function checkTokenMinTransactionSize(uint32 ruleId, uint256 amount) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`amount`|`uint256`|total number of tokens to be transferred|


### checkMinMaxAccountBalanceERC721

*Check the minMaxAccoutBalace rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.*


```solidity
function checkMinMaxAccountBalanceERC721(
    uint32 ruleId,
    uint256 balanceFrom,
    uint256 balanceTo,
    bytes32[] memory toTags,
    bytes32[] memory fromTags
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkAccountApproveDenyOracle

*This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkAccountApproveDenyOracle(uint32 _ruleId, address _address) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id|
|`_address`|`address`|user address to be checked|


### checkBalanceByAccessLevelPasses

*Check if transaction passes Balance by AccessLevel rule.*


```solidity
function checkBalanceByAccessLevelPasses(
    uint32 _ruleId,
    uint8 _accessLevel,
    uint256 _balance,
    uint256 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_accessLevel`|`uint8`|the Access Level of the account|
|`_balance`|`uint256`|account's beginning balance|
|`_amountToTransfer`|`uint256`|total number of tokens to be transferred|


### checkPurchaseLimit

*This function receives a rule id for Purchase Limit details and checks that transaction passes.*


```solidity
function checkPurchaseLimit(
    uint32 ruleId,
    uint256 boughtInPeriod,
    uint256 amount,
    bytes32[] calldata toTags,
    uint64 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`boughtInPeriod`|`uint256`|Number of tokens purchased within purchase Period|
|`amount`|`uint256`|Number of tokens to be transferred|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### checkSellLimit

*This function receives a rule id for Sell Limit details and checks that transaction passes.*


```solidity
function checkSellLimit(
    uint32 ruleId,
    uint256 salesWithinPeriod,
    uint256 amount,
    bytes32[] calldata fromTags,
    uint256 lastUpdateTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`salesWithinPeriod`|`uint256`||
|`amount`|`uint256`|Number of tokens to be transferred|
|`fromTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastUpdateTime`|`uint256`|block.timestamp of most recent transaction from sender.|


### checkMinMaxAccountBalancePassesAMM

*Check the minimum/maximum rule through the AMM Swap*


```solidity
function checkMinMaxAccountBalancePassesAMM(
    uint32 ruleIdToken0,
    uint32 ruleIdToken1,
    uint256 tokenBalance0,
    uint256 tokenBalance1,
    uint256 amountIn,
    uint256 amountOut,
    bytes32[] calldata fromTags
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleIdToken0`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`ruleIdToken1`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`tokenBalance0`|`uint256`|Token balance of the token being swapped|
|`tokenBalance1`|`uint256`|Token balance of the received token|
|`amountIn`|`uint256`|total number of tokens to be swapped|
|`amountOut`|`uint256`|total number of tokens to be received|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|


### checkTokenMaxDailyTrades

*This function receives a rule id, which it uses to get the NFT Trade Counter rule to check if the transfer is valid.*


```solidity
function checkTokenMaxDailyTrades(
    uint32 ruleId,
    uint256 transfersWithinPeriod,
    bytes32[] calldata nftTags,
    uint64 lastTransferTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`transfersWithinPeriod`|`uint256`|Number of transfers within the time period|
|`nftTags`|`bytes32[]`|NFT tags applied|
|`lastTransferTime`|`uint64`|block.timestamp of most recent transaction from sender.|


### checkTransactionLimitByRiskScore

*Check Transaction Limit for Risk Score*


```solidity
function checkTransactionLimitByRiskScore(uint32 _ruleId, uint8 _riskScore, uint256 _amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_riskScore`|`uint8`|the Risk Score of the account|
|`_amountToTransfer`|`uint256`|total dollar amount to be transferred|


### assessAMMFee

*Assess the fee associated with the AMM Fee Rule*


```solidity
function assessAMMFee(uint32 _ruleId, uint256 _collateralizedTokenAmount) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`_collateralizedTokenAmount`|`uint256`|total number of collateralized tokens to be swapped(this could be the "token in" or "token out" as the fees are always * assessed from the collateralized token)|


### checkAdminMinTokenBalance

that the function will revert if the check finds a violation of the rule, but won't give anything
back if everything checks out.

*checks that an admin won't hold less tokens than promised until a certain date*


```solidity
function checkAdminMinTokenBalance(uint32 _ruleId, uint256 _currentBalance, uint256 _amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_currentBalance`|`uint256`|of tokens held by the admin|
|`_amountToTransfer`|`uint256`|Number of tokens to be transferred|


### checkMinBalByDatePasses

*Rule checks if the minimum balance by date rule will be violated. Tagged accounts must maintain a minimum balance throughout the period specified*


```solidity
function checkMinBalByDatePasses(uint32 ruleId, uint256 balance, uint256 amount, bytes32[] calldata toTags)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`balance`|`uint256`|account's current balance|
|`amount`|`uint256`|Number of tokens to be transferred from this account|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|


### checkAccountMaxValueByRiskScore

*This function checks if the requested action is valid according to the AccountBalanceByRiskScore rule*


```solidity
function checkAccountMaxValueByRiskScore(
    uint32 _ruleId,
    address _toAddress,
    uint8 _riskScoreTo,
    uint128 _totalValuationTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_toAddress`|`address`|Address of the recipient|
|`_riskScoreTo`|`uint8`|the Risk Score of the recepient account|
|`_totalValuationTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkAccountMaxValueByAccessLevel

*This function checks if the requested action is valid according to the AccountBalanceByAccessLevel rule*


```solidity
function checkAccountMaxValueByAccessLevel(
    uint32 _ruleId,
    uint8 _accessLevelTo,
    uint128 _totalValuationTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_accessLevelTo`|`uint8`|the Access Level of the recepient account|
|`_totalValuationTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkAccountMaxTransactionValueByRiskScore

that these ranges are set by ranges.

*rule that checks if the tx exceeds the limit size in USD for a specific risk profile
within a specified period of time.*

*this check will cause a revert if the new value of _usdValueTransactedInPeriod in USD exceeds
the limit for the address risk profile.*


```solidity
function checkAccountMaxTransactionValueByRiskScore(
    uint32 ruleId,
    uint128 _usdValueTransactedInPeriod,
    uint128 amount,
    uint64 lastTxDate,
    uint8 riskScore
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_usdValueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`amount`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _usdValueTransactedInPeriod. If _usdValueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


### checkAccessLevel0

*Ensure that Access Level = 0 rule passes. This seems like an easy rule to check but it is still
abstracted to through the token rule router to allow for updates later(like special values)*


```solidity
function checkAccessLevel0(uint8 _accessLevel) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevel`|`uint8`|account access level|


### checkAccountMaxValueOutByAccessLevel

that these ranges are set by ranges.

*rule that checks if the withdrawal exceeds the limit size in USD for a specific access level*


```solidity
function checkAccountMaxValueOutByAccessLevel(
    uint32 _ruleId,
    uint8 _accessLevel,
    uint128 _withdrawal,
    uint128 _amountToTransfer
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|to check against.|
|`_accessLevel`|`uint8`|access level of the sending account|
|`_withdrawal`|`uint128`|the amount, in USD, of previously withdrawn assets|
|`_amountToTransfer`|`uint128`|total value of the transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|Sending account's new total withdrawn.|


### checkPauseRules

*This function checks if the requested action is valid according to pause rules.*


```solidity
function checkPauseRules(address _dataServer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataServer`|`address`|address of the Application Rule Processor Diamond contract|


### checkTokenMaxTradingVolume

*Rule checks if the token transfer volume rule will be violated.*


```solidity
function checkTokenMaxTradingVolume(
    uint32 _ruleId,
    uint256 _volume,
    uint256 _supply,
    uint256 _amount,
    uint64 _lastTransferTs
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_volume`|`uint256`|token's trading volume thus far|
|`_supply`|`uint256`|Number of tokens in supply|
|`_amount`|`uint256`|Number of tokens to be transferred from this account|
|`_lastTransferTs`|`uint64`|the time of the last transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|volumeTotal new accumulated volume|


### checkTokenMaxSupplyVolatility

*Rule checks if the total supply volatility rule will be violated.*


```solidity
function checkTokenMaxSupplyVolatility(
    uint32 _ruleId,
    int256 _volumeTotalForPeriod,
    uint256 _totalSupplyForPeriod,
    uint256 _supply,
    int256 _amount,
    uint64 _lastSupplyUpdateTime
) external view returns (int256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_volumeTotalForPeriod`|`int256`|token's increase/decreased volume total in period|
|`_totalSupplyForPeriod`|`uint256`|token total supply updated at begining of period|
|`_supply`|`uint256`|Number of tokens in supply|
|`_amount`|`int256`|Number of tokens to be minted/burned|
|`_lastSupplyUpdateTime`|`uint64`|the time of the last transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|volumeTotal new accumulated volume|
|`<none>`|`uint256`||


### checkNFTHoldTime

*This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.*


```solidity
function checkNFTHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_holdHours`|`uint32`|minimum number of hours the asset must be held|
|`_ownershipTs`|`uint256`|beginning of hold period|


### validateAMMFee

*Validate the existence of the rule*


```solidity
function validateAMMFee(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTransactionLimitByRiskScore

*Validate the existence of the rule*


```solidity
function validateTransactionLimitByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateMinMaxAccountBalanceERC721

*Validate the existence of the rule*


```solidity
function validateMinMaxAccountBalanceERC721(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxDailyTrades

*Validate the existence of the rule*


```solidity
function validateTokenMaxDailyTrades(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateMinMaxAccountBalance

*Validate the existence of the rule*


```solidity
function validateMinMaxAccountBalance(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxBuySize

*Validate the existence of the rule*


```solidity
function validateAccountMaxBuySize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateSellLimit

*Validate the existence of the rule*


```solidity
function validateSellLimit(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAdminWithdrawal

*Validate the existence of the rule*


```solidity
function validateAdminWithdrawal(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateMinBalByDate

*Validate the existence of the rule*


```solidity
function validateMinBalByDate(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMinTransactionSize

*Validate the existence of the rule*


```solidity
function validateTokenMinTransactionSize(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountApproveDenyOracle

*Validate the existence of the rule*


```solidity
function validateAccountApproveDenyOracle(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxBuyVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxBuyVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxSellVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxSellVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxTradingVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxTradingVolume(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxSupplyVolatility

*Validate the existence of the rule*


```solidity
function validateTokenMaxSupplyVolatility(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxTransactionValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxTransactionValueByRiskScore(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validatePause

*Validate the existence of the rule*


```solidity
function validatePause(uint32 _ruleId, address _dataServer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_dataServer`|`address`|address of the appManager contract|


### validateAccountMaxValueByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxValueOutByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueOutByAccessLevel(uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|



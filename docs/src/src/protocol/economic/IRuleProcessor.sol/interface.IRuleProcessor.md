# IRuleProcessor
[Git Source](https://github.com/thrackle-io/aquifi-rules-v1/blob/39d269094241d21cf978e159a9b52cf3c140671a/src/protocol/economic/IRuleProcessor.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the Rule Processor for an efficient
import into the other contracts for calls to the checkAllRules function.
This is only used internally by the protocol.*


## Functions
### checkAccountMinMaxTokenBalance

*Check the AccountMinMaxTokenBalance rule. This rule ensures that both the to and from accounts do not
exceed the max balance or go below the min balance.*


```solidity
function checkAccountMinMaxTokenBalance(
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


### checkAccountMinTokenBalance

*Check the AccountMinTokenBalance half of the AccountMinMaxTokenBalance rule. This rule ensures that the from account does not
exceed the min balance.*


```solidity
function checkAccountMinTokenBalance(uint256 balanceFrom, bytes32[] memory fromTags, uint256 amount, uint32 ruleId)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceFrom`|`uint256`|Token balance of the sender address|
|`fromTags`|`bytes32[]`|tags applied via App Manager to sender address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|


### checkAccountMaxTokenBalance

*Check the AccountMaxTokenBalance half of the AccountMinMaxTokenBalance rule. This rule ensures that the to account does not
exceed the max balance.*


```solidity
function checkAccountMaxTokenBalance(uint256 balanceTo, bytes32[] memory toTags, uint256 amount, uint32 ruleId)
    external
    view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`balanceTo`|`uint256`|Token balance of the recipient address|
|`toTags`|`bytes32[]`|tags applied via App Manager to recipient address|
|`amount`|`uint256`|total number of tokens to be transferred|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|


### checkTokenMinTxSize

*Check the TokenMinTxSize rule. This rule ensures accounts cannot transfer less than
the specified amount.*


```solidity
function checkTokenMinTxSize(uint32 ruleId, uint256 amount) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Uint value of the ruleId storage pointer for applicable rule.|
|`amount`|`uint256`|total number of tokens to be transferred|


### checkMinMaxAccountBalanceERC721

*Check the MinMaxAccountBalanceERC721 rule. This rule ensures accounts cannot exceed or drop below specified account balances via account tags.*


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


### checkAccountApproveDenyOracles

*This function receives an array of rule ids, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkAccountApproveDenyOracles(Rule[] memory _rules, address _address) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rules`|`Rule[]`|Rule Id Array|
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


### checkAccountMaxTradeSize

If the rule applies to all users, it checks blank tag only. Otherwise loop through
tags and check for specific application. This was done in a minimal way to allow for
modifications later while not duplicating rule check logic.

*Rule checks if recipient balance + amount exceeded max amount for that action type during rule period, prevent transactions for that action for freeze period*


```solidity
function checkAccountMaxTradeSize(
    uint32 ruleId,
    uint256 transactedInPeriod,
    uint256 amount,
    bytes32[] memory toTags,
    uint64 lastTransactionTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|Rule identifier for rule arguments|
|`transactedInPeriod`|`uint256`|Number of tokens transacted during Period|
|`amount`|`uint256`|Number of tokens to be transferred|
|`toTags`|`bytes32[]`|Account tags applied to sender via App Manager|
|`lastTransactionTime`|`uint64`|block.timestamp of most recent transaction transaction from sender for action type.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|cumulativeTotal total amount of tokens bought or sold within Trade period.|


### checkAccountMinMaxTokenBalanceAMM

*Check the minimum/maximum rule through the AMM Swap*


```solidity
function checkAccountMinMaxTokenBalanceAMM(
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

*This function receives a rule id, which it uses to get the TokenMaxDailyTrades rule to check if the transfer is valid.*


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


### checkAccountMaxValueByRiskScore

--------------------------- APPLICATION LEVEL --------------------------------

*This function checks if the requested action is valid according to the AccountMaxValueByRiskScore rule*


```solidity
function checkAccountMaxValueByRiskScore(
    uint32 _ruleId,
    address _toAddress,
    uint8 _riskScoreTo,
    uint128 _totalValueTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_toAddress`|`address`|Address of the recipient|
|`_riskScoreTo`|`uint8`|the Risk Score of the recepient account|
|`_totalValueTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkAccountMaxValueByAccessLevel

*This function checks if the requested action is valid according to the AccountMaxValueByAccessLevel rule*


```solidity
function checkAccountMaxValueByAccessLevel(
    uint32 _ruleId,
    uint8 _accessLevelTo,
    uint128 _totalValueTo,
    uint128 _amountToTransfer
) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier|
|`_accessLevelTo`|`uint8`|the Access Level of the recepient account|
|`_totalValueTo`|`uint128`|recepient account's beginning balance in USD with 18 decimals of precision|
|`_amountToTransfer`|`uint128`|total dollar amount to be transferred in USD with 18 decimals of precision|


### checkAccountMaxTxValueByRiskScore

that these ranges are set by ranges.

*Rule that checks if the tx exceeds the limit size in USD for a specific risk profile
within a specified period of time.*

*this check will cause a revert if the new value of _valueTransactedInPeriod in USD exceeds
the limit for the address risk profile.*


```solidity
function checkAccountMaxTxValueByRiskScore(
    uint32 ruleId,
    uint128 _valueTransactedInPeriod,
    uint128 amount,
    uint64 lastTxDate,
    uint8 riskScore
) external view returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|to check against.|
|`_valueTransactedInPeriod`|`uint128`|the cumulative amount of tokens recorded in the last period.|
|`amount`|`uint128`|in USD of the current transaction with 18 decimals of precision.|
|`lastTxDate`|`uint64`|timestamp of the last transfer of this token by this address.|
|`riskScore`|`uint8`|of the address (0 -> 100)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|updated value for the _valueTransactedInPeriod. If _valueTransactedInPeriod are inside the current period, then this value is accumulated. If not, it is reset to current amount.|


### checkTokenMaxBuySellVolume

*Function receives a rule id, retrieves the rule data and checks if the Token Max Buy Sell Volume Rule passes*


```solidity
function checkTokenMaxBuySellVolume(
    uint32 ruleId,
    uint256 currentTotalSupply,
    uint256 amountToTransfer,
    uint64 lastTransactionTime,
    uint256 totalWithinPeriod
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|id of the rule to be checked|
|`currentTotalSupply`|`uint256`|total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred in transaction.|
|`lastTransactionTime`|`uint64`|time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.|
|`totalWithinPeriod`|`uint256`|total amount of tokens sold within current period|


### checkAccountDenyForNoAccessLevel

*Ensure that AccountDenyForNoAccessLevel passes.*


```solidity
function checkAccountDenyForNoAccessLevel(uint8 _accessLevel) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevel`|`uint8`|account access level|


### checkAccountMaxValueOutByAccessLevel

that these ranges are set by ranges.

*Rule that checks if the value out exceeds the limit size in USD for a specific access level*


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

*Rule checks if the token max trading volume rule will be violated.*


```solidity
function checkTokenMaxTradingVolume(
    uint32 _ruleId,
    uint256 _volume,
    uint256 _supply,
    uint256 _amount,
    uint64 _lastTransferTime
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_volume`|`uint256`|token's trading volume thus far|
|`_supply`|`uint256`|Number of tokens in supply|
|`_amount`|`uint256`|Number of tokens to be transferred from this account|
|`_lastTransferTime`|`uint64`|the time of the last transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|volumeTotal new accumulated volume|


### checkTokenMaxSupplyVolatility

*Rule checks if the tokenMaxSupplyVolatility rule will be violated.*


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


### checkTokenMinHoldTime

*This function receives data needed to check Minimum hold time rule. This a simple rule and thus is not stored in the rule storage diamond.*


```solidity
function checkTokenMinHoldTime(uint32 _holdHours, uint256 _ownershipTs) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_holdHours`|`uint32`|minimum number of hours the asset must be held|
|`_ownershipTs`|`uint256`|beginning of hold period|


### validateAMMFee

*Validate the existence of the rule*


```solidity
function validateAMMFee(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTransactionLimitByRiskScore

*Validate the existence of the rule*


```solidity
function validateTransactionLimitByRiskScore(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMinMaxTokenBalanceERC721

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalanceERC721(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxDailyTrades

*Validate the existence of the rule*


```solidity
function validateTokenMaxDailyTrades(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMinMaxTokenBalance

*Validate the existence of the rule*


```solidity
function validateAccountMinMaxTokenBalance(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxTradeSize

*Validate the existence of the rule*


```solidity
function validateAccountMaxTradeSize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMinTxSize

*Validate the existence of the rule*


```solidity
function validateTokenMinTxSize(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountApproveDenyOracle

*Validate the existence of the rule*


```solidity
function validateAccountApproveDenyOracle(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxBuySellVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxBuySellVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxTradingVolume

*Validate the existence of the rule*


```solidity
function validateTokenMaxTradingVolume(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateTokenMaxSupplyVolatility

*Validate the existence of the rule*


```solidity
function validateTokenMaxSupplyVolatility(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByRiskScore(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxTxValueByRiskScore

*Validate the existence of the rule*


```solidity
function validateAccountMaxTxValueByRiskScore(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validatePause

*Validate the existence of the rule*


```solidity
function validatePause(uint8[] memory _actions, uint32 _ruleId, address _dataServer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`uint8[]`||
|`_ruleId`|`uint32`|Rule Identifier|
|`_dataServer`|`address`|address of the appManager contract|


### validateAccountMaxValueByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueByAccessLevel(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|


### validateAccountMaxValueOutByAccessLevel

*Validate the existence of the rule*


```solidity
function validateAccountMaxValueOutByAccessLevel(ActionTypes[] memory _actions, uint32 _ruleId) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`||
|`_ruleId`|`uint32`|Rule Identifier|



# ERC20RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/1ab1db06d001c0ea3265ec49b85ddd9394430302/src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol)

**Inherits:**
[IRuleProcessorErrors](/src/interfaces/IErrors.sol/interface.IRuleProcessorErrors.md), [IERC20Errors](/src/interfaces/IErrors.sol/interface.IERC20Errors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Fee Rules on Accounts.

*Facet in charge of the logic to check token rules compliance*


## Functions
### checkMinTransferPasses

*Check if transaction passes minTransfer rule.*


```solidity
function checkMinTransferPasses(uint32 _ruleId, uint256 amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred|


### checkOraclePasses

*This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkOraclePasses(uint32 _ruleId, address _address) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id|
|`_address`|`address`|user address to be checked|


### checkPurchasePercentagePasses

White List type
Black List type
Invalid oracle type

*Function receives a rule id, retrieves the rule data and checks if the Purchase Percentage Rule passes*


```solidity
function checkPurchasePercentagePasses(
    uint32 ruleId,
    uint256 currentTotalSupply,
    uint256 amountToTransfer,
    uint64 lastPurchaseTime,
    uint256 purchasedWithinPeriod
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|id of the rule to be checked|
|`currentTotalSupply`|`uint256`|total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred in transaction.|
|`lastPurchaseTime`|`uint64`|time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.|
|`purchasedWithinPeriod`|`uint256`|total amount of tokens purchased in current period|


### checkSellPercentagePasses

resets value for purchases outside of purchase period
check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
update totalPurchasedWithinPeriod to include the amountToTransfer when inside purchase period
perform rule check if amountToTransfer + purchasedWithinPeriod is over allowed amount of total supply


```solidity
function checkSellPercentagePasses(
    uint32 ruleId,
    uint256 currentTotalSupply,
    uint256 amountToTransfer,
    uint64 lastSellTime,
    uint256 soldWithinPeriod
) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`ruleId`|`uint32`|id of the rule to be checked|
|`currentTotalSupply`|`uint256`|total supply value passed in by the handler. This is for ERC20 tokens with a fixed total supply.|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred in transaction.|
|`lastSellTime`|`uint64`|time of the most recent purchase from AMM. This starts the check if current transaction is within a purchase window.|
|`soldWithinPeriod`|`uint256`|total amount of tokens sold within current period|


### checkTokenTransferVolumePasses

resets value for purchases outside of purchase period
check if totalSupply in rule struct is 0 and if it is use currentTotalSupply, if < 0 use rule value
update soldWithinPeriod to include the amountToTransfer when inside purchase period
perform rule check if amountToTransfer + soldWithinPeriod is over allowed amount of total supply

*Rule checks if the token transfer volume rule will be violated.*


```solidity
function checkTokenTransferVolumePasses(
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


### checkTotalSupplyVolatilityPasses

we create the 'data' variable which is simply a connection to the rule diamond
validation block
we procede to retrieve the rule
we perform the rule check
This means that the last trades "tradesWithinPeriod" were inside current period,
and we need to acumulate this trade to the those ones
if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)


```solidity
function checkTotalSupplyVolatilityPasses(
    uint32 _ruleId,
    int256 _volumeTotalForPeriod,
    uint256 _tokenTotalSupply,
    uint256 _supply,
    int256 _amount,
    uint64 _lastSupplyUpdateTime
) external view returns (int256, uint256);
```


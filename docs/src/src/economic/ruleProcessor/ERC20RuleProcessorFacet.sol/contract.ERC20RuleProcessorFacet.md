# ERC20RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/81964a0e15d7593cfe172486fd6691a89432c332/src/economic/ruleProcessor/ERC20RuleProcessorFacet.sol)

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


### checkTokenTransferVolumePasses

Allow List type
If Allow List Oracle rule active, address(0) is exempt to allow for burning
Deny List type
If Deny List Oracle rule active all transactions to addresses registered to deny list (including address(0)) will be denied.
Invalid oracle type

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
|`<none>`|`uint256`|_volume new accumulated volume|


### checkTotalSupplyVolatilityPasses

we create the 'data' variable which is simply a connection to the rule diamond
validation block
we procede to retrieve the rule
If the last trades "tradesWithinPeriod" were inside current period,
we need to acumulate this trade to the those ones. If not, reset to only current amount.
if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)

*Rule checks if the token total supply volatility rule will be violated.*


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
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule identifier for rule arguments|
|`_volumeTotalForPeriod`|`int256`|token's trading volume for the period|
|`_tokenTotalSupply`|`uint256`|the total supply from token tallies|
|`_supply`|`uint256`|token total supply value|
|`_amount`|`int256`|amount in the current transfer|
|`_lastSupplyUpdateTime`|`uint64`|the last timestamp the supply was updated|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|_volumeTotalForPeriod properly adjusted total for the current period|
|`<none>`|`uint256`|_tokenTotalSupply properly adjusted token total supply. This is necessary because if the token's total supply is used it skews results within the period|



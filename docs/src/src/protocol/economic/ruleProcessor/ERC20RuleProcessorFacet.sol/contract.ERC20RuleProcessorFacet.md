# ERC20RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IERC20Errors](/src/common/IErrors.sol/interface.IERC20Errors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Fee Rules on Accounts.

*Facet in charge of the logic to check token rules compliance*


## Functions
### checkTokenMinTransactionSize

*Check if transaction passes minTransfer rule.*


```solidity
function checkTokenMinTransactionSize(uint32 _ruleId, uint256 amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred|


### getMinimumTransferRule

*Function to get Minimum Transfer rules by index*


```solidity
function getMinimumTransferRule(uint32 _index) public view returns (NonTaggedRules.TokenMinimumTransferRule memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMinimumTransferRule`|Rule at index|


### getTotalTokenMinTransactionSize

*Function to get total Minimum Transfer rules*


```solidity
function getTotalTokenMinTransactionSize() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


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


### getAccountApproveDenyOracle

Allow List type
If Allow List Oracle rule active, address(0) is exempt to allow for burning
Deny List type
If Deny List Oracle rule active all transactions to addresses registered to deny list (including address(0)) will be denied.
Invalid oracle type

*Function get Oracle Rule by index*


```solidity
function getAccountApproveDenyOracle(uint32 _index) public view returns (NonTaggedRules.AccountApproveDenyOracle memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in storage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.AccountApproveDenyOracle`|AccountApproveDenyOracle at index|


### getTotalAccountApproveDenyOracles

*Function get total Oracle rules*


```solidity
function getTotalAccountApproveDenyOracles() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total oracleRules array length|


### checkTokenMaxTradingVolume

*Rule checks if the token transfer volume rule will be violated.*


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
|`<none>`|`uint256`|_volume new accumulated volume|


### getTokenMaxTradingVolume

we procede to retrieve the rule
If the last trades "tradesWithinPeriod" were inside current period,
we need to acumulate this trade to the those ones. If not, reset to only current amount.
if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)

*Function get Token Max Trading Volume by index*


```solidity
function getTokenMaxTradingVolume(uint32 _index) public view returns (NonTaggedRules.TokenMaxTradingVolume memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMaxTradingVolume`|TokenMaxTradingVolume rule at index position|


### getTotalTokenMaxTradingVolume

*Function to get total Token Transfer Volume rules*


```solidity
function getTotalTokenMaxTradingVolume() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkTokenMaxSupplyVolatility

*Rule checks if the token total supply volatility rule will be violated.*


```solidity
function checkTokenMaxSupplyVolatility(
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


### getSupplyVolatilityRule

we procede to retrieve the rule
check if totalSupply is specified in rule params
Account for the very first period
check if current transaction is inside rule period
if the totalSupply value is set in the rule, use that as the circulating supply. Otherwise, use the ERC20 totalSupply(sent from handler)
the _tokenTotalSupply is not modified during the rule period. It needs to stay the same value as what it was at the beginning of the period to keep consistent results since mints/burns change totalSupply in the token
update total supply of token when outside of rule period


```solidity
function getSupplyVolatilityRule(uint32 _index) public view returns (NonTaggedRules.SupplyVolatilityRule memory);
```

### getTotalSupplyVolatilityRules

*Function to get total Supply Volitility rules*


```solidity
function getTotalSupplyVolatilityRules() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenMaxSupplyVolatilityRules total length of array|



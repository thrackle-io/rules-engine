# ERC20RuleProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/5c20e54658e3206ed81b54d70494bea2d0a0e5dd/src/protocol/economic/ruleProcessor/ERC20RuleProcessorFacet.sol)

**Inherits:**
[IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IRuleProcessorErrors](/src/common/IErrors.sol/interface.IRuleProcessorErrors.md), [IERC20Errors](/src/common/IErrors.sol/interface.IERC20Errors.md)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Implements Token Fee Rules on Accounts.

*Facet in charge of the logic to check token rules compliance*


## State Variables
### _VOLUME_MULTIPLIER

```solidity
uint256 constant _VOLUME_MULTIPLIER = 10 ** 8;
```


### _BASIS_POINT

```solidity
uint256 constant _BASIS_POINT = 10000;
```


## Functions
### checkTokenMinTxSize

*Check if transaction passes Token Min Tx Size rule.*


```solidity
function checkTokenMinTxSize(uint32 _ruleId, uint256 amountToTransfer) external view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Identifier for rule arguments|
|`amountToTransfer`|`uint256`|total number of tokens to be transferred|


### getTokenMinTxSize

*Function to get Token Min Tx Size rules by index*


```solidity
function getTokenMinTxSize(uint32 _index) public view returns (NonTaggedRules.TokenMinTxSize memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMinTxSize`|Rule at index|


### getTotalTokenMinTxSize

*Function to get total Token Min Tx Size rules*


```solidity
function getTotalTokenMinTxSize() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


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


### checkAccountApproveDenyOracle

*This function receives a rule id, which it uses to get the oracle details, then calls the oracle to determine permissions.*


```solidity
function checkAccountApproveDenyOracle(uint32 _ruleId, address _address) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id|
|`_address`|`address`|user address to be checked|


### getAccountApproveDenyOracle

If Approve List Oracle rule active, address(0) is exempt to allow for burning

*Function get Account Approve Deny Oracle Rule by index*


```solidity
function getAccountApproveDenyOracle(uint32 _index)
    public
    view
    returns (NonTaggedRules.AccountApproveDenyOracle memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|Position of rule in storage|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.AccountApproveDenyOracle`|AccountApproveDenyOracle at index|


### getTotalAccountApproveDenyOracle

*Function get total Account Approve Deny Oracle rules*


```solidity
function getTotalAccountApproveDenyOracle() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|total accountApproveDenyOracleRules array length|


### checkTokenMaxTradingVolume

If the totalSupply value is set in the rule, it is set as the circulating supply. Otherwise, this function uses the ERC20 totalSupply sent from handler.

*Rule checks if the Token Max Trading Volume rule will be violated.*


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

*Function to get total Token Max Trading Volume rules*


```solidity
function getTotalTokenMaxTradingVolume() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|


### checkTokenMaxSupplyVolatility

If the totalSupply value is set in the rule, it is set as the circulating supply. Otherwise, this function uses the ERC20 totalSupply sent from handler.

*Rule checks if the Token Max Supply Volatility rule will be violated.*


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


### getTokenMaxSupplyVolatility

Account for the very first period
The _tokenTotalSupply is not modified during the rule period.
It needs to stay the same value as what it was at the beginning of the period to keep consistent results since mints/burns change totalSupply in the token.
Update total supply of token when outside of rule period

*Function to get Token Max Supply Volatility rule by index*


```solidity
function getTokenMaxSupplyVolatility(uint32 _index)
    public
    view
    returns (NonTaggedRules.TokenMaxSupplyVolatility memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMaxSupplyVolatility`|tokenMaxSupplyVolatility Rule|


### getTotalTokenMaxSupplyVolatility

*Function to get total Token Max Supply Volatility rules*


```solidity
function getTotalTokenMaxSupplyVolatility() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|tokenMaxSupplyVolatility Rules total length of array|


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


### getTokenMaxBuySellVolume

*Function get Token Max Buy Sell Volume by index*


```solidity
function getTokenMaxBuySellVolume(uint32 _index) public view returns (NonTaggedRules.TokenMaxBuySellVolume memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_index`|`uint32`|position of rule in array|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`NonTaggedRules.TokenMaxBuySellVolume`|tokenMaxSellVolumeRules rule at index position|


### getTotalTokenMaxBuySellVolume

*Function to get total Token Max Buy Sell Volume rules*


```solidity
function getTotalTokenMaxBuySellVolume() public view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|Total length of array|



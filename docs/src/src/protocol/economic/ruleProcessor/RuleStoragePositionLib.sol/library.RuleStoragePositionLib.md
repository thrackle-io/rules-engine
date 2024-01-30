# RuleStoragePositionLib
[Git Source](https://github.com/thrackle-io/tron/blob/a542d218e58cfe9de74725f5f4fd3ffef34da456/src/protocol/economic/ruleProcessor/RuleStoragePositionLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Library for Rules

*This contract serves as the storage library for the rules Diamond. It basically serves up the storage position for all rules*


## State Variables
### DIAMOND_CUT_STORAGE_POSITION

```solidity
bytes32 constant DIAMOND_CUT_STORAGE_POSITION = bytes32(uint256(keccak256("diamond-cut.storage")) - 1);
```


### ACCOUNT_MAX_BUY_SIZE_POSITION
every rule has its own storage


```solidity
bytes32 constant ACCOUNT_MAX_BUY_SIZE_POSITION = bytes32(uint256(keccak256("amm.purchase")) - 1);
```


### ACCOUNT_MAX_SELL_SIZE_POSITION

```solidity
bytes32 constant ACCOUNT_MAX_SELL_SIZE_POSITION = bytes32(uint256(keccak256("amm.sell")) - 1);
```


### ACCOUNT_MAX_BUY_VOLUME_POSITION

```solidity
bytes32 constant ACCOUNT_MAX_BUY_VOLUME_POSITION = bytes32(uint256(keccak256("amm.pct-purchase")) - 1);
```


### ACCOUNT_MAX_SELL_VOLUME_POSITION

```solidity
bytes32 constant ACCOUNT_MAX_SELL_VOLUME_POSITION = bytes32(uint256(keccak256("amm.pct.sell")) - 1);
```


### BUY_FEE_BY_TOKEN_MAX_TRADING_VOLUME_POSITION

```solidity
bytes32 constant BUY_FEE_BY_TOKEN_MAX_TRADING_VOLUME_POSITION = bytes32(uint256(keccak256("amm.fee-by-volume")) - 1);
```


### TOKEN_MAX_PRICE_VOLATILITY_POSITION

```solidity
bytes32 constant TOKEN_MAX_PRICE_VOLATILITY_POSITION = bytes32(uint256(keccak256("amm.price.volatility")) - 1);
```


### TOKEN_MAX_TRADING_VOLUME_POSITION

```solidity
bytes32 constant TOKEN_MAX_TRADING_VOLUME_POSITION = bytes32(uint256(keccak256("amm.volume")) - 1);
```


### WITHDRAWAL_RULE_POSITION

```solidity
bytes32 constant WITHDRAWAL_RULE_POSITION = bytes32(uint256(keccak256("vault.withdrawal")) - 1);
```


### ADMIN_MIN_TOKEN_BALANCE_POSITION

```solidity
bytes32 constant ADMIN_MIN_TOKEN_BALANCE_POSITION = bytes32(uint256(keccak256("vault.admin-withdrawal")) - 1);
```


### TOKEN_MIN_TX_SIZE_POSITION

```solidity
bytes32 constant TOKEN_MIN_TX_SIZE_POSITION = bytes32(uint256(keccak256("token.min-transfer")) - 1);
```


### ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION

```solidity
bytes32 constant ACCOUNT_MIN_MAX_TOKEN_BALANCE_POSITION = bytes32(uint256(keccak256("token.min-max-balance-limit")) - 1);
```


### TOKEN_MAX_SUPPLY_VOLATILITY_POSITION

```solidity
bytes32 constant TOKEN_MAX_SUPPLY_VOLATILITY_POSITION = bytes32(uint256(keccak256("token.supply-volatility")) - 1);
```


### ACC_APPROVE_DENY_ORACLE_POSITION

```solidity
bytes32 constant ACC_APPROVE_DENY_ORACLE_POSITION = bytes32(uint256(keccak256("all.oracle")) - 1);
```


### ACC_MAX_VALUE_BY_ACCESS_LEVEL_POSITION

```solidity
bytes32 constant ACC_MAX_VALUE_BY_ACCESS_LEVEL_POSITION = bytes32(uint256(keccak256("token.access")) - 1);
```


### TX_SIZE_TO_RISK_RULE_POSITION

```solidity
bytes32 constant TX_SIZE_TO_RISK_RULE_POSITION = bytes32(uint256(keccak256("token.tx-size-to-risk")) - 1);
```


### ACC_MAX_TX_VALUE_BY_RISK_SCORE

```solidity
bytes32 constant ACC_MAX_TX_VALUE_BY_RISK_SCORE =
    bytes32(uint256(keccak256("token.tx-size-per-period-to-risk")) - 1);
```


### ACCOUNT_MAX_VALUE_BY_RISK_SCORE_POSITION

```solidity
bytes32 constant ACCOUNT_MAX_VALUE_BY_RISK_SCORE_POSITION = bytes32(uint256(keccak256("token.balance-limit-to-risk")) - 1);
```


### TOKEN_MAX_DAILY_TRADES_POSITION

```solidity
bytes32 constant TOKEN_MAX_DAILY_TRADES_POSITION = bytes32(uint256(keccak256("NFT.transfer-rule")) - 1);
```


### MIN_BAL_BY_DATE_RULE_POSITION

```solidity
bytes32 constant MIN_BAL_BY_DATE_RULE_POSITION = bytes32(uint256(keccak256("token.min-bal-by-date-rule")) - 1);
```


### AMM_FEE_RULE_POSITION

```solidity
bytes32 constant AMM_FEE_RULE_POSITION = bytes32(uint256(keccak256("AMM.fee-rule")) - 1);
```


### ACC_MAX_VALUE_OUT_ACCESS_LEVEL_POSITION

```solidity
bytes32 constant ACC_MAX_VALUE_OUT_ACCESS_LEVEL_POSITION =
    bytes32(uint256(keccak256("token.access-level-withdrawal-rule")) - 1);
```


## Functions
### purchaseStorage

*Function to store Purchase rules*


```solidity
function purchaseStorage() internal pure returns (IRuleStorage.PurchaseRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.PurchaseRuleS`|Data Storage of Purchase Rule|


### accountMaxSellSizeStorage

*Function to store Sell rules*


```solidity
function accountMaxSellSizeStorage() internal pure returns (IRuleStorage.SellRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.SellRuleS`|Data Storage of Sell Rule|


### accountMaxBuyVolumeStorage

*Function to store Percent Purchase rules*


```solidity
function accountMaxBuyVolumeStorage() internal pure returns (IRuleStorage.TokenMaxBuyVolumeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMaxBuyVolumeS`|Data Storage of Percent Purchase Rule|


### accountMaxSellVolumeStorage

*Function to store Percent Sell rules*


```solidity
function accountMaxSellVolumeStorage() internal pure returns (IRuleStorage.TokenMaxSellVolumeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMaxSellVolumeS`|Data Storage of Percent Sell Rule|


### purchaseFeeByVolumeStorage

*Function to store Purchase Fee by Volume rules*


```solidity
function purchaseFeeByVolumeStorage() internal pure returns (IRuleStorage.PurchaseFeeByVolRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.PurchaseFeeByVolRuleS`|Data Storage of Purchase Fee by Volume Rule|


### tokenMaxPriceVolatilityStrorage

*Function to store Price Volitility rules*


```solidity
function tokenMaxPriceVolatilityStrorage() internal pure returns (IRuleStorage.TokenMaxPriceVolatilityS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMaxPriceVolatilityS`|Data Storage of Price Volitility Rule|


### tokenMaxTradingVolumeStorage

*Function to store Volume rules*


```solidity
function tokenMaxTradingVolumeStorage() internal pure returns (IRuleStorage.TransferVolRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TransferVolRuleS`|Data Storage of Volume Rule|


### withdrawalStorage

*Function to store Withdrawal rules*


```solidity
function withdrawalStorage() internal pure returns (IRuleStorage.WithdrawalRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.WithdrawalRuleS`|Data Storage of Withdrawal Rule|


### adminMinTokenBalanceStorage

*Function to store AppAdministrator Withdrawal rules*


```solidity
function adminMinTokenBalanceStorage() internal pure returns (IRuleStorage.AdminMinTokenBalanceS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AdminMinTokenBalanceS`|Data Storage of AppAdministrator Withdrawal Rule|


### tokenMinTxSizePosition

*Function to store Minimum Transfer rules*


```solidity
function tokenMinTxSizePosition() internal pure returns (IRuleStorage.TokenMinTransactionSizeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMinTransactionSizeS`|Data Storage of Minimum Transfer Rule|


### minMaxBalanceStorage

*Function to store Balance Limit rules*


```solidity
function minMaxBalanceStorage() internal pure returns (IRuleStorage.MinMaxBalanceRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.MinMaxBalanceRuleS`|Data Storage of Balance Limit Rule|


### tokenMaxSupplyVolatilityStorage

*Function to store Supply Volitility rules*


```solidity
function tokenMaxSupplyVolatilityStorage() internal pure returns (IRuleStorage.TokenMaxSupplyVolatilityS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMaxSupplyVolatilityS`|Data Storage of Supply Volitility Rule|


### accountApproveDenyOracleStorage

*Function to store Oracle rules*


```solidity
function accountApproveDenyOracleStorage() internal pure returns (IRuleStorage.AccountApproveDenyOracleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccountApproveDenyOracleS`|Data Storage of Oracle Rule|


### accountMaxValueByAccessLevelStorage

*Function to store AccessLevel rules*


```solidity
function accountMaxValueByAccessLevelStorage() internal pure returns (IRuleStorage.MaxValueByAccessLevelS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.MaxValueByAccessLevelS`|Data Storage of AccessLevel Rule|


### txSizeToRiskStorage

*Function to store Transaction Size by Risk rules*


```solidity
function txSizeToRiskStorage() internal pure returns (IRuleStorage.TxSizeToRiskRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TxSizeToRiskRuleS`|Data Storage of Transaction Size by Risk Rule|


### accountMaxTxValueByRiskScoreStorage

*Function to store Transaction Size by Risk per Period rules*


```solidity
function accountMaxTxValueByRiskScoreStorage() internal pure returns (IRuleStorage.AccountMaxTransactionValueByRiskScoreS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccountMaxTransactionValueByRiskScoreS`|Data Storage of Transaction Size by Risk per Period Rule|


### accountMaxValueByRiskScoreStorage

*Function to store Account Balance rules*


```solidity
function accountMaxValueByRiskScoreStorage() internal pure returns (IRuleStorage.AccountMaxValueByRiskScoreS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccountMaxValueByRiskScoreS`|Data Storage of Account Balance Rule|


### TokenMaxDailyTradesStorage

*Function to store NFT Transfer rules*


```solidity
function TokenMaxDailyTradesStorage() internal pure returns (IRuleStorage.TokenMaxDailyTradesS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TokenMaxDailyTradesS`|Data Storage of NFT Transfer rule|


### ammFeeRuleStorage

*Function to store AMM Fee rules*


```solidity
function ammFeeRuleStorage() internal pure returns (IRuleStorage.AMMFeeRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AMMFeeRuleS`|Data Storage of AMM Fee rule|


### minBalByDateRuleStorage

*Function to store Minimum Balance By Date rules*


```solidity
function minBalByDateRuleStorage() internal pure returns (IRuleStorage.MinBalByDateRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.MinBalByDateRuleS`|Data Storage of Minimum Balance by Date rule|


### accountMaxValueOutByAccessLevelStorage

*Function to store Access Level Withdrawal rules*


```solidity
function accountMaxValueOutByAccessLevelStorage() internal pure returns (IRuleStorage.AccountMaxValueOutByAccessLevelS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccountMaxValueOutByAccessLevelS`|Data Storage of Access Level Withdrawal rule|



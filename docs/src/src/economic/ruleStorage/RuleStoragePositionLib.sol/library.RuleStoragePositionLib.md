# RuleStoragePositionLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/b3877670eae43a9723081d42c4401502ebd5b9f6/src/economic/ruleStorage/RuleStoragePositionLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Library for Rules

*This contract serves as the storage library for the rules Diamond*


## State Variables
### DIAMOND_CUT_STORAGE_POSITION

```solidity
bytes32 constant DIAMOND_CUT_STORAGE_POSITION = keccak256("diamond-cut.storage");
```


### PURCHASE_RULE_POSITION
every rule has its own storage


```solidity
bytes32 constant PURCHASE_RULE_POSITION = keccak256("amm.purchase");
```


### SELL_RULE_POSITION

```solidity
bytes32 constant SELL_RULE_POSITION = keccak256("amm.sell");
```


### PCT_PURCHASE_RULE_POSITION

```solidity
bytes32 constant PCT_PURCHASE_RULE_POSITION = keccak256("amm.pct-purchase");
```


### PCT_SELL_RULE_POSITION

```solidity
bytes32 constant PCT_SELL_RULE_POSITION = keccak256("amm.pct.sell");
```


### PURCHASE_FEE_BY_VOLUME_RULE_POSITION

```solidity
bytes32 constant PURCHASE_FEE_BY_VOLUME_RULE_POSITION = keccak256("amm.fee-by-volume");
```


### PRICE_VOLATILITY_RULE_POSITION

```solidity
bytes32 constant PRICE_VOLATILITY_RULE_POSITION = keccak256("amm.price.volatility");
```


### VOLUME_RULE_POSITION

```solidity
bytes32 constant VOLUME_RULE_POSITION = keccak256("amm.volume");
```


### WITHDRAWAL_RULE_POSITION

```solidity
bytes32 constant WITHDRAWAL_RULE_POSITION = keccak256("vault.withdrawal");
```


### ADMIN_WITHDRAWAL_RULE_POSITION

```solidity
bytes32 constant ADMIN_WITHDRAWAL_RULE_POSITION = keccak256("vault.admin-withdrawal");
```


### MIN_TRANSFER_RULE_POSITION

```solidity
bytes32 constant MIN_TRANSFER_RULE_POSITION = keccak256("token.min-transfer");
```


### BALANCE_LIMIT_RULE_POSITION

```solidity
bytes32 constant BALANCE_LIMIT_RULE_POSITION = keccak256("token.balance-limit");
```


### SUPPLY_VOLATILITY_RULE_POSITION

```solidity
bytes32 constant SUPPLY_VOLATILITY_RULE_POSITION = keccak256("token.supply-volatility");
```


### ORACLE_RULE_POSITION

```solidity
bytes32 constant ORACLE_RULE_POSITION = keccak256("all.oracle");
```


### AccessLevel_RULE_POSITION

```solidity
bytes32 constant AccessLevel_RULE_POSITION = keccak256("token.access");
```


### TX_SIZE_TO_RISK_RULE_POSITION

```solidity
bytes32 constant TX_SIZE_TO_RISK_RULE_POSITION = keccak256("token.tx-size-to-risk");
```


### TX_SIZE_PER_PERIOD_TO_RISK_RULE_POSITION

```solidity
bytes32 constant TX_SIZE_PER_PERIOD_TO_RISK_RULE_POSITION = keccak256("token.tx-size-per-period-to-risk");
```


### BALANCE_LIMIT_TO_RISK_RULE_POSITION

```solidity
bytes32 constant BALANCE_LIMIT_TO_RISK_RULE_POSITION = keccak256("token.balance-limit-to-risk");
```


### NFT_TRANSFER_RULE_POSITION

```solidity
bytes32 constant NFT_TRANSFER_RULE_POSITION = keccak256("NFT.transfer-rule");
```


### MIN_BAL_BY_DATE_RULE_POSITION

```solidity
bytes32 constant MIN_BAL_BY_DATE_RULE_POSITION = keccak256("token.min-bal-by-date-rule");
```


### AMM_FEE_RULE_POSITION

```solidity
bytes32 constant AMM_FEE_RULE_POSITION = keccak256("AMM.fee-rule");
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


### sellStorage

*Function to store Sell rules*


```solidity
function sellStorage() internal pure returns (IRuleStorage.SellRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.SellRuleS`|Data Storage of Sell Rule|


### pctPurchaseStorage

*Function to store Percent Purchase rules*


```solidity
function pctPurchaseStorage() internal pure returns (IRuleStorage.PctPurchaseRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.PctPurchaseRuleS`|Data Storage of Percent Purchase Rule|


### pctSellStorage

*Function to store Percent Sell rules*


```solidity
function pctSellStorage() internal pure returns (IRuleStorage.PctSellRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.PctSellRuleS`|Data Storage of Percent Sell Rule|


### purchaseFeeByVolumeStorage

*Function to store Purchase Fee by Volume rules*


```solidity
function purchaseFeeByVolumeStorage() internal pure returns (IRuleStorage.PurchaseFeeByVolRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.PurchaseFeeByVolRuleS`|Data Storage of Purchase Fee by Volume Rule|


### priceVolatilityStorage

*Function to store Price Volitility rules*


```solidity
function priceVolatilityStorage() internal pure returns (IRuleStorage.VolatilityRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.VolatilityRuleS`|Data Storage of Price Volitility Rule|


### volumeStorage

*Function to store Volume rules*


```solidity
function volumeStorage() internal pure returns (IRuleStorage.TradingVolRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TradingVolRuleS`|Data Storage of Volume Rule|


### withdrawalStorage

*Function to store Withdrawal rules*


```solidity
function withdrawalStorage() internal pure returns (IRuleStorage.WithdrawalRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.WithdrawalRuleS`|Data Storage of Withdrawal Rule|


### adminWithdrawalStorage

*Function to store AppAdministrator Withdrawal rules*


```solidity
function adminWithdrawalStorage() internal pure returns (IRuleStorage.AdminWithdrawalRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AdminWithdrawalRuleS`|Data Storage of AppAdministrator Withdrawal Rule|


### minTransferStorage

*Function to store Minimum Transfer rules*


```solidity
function minTransferStorage() internal pure returns (IRuleStorage.MinTransferRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.MinTransferRuleS`|Data Storage of Minimum Transfer Rule|


### balanceLimitStorage

*Function to store Balance Limit rules*


```solidity
function balanceLimitStorage() internal pure returns (IRuleStorage.BalanceLimitRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.BalanceLimitRuleS`|Data Storage of Balance Limit Rule|


### supplyVolatilityStorage

*Function to store Supply Volitility rules*


```solidity
function supplyVolatilityStorage() internal pure returns (IRuleStorage.SupplyVolatilityRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.SupplyVolatilityRuleS`|Data Storage of Supply Volitility Rule|


### oracleStorage

*Function to store Oracle rules*


```solidity
function oracleStorage() internal pure returns (IRuleStorage.OracleRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.OracleRuleS`|Data Storage of Oracle Rule|


### accessStorage

*Function to store AccessLevel rules*


```solidity
function accessStorage() internal pure returns (IRuleStorage.AccessLevelRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccessLevelRuleS`|Data Storage of AccessLevel Rule|


### txSizeToRiskStorage

*Function to store Transaction Size by Risk rules*


```solidity
function txSizeToRiskStorage() internal pure returns (IRuleStorage.TxSizeToRiskRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TxSizeToRiskRuleS`|Data Storage of Transaction Size by Risk Rule|


### txSizePerPeriodToRiskStorage

*Function to store Transaction Size by Risk per Period rules*


```solidity
function txSizePerPeriodToRiskStorage() internal pure returns (IRuleStorage.TxSizePerPeriodToRiskRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.TxSizePerPeriodToRiskRuleS`|Data Storage of Transaction Size by Risk per Period Rule|


### accountBalanceToRiskStorage

*Function to store Account Balance rules*


```solidity
function accountBalanceToRiskStorage() internal pure returns (IRuleStorage.AccountBalanceToRiskRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.AccountBalanceToRiskRuleS`|Data Storage of Account Balance Rule|


### nftTransferStorage

*Function to store NFT Transfer rules*


```solidity
function nftTransferStorage() internal pure returns (IRuleStorage.NFTTransferCounterRuleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`IRuleStorage.NFTTransferCounterRuleS`|Data Storage of NFT Transfer rule|


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



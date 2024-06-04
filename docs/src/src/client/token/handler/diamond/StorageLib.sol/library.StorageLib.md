# StorageLib
[Git Source](https://github.com/thrackle-io/tron/blob/16aa388bf7edf8163f2f93600ba5d420a17a40c0/src/client/token/handler/diamond/StorageLib.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Library for Rules

*This contract serves as the storage library for the rules Diamond. It basically serves up the storage position for all rules*


## State Variables
### DIAMOND_CUT_STORAGE_HANDLER_POS

```solidity
bytes32 constant DIAMOND_CUT_STORAGE_HANDLER_POS = bytes32(uint256(keccak256("diamond-cut.storage-handler")) - 1);
```


### ACCOUNT_APPROVE_DENY_ORACLE_HANDLER_POSITION

```solidity
bytes32 constant ACCOUNT_APPROVE_DENY_ORACLE_HANDLER_POSITION =
    bytes32(uint256(keccak256("account-approve-deny-oracle-position")) - 1);
```


### ACCOUNT_MIN_MAX_TOKEN_BALANCE_HANDLER_POSITION

```solidity
bytes32 constant ACCOUNT_MIN_MAX_TOKEN_BALANCE_HANDLER_POSITION =
    bytes32(uint256(keccak256("account-min-max-token-balance-position")) - 1);
```


### HANDLER_BASE_POSITION

```solidity
bytes32 constant HANDLER_BASE_POSITION = bytes32(uint256(keccak256("handler-base-position")) - 1);
```


### FEES_HANDLER_POSITION

```solidity
bytes32 constant FEES_HANDLER_POSITION = bytes32(uint256(keccak256("fees-position")) - 1);
```


### TOKEN_MAX_SUPPLY_VOLATILITY_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MAX_SUPPLY_VOLATILITY_HANDLER_POSITION =
    bytes32(uint256(keccak256("token-max-supply-volatility-position")) - 1);
```


### TOKEN_MAX_TRADING_VOLUME_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MAX_TRADING_VOLUME_HANDLER_POSITION =
    bytes32(uint256(keccak256("token-max-trading-volume-position")) - 1);
```


### TOKEN_MIN_TX_SIZE_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MIN_TX_SIZE_HANDLER_POSITION = bytes32(uint256(keccak256("token-min-tx-size-position")) - 1);
```


### TOKEN_MIN_HOLD_TIME_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MIN_HOLD_TIME_HANDLER_POSITION = bytes32(uint256(keccak256("token-min-hold-time-position")) - 1);
```


### TOKEN_MAX_DAILY_TRADES_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MAX_DAILY_TRADES_HANDLER_POSITION =
    bytes32(uint256(keccak256("nft-max-daily-trades-position")) - 1);
```


### NFT_VALUATION_LIMIT_POSITION

```solidity
bytes32 constant NFT_VALUATION_LIMIT_POSITION = bytes32(uint256(keccak256("nft-valuation-position")) - 1);
```


### INITIALIZED_POSITION

```solidity
bytes32 constant INITIALIZED_POSITION = bytes32(uint256(keccak256("initialized-position")) - 1);
```


### TOKEN_MAX_BUY_SELL_VOLUME_HANDLER_POSITION

```solidity
bytes32 constant TOKEN_MAX_BUY_SELL_VOLUME_HANDLER_POSITION =
    bytes32(uint256(keccak256("token-max-buy-sell-position")) - 1);
```


### ACCOUNT_MAX_TRADE_SIZE_HANDLER_POSITION

```solidity
bytes32 constant ACCOUNT_MAX_TRADE_SIZE_HANDLER_POSITION =
    bytes32(uint256(keccak256("account-max-trading-size-handler-postion")) - 1);
```


### HANDLER_VERSION_POSITION

```solidity
bytes32 constant HANDLER_VERSION_POSITION = bytes32(uint256(keccak256("handler-version-position")) - 1);
```


## Functions
### handlerVersionStorage

*Function to store the Initialized flag*


```solidity
function handlerVersionStorage() internal pure returns (HandlerVersionS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`HandlerVersionS`|Data Storage of the Initialized flag|


### initializedStorage

*Function to store the Initialized flag*


```solidity
function initializedStorage() internal pure returns (InitializedS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`InitializedS`|Data Storage of the Initialized flag|


### handlerBaseStorage

*Function to store Handler Base*


```solidity
function handlerBaseStorage() internal pure returns (HandlerBaseS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`HandlerBaseS`|Data Storage of Handler Base|


### feeStorage

*Function to store the fees*


```solidity
function feeStorage() internal pure returns (FeeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`FeeS`|Data Storage of Fees|


### accountMaxTradeSizeStorage

*Function to store Max Trade Size rules*


```solidity
function accountMaxTradeSizeStorage() internal pure returns (AccountMaxTradeSizeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`AccountMaxTradeSizeS`|Data Storage of Max Trade Size Rule|


### tokenMaxBuySellVolumeStorage

*Function to store Token Max Buy Sell Volume rules*


```solidity
function tokenMaxBuySellVolumeStorage() internal pure returns (TokenMaxBuySellVolumeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMaxBuySellVolumeS`|Data Storage of Token Max Buy Sell Volume Rule|


### tokenMaxTradingVolumeStorage

*Function to store Max Trading Volume rules*


```solidity
function tokenMaxTradingVolumeStorage() internal pure returns (TokenMaxTradingVolumeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMaxTradingVolumeS`|Data Storage of Max Trading Volume Rule|


### tokenMaxDailyTradesStorage

*Function to store Max Daily Trade rules*


```solidity
function tokenMaxDailyTradesStorage() internal pure returns (TokenMaxDailyTradesS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMaxDailyTradesS`|Data Storage of Max Daily Trade Rule|


### tokenMinTxSizeStorage

*Function to store Token Min Transaction Size rules*


```solidity
function tokenMinTxSizeStorage() internal pure returns (TokenMinTxSizeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMinTxSizeS`|Data Storage of Token Min Transaction Size Rule|


### accountMinMaxTokenBalanceStorage

*Function to store Account Min Max Token Balance rules*


```solidity
function accountMinMaxTokenBalanceStorage() internal pure returns (AccountMinMaxTokenBalanceHandlerS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`AccountMinMaxTokenBalanceHandlerS`|Data Storage of Account Min Max Token Balance Rule|


### tokenMaxSupplyVolatilityStorage

*Function to store Max Supply Volitility rules*


```solidity
function tokenMaxSupplyVolatilityStorage() internal pure returns (TokenMaxSupplyVolatilityS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMaxSupplyVolatilityS`|Data Storage of Max Supply Volitility Rule|


### accountApproveDenyOracleStorage

*Function to store Oracle rules*


```solidity
function accountApproveDenyOracleStorage() internal pure returns (AccountApproveDenyOracleS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`AccountApproveDenyOracleS`|Data Storage of Oracle Rule|


### tokenMinHoldTimeStorage

*Function to store Token Min Hold Time*


```solidity
function tokenMinHoldTimeStorage() internal pure returns (TokenMinHoldTimeS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`TokenMinHoldTimeS`|Data Storage of Token Min Hold Time|


### nftValuationLimitStorage

*Function to store NFT Valuation Limit storage*


```solidity
function nftValuationLimitStorage() internal pure returns (NFTValuationLimitS storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`NFTValuationLimitS`|Data Storage of NFT Valuation Limit|



# ProtocolApplicationHandler
[Git Source](https://github.com/thrackle-io/tron/blob/3cbe4e765eb8a4f99ff305a3831acec21bbc5481/src/client/application/ProtocolApplicationHandler.sol)

**Inherits:**
Ownable, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IApplicationHandlerEvents](/src/common/IEvents.sol/interface.IApplicationHandlerEvents.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IAppHandlerErrors](/src/common/IErrors.sol/interface.IAppHandlerErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the rules handler for all application level rules. It is implemented via the AppManager

*This contract is injected into the appManagers.*


## State Variables
### VERSION

```solidity
string private constant VERSION = "1.1.0";
```


### appManager

```solidity
AppManager immutable appManager;
```


### appManagerAddress

```solidity
address public immutable appManagerAddress;
```


### ruleProcessor

```solidity
IRuleProcessor immutable ruleProcessor;
```


### accountMaxValueByRiskScoreId
Risk Rule Ids


```solidity
uint32 private accountMaxValueByRiskScoreId;
```


### accountMaxTransactionValueByRiskScoreId

```solidity
uint32 private accountMaxTransactionValueByRiskScoreId;
```


### accountMaxValueByRiskScoreActive
Risk Rule on-off switches


```solidity
bool private accountMaxValueByRiskScoreActive;
```


### accountMaxTransactionValueByRiskScoreActive

```solidity
bool private accountMaxTransactionValueByRiskScoreActive;
```


### accountMaxValueByAccessLevelId
AccessLevel Rule Ids


```solidity
uint32 private accountMaxValueByAccessLevelId;
```


### accountMaxValueOutByAccessLevelId

```solidity
uint32 private accountMaxValueOutByAccessLevelId;
```


### accountMaxValueByAccessLevelActive
AccessLevel Rule on-off switches


```solidity
bool private accountMaxValueByAccessLevelActive;
```


### AccountDenyForNoAccessLevelRuleActive

```solidity
bool private AccountDenyForNoAccessLevelRuleActive;
```


### accountMaxValueOutByAccessLevelActive

```solidity
bool private accountMaxValueOutByAccessLevelActive;
```


### pauseRuleActive
Pause Rule on-off switch


```solidity
bool private pauseRuleActive;
```


### erc20Pricer
Pricing Module interfaces


```solidity
IProtocolERC20Pricing erc20Pricer;
```


### nftPricer

```solidity
IProtocolERC721Pricing nftPricer;
```


### erc20PricingAddress

```solidity
address public erc20PricingAddress;
```


### nftPricingAddress

```solidity
address public nftPricingAddress;
```


### usdValueTransactedInRiskPeriod
MaxTxSizePerPeriodByRisk data


```solidity
mapping(address => uint128) usdValueTransactedInRiskPeriod;
```


### lastTxDateRiskRule

```solidity
mapping(address => uint64) lastTxDateRiskRule;
```


### usdValueTotalWithrawals
AdminMinTokenBalanceRule data


```solidity
mapping(address => uint128) usdValueTotalWithrawals;
```


## Functions
### constructor

*Initializes the contract setting the AppManager address as the one provided and setting the ruleProcessor for protocol access*


```solidity
constructor(address _ruleProcessorProxyAddress, address _appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleProcessorProxyAddress`|`address`|of the protocol's Rule Processor contract.|
|`_appManagerAddress`|`address`|address of the application AppManager.|


### requireApplicationRulesChecked

*checks if any of the Application level rules are active*


```solidity
function requireApplicationRulesChecked() public view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if one or more rules are active|


### checkApplicationRules

*Check Application Rules for valid transaction.*


```solidity
function checkApplicationRules(
    address _tokenAddress,
    address _from,
    address _to,
    uint256 _amount,
    uint16 _nftValuationLimit,
    uint256 _tokenId,
    ActionTypes _action,
    HandlerTypes _handlerType
) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`||
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|amount of tokens to be transferred|
|`_nftValuationLimit`|`uint16`|number of tokenID's per collection before checking collection price vs individual token price|
|`_tokenId`|`uint256`|tokenId of the NFT token|
|`_action`|`ActionTypes`|Action to be checked. This param is intentially added for future enhancements.|
|`_handlerType`|`HandlerTypes`|the type of handler, used to direct to correct token pricing|


### _checkRiskRules

Based on the Handler Type retrieve pricing valuations

*This function consolidates all the Risk rule checks.*


```solidity
function _checkRiskRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_balanceValuation`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_transferValuation`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### _checkAccessLevelRules

*This function consolidates all the Access Level rule checks.*


```solidity
function _checkAccessLevelRules(address _from, address _to, uint128 _balanceValuation, uint128 _transferValuation)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`||
|`_to`|`address`|address of the to account|
|`_balanceValuation`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_transferValuation`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### setNFTPricingAddress

Exempting address(0) allows for burning.
-------------- Pricing Module Configurations ---------------

*Sets the address of the nft pricing contract and loads the contract.*


```solidity
function setNFTPricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Nft Pricing Contract address.|


### setERC20PricingAddress

*Sets the address of the erc20 pricing contract and loads the contract.*


```solidity
function setERC20PricingAddress(address _address) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|ERC20 Pricing Contract address.|


### getAccTotalValuation

This gets the account's balance in dollars.

*Get the account's balance in dollars. It uses the registered tokens in the app manager.*


```solidity
function getAccTotalValuation(address _account, uint256 _nftValuationLimit)
    public
    view
    returns (uint256 totalValuation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address to get the balance for|
|`_nftValuationLimit`|`uint256`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValuation`|`uint256`|of the account in dollars|


### _getERC20Price

check if _account is zero address. If zero address we return a valuation of zero to allow for burning tokens when rules that need valuations are active.
Loop through all Nfts and ERC20s and add values to balance for account valuation
Check to see if user owns the asset

This gets the token's value in dollars.

*Get the value for a specific ERC20. This is done by interacting with the pricing module*


```solidity
function _getERC20Price(address _tokenAddress) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|price the price of 1 in dollars|


### _getNFTValuePerCollection

This gets the token's value in dollars.

*Get the value for a specific ERC721. This is done by interacting with the pricing module*


```solidity
function _getNFTValuePerCollection(address _tokenAddress, address _account, uint256 _tokenAmount)
    internal
    view
    returns (uint256 totalValueInThisContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|
|`_account`|`address`|of the token holder|
|`_tokenAmount`|`uint256`|amount of NFTs from _tokenAddress contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValueInThisContract`|`uint256`|in whole USD|


### _getNFTCollectionValue

This function gets the total token value in dollars of all tokens owned in each collection by address.

*Get the total value for all tokens held by a wallet for a specific collection. This is done by interacting with the pricing module*


```solidity
function _getNFTCollectionValue(address _tokenAddress, uint256 _tokenAmount)
    private
    view
    returns (uint256 totalValueInThisContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the token|
|`_tokenAmount`|`uint256`|amount of NFTs from _tokenAddress contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`totalValueInThisContract`|`uint256`|total valuation of tokens by collection in whole USD|


### setAccountMaxValueByRiskScoreId

that setting a rule will automatically activate it.

*Set the accountMaxValueByRiskScoreRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByRiskScoreActive

*Tells you if the accountMaxValueByRiskScore Rule is active or not.*


```solidity
function isAccountMaxValueByRiskScoreActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByRiskScoreId

*Retrieve the accountMaxValueByRiskScore Rule id*


```solidity
function getAccountMaxValueByRiskScoreId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueByRiskScoreId rule id|


### setAccountMaxValueByAccessLevelId

that setting a rule will automatically activate it.

*Set the accountMaxValueByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByAccessLevelActive

*Tells you if the accountMaxValueByAccessLevel Rule is active or not.*


```solidity
function isAccountMaxValueByAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByAccessLevelId

*Retrieve the accountMaxValueByAccessLevel rule id*


```solidity
function getAccountMaxValueByAccessLevelId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueByAccessLevelId rule id|


### activateAccountDenyForNoAccessLevelRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountDenyForNoAccessLevelRule(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountDenyForNoAccessLevelActive

*Tells you if the AccountDenyForNoAccessLevel Rule is active or not.*


```solidity
function isAccountDenyForNoAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setAccountMaxValueOutByAccessLevelId

that setting a rule will automatically activate it.

*Set the accountMaxValueOutByAccessLevel Rule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueOutByAccessLevelId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueOutByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueOutByAccessLevel(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueOutByAccessLevelActive

*Tells you if the accountMaxValueOutByAccessLevel Rule is active or not.*


```solidity
function isAccountMaxValueOutByAccessLevelActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueOutByAccessLevelId

*Retrieve the accountMaxValueOutByAccessLevel Rule rule id*


```solidity
function getAccountMaxValueOutByAccessLevelId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueOutByAccessLevelId rule id|


### getAccountMaxTxValueByRiskScoreId

*Retrieve the AccountMaxTransactionValueByRiskScore rule id*


```solidity
function getAccountMaxTxValueByRiskScoreId() external view returns (uint32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxTransactionValueByRiskScoreId rule id for specified token|


### setAccountMaxTxValueByRiskScoreId

that setting a rule will automatically activate it.

*Set the AccountMaxTransactionValueByRiskScore Rule. Restricted to app administrators only.*


```solidity
function setAccountMaxTxValueByRiskScoreId(uint32 _ruleId) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxTxValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxTxValueByRiskScore(bool _on) external ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxTxValueByRiskScoreActive

*Tells you if the accountMaxTransactionValueByRiskScore Rule is active or not.*


```solidity
function isAccountMaxTxValueByRiskScoreActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active for specified token|


### activatePauseRule

This function uses the onlyOwner modifier since the appManager contract is calling this function when adding a pause rule or removing the final pause rule of the array.

*enable/disable rule. Disabling a rule will save gas on transfer transactions.
This function does not use ruleAdministratorOnly modifier, the onlyOwner modifier checks that the caller is the appManager contract.*


```solidity
function activatePauseRule(bool _on) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isPauseRuleActive

*Tells you if the pause rule check is active or not.*


```solidity
function isPauseRuleActive() external view returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active for specified token|


### version

*gets the version of the contract*


```solidity
function version() external pure returns (string memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|VERSION|



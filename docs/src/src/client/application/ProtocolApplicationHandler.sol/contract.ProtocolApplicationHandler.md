# ProtocolApplicationHandler
[Git Source](https://github.com/thrackle-io/rules-engine/blob/0add9b8cd140006448dad92dd54fc23fca23f012/src/client/application/ProtocolApplicationHandler.sol)

**Inherits:**
[ActionTypesArray](/src/client/common/ActionTypesArray.sol/contract.ActionTypesArray.md), Ownable, [RuleAdministratorOnly](/src/protocol/economic/RuleAdministratorOnly.sol/contract.RuleAdministratorOnly.md), [IApplicationHandlerEvents](/src/common/IEvents.sol/interface.IApplicationHandlerEvents.md), [ICommonApplicationHandlerEvents](/src/common/IEvents.sol/interface.ICommonApplicationHandlerEvents.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IAppHandlerErrors](/src/common/IErrors.sol/interface.IAppHandlerErrors.md), [ProtocolApplicationHandlerCommon](/src/client/application/ProtocolApplicationHandlerCommon.sol/abstract.ProtocolApplicationHandlerCommon.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the rules handler for all application level rules. It is implemented via the AppManager

*This contract is injected into the appManagers.*


## State Variables
### VERSION

```solidity
string private constant VERSION = "2.1.0";
```


### appManager

```solidity
IAppManager immutable appManager;
```


### appManagerAddress

```solidity
address public immutable appManagerAddress;
```


### ruleProcessor

```solidity
IRuleProcessor immutable ruleProcessor;
```


### ruleProcessorAddress

```solidity
address public immutable ruleProcessorAddress;
```


### accountMaxValueByAccessLevel
Rule mappings


```solidity
mapping(ActionTypes => Rule) accountMaxValueByAccessLevel;
```


### accountMaxValueByRiskScore

```solidity
mapping(ActionTypes => Rule) accountMaxValueByRiskScore;
```


### accountMaxTxValueByRiskScore

```solidity
mapping(ActionTypes => Rule) accountMaxTxValueByRiskScore;
```


### accountMaxValueOutByAccessLevel

```solidity
mapping(ActionTypes => Rule) accountMaxValueOutByAccessLevel;
```


### accountDenyForNoAccessLevel

```solidity
mapping(ActionTypes => Rule) accountDenyForNoAccessLevel;
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


### _checkWhichApplicationRulesActive


```solidity
function _checkWhichApplicationRulesActive(ActionTypes _action) internal view returns (bool);
```

### _checkNonCustodialRules


```solidity
function _checkNonCustodialRules(ActionTypes _action) internal view returns (bool);
```

### requireApplicationRulesChecked

*checks if any of the Application level rules are active*


```solidity
function requireApplicationRulesChecked(ActionTypes _action, address _sender) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the current action type|
|`_sender`|`address`||

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if one or more rules are active|


### checkApplicationRules

*Check Application Rules for valid transaction.*


```solidity
function checkApplicationRules(
    address _tokenAddress,
    address _sender,
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
|`_tokenAddress`|`address`|address of the token|
|`_sender`|`address`|address of the calling account passed through from the token|
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
function _checkRiskRules(
    address _from,
    address _to,
    address _sender,
    uint128 _balanceValuation,
    uint128 _transferValuation,
    ActionTypes _action
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the caller|
|`_balanceValuation`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_transferValuation`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|
|`_action`|`ActionTypes`|the current user action|


### _checkAccessLevelRules

non custodial buy
non custodial sell

*This function consolidates all the Access Level rule checks.*


```solidity
function _checkAccessLevelRules(
    address _from,
    address _to,
    address _sender,
    uint128 _balanceValuation,
    uint128 _transferValuation,
    ActionTypes _action
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_sender`|`address`|address of the to caller|
|`_balanceValuation`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_transferValuation`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|
|`_action`|`ActionTypes`|the current user action|


### _checkAccountMaxTxValueByRiskScore

Non custodial buy
Non custodial sell

*This function consolidates the MaxTXValueByRiskScore rule checks for the from address.*


```solidity
function _checkAccountMaxTxValueByRiskScore(
    ActionTypes _action,
    address _address,
    uint8 _riskScoreFrom,
    uint128 _transferValuation
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the current user action|
|`_address`|`address`|address of the account|
|`_riskScoreFrom`|`uint8`|sender address risk score|
|`_transferValuation`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### setNFTPricingAddress

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
function setAccountMaxValueByRiskScoreId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types in which to apply the rules|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxValueByRiskScoreIdFull

that setting a rule will automatically activate it.

*Set the accountMaxValueByRiskScoreRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByRiskScoreIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxValueByRiskScore

*Clear the rule data structure*


```solidity
function clearAccountMaxValueByRiskScore() internal;
```

### setAccountMaxValueByRiskScoreIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxValuebyRiskSCoreRuleId.*


```solidity
function setAccountMaxValueByRiskScoreIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByRiskScore(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByRiskScoreActive

*Tells you if the accountMaxValueByRiskScore Rule is active or not.*


```solidity
function isAccountMaxValueByRiskScoreActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByRiskScoreId

*Retrieve the accountMaxValueByRiskScore rule id*


```solidity
function getAccountMaxValueByRiskScoreId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueByRiskScoreId rule id|


### setAccountDenyForNoAccessLevelId

that setting a rule will automatically activate it.

*Set the activateAccountDenyForNoAccessLevel. Restricted to app administrators only.*


```solidity
function setAccountDenyForNoAccessLevelId(ActionTypes[] calldata _actions)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types in which to apply the rules|


### setAccountDenyForNoAccessLevelIdFull

that setting a rule will automatically activate it.

*Set the activateAccountDenyForNoAccessLevel. Restricted to app administrators only.*


```solidity
function setAccountDenyForNoAccessLevelIdFull(ActionTypes[] calldata _actions)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|


### clearAccountDenyForNoAccessLevel

*Clear the rule data structure*


```solidity
function clearAccountDenyForNoAccessLevel() internal;
```

### setAccountDenyForNoAccessLevelIdUpdate

that setting a rule will automatically activate it.

*Set the AccountDenyForNoAccessLevelRuleId.*


```solidity
function setAccountDenyForNoAccessLevelIdUpdate(ActionTypes _action) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|


### activateAccountDenyForNoAccessLevelRule

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountDenyForNoAccessLevelRule(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountDenyForNoAccessLevelActive

*Tells you if the AccountDenyForNoAccessLevel Rule is active or not.*


```solidity
function isAccountDenyForNoAccessLevelActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### setAccountMaxValueByAccessLevelId

that setting a rule will automatically activate it.

*Set the accountMaxValueByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByAccessLevelId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types in which to apply the rules|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxValueByAccessLevelIdFull

that setting a rule will automatically activate it.

*Set the accountMaxValueByAccessLevelRule. Restricted to app administrators only.*


```solidity
function setAccountMaxValueByAccessLevelIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxValueByAccessLevel

*Clear the rule data structure*


```solidity
function clearAccountMaxValueByAccessLevel() internal;
```

### setAccountMaxValuebyAccessLevelIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxValuebyAccessLevelRuleId.*


```solidity
function setAccountMaxValuebyAccessLevelIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueByAccessLevel(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueByAccessLevelActive

*Tells you if the accountMaxValueByAccessLevel Rule is active or not.*


```solidity
function isAccountMaxValueByAccessLevelActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueByAccessLevelId

*Retrieve the accountMaxValueByAccessLevel rule id*


```solidity
function getAccountMaxValueByAccessLevelId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueByAccessLevelId rule id|


### setAccountMaxValueOutByAccessLevelId

that setting a rule will automatically activate it.

*Set the AccountMaxValueOutByAccessLevel. Restricted to app administrators only.*


```solidity
function setAccountMaxValueOutByAccessLevelId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types in which to apply the rules|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxValueOutByAccessLevelIdFull

that setting a rule will automatically activate it.

*Set the AccountMaxValueOutByAccessLevel. Restricted to app administrators only.*


```solidity
function setAccountMaxValueOutByAccessLevelIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxValueOutByAccessLevel

*Clear the rule data structure*


```solidity
function clearAccountMaxValueOutByAccessLevel() internal;
```

### setAccountMaxValueOutByAccessLevelIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxValueOutByAccessLevelRuleId.*


```solidity
function setAccountMaxValueOutByAccessLevelIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxValueOutByAccessLevel

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxValueOutByAccessLevel(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxValueOutByAccessLevelActive

*Tells you if the AccountMaxValueOutByAccessLevel Rule is active or not.*


```solidity
function isAccountMaxValueOutByAccessLevelActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxValueOutByAccessLevelId

*Retrieve the accountMaxValueOutByAccessLevel rule id*


```solidity
function getAccountMaxValueOutByAccessLevelId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxValueOutByAccessLevelId rule id|


### setAccountMaxTxValueByRiskScoreId

that setting a rule will automatically activate it.

*Set the accountMaxTxValueByRiskScore. Restricted to app administrators only.*


```solidity
function setAccountMaxTxValueByRiskScoreId(ActionTypes[] calldata _actions, uint32 _ruleId)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types in which to apply the rules|
|`_ruleId`|`uint32`|Rule Id to set|


### setAccountMaxTxValueByRiskScoreIdFull

that setting a rule will automatically activate it.

*Set the accountMaxTxValueByRiskScore. Restricted to app administrators only.*


```solidity
function setAccountMaxTxValueByRiskScoreIdFull(ActionTypes[] calldata _actions, uint32[] calldata _ruleIds)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|actions to have the rule applied to|
|`_ruleIds`|`uint32[]`|Rule Id corresponding to the actions|


### clearAccountMaxTxValueByRiskScore

*Clear the rule data structure*


```solidity
function clearAccountMaxTxValueByRiskScore() internal;
```

### setAccountMaxTxValueByRiskScoreIdUpdate

that setting a rule will automatically activate it.

*Set the AccountMaxTxValueByRiskScoreRuleId.*


```solidity
function setAccountMaxTxValueByRiskScoreIdUpdate(ActionTypes _action, uint32 _ruleId) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type to set the rule|
|`_ruleId`|`uint32`|Rule Id to set|


### activateAccountMaxTxValueByRiskScore

*enable/disable rule. Disabling a rule will save gas on transfer transactions.*


```solidity
function activateAccountMaxTxValueByRiskScore(ActionTypes[] calldata _actions, bool _on)
    external
    ruleAdministratorOnly(appManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_actions`|`ActionTypes[]`|action types|
|`_on`|`bool`|boolean representing if a rule must be checked or not.|


### isAccountMaxTxValueByRiskScoreActive

*Tells you if the accountMaxTxValueByRiskScore Rule is active or not.*


```solidity
function isAccountMaxTxValueByRiskScoreActive(ActionTypes _action) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|the action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|boolean representing if the rule is active|


### getAccountMaxTxValueByRiskScoreId

*Retrieve the AccountMaxTxValueByRiskScore rule id*


```solidity
function getAccountMaxTxValueByRiskScoreId(ActionTypes _action) external view returns (uint32);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|action type|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint32`|accountMaxTxValueByRiskScoreId rule id|


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


### isContract

*Check if the addresss is a contract*


```solidity
function isContract(address account) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to check|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool|


### getRuleProcessAddress

*Getter for rule processor address*


```solidity
function getRuleProcessAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|ruleProcessorAddress|



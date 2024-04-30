# IAppManager
[Git Source](https://github.com/thrackle-io/tron/blob/f405cfa7d52aca0d1bdf3d82da9748579a0bb635/src/client/application/IAppManager.sol)

**Inherits:**
[IAppManagerErrors](/src/common/IErrors.sol/interface.IAppManagerErrors.md), [IPermissionModifierErrors](/src/common/IErrors.sol/interface.IPermissionModifierErrors.md), [IInputErrors](/src/common/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/common/IErrors.sol/interface.IZeroAddressError.md), [IOwnershipErrors](/src/common/IErrors.sol/interface.IOwnershipErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Interface for app manager server functions.

*This interface is a lightweight counterpart to AppManager. It should be used by calling contracts that only need inquiry actions*


## Functions
### isSuperAdmin

*This function is where the super admin role is actually checked*


```solidity
function isSuperAdmin(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if admin, false if not|


### isAppAdministrator

*This function is where the app administrator role is actually checked*


```solidity
function isAppAdministrator(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if app administrator, false if not|


### isRuleAdministrator

*This function is where the rule administrator role is actually checked*


```solidity
function isRuleAdministrator(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if rule administrator, false if not|


### isRuleBypassAccount

*This function is where the rule bypass account role is actually checked*


```solidity
function isRuleBypassAccount(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if RULE_BYPASS_ACCOUNT, false if not|


### isAccessLevelAdmin

*This function is where the access level admin role is actually checked*


```solidity
function isAccessLevelAdmin(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if ACCESS_LEVEL_ADMIN_ROLE, false if not|


### isRiskAdmin

*This function is where the risk admin role is actually checked*


```solidity
function isRiskAdmin(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if RISK_ADMIN_ROLE, false if not|


### getAllTags

*Get all the tags for the address*


```solidity
function getAllTags(address _address) external view returns (bytes32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address to retrieve the tags|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32[]`|tags Array of all tags for the account|


### getAccessLevel

*Get the AccessLevel Score for the specified account*


```solidity
function getAccessLevel(address _account) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the user|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`||


### getRiskScore

*Get the Risk Score for an account.*


```solidity
function getRiskScore(address _account) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address upon which the risk score was set|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|score risk score(0-100)|


### getPauseRules

*Get all pause rules for the token*


```solidity
function getPauseRules() external view returns (PauseRule[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PauseRule[]`|PauseRule An array of all the pause rules|


### hasTag

*Check to see if an account has a specific general tag*


```solidity
function hasTag(address _account, bytes32 _tag) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address to check|
|`_tag`|`bytes32`|Tag to be checked for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if account has the tag, false if it does not|


### getAccessLevelProvider

*Get the address of the access level provider*


```solidity
function getAccessLevelProvider() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|accessLevelProvider Address of the access level provider|


### registerToken

*This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory*


```solidity
function registerToken(string calldata _tokenId, address _tokenAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`string`|The token id(may be NFT or ERC20)|
|`_tokenAddress`|`address`|Address corresponding to the tokenId|


### deregisterToken

*This function allows the devs to deregister a token contract address. This keeps everything in sync and will aid with the token factory*


```solidity
function deregisterToken(string calldata _tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`string`|The token id(may be NFT or ERC20)|


### getTokenList

*Return a the token list for calculation purposes*


```solidity
function getTokenList() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|tokenList list of all tokens registered|


### getTokenID

*This function gets token identification string.*


```solidity
function getTokenID(address _tokenAddress) external view returns (string memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|the address of the contract of the token to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`string`|the identification string.|


### registerAMM

*This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions*


```solidity
function registerAMM(address _AMMAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|Address for the AMM to be registered|


### isRegisteredAMM

*This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions*


```solidity
function isRegisteredAMM(address _AMMAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|Address for the AMM|


### deRegisterAMM

*This function allows the devs to deregister an AMM contract address.*


```solidity
function deRegisterAMM(address _AMMAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|The address of the AMM to be de-registered|


### isTreasury

*This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions*


```solidity
function isTreasury(address _treasuryAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Address for the treasury|


### approveAddressToTradingRuleAllowlist

*manage the allowlist for trading-rule bypasser accounts*


```solidity
function approveAddressToTradingRuleAllowlist(address _address, bool isApproved) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|account in the list to manage|
|`isApproved`|`bool`|set to true to indicate that _address can bypass trading rules.|


### isTradingRuleBypasser

*tells if an address can bypass trading rules*


```solidity
function isTradingRuleBypasser(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|the address to check for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if the address can bypass trading rules, or false otherwise.|


### checkApplicationRules

*Jump through to the gobal rules to see if the requested action is valid.*


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
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|address of the token calling the rule check|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_amount`|`uint256`|amount of tokens to be transferred|
|`_nftValuationLimit`|`uint16`|number of tokenID's per collection before checking collection price vs individual token price|
|`_tokenId`|`uint256`|tokenId of the NFT token|
|`_action`|`ActionTypes`|Action to be checked|
|`_handlerType`|`HandlerTypes`|type of handler calling checkApplicationRules function|


### confirmNewDataProvider

*Part of the two step process to set a new Data Provider within a Protocol AppManager. Final confirmation called by new provider*


```solidity
function confirmNewDataProvider(IDataModule.ProviderType _providerType) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_providerType`|`IDataModule.ProviderType`|the type of data provider|



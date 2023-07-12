# IAppManager
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/application/IAppManager.sol)

**Inherits:**
[IAppManagerErrors](/src/interfaces/IErrors.sol/interface.IAppManagerErrors.md), [IAppAdministratorOnlyErrors](/src/interfaces/IErrors.sol/interface.IAppAdministratorOnlyErrors.md), [IInputErrors](/src/interfaces/IErrors.sol/interface.IInputErrors.md), [IZeroAddressError](/src/interfaces/IErrors.sol/interface.IZeroAddressError.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Interface for app manager server functions.

*This interface is a lightweight counterpart to AppManager. It should be used by calling contracts that only need inquiry actions*


## Functions
### isAdmin

*This function is where the default admin role is actually checked*


```solidity
function isAdmin(address account) external view returns (bool);
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


### isAccessTier

*This function is where the access tier role is actually checked*


```solidity
function isAccessTier(address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if ACCESS_TIER_ADMIN_ROLE, false if not|


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


### isUser

*This function is where the user role is actually checked*


```solidity
function isUser(address _address) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if USER_ROLE, false if not|


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

*Get the address of the access levelprovider*


```solidity
function getAccessLevelProvider() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|accessLevelProvider Address of the access levelprovider|


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


### registerStaking

*This function allows the devs to register their Staking contract addresses. Allow contracts to check if contract is registered staking contract within ecosystem.
This check is used in minting rewards tokens for example.*


```solidity
function registerStaking(address _stakingAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|Address for the AMM|


### isRegisteredStaking

*This function checks if the Staking contract address is registered.*


```solidity
function isRegisteredStaking(address _stakingAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|Address of the Staking contract that is checked.|


### deRegisterStaking

*This function allows the devs to deregister an Staking contract address.*


```solidity
function deRegisterStaking(address _stakingAddress) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|The address of the Staking contract to be de-registered|


### isTreasury

*This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions*


```solidity
function isTreasury(address _treasuryAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Address for the treasury|


### checkApplicationRules

*Jump through to the gobal rules to see if the requested action is valid.*


```solidity
function checkApplicationRules(
    ActionTypes _action,
    address _from,
    address _to,
    uint128 _usdBalanceTo,
    uint128 _usdAmountTransferring
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ActionTypes`|Action to be checked|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_usdBalanceTo`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### requireValuations

*checks if any of the balance prerequisite rules are active*


```solidity
function requireValuations() external returns (bool);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if one or more rules are active|



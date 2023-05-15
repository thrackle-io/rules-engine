# AppManager
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/ca661487b49e5b916c4fa8811d6bdafbe530a6c8/src/application/AppManager.sol)

**Inherits:**
AccessControlEnumerable, [IAppLevelEvents](/src/interfaces/IEvents.sol/interface.IAppLevelEvents.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This contract is the permissions contract

*This uses AccessControlEnumerable to maintain user roles and allows for metadata to be saved for users.*


## State Variables
### USER_ROLE

```solidity
bytes32 constant USER_ROLE = keccak256("USER");
```


### APP_ADMIN_ROLE

```solidity
bytes32 constant APP_ADMIN_ROLE = keccak256("APP_ADMIN_ROLE");
```


### ACCESS_TIER_ADMIN_ROLE

```solidity
bytes32 constant ACCESS_TIER_ADMIN_ROLE = keccak256("ACCESS_TIER_ADMIN_ROLE");
```


### RISK_ADMIN_ROLE

```solidity
bytes32 constant RISK_ADMIN_ROLE = keccak256("RISK_ADMIN_ROLE");
```


### accounts
Data contracts


```solidity
IAccounts accounts;
```


### accessLevels

```solidity
IAccessLevels accessLevels;
```


### riskScores

```solidity
IRiskScores riskScores;
```


### generalTags

```solidity
IGeneralTags generalTags;
```


### pauseRules

```solidity
IPauseRules pauseRules;
```


### applicationHandler
Access Action Contract


```solidity
ApplicationHandler public applicationHandler;
```


### applicationHandlerAddress

```solidity
address applicationHandlerAddress;
```


### applicationRulesActive

```solidity
bool applicationRulesActive;
```


### tokenToAddress

```solidity
mapping(string => address) tokenToAddress;
```


### addressToToken

```solidity
mapping(address => string) addressToToken;
```


### tokenList
Token array (for balance tallying)


```solidity
address[] tokenList;
```


### ammList
AMM List (for token level rule exemptions)


```solidity
address[] ammList;
```


### treasuryList
Treasury List (for token level rule exemptions)


```solidity
address[] treasuryList;
```


### stakingList
Staking Contracts List (for token level rule exemptions)


```solidity
address[] stakingList;
```


### appName
Application name string


```solidity
string appName;
```


## Functions
### constructor

*This sets up the first default admin and app administrator roles while also forming the hierarchy of roles and deploying data contracts.*


```solidity
constructor(address root, string memory _appName, bool upgradeMode);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`root`|`address`|address to set as the default admin and first app administrator|
|`_appName`|`string`|Application Name String|
|`upgradeMode`|`bool`|specifies whether this is a fresh AppManager or an upgrade replacement.|


### onlyAdmin

-------------ADMIN---------------

*Modifier used to restrict to default admin role*


```solidity
modifier onlyAdmin();
```

### isAdmin

*This function is where the default admin role is actually checked*


```solidity
function isAdmin(address account) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if admin, false if not|


### onlyAppAdministrator

-------------APP ADMIN---------------

*Checks if msg.sender is a Application Administrators role*


```solidity
modifier onlyAppAdministrator();
```

### isAppAdministrator

*This function is where the app administrator role is actually checked*


```solidity
function isAppAdministrator(address account) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if app administrator, false if not|


### addAppAdministrator

*Add an account to the app administrator role. Restricted to admins.*


```solidity
function addAppAdministrator(address account) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be added|


### renounceAppAdministrator

*Remove oneself from the app administrator role.*


```solidity
function renounceAppAdministrator() public;
```

### onlyAccessTierAdministrator

-------------ACCESS TIER---------------

*Checks for if msg.sender is a Access Tier*


```solidity
modifier onlyAccessTierAdministrator();
```

### isAccessTier

*This function is where the access tier role is actually checked*


```solidity
function isAccessTier(address account) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if ACCESS_TIER_ADMIN_ROLE, false if not|


### addAccessTier

*Add an account to the access tier role. Restricted to app administrators.*


```solidity
function addAccessTier(address account) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be added as a access tier|


### renounceAccessTier

*Remove oneself from the access tier role.*


```solidity
function renounceAccessTier() public;
```

### onlyRiskAdmin

-------------RISK ADMIN---------------

*Checks if msg.sender is a Risk Admin role*


```solidity
modifier onlyRiskAdmin();
```

### isRiskAdmin

*This function is where the risk admin role is actually checked*


```solidity
function isRiskAdmin(address account) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if RISK_ADMIN_ROLE, false if not|


### addRiskAdmin

*Add an account to the risk admin role. Restricted to app administrators.*


```solidity
function addRiskAdmin(address account) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|address to be added|


### renounceRiskAdmin

*Remove oneself from the risk admin role.*


```solidity
function renounceRiskAdmin() public;
```

### onlyUser

-------------USER---------------
The user roles are stored in a separate data contract
Restricted to members of the user role.

*Checks if the msg.sender is in the user role*


```solidity
modifier onlyUser();
```

### isUser

*This function is where the user role is actually checked*


```solidity
function isUser(address _address) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address to be checked|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if USER_ROLE, false if not|


### addUser

*Add an account to the user role. Restricted to app administrators.*


```solidity
function addUser(address _account) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address to be added as a user|


### removeUser

*Remove an account from the user role. Restricted to app administrators.*


```solidity
function removeUser(address _account) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address to be removed as a user|


### addAccessLevel

-------------MAINTAIN ACCESS LEVELS---------------

*Add the Access Level(0-4) to the account. Restricted to Access Tiers.*


```solidity
function addAccessLevel(address _account, uint8 _level) external onlyAccessTierAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address upon which to apply the Access Level|
|`_level`|`uint8`|Access Level to add|


### getAccessLevel

*Get the AccessLevel Score for the specified account*


```solidity
function getAccessLevel(address _account) public view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the user|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`||


### addRiskScore

-------------MAINTAIN RISK SCORES---------------

*Add the Risk Score. Restricted to Risk Admins.*


```solidity
function addRiskScore(address _account, uint8 _score) external onlyRiskAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address upon which to apply the Risk Score|
|`_score`|`uint8`|Risk Score(0-100)|


### getRiskScore

*Get the Risk Score for an account.*


```solidity
function getRiskScore(address _account) public view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address upon which the risk score was set|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint8`|score risk score(0-100)|


### addPauseRule

--------------MAINTAIN PAUSE RULES---------------

*Add a pause rule. Restricted to Application Administrators*


```solidity
function addPauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|Beginning of the pause window|
|`_pauseStop`|`uint256`|End of the pause window|


### removePauseRule

*Remove a pause rule. Restricted to Application Administrators*


```solidity
function removePauseRule(uint256 _pauseStart, uint256 _pauseStop) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_pauseStart`|`uint256`|Beginning of the pause window|
|`_pauseStop`|`uint256`|End of the pause window|


### getPauseRules

*Get all pause rules for the token*


```solidity
function getPauseRules() external view returns (PauseRule[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`PauseRule[]`|PauseRule An array of all the pause rules|


### cleanOutdatedRules

*Remove any expried pause windows.*


```solidity
function cleanOutdatedRules() external;
```

### addGeneralTag

-------------MAINTAIN GENERAL TAGS---------------

*Add a general tag to an account. Restricted to Application Administrators.*


```solidity
function addGeneralTag(address _account, bytes32 _tag) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address to be tagged|
|`_tag`|`bytes32`|Tag for the account. Can be any allowed string variant|


### removeGeneralTag

*Remove a general tag. Restricted to Application Administrators.*


```solidity
function removeGeneralTag(address _account, bytes32 _tag) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address to have its tag removed|
|`_tag`|`bytes32`|The tag to remove|


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


### getAllTags

*Get all the tags for the address*


```solidity
function getAllTags(address _address) public view returns (bytes32[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|Address to retrieve the tags|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32[]`|tags Array of all tags for the account|


### setRiskProvider

*Set the address of the Risk Provider contract. Restricted to Application Administrators*


```solidity
function setRiskProvider(address _provider) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_provider`|`address`|Address of the provider|


### getRiskProvider

*Get the address of the risk score provider*


```solidity
function getRiskProvider() public view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|provider Address of the provider|


### setGeneralTagProvider

*Set the address of the General Tag Provider contract. Restricted to Application Administrators*


```solidity
function setGeneralTagProvider(address _provider) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_provider`|`address`|Address of the provider|


### getGeneralTagProvider

*Get the address of the general tag provider*


```solidity
function getGeneralTagProvider() public view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|provider Address of the provider|


### setAccountProvider

*Set the address of the Account Provider contract. Restricted to Application Administrators*


```solidity
function setAccountProvider(address _provider) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_provider`|`address`|Address of the provider|


### getAccountProvider

*Get the address of the account provider*


```solidity
function getAccountProvider() public view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|provider Address of the provider|


### setPauseRuleProvider

*Set the address of the Pause Rule Provider contract. Restricted to Application Administrators*


```solidity
function setPauseRuleProvider(address _provider) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_provider`|`address`|Address of the provider|


### getPauseRulesProvider

*Get the address of the pause rules provider*


```solidity
function getPauseRulesProvider() public view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|provider Address of the provider|


### setAccessLevelProvider

*Set the address of the Access Level Provider contract. Restricted to Application Administrators*


```solidity
function setAccessLevelProvider(address _accessLevelProvider) public onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accessLevelProvider`|`address`|Address of the Access Level provider|


### getAccessLevelProvider

*Get the address of the Access Level provider*


```solidity
function getAccessLevelProvider() public view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|accessLevelProvider Address of the Access Level provider|


### areAccessLevelOrRiskRulesActive

APPLICATION CHECKS

*checks if any of the AccessLevel or Risk rules are active in order to decide to perform or not
the USD valuation of assets*


```solidity
function areAccessLevelOrRiskRulesActive() external returns (bool);
```

### checkApplicationRules

*Check Application Rules for valid transactions.*


```solidity
function checkApplicationRules(
    ApplicationRuleProcessorDiamondLib.ActionTypes _action,
    address _from,
    address _to,
    uint128 _usdBalanceTo,
    uint128 _usdAmountTransferring
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_action`|`ApplicationRuleProcessorDiamondLib.ActionTypes`|Action to be checked|
|`_from`|`address`|address of the from account|
|`_to`|`address`|address of the to account|
|`_usdBalanceTo`|`uint128`|recepient address current total application valuation in USD with 18 decimals of precision|
|`_usdAmountTransferring`|`uint128`|valuation of the token being transferred in USD with 18 decimals of precision|


### registerToken

*This function allows the devs to register their token contract addresses. This keeps everything in sync and will aid with the token factory*


```solidity
function registerToken(string calldata _token, address _tokenAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`string`|The token identifier(may be NFT or ERC20)|
|`_tokenAddress`|`address`|Address corresponding to the tokenId|


### getTokenAddress

*This function gets token contract address.*


```solidity
function getTokenAddress(string calldata _tokenId) external view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`string`|The token id(may be NFT or ERC20)|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|tokenAddress the address corresponding to the tokenId|


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


### deregisterToken

*This function allows the devs to deregister a token contract address. This keeps everything in sync and will aid with the token factory*


```solidity
function deregisterToken(string calldata _tokenId) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenId`|`string`|The token id(may be NFT or ERC20)|


### _removeAddress

*This function removes an address from a dynamic address array by putting the last element in the one to remove and then removing last element.*


```solidity
function _removeAddress(address[] storage _addressArray, address _address) private;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_addressArray`|`address[]`|The array to have an address removed|
|`_address`|`address`|The address to remove|


### registerAMM

*This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions*


```solidity
function registerAMM(address _AMMAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|Address for the AMM|


### isRegisteredAMM

*This function allows the devs to register their AMM contract addresses. This will allow for token level rule exemptions*


```solidity
function isRegisteredAMM(address _AMMAddress) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|Address for the AMM|


### deRegisterAMM

*This function allows the devs to deregister an AMM contract address.*


```solidity
function deRegisterAMM(address _AMMAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_AMMAddress`|`address`|The of the AMM to be de-registered|


### isTreasury

*This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions*


```solidity
function isTreasury(address _treasuryAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Address for the treasury|


### registerTreasury

*This function allows the devs to register their treasury addresses. This will allow for token level rule exemptions*


```solidity
function registerTreasury(address _treasuryAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|Address for the treasury|


### deRegisterTreasury

*This function allows the devs to deregister an treasury address.*


```solidity
function deRegisterTreasury(address _treasuryAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_treasuryAddress`|`address`|The of the AMM to be de-registered|


### registerStaking

*This function allows the devs to register their Staking contract addresses. Allow contracts to check if contract is registered staking contract within ecosystem.
This check is used in minting rewards tokens for example.*


```solidity
function registerStaking(address _stakingAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|Address for the AMM|


### isRegisteredStaking

*This function allows the devs to register their Staking contract addresses.*


```solidity
function isRegisteredStaking(address _stakingAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|Address for the Staking Contract|


### deRegisterStaking

*This function allows the devs to deregister a Staking contract address.*


```solidity
function deRegisterStaking(address _stakingAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_stakingAddress`|`address`|The of the Staking contract to be de-registered|


### getAccessLevelDataAddress

*Getter for the access level contract address*


```solidity
function getAccessLevelDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|AccessLevelDataAddress|


### getAccountDataAddress

*Getter for the Account data contract address*


```solidity
function getAccountDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|accountDataAddress|


### getRiskDataAddress

*Getter for the risk data contract address*


```solidity
function getRiskDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|riskDataAddress|


### getGeneralTagsDataAddress

*Getter for the general tags data contract address*


```solidity
function getGeneralTagsDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|generalTagsDataAddress|


### getPauseRulesDataAddress

*Getter for the pause rules data contract address*


```solidity
function getPauseRulesDataAddress() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|pauseRulesDataAddress|


### getTokenList

*Return the token list for calculation purposes*


```solidity
function getTokenList() external view returns (address[] memory);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|tokenList list of all tokens registered|


### setNewApplicationHandlerAddress

this is for upgrading to a new ApplicationHandler contract

*Update the Application Handler Contract Address*


```solidity
function setNewApplicationHandlerAddress(address _newApplicationHandler) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newApplicationHandler`|`address`|address of new Application Handler contract|


### setAppName

*Setter for application Name*


```solidity
function setAppName(string calldata _appName) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appName`|`string`|application name string|


### deployDataContracts

-------------DATA CONTRACT DEPLOYMENT---------------

*Deploy all the child data contracts. Only called internally from the constructor.*


```solidity
function deployDataContracts() private;
```

### migrateDataContracts

*This function is used to migrate the data contracts to a new AppManager. Use with care because it changes ownership. They will no
longer be accessible from the original AppManager*


```solidity
function migrateDataContracts(address _newOwner) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_newOwner`|`address`|address of the new AppManager|


### deployApplicationHandler

*Deploy the ApplicationHandler contract. Only called internally from the constructor.*


```solidity
function deployApplicationHandler(address _appManagerAddress) private returns (address);
```

### connectDataContracts

*This function is used to connect data contracts from an old AppManager to the current AppManager.*


```solidity
function connectDataContracts(address _oldAppManagerAddress) external onlyAppAdministrator;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_oldAppManagerAddress`|`address`|address of the old AppManager|


## Errors
### PricingModuleNotConfigured

```solidity
error PricingModuleNotConfigured(address _erc20PricingAddress, address nftPricingAddress);
```

### riskScoreOutOfRange

```solidity
error riskScoreOutOfRange(uint8 riskScore);
```

### InvalidDateWindow

```solidity
error InvalidDateWindow(uint256 startDate, uint256 endDate);
```

### NotAdmin

```solidity
error NotAdmin(address _address);
```

### NotAppAdministrator

```solidity
error NotAppAdministrator(address _address);
```

### NotAccessTierAdministrator

```solidity
error NotAccessTierAdministrator(address _address);
```

### NotRiskAdmin

```solidity
error NotRiskAdmin(address _address);
```

### NotAUser

```solidity
error NotAUser(address _address);
```

### AccessLevelIsNotValid

```solidity
error AccessLevelIsNotValid(uint8 accessLevel);
```

### BlankTag

```solidity
error BlankTag();
```

### NoAddressToRemove

```solidity
error NoAddressToRemove();
```

### actionCheckFailed

```solidity
error actionCheckFailed();
```

### ZeroAddress

```solidity
error ZeroAddress();
```


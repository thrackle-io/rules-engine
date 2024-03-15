# RiskScores
[Git Source](https://github.com/thrackle-io/tron/blob/f201d50818b608b30301a670e76c0b866af89050/src/client/application/data/RiskScores.sol)

**Inherits:**
[IRiskScores](/src/client/application/data/IRiskScores.sol/interface.IRiskScores.md), [DataModule](/src/client/application/data/DataModule.sol/abstract.DataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data contract to store risk scores for user accounts

*This contract stores and serves risk scores via an internal mapping*


## State Variables
### scores

```solidity
mapping(address => uint8) public scores;
```


### MAX_RISK

```solidity
uint8 constant MAX_RISK = 100;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor(address _dataModuleAppManagerAddress) DataModule(_dataModuleAppManagerAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataModuleAppManagerAddress`|`address`|address of the owning app manager|


### addScore

*Add the risk score to the account. Restricted to the owner*


```solidity
function addScore(address _address, uint8 _score) public virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_score`|`uint8`|risk score (0-100)|


### addMultipleRiskScores

*Add the Risk Score at index to Account at index in array. Restricted to Risk Admins.*


```solidity
function addMultipleRiskScores(address[] memory _accounts, uint8[] memory _scores) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address array upon which to apply the Risk Score|
|`_scores`|`uint8[]`|Risk Score array (0-100)|


### addRiskScoreToMultipleAccounts

*Add the Risk Score to each address in array. Restricted to Risk Admins.*


```solidity
function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address array upon which to apply the Risk Score|
|`_score`|`uint8`|Risk Score(0-100)|


### removeScore

*Remove the risk score for the account. Restricted to the owner*


```solidity
function removeScore(address _account) external virtual onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### getRiskScore

*Get the risk score for the account. Restricted to the owner*


```solidity
function getRiskScore(address _account) external view virtual returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|



# RiskScores
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/e66fc809d7d2554e7ebbff7404b6c1d6e84d340d/src/data/RiskScores.sol)

**Inherits:**
[IRiskScores](/src/data/IRiskScores.sol/interface.IRiskScores.md), [DataModule](/src/data/DataModule.sol/abstract.DataModule.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data contract to store risk scores for user accounts

*This contract stores and serves risk scores via an internal mapping*


## State Variables
### scores

```solidity
mapping(address => uint8) public scores;
```


## Functions
### constructor

*Constructor that sets the app manager address used for permissions. This is required for upgrades.*


```solidity
constructor(address _dataModuleAppManagerAddress) DataModule(dataModuleAppManagerAddress);
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
function getRiskScore(address _account) external view virtual onlyOwner returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|



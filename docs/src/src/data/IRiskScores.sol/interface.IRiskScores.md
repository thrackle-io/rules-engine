# IRiskScores
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/data/IRiskScores.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md), [IRiskInputErrors](/src/interfaces/IErrors.sol/interface.IRiskInputErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Data interface to store risk scores for user accounts

*This interface contains storage and retrieval function definitions*


## Functions
### addScore

*Add the risk score to the account. Restricted to the owner*


```solidity
function addScore(address _address, uint8 _score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_score`|`uint8`|risk score (0-100)|


### removeScore

*Remove the risk score for the account. Restricted to the owner*


```solidity
function removeScore(address _account) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### getRiskScore

*Get the risk score for the account. Restricted to the owner*


```solidity
function getRiskScore(address _account) external view returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### addRiskScoreToMultipleAccounts

*Add the Risk Score to each address in array. Restricted to Risk Admins.*


```solidity
function addRiskScoreToMultipleAccounts(address[] memory _accounts, uint8 _score) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_accounts`|`address[]`|address array upon which to apply the Risk Score|
|`_score`|`uint8`|Risk Score(0-100)|



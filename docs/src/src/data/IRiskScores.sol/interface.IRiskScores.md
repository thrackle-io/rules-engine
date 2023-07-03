# IRiskScores
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/data/IRiskScores.sol)

**Inherits:**
[IDataModule](/src/data/IDataModule.sol/interface.IDataModule.md)

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



# RiskScores
[Git Source](https://github.com/thrackle-io/Tron/blob/89e7f7b48d79c8e2bc6476fb1601cc9680f2c384/src/data/RiskScores.sol)

**Inherits:**
[IRiskScores](/src/data/IRiskScores.sol/interface.IRiskScores.md), [DataModule](/src/data/DataModule.sol/contract.DataModule.md)

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
constructor();
```

### addScore

*Add the risk score to the account. Restricted to the owner*


```solidity
function addScore(address _address, uint8 _score) public onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_address`|`address`|address of the account|
|`_score`|`uint8`|risk score (0-100)|


### removeScore

*Remove the risk score for the account. Restricted to the owner*


```solidity
function removeScore(address _account) external onlyOwner;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|


### getRiskScore

*Get the risk score for the account. Restricted to the owner*


```solidity
function getRiskScore(address _account) external view onlyOwner returns (uint8);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|address of the account|



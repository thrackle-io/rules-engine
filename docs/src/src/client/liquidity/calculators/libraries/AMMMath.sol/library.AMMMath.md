# AMMMath
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/libraries/AMMMath.sol)


## Functions
### sqrt

*This function calculates the square root using uniswap style logic*


```solidity
function sqrt(uint256 y) internal pure returns (uint256 z);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`y`|`uint256`|the value to get the square root of.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`z`|`uint256`|the square root of y|


### getNumberOfDigits

*calculate the total digits in number expressed in decimal system.*


```solidity
function getNumberOfDigits(uint256 _number) internal pure returns (uint8 digits);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_number`|`uint256`|number to count digits for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`digits`|`uint8`|the number of digits of _number|



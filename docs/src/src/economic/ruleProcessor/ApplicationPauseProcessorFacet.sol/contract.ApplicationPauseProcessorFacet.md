# ApplicationPauseProcessorFacet
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol)

**Inherits:**
ERC173

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Contains logic for checking specific action against pause rules. (part of diamond structure)

*Standard EIP2565 Facet with storage defined in its imported library*


## Functions
### checkPauseRules

*This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.*


```solidity
function checkPauseRules(address _dataServer) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_dataServer`|`address`|address of the appManager contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if passes, false if not passes|


## Errors
### ApplicationPaused

```solidity
error ApplicationPaused(uint256 started, uint256 ends);
```


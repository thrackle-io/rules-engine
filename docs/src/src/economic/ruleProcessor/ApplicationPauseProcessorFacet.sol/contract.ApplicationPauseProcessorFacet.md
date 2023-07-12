# ApplicationPauseProcessorFacet
[Git Source](https://github.com/thrackle-io/Tron_Internal/blob/2eb992c5f8a67ecb6f7fb3675bc386aaa483c728/src/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol)

**Inherits:**
ERC173, [IPauseRuleErrors](/src/interfaces/IErrors.sol/interface.IPauseRuleErrors.md)

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



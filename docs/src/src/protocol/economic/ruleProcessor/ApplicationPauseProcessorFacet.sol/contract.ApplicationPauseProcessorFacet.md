# ApplicationPauseProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/3af53b224777c5c1f4e2e734b7757bd798236667/src/protocol/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol)

**Inherits:**
ERC173, [IPauseRuleErrors](/src/common/IErrors.sol/interface.IPauseRuleErrors.md)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Contains logic for checking specific action against pause rules.

*Standard EIP2565 Facet with storage defined in its imported library*


## Functions
### checkPauseRules

*This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.*


```solidity
function checkPauseRules(address _appManagerAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_appManagerAddress`|`address`|address of the appManager contract|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true if passes, false if not passes|



# ApplicationPauseProcessorFacet
[Git Source](https://github.com/thrackle-io/tron/blob/a6e068f4bc8dd6e86015430d874759ac1519196d/src/protocol/economic/ruleProcessor/ApplicationPauseProcessorFacet.sol)

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



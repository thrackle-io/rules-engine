# ApplicationPauseProcessorLib
[Git Source](https://github.com/thrackle-io/Tron/blob/afc52571532b132ea1dea91ad1d1f1af07381e8a/src/economic/ruleProcessor/application/ApplicationPauseProcessorLib.sol)


## State Variables
### PAUSE_PROCESSOR_STORAGE_POSITION

```solidity
bytes32 constant PAUSE_PROCESSOR_STORAGE_POSITION = keccak256("pause-processor.storage");
```


## Functions
### s

*This function returns the storage struct for reading and writing.*


```solidity
function s() internal pure returns (PauseRuleProcessorStorage storage storageStruct);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`storageStruct`|`PauseRuleProcessorStorage`|actual storage for the facet|


### checkPauseRules

*This function checks if action passes according to application pause rules. Checks for all pause windows set for this token.*


```solidity
function checkPauseRules(address _dataServer) internal view returns (bool);
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


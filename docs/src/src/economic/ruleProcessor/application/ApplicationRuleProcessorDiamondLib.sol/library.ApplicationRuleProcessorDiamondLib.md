# ApplicationRuleProcessorDiamondLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/economic/ruleProcessor/application/ApplicationRuleProcessorDiamondLib.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

This library provides the common data structures for use in other contracts.

*Used by various contracts for definition of actions and whether they are considered a transaction*


## State Variables
### DIAMOND_CUT_STORAGE_POSITION

```solidity
bytes32 constant DIAMOND_CUT_STORAGE_POSITION = keccak256("diamond-cut.storage");
```


### APPLICATION_DATA_POSITION

```solidity
bytes32 constant APPLICATION_DATA_POSITION = keccak256("application-rules.storage");
```


## Functions
### isTransaction

Utility function to check actions for the ones that are actually a transaction.


```solidity
function isTransaction(uint256 _action) internal pure returns (bool);
```

### s

*Function for position of rules. Every rule has its own storage.*


```solidity
function s() internal pure returns (DiamondStorage storage ds);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`ds`|`DiamondStorage`|Data storage for Application Rule Processor Storage|


### applicationStorage

*This function returns the storage struct for reading and writing.*


```solidity
function applicationStorage() internal pure returns (ApplicationRuleDataStorage storage storageStruct);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`storageStruct`|`ApplicationRuleDataStorage`|actual storage for the facet|


### diamondCut

*Internal function version of _diamondCut*


```solidity
function diamondCut(FacetCut[] memory _diamondCut, address init, bytes memory data) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_diamondCut`|`FacetCut[]`|Facets Array|
|`init`|`address`|Address of the contract or facet to execute "data"|
|`data`|`bytes`|A function call, including function selector and arguments calldata is executed with delegatecall on "init"|


### addFunctions

*Add Function to Diamond*


```solidity
function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Address of Facet|
|`_functionSelectors`|`bytes4[]`|Signature array of function selectors|


### replaceFunctions

*Replace Function from Diamond*


```solidity
function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Address of Facet|
|`_functionSelectors`|`bytes4[]`|Signature array of function selectors|


### removeFunctions

can't replace immutable functions -- functions defined directly in the diamond in this case
replace old facet address

*Remove Function from Diamond*


```solidity
function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_facetAddress`|`address`|Address of Facet|
|`_functionSelectors`|`bytes4[]`|Signature array of function selectors|


### initializeDiamondCut

can't remove immutable functions -- functions defined directly in the diamond
replace selector with last selector
delete last selector

*Initialize Diamond Cut of new Facet*


```solidity
function initializeDiamondCut(address init, bytes memory data) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`init`|`address`|The address of the contract or facet to execute "data"|
|`data`|`bytes`|A function call, including function selector and arguments calldata is executed with delegatecall on "init"|


### enforceHasContractCode

*Internal function to enforce contract has code*


```solidity
function enforceHasContractCode(address _contract, string memory _errorMessage) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_contract`|`address`|The address of the contract be checked or enforced|
|`_errorMessage`|`string`|Error for contract with non matching co|


## Events
### DiamondCut

```solidity
event DiamondCut(FacetCut[] _diamondCut, address init, bytes data);
```

## Enums
### ActionTypes

```solidity
enum ActionTypes {
    PURCHASE,
    SELL,
    TRADE,
    INQUIRE
}
```


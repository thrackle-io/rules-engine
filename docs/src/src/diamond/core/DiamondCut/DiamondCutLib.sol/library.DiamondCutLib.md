# DiamondCutLib
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/diamond/core/DiamondCut/DiamondCutLib.sol)


## State Variables
### DIAMOND_CUT_STORAGE_POSITION

```solidity
bytes32 constant DIAMOND_CUT_STORAGE_POSITION = keccak256("diamond-cut.storage");
```


## Functions
### s


```solidity
function s() internal pure returns (DiamondCutStorage storage ds);
```

### diamondCut


```solidity
function diamondCut(FacetCut[] memory _diamondCut, address init, bytes memory data) internal;
```

### addFunctions


```solidity
function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### replaceFunctions


```solidity
function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### removeFunctions


```solidity
function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal;
```

### initializeDiamondCut


```solidity
function initializeDiamondCut(address init, bytes memory data) internal;
```

### enforceHasContractCode


```solidity
function enforceHasContractCode(address _contract, string memory _errorMessage) internal view;
```

## Events
### DiamondCut

```solidity
event DiamondCut(FacetCut[] _diamondCut, address init, bytes data);
```


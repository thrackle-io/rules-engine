# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/ce8f3ce20cc777375e5a3cbfcde63db2607acc28/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```


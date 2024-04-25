# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/bbc344dde218df220c4305ef421070eaa38c5cad/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```


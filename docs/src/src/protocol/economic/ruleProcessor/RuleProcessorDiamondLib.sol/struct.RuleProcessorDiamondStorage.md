# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/87ff5b38c590a4edb91556fd9ab3428df36445b8/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```


# RuleProcessorDiamondStorage
[Git Source](https://github.com/thrackle-io/tron/blob/9665732f3266b703cc028112f97a9a18c551bb91/src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol)


```solidity
struct RuleProcessorDiamondStorage {
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}
```


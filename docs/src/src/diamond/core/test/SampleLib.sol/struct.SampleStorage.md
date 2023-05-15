# SampleStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/diamond/core/test/SampleLib.sol)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


```solidity
struct SampleStorage {
    uint256 v1;
}
```


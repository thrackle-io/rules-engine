# SampleStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4e5c0bf97c314267dd6acccac5053bfaa6859607/src/diamond/core/test/SampleLib.sol)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


```solidity
struct SampleStorage {
    uint256 v1;
}
```


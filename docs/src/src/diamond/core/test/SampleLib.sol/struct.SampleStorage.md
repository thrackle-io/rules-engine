# SampleStorage
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/diamond/core/test/SampleLib.sol)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


```solidity
struct SampleStorage {
    uint256 v1;
}
```


# SampleStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/diamond/core/test/SampleLib.sol)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


```solidity
struct SampleStorage {
    uint256 v1;
}
```


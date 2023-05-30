# SampleStorage
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/941799bce65220406b4d9686c5c5f1ae7c99f4ee/src/diamond/core/test/SampleLib.sol)

This contract only exists for testing purposes. It is here to test diamond upgrades. It is named "Sample" instead
of "Test" because naming it "Test" causes problems with Foundry testing.


```solidity
struct SampleStorage {
    uint256 v1;
}
```


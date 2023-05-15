# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/data/PauseRule.sol)

**Author:**
@ShaneDuncan602, @oscarsernarosero, @TJ-Everett

Contains data structure for a pause rule


```solidity
struct PauseRule {
    uint256 dateCreated;
    uint256 pauseStart;
    uint256 pauseStop;
    bool active;
}
```


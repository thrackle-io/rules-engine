# PauseRule
[Git Source](https://github.com/thrackle-io/Tron/blob/0f66d21b157a740e3d9acae765069e378935a031/src/data/PauseRule.sol)

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


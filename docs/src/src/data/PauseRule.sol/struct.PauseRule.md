# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/121468a758a67e73dd1df571fd4e956242c3c973/src/data/PauseRule.sol)

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


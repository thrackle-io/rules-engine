# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/63b22fe4cc7ce8c74a4c033635926489351a3581/src/data/PauseRule.sol)

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


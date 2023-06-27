# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2955538441cd4ad2d51a27d7c28af7eec4cd8814/src/data/PauseRule.sol)

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


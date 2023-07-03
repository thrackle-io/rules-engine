# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/9adfea3f253340fbb4af30cdc0009d491b72e160/src/data/PauseRule.sol)

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


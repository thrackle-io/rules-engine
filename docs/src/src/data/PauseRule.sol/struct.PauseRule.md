# PauseRule
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/4f7789968960e18493ff0b85b09856f12969daac/src/data/PauseRule.sol)

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


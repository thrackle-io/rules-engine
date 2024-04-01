# AggregatorV3Interface
[Git Source](https://github.com/thrackle-io/tron/blob/d0e19eee889b51e6e21299e25b4ddf10ffd75bd7/src/example/pricing/AggregatorV3Interface.sol)

This is the standard Chainlink feed interface


## Functions
### decimals


```solidity
function decimals() external view returns (uint8);
```

### description


```solidity
function description() external view returns (string memory);
```

### version


```solidity
function version() external view returns (uint256);
```

### getRoundData


```solidity
function getRoundData(uint80 _roundId)
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```

### latestRoundData


```solidity
function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
```


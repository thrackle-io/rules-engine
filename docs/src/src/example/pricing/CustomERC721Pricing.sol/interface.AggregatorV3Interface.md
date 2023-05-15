# AggregatorV3Interface
[Git Source](https://github.com/thrackle-io/rules-protocol/blob/2738cf9716e0fddfad4df13fdb6486b5987af931/src/example/pricing/CustomERC721Pricing.sol)

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


# LinearWholeB
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol)

this is how the internal line should be saved since this will allow more precision during mathematical operations.
definition: y = (m_num/m_den) * x + b

*Linear curve expressed in fractions.*


```solidity
struct LinearWholeB {
    uint256 m_num;
    uint256 m_den;
    uint256 b;
}
```


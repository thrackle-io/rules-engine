# LinearInput
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/client/liquidity/calculators/dataStructures/CurveDataStructures.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

Every TBC curve must have its definition here.

*This is a collection of data structures that define different curves for TBCs.*

*Linear curve
definition: y = m*x + b*


```solidity
struct LinearInput {
    uint256 m;
    uint256 b;
}
```


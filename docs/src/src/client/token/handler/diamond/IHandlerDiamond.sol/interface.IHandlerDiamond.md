# IHandlerDiamond
[Git Source](https://github.com/thrackle-io/tron/blob/703713c2070ab34d0f0fc0114244d5a3fa7ac84a/src/client/token/handler/diamond/IHandlerDiamond.sol)

**Author:**
@ShaneDuncan602 @oscarsernarosero @TJ-Everett

*the light version of the Handler Diamond for an efficient
import into the other contracts for calls to the checkAllRules function.
This is only used internally by the protocol.*


## Functions
### checkAllRules


```solidity
function checkAllRules(
    uint256 balanceFrom,
    uint256 balanceTo,
    address _from,
    address _to,
    address _sender,
    uint256 _amount
) external returns (bool);
```

### isFeeActive


```solidity
function isFeeActive() external view returns (bool);
```

### getApplicableFees


```solidity
function getApplicableFees(address _from, uint256 _balanceFrom)
    external
    view
    returns (address[] memory feeCollectorAccounts, int24[] memory feePercentages);
```

### checkNonTaggedRules


```solidity
function checkNonTaggedRules(address _from, address _to, uint256 _amount, ActionTypes action) external;
```

### checkTaggedAndTradingRules


```solidity
function checkTaggedAndTradingRules(
    uint256 _balanceFrom,
    uint256 _balanceTo,
    address _from,
    address _to,
    uint256 _amount,
    ActionTypes action
) external;
```

### checkTradingRules


```solidity
function checkTradingRules(
    address _from,
    address _to,
    bytes32[] memory fromTags,
    bytes32[] memory toTags,
    uint256 _amount,
    ActionTypes action
) external;
```


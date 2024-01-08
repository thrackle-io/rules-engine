# AMMErrors
[Git Source](https://github.com/thrackle-io/tron/blob/ee06788a23623ed28309de5232eaff934d34a0fe/src/common/IErrors.sol)


## Errors
### TokenInvalid

```solidity
error TokenInvalid(address);
```

### AmountExceedsBalance

```solidity
error AmountExceedsBalance(uint256);
```

### TransferFailed

```solidity
error TransferFailed();
```

### NotTheOwnerOfNFT

```solidity
error NotTheOwnerOfNFT(uint256 _tokenId);
```

### NotEnumerable

```solidity
error NotEnumerable();
```

### NotEnoughTokensForSwap

```solidity
error NotEnoughTokensForSwap(uint256 _tokensIn, uint256 _tokensRequired);
```

### InsufficientPoolDepth

```solidity
error InsufficientPoolDepth(uint256 pool, uint256 attemptedWithdrawal);
```


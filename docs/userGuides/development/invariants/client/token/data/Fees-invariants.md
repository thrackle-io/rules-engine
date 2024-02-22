# Fees Invariants

## General Invariants

- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- A non-owner can never add a fee
- A non-owner can never remove a fee
- A non-owner can never retrieve a fee
- A non-owner can never propose a new owner
- When adding a fee, minimum balance can never be more than maximum balance
- When adding a fee, fee percentage can never be greater than 10000(100%) or less than -10000(-100%)
- When adding a fee, fee percentage can never be 0
- When adding a fee, target account can never be a zero address when the feePercentage is positive
- When adding a fee, maxBalance will be max uint256 when maxBalance is sent in as 0
- When removing an existing fee, fee total will decrement by 1
- When removing an existing fee, FeeType event is emitted
- When attempting to remove a non existent fee, FeeType event is not emitted
- Can never propose zero address as the new owner
  


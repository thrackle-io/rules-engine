# ProtocolERC20 Invariants

## Protocol Related Invariants

- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- Only app admins may connect a handler
- A non-appAdmin can never pause the contract
- A non-appAdmin can never unpause the contract
- A non-appAdmin can never connect a handler to the contract
- Any account can retrieve handler address
- Handler address can never be zero address
- New deployment will always emit NewTokenDeployed event
- When paused, mint reverts with "Pausable: paused"
- When paused, burn reverts with "Pausable: paused"
- When paused, transfer reverts with "Pausable: paused"
- When paused, transferFrom reverts with "Pausable: paused"
- When paused, connectHandlerToToken still works
- If a cumulative positive fees exist, the amount of tokens received by the toAddress is less than the amount transferred by the fromAddress
- If a cumulative negative fees exist, the amount of tokens received by the toAddress is equal to the amount transferred by the fromAddress
- If a cumulative positive fees exist, the treasury address balance will increase with a transfer
- If a cumulative negative fees exist, the treasury address balance will remain the same with a transfer

## Base ERC20 Invariants
- Total supply should be constant for non-mintable and non-burnable tokens.
- No user balance should be greater than the token's total supply.
- The sum of users balances should not be greater than the token's total supply.
- Token balance for address zero should be zero.
- transfers to zero address should not be allowed.
- transferFroms to zero address should not be allowed.
- Self transfers should not break accounting.
- Self transferFroms should not break accounting.
- transfers for more than account balance should not be allowed.
- transferFroms for more than account balance should not be allowed.
- transfers for zero amount should not break accounting.
- transferFroms for zero amount should not break accounting.
- Valid transfers should update accounting correctly.
- Valid transferFroms should update accounting correctly.
- Allowances should be set correctly when approve is called.
- Allowances should be updated correctly when approve is called twice.
- After transferFrom, allowances should be updated correctly.

## Burnable ERC20 Invariants
- User balance and total supply should be updated correctly when burn is called.
- User balance and total supply should be updated correctly when burnFrom is called.
- Allowances should be updated correctly when burnFrom is called.

## Mintable ERC20 Invariants
- User balance and total supply should be updated correctly after minting.

## ProtocolTokenCommon Invariants

- Only an App Admin can propose a new AppManager
- Proposed AppManagerAddress can not be set to zero address
- Any type of address may confirm the proposed AppManager as long as it is the proposed AppManager.
- Only the proposed AppManager may confirm the AppManagerAddress
- When AppManagerAddress is confirmed, AppManagerAddressSet event is always emitted
- Any type of address may retrieve the AppManagerAddress
- Any type of address may retrieve the HandlerAddress
  
# ProtocolERC20 Invariants

## [Base ERC20 Invariants](../../../../../../../test/client/token/ERC20/invariant/ApplicationERC20Basic.t.i.sol)
- User balance must not exceed total supply
- Sum of users balance must not exceed total supply
- Address zero should have zero balance
- Transfers to zero address should not be allowed.
- transferFroms to zero address should not be allowed.
- Self transfers should not break accounting.
- Self transferFroms should not break accounting.
- Transfers for more than available balance should not be allowed
- TransferFroms for more than available balance should not be allowed
- Zero amount transfers should not break accounting
- Zero amount transferFroms should not break accounting
- Transfers should update accounting correctly
- TransferFroms should update accounting correctly
- Approve should set correct allowances
- Allowances should be updated correctly when approve is called twice.
- TransferFrom should decrease allowance

## [Burnable ERC20 Invariants](../../../../../../../test/client/token/ERC20/invariant/ApplicationERC20MintBurn.t.i.sol)
- Burn should update user balance and total supply
- Burn should update user balance and total supply when burnFrom is called twice
- burnFrom should update allowance

# Unimplemented

## Protocol Related Invariants
##### note: Not implemented fully
- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- Only app admins may connect a handler
- A non-appAdmin can never connect a handler to the contract
- Any account can retrieve handler address
- Once set to a non zero address, a Handler address can never be set to zero address
- New deployment will always emit NewTokenDeployed event
- If a cumulative positive fees exist, the amount of tokens received by the toAddress is less than the amount transferred by the fromAddress
- If a cumulative negative fees exist, the amount of tokens received by the toAddress is equal to the amount transferred by the fromAddress
- If a cumulative positive fees exist, the treasury address balance will increase with a transfer
- If a cumulative negative fees exist, the treasury address balance will remain the same with a transfer


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
  
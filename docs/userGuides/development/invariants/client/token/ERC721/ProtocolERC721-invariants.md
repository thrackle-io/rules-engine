# ProtocolERC721 Invariants

## Protocol Related Invariants

- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- Only app admins may connect a handler
- A non-appAdmin can never pause the contract
- A non-appAdmin can never unpause the contract
- A non-appAdmin can never connect a handler to the contract
- Any account can retrieve handler address
- Once the handler address is set to a non zero address, Handler address can never be zero address
- New deployment will always emit NewTokenDeployed event
- When paused, mint reverts with "Pausable: paused"
- When paused, burn reverts with "Pausable: paused"
- When paused, transfer reverts with "Pausable: paused"
- When paused, transferFrom reverts with "Pausable: paused"
- When paused, connectHandlerToToken still works

## Base ERC721 Invariants
- Calling balanceOf for the zero address should revert.
- Calling ownerOf for an invalid token should revert.
- approve() should revert on invalid token.
- transferFrom() should revert if caller is not operator.
- transferFrom() should reset approvals.
- transferFrom() should update the token owner.
- transferFrom() should revert if from is the zero address.
- transferFrom() should revert if to is the zero address.
- transferFrom() to self should not break accounting.
- transferFrom() to self should reset approvals.
- safeTransferFrom() should revert if receiver is a contract that does not implement onERC721Received()
  

## Burnable ERC721 Invariants
- User balance and total supply should be updated correctly when burn is called.
- A token that has been burned cannot be transferred.
- A token that has been burned cannot be transferred.
- A burned token should have its approvals reset.
- getApproved() should revert if the token is burned.
- ownerOf() should revert if the token has been burned.

## Mintable ERC721 Invariants
- User balance and total supply should be updated correctly after minting.

## ProtocolTokenCommon Invariants

- Only an App Admin can propose a new AppManager
- Proposed AppManagerAddress can not be set to zero address
- Any type of address may confirm the proposed AppManager as long as it is the proposed AppManager.
- Only the proposed AppManager may confirm the AppManagerAddress
- When AppManagerAddress is confirmed, AppManagerAddressSet event is always emitted
- Any type of address may retrieve the AppManagerAddress
- Any type of address may retrieve the HandlerAddress
  

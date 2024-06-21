# ApplicationERC721 Invariants



## [Base ERC721 Invariants](../../../../../../../test/client/token/ERC721/invariant/ApplicationERC721Base.t.i.sol)
- Calling balanceOf for the zero address should revert.
- Calling ownerOf for an invalid token should revert.
- approve() should revert on invalid token.
- transferFrom() should revert if caller is not approved.
- transferFrom() should reset approvals.
- transferFrom() should update the token owner.
- transferFrom() should revert if from is the zero address.
- transferFrom() should revert if to is the zero address.
- transferFrom() to self should not break accounting.
- transferFrom() to self should reset approvals.
  

## [Burnable ERC721 Invariants](../../../../../../../test/client/token/ERC721/invariant/ApplicationERC721MintBurn.t.i.sol)
- The burn function should destroy tokens and reduce the total supply
- A burned token should not be transferrable
- approve() should revert if the token is burned
- getApproved() should revert if the token is burned
- ownerOf() should revert if the token has been burned.
- A burned token should have its approvals reset.

## [Mintable ERC721 Invariants](../../../../../../../test/client/token/ERC721/invariant/ApplicationERC721MintBurn.t.i.sol)
- Mint increases the total supply
- Mint creates a fresh applicationNFT
- Minting tokens should update user's balance


# Not Implemented

## [Protocol Related Invariants](../../../../../../../test/client/token/ERC721/invariant/ApplicationERC721System.t.i.sol)

- Any user can get the contract's version
- Only app admins may connect a handler
- A non-appAdmin can never connect a handler to the contract
- Any account can retrieve handler address
- Once the handler address is set to a non zero address, Handler address can never be zero address
- New deployment will always emit NewTokenDeployed event

## Base
- safeTransferFrom() should revert if receiver is a contract that does not implement onERC721Received()



## [ProtocolTokenCommon Invariants](../../../../../../../test/client/token/ERC721/invariant/ApplicationERC721System.t.i.sol)

- Only an App Admin can propose a new AppManager
- Proposed AppManagerAddress can not be set to zero address
- Any type of address may confirm the proposed AppManager as long as it is the proposed AppManager.
- Only the proposed AppManager may confirm the AppManagerAddress
- When AppManagerAddress is confirmed, AppManagerAddressSet event is always emitted
- Any type of address may retrieve the AppManagerAddress
- Any type of address may retrieve the HandlerAddress
  

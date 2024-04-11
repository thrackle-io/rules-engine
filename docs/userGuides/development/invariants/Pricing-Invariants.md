# Pricing Invariants

## ERC20-Pricing Invariants

- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- It will always return a price, even if it is 0
- Prices can be set for any valid address, regardless of the type(EOA or contract)
- A non-owner address can never set a price
- Any user can get the token's price
- Any user can retrieve the price mapping
- Setting a price will always emit TokenPrice event


## ERC721-Pricing Invariants
##### Note: Not implemented yet

- Version will never be blank
- Version will never change.
- Any user can get the contract's version
- It will always return a price, even if it is 0
- Prices cannot be for non ERC721 compliant NFT's
- Trying to set a price for non ERC721 compliant NFT's always reverts with NotAnNFTContract
- Trying to set a price for non ERC721 compliant NFT collections always reverts with NotAnNFTContract
- A non-owner address can never set a price
- Any user can get a token's price
- Any user can get a collection's price
- Any user can retrieve the nft price mapping
- Any user can retrieve the collection price mapping
- When using an ERC721 compliant NFT's address, setting an NFT price always emits SingleTokenPrice event with the correct address, id, and price.
- When using an ERC721 compliant NFT's address, setting an NFT collection price always emits CollectionPrice event with the correct address and price.
- When a specific tokenId price is set and a collection price is set and that specific tokenId's price is retrieved, it always returns the specific tokenId's price and not the collection's price.
- When no specific tokenId price is set and a collection price is set, it always retrieves the collection price.
- When no specific tokenId price is set and no collection price is set, it always returns 0.
- When a specific tokenId prices are set and a collection price is set, it always returns the specific tokenId's price. 
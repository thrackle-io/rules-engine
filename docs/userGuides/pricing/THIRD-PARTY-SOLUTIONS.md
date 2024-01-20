# Third-Party Solutions

Developers may choose their preferred third-party solutions for token pricing. In order for these to be able to communicate properly with the protocol, they simply have to deploy an adapter contract -if necessary- that implements the protocol interface for the respective kind of token.

This way, the adapter contract will live in the middle of the application and the external pricer contract in order to format the request and response between these two elements:

    _______________        ___________        ________________________
    | Application | <----> | Adapter | <----> | Third-Party Solution |
    ---------------        -----------        ------------------------

The functions that these adapters must implement are:

## ERC721 Pricing Functions

```c
    /**
     * @dev gets the price for an NFT. It will return the NFT's specific price, or the
     * price of the collection if no specific price has been given
     * @param nftContract is the address of the NFT contract
     * @param id of the NFT
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getNFTPrice(address nftContract, uint256 id) external view returns (uint256 price);

    /**
     * @dev gets the default price for an NFT collection.
     * @param nftContract is the address of the NFT contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getNFTCollectionPrice(address nftContract) external view returns (uint256 price);
```

For the full interface, see [IProtocolERC721Pricing]("../../../../../src/common/IProtocolERC721Pricing.sol").

## ERC20 Pricing Functions

```c
    /**
     * @dev gets the price of a Token. It will return the Token's specific price.
     * @param tokenContract is the address of the Token contract
     * @return price of the Token in weis of dollars. 10^18 => $ 1.00 USD
     */
    function getTokenPrice(address tokenContract) external view returns (uint256 price);
```

For the full interface, see [IProtocolERC20Pricing]("../../../../../src/common/IProtocolERC20Pricing.sol").

Developers may choose to implement and deploy an adapter contract per token standard (one for ERC20 and another for ERC721), or to implement both in a single contract to deploy. No matter the route taken, the appManager Handler must have **both** pricer addresses set in order to properly work.

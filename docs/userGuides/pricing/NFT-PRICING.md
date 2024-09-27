# NFT Pricing
[![Project Version][version-image]][version-url]

---

## Setting NFT Price for Protocol Pricer

1.  Ensure the [environment variables][environment-url] are set correctly.
2.  Set the price for each collection
    1.  Call the setNFTCollectionPrice function on the NFTPricing contract from previous steps. It accepts parameters of NFTAddress and price, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1 * 10**18)
        1.  Price is 18 decimals so 1 * 10**18 = $1
        2.  Collection price may be updated at any time
         ````
         cast send $NFT_PRICER "setNFTCollectionPrice(address,uint256)" $APPLICATION_ERC721_1 1000000000000000000 --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL

         ````
    2.  If pricing for specific tokenId's is required, they can be set by calling the setSingleNFTPrice function on the NFTPricing contract. It accepts parameters of NFTAddress, tokenId, and price, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,12, 1 * 10**18)
        1.  Price is 18 decimals so 1 * 10**18 = $1
        2.  Individual prices may be updated at any time    
         ````
         cast send $NFT_PRICER "setSingleNFTPrice(address,uint256,uint256)" $APPLICATION_ERC721_1 1 1000000000000000000 --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
         ````
    3. Connect the pricing module to any Protocol Supported ERC721's or ERC20's
   
        - Run the following for each asset's handler:
           ````
           cast send $APPLICATION_ERC721_HANDLER "setNFTPricingAddress(address)"  $NFT_PRICER --private-key $APP_ADMIN_PRIVATE_KEY --rpc-url $ETH_RPC_URL
           ````


<!-- These are the body links -->
[environment-url]: ../deployment/SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/forte-rules-engine
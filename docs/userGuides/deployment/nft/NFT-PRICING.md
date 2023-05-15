# NFT Pricing
[![Project Version][version-image]][version-url]

---

## Setting NFT Price for Protocol Pricer

1.  Ensure the [environment variable][environment-url] is set correctly.
2.  Set the price for each collection
    1.  Call the setNFTCollectionPrice function on the NFTPricing contract from previous steps. It accepts parameters of NFTAddress and price, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 1 * 10**18)
        1.  Price is 18 decimals so 1 * 10**18 = $1
        2.  Collection price may be updated at any time
         ````
         cast send 0x2bdCC0de6bE1f7D2ee689a0342D76F52E8EFABa3 "setNFTCollectionPrice(address,uint256)" 0xbd416e972a4F2cfb378A2333F621e93D5845C055 1000000000000000000 --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --rpc-url $ETH_RPC_URL

         ````
    2.  If pricing for specific tokenId's is required, they can be set by calling the setSingleNFTPrice function on the newly deployed contract from 13.4.1. It accepts parameters of NFTAddress, tokenId, and price, e.g. (0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,12, 1 * 10**18)
        1.  Price is 18 decimals so 1 * 10**18 = $1
        2.  Individual prices may be updated at any time    
         ````
         cast send 0x2bdCC0de6bE1f7D2ee689a0342D76F52E8EFABa3 "setSingleNFTPrice(address,uint256,uint256)" 0xbd416e972a4F2cfb378A2333F621e93D5845C055 1 1000000000000000000 --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba --rpc-url $ETH_RPC_URL

         ````


## Setting NFT Price for Custom Pricer

TODO: Add when we have one

<!-- These are the body links -->
[environment-url]: ../SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
# Pricing Module Deployment
[![Project Version][version-image]][version-url]

---


In order for US-Dollar-based global rules to function properly, the protocol needs to be able to determine the price of each asset. There are two ways to accomplish this: the protocol provided example and a custom pricer.

### NFT Pricing Module

1.  Protocol provided example:
    1.  Ensure the [environment variable][environment-url] is set correctly.
    2.  It allows for setting the prices on a collection and also for individual NFT's. To use the example:
        1.  Copy the template from _src/example/pricing/ApplicationERC721Pricing.sol_ to your desired location
        2.  Change the name of the contract to suit your naming standards
            1.  *Do not change the import or parent contract*
        3.  Compile the contract
            ````
            forge build --use solc:0.8.17

            ````
        4.  Deploy the contract. (no parameters required)

            ````
            forge create src/example/pricing/ApplicationERC721Pricing.sol:ApplicationERC721Pricing --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url $ETH_RPC_URL

            ````
            1.  Use the output from the previous deployment to take note of the AppManagers's address.
                1.  example:
                    ````
                    Deployed to: 0x2bdCC0de6bE1f7D2ee689a0342D76F52E8EFABa3
                    Transaction hash: 0x44f9979c57c8799732b14e561f547c088c3428958602a817a9d77ca972ff4fde
                    ````
2.  Custom Pricer(TODO: provide more detail)



<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
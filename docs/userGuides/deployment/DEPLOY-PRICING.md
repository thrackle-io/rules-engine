# Pricing Module Deployment
[![Project Version][version-image]][version-url]

---


In order for US-Dollar-based application rules to function properly, the protocol needs to be able to determine the price of each asset. There are two ways to accomplish this: the protocol provided example and a custom pricer.

### NFT Pricing Module

1.  Protocol provided example:
    1.  Ensure the [environment variables][environment-url] are set correctly.
    2.  It allows for setting the prices on a collection and also for individual NFT's. To use the example:
        1.  Copy the template from _example/pricing/ApplicationERC721Pricing.sol_ to your desired location
        2.  Change the name of the contract to suit your naming standards
            - *Do not change the import or parent contract*
        3.  Compile the contract
            ````
            forge build --use solc:0.8.17

            ````
        4.  Deploy the contract. (no parameters required)

            ````
            forge create example/pricing/ApplicationERC721Pricing.sol:ApplicationERC721Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL --from $APP_ADMIN_1

            ````
        5. locate the address from the output, example:
            ````
            Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
            Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
            ````
            2. Set the environment variable
            ````
            export APPLICATION_PRICER=address from output
            ````
2.  Custom Pricer - Please reach out to the development team for more information on how to implement a custom pricing contract.



<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
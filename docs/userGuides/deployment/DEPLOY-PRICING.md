# Pricing Module Deployment
[![Project Version][version-image]][version-url]

---


In order for US-Dollar-based application rules to function properly, the protocol needs to be able to determine the price of each asset. There are two ways to accomplish this: the protocol provided example and a third-party pricer.

### NFT Pricing Module

1.  Protocol provided example:
    1.  Ensure the [environment variables][environment-url] are set correctly.
    2.  It allows for setting the prices on a collection and also for individual NFT's. To use the example:
        1.  Copy the template from _src/example/pricing/ApplicationERC721Pricing.sol_ to your desired location
        2.  Change the name of the contract to suit your naming standards
            - *Do not change the import or parent contract*
        3.  Compile the contract
            ````
            forge build --use solc:0.8.17

            ````
        4.  Deploy the contract. (no parameters required)

            ````
            forge create src/example/pricing/ApplicationERC721Pricing.sol:ApplicationERC721Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

            ````
        5. locate the address from the output, example:
            ````
            Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
            Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
            ````
        6. Set the environment variable
            ````
            export APPLICATION_ERC721_PRICER=address from output
            ````
2. ## ERC20 Pricing Module

1.  Protocol provided example:
    1.  Ensure the [environment variables][environment-url] are set correctly.
    2.  It allows for setting the prices for fungible tokens. To use the example:
        1.  Copy the template from _src/example/pricing/ApplicationERC20Pricing.sol_ to your desired location
        2.  Change the name of the contract to suit your naming standards
            - *Do not change the import or parent contract*
        3.  Compile the contract
            ````
            forge build --use solc:0.8.17

            ````
        4.  Deploy the contract. (no parameters required)

            ````
            forge create src/example/pricing/ApplicationERC20Pricing.sol:ApplicationERC20Pricing --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

            ````
        5. locate the address from the output, example:
            ````
            Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
            Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
            ````
        6. Set the environment variable
            ````
            export APPLICATION_ERC20_PRICER=address from output
            ````

# Third-Party Pricing Solutions

To be able to use third-party pricing solutions with the protocol, you must make sure that the third party contract complies with our interfaces. If they don't, an adapter contract will have to be deployed. For more information see the [third-party solution guide](../pricing/THIRD-PARTY-SOLUTIONS.md).

# Pricing Module Configuration 

Once your pricing modules have been deployed, it is time to set their addresses in you appManager handler:
1. Export your appManager handler address to zsh:

    ```
    export APP_MANAGER_HANDLER=<YOUR_APP_MANAGER_HANDLER_ADDRESS>
    ```
2. Through a ruleAdmin private key (see [admin roles](../permissions/ADMIN-ROLES.md)), do:
    - For ERC20 pricer:
        ```
        cast send $APP_MANAGER_HANDLER "setERC20PricingAddress(address)()" $APPLICATION_ERC20_PRICER --private-key $RULE_ADMIN_KEY --rpc-url $ETH_RPC_URL
        ```
    - For ERC721 pricer:
        ```
        cast send $APP_MANAGER_HANDLER "setNFTPricingAddress(address)()" $APPLICATION_ERC721_PRICER --private-key $RULE_ADMIN_KEY --rpc-url $ETH_RPC_URL
        ```

<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
# NFTHandler Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variable][environment-url] is set correctly.
    1. Manual deployment of Handler contract for upgrading to new handler only. Handler Contract 
    will automatically deploy from the ERC721 contract. 
2. Copy the template from _src/example/ERC721/ApplicationERC721Handler.sol_ to your desired location
3. Change the name of the contract to suit your naming standards
    1. *Do not change the import or parent contract*
4. Compile the contract
    ````
    forge build --use solc:0.8.17

    ````
5. Deploy the contract sending in the following parameters:
    1. _RuleProcessorAddress_ - The address noted from previous steps and set as an environment variable($RULE_PROCESSOR_DIAMOND).
    2. _App Manager Address_ - The address noted from previous steps and set as an environment variable($APPLICATION_APP_MANAGER).
    3. _assetAddress_ - The address of the controlling asset
6. Run the command to create and deploy the contract. NOTE: The path includes source name and contract name.
    ````
    forge create src/example/deploy/FrankensteinERC721Handler.sol:FrankensteinERC721Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_ERC721_1 false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

    ````
7. Use the output from the deployment to set an environment variable for NFT Handler's address.
    1. Locate the address from the output, example:
    ````
    Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
    Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
    ````
    2. Set the environment variable
    ````
    export APPLICATION_ERC721_1_HANDLER=address from output
    ````


<!-- These are the body links -->
[deploymentDirectory-url]: ../DEPLOYMENT-DIRECTORY.md
[environment-url]: ../SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
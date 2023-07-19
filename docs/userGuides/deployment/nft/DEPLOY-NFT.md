# NFT Deployment
[![Project Version][version-image]][version-url]

---

NOTE: NFT Batch minting and burning is not supported in this release.

1. Ensure the [environment variables][environment-url] are set correctly.
2. Copy the template from src/example/ApplicationERC721.sol to your desired location
3. Change the name of the contract to suit your naming standards
    1. Do not change the import or parent contract
4. Compile the contract
   ````
   forge build --use solc:0.8.17

   ````
5. Deploy the contract sending in the parameters:
    1. _Name_ - Desired name of the ERC721(see [ERC721][ERC721-url] standards for more information)
    2. _Symbol_ - Desired symbol of the ERC721(see [ERC721][ERC721-url] standards for more information)
    3. _App Manager Address_ - The address noted from previous steps and set as an environment variable($APPLICATION_APP_MANAGER).
    4. _BaseURI_ - Desired baseURI of the ERC721(see [ERC721][ERC721-url] standards for more information)
    5. Run the command to create and deploy the contract. NOTE: The path includes source name and contract name.
         ````
         forge create src/example/deploy/FrankensteinNFT.sol:Frankenstein --constructor-args "Frankenstein" "FRANKPIC" $APPLICATION_APP_MANAGER "baseURI" --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

         ````
     6. Use the output from the deployment to set an environment variable for NFT's address.
       1. Locate the address from the output, example:
          ````
          Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
          Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
          ````
       2. Set the environment variable
          ````
          export APPLICATION_ERC721_1=address from output
          ````
6. Deploy an NFT handler contract sending in the following parameters:
    1. _RuleProcessorAddress_ - The address noted from previous steps and set as an environment variable($RULE_PROCESSOR_DIAMOND).
    2. _AppManagerAddress_ - The address noted from previous steps and set as an environment variable($APPLICATION_APP_MANAGER).
    3. _AssetAddress_ - The address noted from previous steps and set as an environment variable($APPLICATION_ERC721_1).
    4. _upgradeMode_ 
       1. The bool representing if this is an upgraded handler contract
    5. Run the command to create and deploy the contract. NOTE: The path includes source name and contract name.
    ````
    forge create src/example/ApplicationERC721Handler.sol:ApplicationERC721Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_ERC721_1 false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

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
8.  Connect the Handler to its token
    ````
    cast send $APPLICATION_ERC721_1 "connectHandlerToToken(address)" $APPLICATION_ERC721_1_HANDLER --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1
    ```` 
9. Register NFT with the App Manager: Call the registerToken function on the App Manager created in previous steps. It accepts parameters of an identifying name and the NFT address, e.g. ("FRANKPIC", 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) 
    ````
    cast send $APPLICATION_APP_MANAGER "registerToken(string,address)" "FRANKPIC" $APPLICATION_ERC721_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

    ````


<!-- These are the body links -->
[ERC721-url]: https://docs.openzeppelin.com/contracts/2.x/api/token/erc721
[environment-url]: ./SETENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
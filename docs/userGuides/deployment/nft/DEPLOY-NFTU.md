# Upgradeable NFT Deployment
[![Project Version][version-image]][version-url]

---

### Please note that to insure the upgradeable ERC721 initialization is not front run, it is highly recommended that a deployment script is used. By using a script, the creation and initialization is all done in a single transaction which helps prevent the front running. 

## Script Deployment

1. Ensure the [environment variables][environment-url] are set correctly.
2. Copy the upgradeable NFT template from src/example/ApplicationERC721U.sol to your desired location
3. Change the name of the contract to suit your naming standards
    1. Do not change the import or parent contract   
4. Copy the upgradeable NFT proxy template from src/example/ApplicationERC721UProxy.sol to your desired location
5. Change the name of the contract to suit your naming standards
    1. Do not change the import or parent contract
6. Modify src/example/script/ApplicaitonERC721U.s.sol so that it points to the desired versions of ApplicationERC721U and ApplicationERC721UProxy.
7. Set the following environment variables:
   1. DEPLOYMENT_OWNER_KEY
      1. address responsible for deploying and gas costs
   2. APPLICATIONERC721U_PROXY_OWNER_ADDRESS
      1. address set as owner of the proxy contract
8. Run the script
   ````
   forge script src/example/script/ApplicationERC721U.s.sol:ApplicationERC721UScript --ffi --broadcast --verify -vvvv
   ````
9. Check the output for success and newly deployed contract addresses.

## Manual Deployment

1. Ensure the [environment variables][environment-url] are set correctly.
2. Copy the upgradeable NFT template from src/example/ApplicationERC721U.sol to your desired location
3. Change the name of the contract to suit your naming standards
    1. Do not change the import or parent contract
4. Compile the contract
   ````
   forge build --use solc:0.8.17

   ````   
5. Copy the upgradeable NFT proxy template from src/example/ApplicationERC721UProxy.sol to your desired location
6. Change the name of the contract to suit your naming standards
    1. Do not change the import or parent contract
7. Compile the contract
   ````
   forge build --use solc:0.8.17

   ````
8. Deploy the upgradeable NFT contract
   ````
      forge create src/example/deploy/FrankensteinNFTU.sol:Frankenstein --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
   ````
9.  Use the output from the deployment to set an environment variable for NFT's address.
       1. Locate the address from the output, example:
          ````
          Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
          Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
          ````
       2. Set the environment variable
          ````
          export APPLICATION_ERC721U_1=address from output
          ````
10. Deploy the upgradeable NFT proxy contract   
      ````
      forge create src/example/deploy/FrankensteinNFTUProxy.sol:Frankenstein --constructor-args $APPLICATION_ERC721U_1 $APP_ADMIN_1 "" --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
      ```` 
    1. Use the output from the deployment to set an environment variable for NFT's proxy address.
       1. Locate the address from the output, example:
          ````
          Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
          Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
          ````
       2. Set the environment variable
          ````
          export APPLICATION_ERC721_1=address from output
          ````
    2. Initialize the upgradeable NFT
       1. Invoke the initialize function on the upgradeable NFT 
            ````
            cast send $APPLICATION_ERC721_ADDRESS_1 "initialize()" --private-key $APP_ADMIN_1_KEY --from $APP_ADMIN_1
            ````    
11. Retrieve the NFT Handler address by running the following command:
     ````
     cast call $APPLICATION_ERC721_1 "getHandlerAddress()(address)"  --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
     ````
    1. Locate the address from the output, example:
    ````
    0x0C25Bc46542acb274F055D7368F9Bec7fB23aE74
    ````
    2. Set the environment variable
    ````
    export APPLICATION_ERC721_1_HANDLER=address from output
    ````
12. Register NFT with the App Manager: Call the registerToken function on the App Manager created in previous steps. It accepts parameters of an identifying name and the NFT address, e.g. ("FRANKPIC", 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) 
    ````
    cast send $APPLICATION_APP_MANAGER "registerToken(string,address)" "FRANKPIC" $APPLICATION_ERC721_ADDRESS_1 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL

    ````


<!-- These are the body links -->
[ERC721-url]: https://docs.openzeppelin.com/contracts/2.x/api/token/erc721
[environment-url]: ../SET-ENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
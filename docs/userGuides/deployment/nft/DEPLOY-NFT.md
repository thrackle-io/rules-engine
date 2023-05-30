# NFT Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variable][environment-url] is set correctly.
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
    3. _App Manager Address_ - The address noted from previous steps
    4. _Rule Processor Address_ - The address noted from previous steps
    5. _upgradeMode_ - A boolean value for if this deploys the token handler contract. NOTE:
       Passing in a true boolean value will not deploy ne data contracts. 
    6. _BaseURI_ - Desired baseURI of the ERC721(see [ERC721][ERC721-url] standards for more information)

         ````
         forge create src/example/ApplicationERC721.sol:ApplicationERC721 --constructor-args "Frankenstein" "FRANKPIC" 0x0116686E2291dbd5e317F47faDBFb43B599786Ef 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1 false "nfturigoeshere" --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba 

         ````
6. Take note of the deployed address for later use by running the following command:
     ````
     cast call APP_MANAGER_ADDRESS "getApplicationHandlerAddress()(address)" -private-key OWNER_PRIVATE_KEY
     ````
    - Output:
     ````
     Deployed to: 0x3F434D50520C642A53d703cb07F2c92121f6b549
     Transaction hash: 0x60496b04529f797842164fbc7b39e8eb172ed61249b1ca60ac00237fad8e60d3

8. Register NFT
    1.  Register NFT with its Handler: Call the setERC721Address function on the NFTHandler created in previous steps. It accepts one parameter, the NFT address.

         ````
         cast send 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1 "setERC721Address(address)" 0xbd416e972a4F2cfb378A2333F621e93D5845C055 --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba 

         ````

    2.  Register NFT with the App Manager: Call the registerToken function on the App Manager created in previous steps. It accepts parameters of an identifying name and the NFT address, e.g. ("FRANKPIC", 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266) 
         ````
         cast send 0x0116686E2291dbd5e317F47faDBFb43B599786Ef "registerToken(string,address)" "FRANKPIC" 0xbd416e972a4F2cfb378A2333F621e93D5845C055 --private-key 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba 

         ````


<!-- These are the body links -->
[ERC721-url]: https://docs.openzeppelin.com/contracts/2.x/api/token/erc721
[environment-url]: ./SETENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
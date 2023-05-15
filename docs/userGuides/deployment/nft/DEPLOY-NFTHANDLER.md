# NFTHandler Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variable][environment-url] is set correctly.
2. Copy the template from _src/example/ApplicationERC721Handler.sol_ to your desired location
3. Change the name of the contract to suit your naming standards
    1. *Do not change the import or parent contract*
4. Compile the contract
    ````
    forge build --use solc:0.8.17

    ````
5. Deploy the contract sending in the following parameters:
    1. _Token Rules Router Address_
       1. The Token-Rules-Router's contract address from previous steps for local deployment or from the [Deployment Directory][deploymentDirectory-url]
    2. _App Manager Address_
       1. The address noted from previous steps

    ````
    forge create src/example/ApplicationERC721Handler.sol:ApplicationERC721Handler --constructor-args 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url  $ETH_RPC_URL

    ````
6. Use the output from this deployment to take note of the GameNFTHandler's address.
    ````
    Deployer: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
    Deployed to: 0x82e01223d51Eb87e16A03E24687EDF0F294da6f1
    Transaction hash: 0xf74e37c3d173896d67c723e7b5e7a73648e7ec0d2585046b9eaea35ff921c624
    ````


<!-- These are the body links -->
[deploymentDirectory-url]: ../DEPLOYMENT-DIRECTORY.md
[environment-url]: ../SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
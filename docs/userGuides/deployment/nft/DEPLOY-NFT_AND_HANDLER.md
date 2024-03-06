# NFT And Handler Deployment
[![Project Version][version-image]][version-url]

---

NOTE: NFT Batch minting and burning is not supported in this release.

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER` is used by the deployment script. 

2. Inside the [ApplicationNFT script](../../../../script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol) change the `name` and `symbol` of your NFT to the desired name and symbol for the token. 

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash script/ParseApplicationDeploy.sh 3
        ````
5. This script deploys the NFT token, Asset Handler Diamond, Initializes the diamond, connects the token to the handler and registers the token with the [Application Manager](../../Architecture/Client/Application/APPLICATION-MANAGER.md). 


<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ../SET-ENVIRONMENT.md


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
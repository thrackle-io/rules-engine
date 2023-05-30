
# Non-Fungible Token (NFT) Deployment
[![Project Version][version-image]][version-url]

---

### Application Ecosystem minimum deployment: 

1. The Protocol must be deployed to the target chain, or is currently deployed to the target chain.
2. An AppManager must be deployed to the target chain.

### NFT minimum deployment:

1. The Protocol must be deployed to the target chain, or is currently deployed to the target chain.
2. An AppManager must be deployed to the target chain, or is currently deployed to the target chain.
   - NOTE: AppManagers must be reused by all tokens in the ecosystem
3. An NFTHandler is deployed with each NFT on the target chain.
4. A ProtocolSupportedNFT must be be deployed to the target chain
   - The ProtocolSupportedNFT will also deploy a new NFTHandler.


### Manual Deployments
#### [Local Deployment with Foundry][localDeploymentFoundry-url]

#### [Testnet Deployments][testnetDeployment-url]

#### [Mainnet Deployments][mainnetDeployment-url]

#### [Customizations][customizations-url]


## Fungible Token (NFT) Deployment
** UNDER CONSTRUCTION **


## Release History

* 0.1.1
    * Initial document creation
  
<!-- These are the body links -->
[localDeploymentFoundry-url]: ./nft/DEPLOYMENT-LOCAL.md
[testnetDeployment-url]: ./nft/DEPLOYMENT-TESTNET.md
[mainnetDeployment-url]: ./nft/DEPLOYMENT-MAINNET.md
[customizations-url]: ./nft/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron


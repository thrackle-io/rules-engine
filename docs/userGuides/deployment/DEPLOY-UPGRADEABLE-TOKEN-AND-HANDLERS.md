# Deploying Ugradable Token and Handler
[![Project Version][version-image]][version-url]

---

Upgradeable Non-funglible token contracts require special attention and processes during deployment. Follow the steps outlined below to utilize the deployment scripts and processes for deploying a protocol supported upgradable NFT and Handler. 

## Index

- [Deploying Ugradable Token and Handler](#deploying-ugradable-token-and-handler)
  - [Index](#index)
  - [Prerequisites](#prerequisites)
  - [Upgradable NFT Deployment](#upgradable-nft-deployment)

## Prerequisites

It's required that the token you are deploying is a protocol compatible token and therefore inherits the protocol token set (see example [here](../../../src/example/ERC721/upgradeable/ApplicationERC721UpgAdminMint.sol)). It is also required that you have a [deployed protocol](./DEPLOY-PROTOCOL.md), and a [deployed application manager](./DEPLOY-APPMANAGER.md). It's also required that you have properly configured [admins](../permissions/ADMIN-ROLES.md) as two App Administrator roles are required for these scripts to function.

If you are using an already deployed rule processor address and app manager address set the addresses:
        ````
        export RULE_PROCESSOR_DIAMOND=<ruleProcessorDiamondAddress>
        ````    
        &        
        ````
        export APPLICATION_APP_MANAGER=<applicationAppManagerAddress>
        ````

## Upgradable NFT Deployment

NOTE: 
- NFT Batch minting and burning is not supported in this release.

- Upgradable Tokens require 3 addresses during the deployment steps. First, the deployment owner that deploys the app manager and sets roles. Second, an Application Administrator address to deploy the token, token proxy and initialize the token. Third, a Configuration Application Administrator address to connect the token with the handler address once deployed and initilaized. The token and the handler contracts require initialize functions called and are controlled through the protocol RBAC roles.

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER`, `CONFIG_APP_ADMIN` and `DEPLOYMENT_OWNER_KEY` are used by the deployment script.  

2. Inside the [ApplicationNFT script](../../../script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol) change the `Wolfman` name, `WOLF` symbol inside the script and `APPLICATION_ERC721_URI_1` inside the .env file to the desired name, symbol and token URI for your NFT deployment.

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash  script/ParseApplicationDeploy.sh 3 && source .env
        ````
5. Configure the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol --ffi --broadcast
        ````

These scripts deploy an Upgradable Non-Fungible Token, Asset Handler Diamond, Initializes the token and diamond, connects the tokens to their handler and registers the token with the [Application Manager](../architecture/client/application/APPLICATION-MANAGER.md). 


<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ./SET-ENVIRONMENT.md
[customizations-url]: ../rules/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/forte-rules-engine
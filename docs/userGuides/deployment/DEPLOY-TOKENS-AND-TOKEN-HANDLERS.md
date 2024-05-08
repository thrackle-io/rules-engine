# Deploying Tokens and their Handlers
[![Project Version][version-image]][version-url]

---

Tokens are the lifeblood of the web3 economy and with games they are no different. However sometimes it's better when you're more easily able to craft rules for your tokens. The architecture of the rules protocol necessitates that when deploying a token, you do so with it connected into what's called a "token handler". This handler will connect to your application and simplify the process of adding a variety of rules to your protocol. In order to begin deploying your tokens and connecting them to a token handler, we've added some simple scripts to ease the process. The scripts lay out a basic way of getting a deployed application manager to connect a fresh deployed token and get it connected into the application's token handler. We highly encourage exploring them if you want a more intricate setup for your application. Once you run these, you're ready to start applying [rules](../rules/README.md)!

## Index

1. [Prerequisites](#prerequisites)
2. [Simple ERC20 Token Deployment](#simple-erc20-deployment)
3. [Simple NFT Deployment](#simple-nft-deployment)

## Prerequisites

It's required that the token that you are deploying is a protocol compatible token and therefore inherits the protocol token set (see example [here](../../../src/example/ERC20/ApplicationERC20.sol)). It is also required that you have a [deployed protocol](./DEPLOY-PROTOCOL.md), and a [deployed application manager](./DEPLOY-APPMANAGER.md). It's also required that you have properly configured [admins](../permissions/ADMIN-ROLES.md).

## Simple ERC20 Deployment

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER` is used by the deployment script. 

2. Inside the [Application Token script](../../../script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol) change the `Frankenstein` name and `FRANK` symbol to the desired name and symbol for the token. 

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash script/ParseApplicationDeploy.sh 2
        ````


## Simple NFT Deployment

NOTE: NFT Batch minting and burning is not supported in this release.

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER` is used by the deployment script. 

2. Inside the [ApplicationNFT script](../../../script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol) change the `name` and `symbol` of your NFT to the desired name and symbol for the token. 

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash script/ParseApplicationDeploy.sh 3
        ````
5. This script deploys the NFT token, Asset Handler Diamond, Initializes the diamond, connects the token to the handler and registers the token with the [Application Manager](../architecture/client/application/APPLICATION-MANAGER.md).

6. To use a script for an example upgradeable ERC721 token with proper initialization, run the following:
        ````
        forge script script/DeployProtocolERC721U.sol --ffi --broadcast
        ````

<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ./SET-ENVIRONMENT.md
[customizations-url]: ../rules/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
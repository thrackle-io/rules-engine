# Deploying Tokens and their Handlers
[![Project Version][version-image]][version-url]

---

Tokens are the lifeblood of the web3 economy and with applications they are no different. However sometimes it's better when you're more easily able to craft rules for your tokens. The architecture of the rules protocol necessitates that when deploying a token, you do so with it connected into what's called a "token handler". This handler will connect to your application and simplify the process of adding a variety of rules to your protocol. In order to begin deploying your tokens and connecting them to a token handler, we've added some simple scripts to ease the process. The scripts lay out a basic way of getting a deployed application manager to connect a freshly deployed token and get it connected into the application's token handler. We highly encourage exploring them if you want a more intricate setup for your application. Once you run these, you're ready to start applying [rules](../rules/README.md)!

## Index

1. [Prerequisites](#prerequisites)
2. [Simple ERC20 Token Deployment](#simple-erc20-deployment)
3. [Simple NFT Deployment](#simple-nft-deployment)
4. [Integrate with Protocol Hook](#integrate-protocol)

## Prerequisites

It's required that the token that you are deploying is a protocol compatible token and therefore inherits the protocol token set (see example [here](../../../src/example/ERC20/ApplicationERC20.sol)). It is also required that you have a [deployed protocol](./DEPLOY-PROTOCOL.md), and a [deployed application manager](./DEPLOY-APPMANAGER.md). It's also required that you have properly configured [admins](../permissions/ADMIN-ROLES.md) as the App Administrator role is required for the scripts to function.

If you are using an already deployed rule processor address and app manager address set the addresses:
        ````
        export RULE_PROCESSOR_DIAMOND=<ruleProcessorDiamondAddress>
        ````    
        &        
        ````
        export APPLICATION_APP_MANAGER=<applicationAppManagerAddress>
        ````

## Simple ERC20 Deployment

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER` and `DEPLOYMENT_OWNER_KEY` are used by the deployment script. 

2. Inside the [Application Token script](../../../script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol) change the `Frankenstein` name and `FRANK` symbol to the desired name and symbol for the token. 

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash script/ParseApplicationDeploy.sh 2
        ````
5. Configure the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast
        ````

## Simple NFT Deployment

NOTE: NFT Batch minting and burning is not supported in this release.

1. Ensure the [environment variables][environment-url] are set correctly. The `APPLICATION_APP_MANAGER` and `DEPLOYMENT_OWNER_KEY` are used by the deployment script. 

2. Inside the [ApplicationNFT script](../../../script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol) change the `name`, `symbol` and `APPLICATION_ERC721_URI_1` of your NFT to the desired name, symbol and token URI for the deployment. 

3. Deploy the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
        ````
4. Use the output from the deployment to set relevant environment variables:
        ````
        bash script/ParseApplicationDeploy.sh 3
        ````
5. Configure the contracts:
        ````
        forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast
        ````

These scripts deploy a Fungible Token, Non-Fungible Token, Asset Handler Diamond for each token, Initializes each diamond, connects the tokens to their handler and registers each token with the [Application Manager](../architecture/client/application/APPLICATION-MANAGER.md). 

## Integrate Protocol 
If a custom ERC721 implementation is being used, follow these steps to integrate the Protocol's _checkAllRules() hook:

1. Import the [ProtocolERC721.sol](../../../src/client/token/ERC721/ProtocolERC721.sol) contract into the desired ERC721 contract:
```
import "src/client/token/ERC721/ProtocolERC721.sol";
```
2. Inherit the ProtocolERC721 contract: 
```
contract ERC721Example is ProtocolERC721 {} 
```
3. Update constructor of ERC721 contract to include the ProtocolERC721.sol and accept appManager address variable: 
```
constructor(string memory _name, string memory _symbol, address _appManagerAddress, string memory _baseUri) ProtocolERC721(_name, _symbol, _appManagerAddress, _baseUri) {}
```
4. Ensure the desired ERC721 contract implementation compiles and passes all tests. 
5. Replace `ApplicationERC721AdminOrOwnerMint` inside of the NFT deployment scripts: [Part 1](../../../script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol) and [Part2](../../../script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol) with desired ERC721 contract name and directory location. 
6. Follow the steps for [Simple NFT Deployment](#simple-nft-deployment) with updated script to deploy the desired ERC721 implementation. 

<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ./SET-ENVIRONMENT.md
[customizations-url]: ../rules/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
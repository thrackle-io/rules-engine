# Deploying Tokens 
[![Project Version][version-image]][version-url]

---

Tokens are the lifeblood of the web3 economy and with applications they are no different. However sometimes it's better when you're more easily able to craft rules for your tokens. The architecture of the rules engine necessitates that when deploying a token, you do so with it connected into what's called a "token handler". This handler will connect to your application and simplify the process of adding a variety of rules to your protocol. Once you have a deployed and configured protocol supported token, you're ready to start applying [rules](../rules/README.md)!

## Index

- [Deploying Tokens](#deploying-tokens)
  - [Index](#index)
  - [Prerequisites](#prerequisites)
  - [ERC20 Integration](#erc20-integration)
  - [ERC721 Integration](#erc721-integration)


## Prerequisites

The following steps must already be completed on the target chain:

1. The [Protocol](./DEPLOY-PROTOCOL.md) has been deployed
2. You have deployed an [Application Manager](./DEPLOY-APPMANAGER.md)
3. You have created at least one [Application Administrator](../permissions/ADMIN-ROLES.md) role in the Application Manager.
4. You have created an [ERC20 Handler](./DEPLOY-TOKEN-HANDLERS.md)

It's required that your token be a protocol compatible token that adheres to the [protocol interface](../../../src/client/token/IProtocolToken.sol). 


## ERC20 Integration

1. Ensure the [environment variables][environment-url] are set correctly. 

2. Inside the ERC20 contract, import [IProtocolToken.sol](../../../src/client/token/IProtocolToken.sol).
   ```
    import "src/client/token/IProtocolToken.sol";       
   ``` 
3. Add [IProtocolToken.sol](../../../src/client/token/IProtocolToken.sol) to the implementation list.
   ```
    contract ClientERC20() is IProtocolToken {       
   ``` 
4. Implement the following functions: 
   1. Required: ```getHandlerAddress()```
   2. Required: ```connectHandlerToToken(address _deployedHandlerAddress)```
   3. Optional: TRANSFER FUNCTION GROUP, only required if you want to set fees.
      1. ```transfer(address to, uint256 amount)```
      2. ```transferFrom(address from, address to, uint256 amount)```
      3. ```_handleFees(address from, uint256 amount)```
   
   NOTE: Function templates can be found in [ApplicationERC20](../../../src/example/ERC20/ApplicationERC20.sol)
5. Open a terminal
6. Compile and deploy the ERC20
   ```
     forge create src/clientFolder/ClientERC20.sol:ClientERC20 --rpc-url=$ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY
   ```
7. Export the newly deployed ERC20 address to the terminal
   ```
   export APPLICATION_ERC20_ADDRESS=0xADDRESS_FROM_PREVIOUS_STEP
   ```
8. Connect the ERC20 to the ERC20 Handler
   ```
     cast send $APPLICATION_ERC20_ADDRESS "connectHandlerToToken(address)" $APPLICATION_ERC20_HANDLER_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --from $APP_ADMIN --rpc-url $ETH_RPC_URL
   ```
9. Register the token with the Application Manager
   ```
     cast send $APPLICATION_APP_MANAGER "registerToken(string, address)" "Token Name" $APPLICATION_ERC20_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --from $APP_ADMIN --rpc-url $ETH_RPC_URL
   ```

## ERC721 Integration

1. Ensure the [environment variables][environment-url] are set correctly. 

2. Inside the ERC721 contract, import [IProtocolToken.sol](../../../src/client/token/IProtocolToken.sol).
   ```
    import "src/client/token/IProtocolToken.sol";       
   ``` 
3. Add [IProtocolToken.sol](../../../src/client/token/IProtocolToken.sol) to the implementation list.
   ```
    contract ClientERC721() is IProtocolToken {       
   ``` 
4. Implement the following functions: 
   1. Required: ```getHandlerAddress()```
   2. Required: ```connectHandlerToToken(address _deployedHandlerAddress)``` 
   NOTE: Function templates can be found in [ApplicationERC721](../../../src/example/ERC721/ApplicationERC721.sol)
5. Compile and deploy the ERC721
   ```
     forge create src/clientFolder/ClientERC721.sol:ClientERC721 --rpc-url=$ETH_RPC_URL --private-key $DEPLOYMENT_OWNER_KEY
   ```
6. Export the newly deployed ERC721 address to the terminal
   ```
   export APPLICATION_ERC721_ADDRESS=0xADDRESS_FROM_PREVIOUS_STEP
   ```
7. Connect the ERC721 to the ERC721 Handler
   ```
     cast send $APPLICATION_ERC721_ADDRESS "connectHandlerToToken(address)" $APPLICATION_ERC721_HANDLER_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --from $APP_ADMIN --rpc-url $ETH_RPC_URL
   ```
8. Register the token with the Application Manager
   ```
     cast send $APPLICATION_APP_MANAGER "registerToken(string, address)" "Token Name" $APPLICATION_ERC721_ADDRESS --private-key $APP_ADMIN_PRIVATE_KEY --from $APP_ADMIN --rpc-url $ETH_RPC_URL
   ```

<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ./SET-ENVIRONMENT.md
[customizations-url]: ../rules/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine
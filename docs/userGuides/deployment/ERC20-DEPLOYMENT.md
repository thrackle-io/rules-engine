# ERC20 Token Deployment
[![Project Version][version-image]][version-url]

---

### Application Ecosystem minimum deployment: 

1. The Protocol must be deployed to the target chain, or is currently deployed to the target chain.
2. An AppManager must be deployed to the target chain.

### ERC20 minimum deployment:

1. The Protocol must be deployed to the target chain, or is currently deployed to the target chain.
2. An AppManager must be deployed to the target chain, or is currently deployed to the target chain.
   - NOTE: AppManagers must be reused by all tokens in the ecosystem
3. A Protocol-Supported ERC20 must be be deployed to the target chain
4. An ERC20Handler must be deployed with each ERC20 token and connected accordingly.


### Deployment

1. Ensure the [environment variables][environment-url] are set correctly.
2. Copy the template from `src/example/ERC20/ApplicationERC20.sol` to your desired location.
3. Change the name of the contract to suit your naming standards.
   - Do not change the import or parent contract.
4. Compile the contract:
   ````
   forge build --use solc:0.8.17
   ````
5. Deploy the contract with the respective constructor parameters:
    - **_name** - The full name of your token. For instance, MickeyMouseCoin.
    - **_symbol** - The ticker or symbol of your token. for example, MMC.
    - **_appManagerAddress** - The address of your appManager. see [Deploy AppManager][deployAppManager].
    1. Run the command to create and deploy the contract: 

        *NOTE: The path includes source name and contract name.*
    
        ````
        forge create src/example/ERC20/ApplicationERC20.sol:ApplicationERC20 --constructor-args  "MickeyMouseCoin" "MMC" $APPLICATION_APP_MANAGER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
        ````

    2. Now, locate the address from the output, example:
        ````
        0x0116686E2291dbd5e317F47faDBFb43B599786Ef
        ````
    3. Set the environment variable:
        ````
        export APPLICATION_COIN=address from output
        ````
6. Deploy the tokenHandler contract with the following parameters:
    - **_ruleProcessorProxyAddress** The address of the RuleProcessorDiamond. See [Deploy Protocol][deployProtocol].
    - **_appManagerAddress** The address of your appManager. see [Deploy AppManager][deployAppManager].
    - **_assetAddress** Address of the token deployed in previous step. You can use the exported variable APPLICATION_NFT.
    - **_upgradeMode** set to `false` since this is a fresh token.
    1. Run the command to create and deploy the contract. 

        *NOTE: The path includes source name and contract name.*
        ````
        forge create src/example/ERC20/ApplicationERC20Handler.sol:ApplicationERC20Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_COIN false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
        ````
    2. Locate the address from the output, example:
        ````
        0x0C25Bc46542acb274F055D7368F9Bec7fB23aE74
        ````
    3. Set the environment variable:
        ````
        export APPLICATION_COIN_HANDLER=address from output
        ````
7. Connect the handler to the token:
    ```
    cast send $APPLICATION_COIN "connectHandlerToToken(address)()" $APPLICATION_COIN_HANDLER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```

8. Finally, register your new token in your application:
    ```
    cast send $APPLICATION_APP_MANAGER "registerToken(string,address)()" "MMYC" $APPLICATION_COIN --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```
 
<!-- These are the body links -->
[deployAppManager]: DEPLOY-APPMANAGER.md
[deployProtocol]: DEPLOY-PROTOCOL.md
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
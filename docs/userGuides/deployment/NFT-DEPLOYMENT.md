
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
3. A ProtocolSupportedNFT must be be deployed to the target chain
4. An NFTHandler must be deployed with each NFT and connected accordingly.

### Deployment

1. Ensure the [environment variables][environment-url] are set correctly.
2. Select the NFT base contract that you wish to use from src/example/ERC721 directory, or your own custom protocol-compliant ERC721 contract, and copy the file to your desired location.
3. Change the name of the contract to suit your naming standards
   - Do not change the import or parent contract
4. Compile the contract
   ````
   forge build --use solc:0.8.17
   ````
5. Deploy the contract with the respective constructor parameters. As an example, we will use the `ApplicationERC721WhitelistMint.sol`. For this particular case, the contruction arguments are:
    - **_name** - The full name of your token. For instance, MickeyMouseYachtClub.
    - **_symbol** - The ticker or symbol of your token. for example, MMYC.
    - **_appManagerAddress** - The address of your appManager. see [Deploy AppManager][deployAppManager].
    - **_baseUri** - The base URI for the metadata of your NFTs.
    - **_mintsAllowed** - The amounts of free mints granted to a whitelisted address. For instance, 3 free NFTs.
    1. Run the command to create and deploy the contract: 

        *NOTE: The path includes source name and contract name.*
    
        ````
        forge create src/example/ERC721/ApplicationERC721WhitelistMint.sol:ApplicationERC721 --constructor-args  "MickeyMouseYachtClub" "MMYC" $APPLICATION_APP_MANAGER "my.base.uri.com/mmyc/" 3 --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
        ````

    2. Now, locate the address from the output, example:
        ````
        0x0116686E2291dbd5e317F47faDBFb43B599786Ef
        ````
    3. Set the environment variable
        ````
        export APPLICATION_NFT=address from output
        ````
6. Deploy the tokenHandler contract with the following parameters:
    - **_ruleProcessorProxyAddress** The address of the RuleProcessorDiamond. See [Deploy Protocol][deployProtocol].
    - **_appManagerAddress** The address of your appManager. see [Deploy AppManager][deployAppManager].
    - **_assetAddress** Address of the token deployed in previous step. You can use the exported variable APPLICATION_NFT.
    - **_upgradeMode** set to `false` since this is a fresh token.
    3. Run the command to create and deploy the contract. 

        *NOTE: The path includes source name and contract name.*
        ````
        forge create src/client/token/ERC721/ProtocolERC721Handler.sol:ProtocolERC721Handler --constructor-args $RULE_PROCESSOR_DIAMOND $APPLICATION_APP_MANAGER $APPLICATION_NFT false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
        ````
    4. Locate the address from the output, example:
        ````
        0x0C25Bc46542acb274F055D7368F9Bec7fB23aE74
        ````
    5. Set the environment variable
        ````
        export APPLICATION_NFT_HANDLER=address from output
        ````
7. Connect the handler to the token:
    ```
    cast send $APPLICATION_NFT "connectHandlerToToken(address)()" $APPLICATION_NFT_HANDLER --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```

8. Finally, register your new token in your application:
    ```
    cast send $APPLICATION_APP_MANAGER "registerToken(string,address)()" "MMYC" $APPLICATION_NFT --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ```
   

### Manual Deployments
#### [Local Deployment with Foundry][localDeploymentFoundry-url]

#### [Testnet Deployments][testnetDeployment-url]

#### [Mainnet Deployments][mainnetDeployment-url]

#### [Customizations][customizations-url]


## Fungible Token (NFT) Deployment
** UNDER CONSTRUCTION **


## Release History

* 0.1.1  --> NOT SURE WHAT TO PUT HERE
    * Initial document creation
  
<!-- These are the body links -->
[localDeploymentFoundry-url]: ./nft/DEPLOYMENT-LOCAL.md
[testnetDeployment-url]: ./nft/DEPLOYMENT-TESTNET.md
[mainnetDeployment-url]: ./nft/DEPLOYMENT-MAINNET.md
[customizations-url]: ./nft/CUSTOMIZATIONS.md
[deployAppManager]: DEPLOY-APPMANAGER.md
[deployProtocol]: DEPLOY-PROTOCOL.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron


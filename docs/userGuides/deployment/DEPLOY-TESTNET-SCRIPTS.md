# Deployment To Testnet Using Individual Scripts

[![Project Version][version-image]][version-url]

For testnet deployments, a one at a time script solution is provided. In order to use these scripts, follow these steps:

1. Open the .env file and set the following environment variables:
   1. DEPLOYMENT_OWNER(address that will own the application contracts)
   2. DEPLOYMENT_OWNER_KEY
   3. APP_ADMIN(Main admin role for example application)
   4. APP_ADMIN_KEY
   5. CONFIG_APP_ADMIN(upgradeable contract owner)
   6. CONFIG_APP_ADMIN_KEY
   7. LOCAL_RULE_ADMIN(Main rule admin role for example application)
2. Open a terminal and run the following commands, setting the values accordingly. NOTE: These are for the target testnet.

```
   export ETH_RPC_URL=???? 
   export CHAIN_ID=????
```

3. In the same terminal run these commands in succession:

NOTE: These commands must all be run one at a time

```bash

forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 1 --chainid $CHAIN_ID
forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 2 --chainid $CHAIN_ID
forge script script/clientScripts/Application_Deploy_02_ApplicationFT1Pt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 3 --chainid $CHAIN_ID
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTPt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 4 --chainid $CHAIN_ID
forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
sh script/ParseApplicationDeploy.sh 5 --chainid $CHAIN_ID
forge script script/clientScripts/Application_Deploy_07_ApplicationAdminRoles.s.sol --ffi --broadcast --rpc-url $ETH_RPC_URL
```

Make sure that all the srcipts ran successfully, and then:

```bash 
forge test --ffi --rpc-url $ETH_RPC_URL 
```


##### Note: an ETH_RPC_URL can be found in the .env file.

#### Deploy The Protocol

Be sure to [set environmental variables](./deployment/SET-ENVIRONMENT.md) and source the .env file (`source .env`) and then feel free to run this script:

`scripts/deploy/DeployProtocol.sh`
This script is responsible for deploying all the protocol contracts. Take into account that no application-specific contracts are deployed here.

#### Deploy Some Test Application Tokens

`script/clientScripts/Application_Deploy_01_AppManager.s.sol`
`script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol`
`script/clientScripts/Application_Deploy_03_ApplicationFT2.s.sol`
`script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol`
`script/clientScripts/Application_Deploy_05_Oracle.s.sol`
`script/clientScripts/Application_Deploy_06_Pricing.s.sol`
These scripts deploy the contracts that are specific for applications, emulating the steps that a application dev would follow. They will deploy 2 ERC20s and 2 ERC721 tokens, among the other setup contracts.

If anvil is not listening to the commands in the scripts, make sure you have exported the local foundry profile `export FOUNDRY_PROFILE=local`.


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-protocol
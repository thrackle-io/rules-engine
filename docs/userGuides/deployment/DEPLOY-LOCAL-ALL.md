# Deployment Using All-In-One Scripts

[![Project Version][version-image]][version-url]

For local deployments, an all-in-one script solution is provided. In order to use this script, follow these steps:

1. Start an instance of anvil
   Open a dedicated terminal to run an Anvil local blockchain:

    ```bash
    export FOUNDRY_PROFILE=local
    anvil
    ```

2. Open the .env file and set the following environment variables:
   1. DEPLOYMENT_OWNER(address that will own the protocol contracts)
   2. DEPLOYMENT_OWNER_KEY
   3. APP_ADMIN(Main admin role for example application)
   4. APP_ADMIN_KEY
   5. CONFIG_APP_ADMIN(upgradeable contract owner)
   6. CONFIG_APP_ADMIN_KEY
   7. LOCAL_RULE_ADMIN(Main rule admin role for example application)
3. Run the following command:

```

sh script/clientScripts/Application_Deploy_Example.sh

```

4. Enter the data requested by the script
5. Results of the deployment(contract address and transaction receipts) can be found in the broadcast folder within the following subdirectories. 

```
   broadcast/DeployAllModulesPt1.s.sol/31337/run-latest.json 
   broadcast/DeployAllModulesPt2.s.sol/31337/run-latest.json 
   broadcast/DeployAllModulesPt3.s.sol/31337/run-latest.json 
   broadcast/DeployAllModulesPt4.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_01_AppManager.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_02_ApplicationFT1.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_02_ApplicationFT1Pt2.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_04_ApplicationNFT.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_04_ApplicationNFTUpgradeable.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_04_ApplicationNFTPt2.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_04_ApplicationNFTUpgradeablePt2.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_05_Oracle.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_06_Pricing.s.sol/31337/run-latest.json 
   broadcast/Application_Deploy_07_ApplicationAdminRoles.s.sol/31337/run-latest.json 
```

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-protocol

# AppManager Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variables][environment-url] are set correctly.
2. Copy the template from src/example/ApplicationAppManager.sol to your desired location
3. Change the name of the contract to suit your naming standards
   - Do not change the import or parent contract
4. Compile the contract
   ````
   forge build --use solc:0.8.17

   ````
5. Deploy the contract sending in the following parameters:
    1. _Owner Address_ - This is the account that is to be the first Application Administrator and Super Admin. NOTE: This address must be used throughout the deployment process
    2. _appName_ - The Name for your Application. 
    3. _ruleProcessorAddress_ - The address of the RuleProcessorDiamond contract set in Step 1.
    4. _upgradeMode_ - This is a boolean value for if this is an upgraded AppManager being deployed. NOTE: Passing in a true boolean value will not deploy new data contracts. 
    5. Run the command to create and deploy the contract. NOTE: The path includes source name and contract name.
    ````
    forge create src/example/deploy/CastlevaniaAppManager.sol:CastlevaniaAppManager --constructor-args $APP_ADMIN_1 "Castlevania" $RULE_PROCESSOR_DIAMOND false --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````
    6. Locate the address from the output, example:
    ````
    0x0116686E2291dbd5e317F47faDBFb43B599786Ef
    ````
    7. Set the environment variable
    ````
    export APPLICATION_APP_MANAGER=address from output
    ````
6. Deploy the applicationHandler contract with the following parameters:
    1. _rule processor diamond address_ - The address of the RuleProcessorDiamond contract set in Step 1.
    2. _application app manager address_ - The address of the app manager deployed in previous step.
    3. Run the command to create and deploy the contract. NOTE: The path includes source name and contract name.
    ````
    forge create src/example/deploy/ApplicationHandler.sol:CastlevaniaHandler --constructor-args $RULE_PROCESSOR_DIAMOND $APP_MANAGER_ADDRESS --private-key $APP_ADMIN_1_KEY --rpc-url $ETH_RPC_URL
    ````
    4. Locate the address from the output, example:
    ````
    0x0C25Bc46542acb274F055D7368F9Bec7fB23aE74
    ````
    5. Set the environment variable
    ````
    export APPLICATION_APPLICATION_HANDLER=address from output
    ````
7. [Create additional administrators][createAdminRole-url] (Optional)
   


<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
# AppManager Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variable][environment-url] is set correctly.
2. Copy the template from src/example/ApplicationAppManager.sol to your desired location
3. Change the name of the contract to suit your naming standards
   - Do not change the import or parent contract
4. Compile the contract
   ````
   forge build --use solc:0.8.17

   ````
5. Deploy the contract sending in the following parameters:
    1. _Owner Address_ - This is the account that is to be the first Application Administrator. NOTE: This address must be used throughout the deployment process
    2. _appName_ - The Name for your Application Manager. 
    3. _ruleProcessorAddress_ - The address of the RuleProcessorDiamond contract deployed in the previous section
    4. _upgradeMode_ - This is a boolean value for if this is an upgraded AppManager being deployed. NOTE: Passing in a true boolean value will not deploy new data contracts. 
     ````
     forge create src/example/ApplicationAppManager.sol:ApplicationAppManager --constructor-args 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 "appName" 0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f upgradeBool --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url $ETH_RPC_URL

    ````
6. Use the output from the previous deployment to take note of the AppManager's address.
    example:
    ````
    Deployed to: 0xb7278A61aa25c888815aFC32Ad3cC52fF24fE575
    Transaction hash: 0xeac248a8c7dfd3c09927f607723acebeb1f6e1efb6bd6eef8f273982c762b526
    ````
7. Retrieve the Handler address that was automatically deployed by the AppManager:
    ````
    cast call APP_MANAGER_ADDRESS "getApplicationHandlerAddress()(address)" -private-key OWNER_PRIVATE_KEY
    ````

8. [Create additional administrators][createAdminRole-url] (Optional)
   


<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
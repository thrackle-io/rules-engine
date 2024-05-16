# Application Manager Deployment
[![Project Version][version-image]][version-url]

---

1. Ensure the [environment variables][environment-url] are set correctly. The `RULE_PROCESSOR_DIAMOND` is used by the deployment script.
2. Use the following script to deploy the Application Manager and Application Handler: 
    ```bash
    forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast
    ```
3. Use the output from the deployment to set relevant environment variables:
    ```bash
    bash script/ParseApplicationDeploy.sh 1
    ```
4. The deployer of the Application Manager is granted the [super admin role](../permissions/ADMIN-ROLES.md). 
5. [Create additional administrators][createAdminRole-url] (Optional)



<!-- These are the body links -->
[createAdminRole-url]: ../permissions/ADMIN-CONFIG.md
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md
[environment-url]: ./SET-ENVIRONMENT.md



<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
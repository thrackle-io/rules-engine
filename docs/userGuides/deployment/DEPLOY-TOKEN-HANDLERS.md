# Deploying Token Handlers
[![Project Version][version-image]][version-url]

---

Protocol supported tokens require a Token Handler be deployed. The Token Handler connects the token to the protocol and the Application Manager, providing the ability to configure rules. It is recommended that the Token Handler is deployed prior to the token.  See below for details.

## Index

- [Deploying Token Handlers](#deploying-token-handlers)
  - [Index](#index)
  - [Prerequisites](#prerequisites)
  - [ERC20 Token Handler Deployment](#erc20-token-handler-deployment)
  - [ERC721 Token Handler Deployment](#erc721-token-handler-deployment)


## Prerequisites

The following steps must already be completed on the target chain:

1. The [Protocol](./DEPLOY-PROTOCOL.md) has been deployed
2. You have deployed an [Application Manager](./DEPLOY-APPMANAGER.md)
3. You have created at least one [Application Administrator](../permissions/ADMIN-ROLES.md) role in the Application Manager.


## ERC20 Token Handler Deployment 

1. Ensure the [environment variables][environment-url] are set correctly. The `DEPLOYMENT_OWNER` and `DEPLOYMENT_OWNER_KEY` are used by the deployment script.
2. Run a script to deploy the Handler:
   
```
  forge script script/clientScripts/DeployERC20Handler.s.sol --ffi --broadcast
```

3. Run a script to configure the Handler:
   
```
  forge script script/clientScripts/DeployERC20HandlerPt2.s.sol --ffi --broadcast
```


## ERC721 Token Handler Deployment 

1. Ensure the [environment variables][environment-url] are set correctly. The `DEPLOYMENT_OWNER` and `DEPLOYMENT_OWNER_KEY` are used by the deployment script.
2. Run a script to deploy the Handler:

```
  forge script script/clientScripts/DeployERC721Handler.s.sol --ffi --broadcast
```

3. Run a script to configure the Handler:
   
```
  forge script script/clientScripts/DeployERC721HandlerPt2.s.sol --ffi --broadcast
```
<!-- These are the body links -->
[ERC721-url]: https://eips.ethereum.org/EIPS/eip-721
[environment-url]: ./SET-ENVIRONMENT.md
[customizations-url]: ../rules/CUSTOMIZATIONS.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine
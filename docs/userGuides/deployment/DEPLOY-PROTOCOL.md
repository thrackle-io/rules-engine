# Protocol Deployment
[![Project Version][version-image]][version-url]

---
Due to the architecture of the Protocol, several contracts are required to be deployed to utilize the protocol. Once these are deployed, 
several application ecosystems may utilize these contracts independently without affecting each other. The following diagram
is an overview of this deployment process:
![Protocol deployment sequence diagram](../images/ProtocolDeployment.png)

1. Ensure the [environment variable][environment-url] is set correctly.
2. Open a terminal, navigate to the cloned repo directory and run the build script
````
    forge script script/DeployAllModules.s.sol --ffi --broadcast --verify --rpc-url $ETH_RPC_URL
````
- Take note of the output and locate the following addresses(from terminal output or broadcast/DeployAllModules.s.sol/31337/run-latest.json):
```
      "hash": "0x23d223c2e2532026ec319dcfd224248bbaadc432348f77ea289434e07ab3a7aa",
      "transactionType": "CREATE",
      "contractName": "ContractRegistry",
      "contractAddress": "0x5FbDB2315678afecb367f032d93F642f64180aa3",

```
3. Note the addresses for the following contract deployments
   1. ContractRegistry
   2. RuleStorageDiamond
   3. RuleHandler

<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

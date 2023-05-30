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

# *** UNDER CONSTRUCTION ***
- Take note of the output and locate the following addresses(from terminal output or broadcast/DeployAllModules.s.sol/31337/run-latest.json):
```
      "hash": "0x1902f5f3c6f2ed24ae3a64c8ddb41e72fb71b57c3404278c965dee920aa6f40f",
      "transactionType": "CREATE",
      "contractName": "RuleStorageDiamond",
      "contractAddress": "0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8"

```
3. Note the addresses for the following contract deployments
   1. RuleProcessorDiamond
   2. RuleStorageDiamond


<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
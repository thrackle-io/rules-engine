# Environment Variable Configuration
[![Project Version][version-image]][version-url]

---
## Set Environment Variable


| Environment         | RPC URL|
| :--- | :---  | 
| Local | http://localhost:8545 | 
| Polygon Mumbai |  https://rpc-mumbai.matic.today |
| Polygon POS |  https://polygon-rpc.com  |

_NOTE: These are the public examples. You still need to use a node provider like [Alchemy][alchemy-url] or [Infura][infura-url]_

---

1. Set the RPC URL
   1. Choose the RPC URL that corresponds with the desired environment.
   2. Export it to zsh
        ````
        export ETH_RPC_URL=http://localhost:8545
        ````
2. Set the Rule Processor Address to make the connection with the protocol
   1. For local deployments, the Rule Processor address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url] for the target chain.
   2. Export it to zsh
        ````
        export RULE_PROCESSOR_DIAMOND=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266(substitute with your desired address)
        ````
3. Set the Rule Storage Address for ease of rule creation
   1. For local deployments, the Rule Storage address can be found in previous steps, otherwise consult the [Deployment Directory][deploymentDirectory-url] for the target chain.
   2. Export it to zsh
        ````
        export RULE_STORAGE_DIAMOND=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266(substitute with your desired address)
        ````
4. Set the Application Admin Address
   1. This is the initial owner and/or Application Administrator. It is suggested that this address be reused during the initial deployment process. The environment variable is reused for each deployment.
   2. Export it to zsh
        ````
        export APP_ADMIN_1=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266(substitute with your desired address)
        ````
5. Set the Application Admin Private Key
   1. This is the private key for the initial owner and/or Application Administrator. This should correspond to the Application Admin Address set in Step 4. NOTE: This account needs to have sufficient funds to cover deployment costs.
   2. Export it to zsh
        ````
        export APP_ADMIN_1_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80(substitute with your desired private key)
        ````


<!-- These are the body links -->
[alchemy-url]: https://www.alchemy.com
[infura-url]: https://www.infura.io
[deploymentDirectory-url]: ./DEPLOYMENT-DIRECTORY.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
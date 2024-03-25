# Protocol Deployment
[![Project Version][version-image]][version-url]

---
Due to the architecture of the Protocol, several contracts are required to be deployed to utilize the protocol. Once these are deployed, 
several application ecosystems may utilize these contracts independently without affecting each other. The following diagram
is an overview of this deployment process:


![Protocol deployment sequence diagram](../images/ProtocolDeployment.png)

1. Open a new terminal
2. Create a fresh .env: `touch .env`
3. Set the RPC URL
   1. Choose the RPC URL that corresponds with the desired environment and chain.
   2. Export it to zsh. The following is an example when working with a local blockchain in the localhost:
        ````
        export ETH_RPC_URL=http://localhost:8545
        ````
4. Set the Protocol Owner Private Key
   1. This is the private key for the account that will "own" all the protocol contracts and has full permissions to upgrade. It is recommended that this address is a disposable address, and that the ownership of the protocol pass to a multi-signature wallet immediately after deployment. 
   
      *NOTE: This account needs to have sufficient funds to cover deployment costs and ownership transfer.*
   2. Export it to zsh
        ````
        export DEPLOYMENT_OWNER_KEY=desired private key
        ```` 
5. Set the Protocol Owner Address
   1. This is the account derived from the private key from step 3.
   2. Export it to zsh
        ````
        export DEPLOYMENT_OWNER=<address derived from owner private key>
        ````
6. In the same terminal as above, ensure that the Foundry installation is current (see troubleshooting section)
   ````
   foundryUp
   ````

7. In the same terminal as above, navigate to the cloned repo directory and run the build script.
   ````
	bash script/deploy/DeployProtocol.sh
   ````

   If this is your first time and you're trying to deploy in a local development environment, you might run into errors with the above approach, it's recommended to set a local profile for foundry prior to deployment:

   ````
   export FOUNDRY_PROFILE=local
   ````

8. Take note of the output and locate the following addresses(from terminal output or broadcast/DeployAllModulesPt1.s.sol/<YOUR_CHAIN_ID>/run-latest.json). Example:
   ```
   "hash": "0x1902f5f3c6f2ed24ae3a64c8ddb41e72fb71b57c3404278c965dee920aa6f40f",
   "transactionType": "CREATE",
   "contractName": "RuleProcessorDiamond",
   "contractAddress": "0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8"
   ```
9. Note the address for the following contract deployments
   1. RuleProcessorDiamond
   2. Export it to zsh
        ````
        export RULE_PROCESSOR_DIAMOND=0x1613beB3B2C4f22Ee086B2b38C1476A3cE7f78E8(substitute with your deployed RuleProcessorDiamond contract address)
        ````
10. Set the version of the protocol:
   ```
   cast send $RULE_PROCESSOR_DIAMOND "updateVersion(string)()" <PROTOCOL_VERSION> --private-key $DEPLOYMENT_OWNER_KEY --rpc-url ETH_RPC_URL
   ```
   *substitute <PROTOCOL_VERSION> with the proper value. i.e: "1.1.0".*

11. (Optional) If a multi-sig wallet is to hold the protocol's ownership, then:
      1. Export the multi-sig address to zsh:
         ```
         export MULTISIG_WALLET=<MULTI-SIG_ADDRESS>
         ```   
      2. Transfer the ownership to multi-sig wallet.
         ```
         cast send $RULE_PROCESSOR_DIAMOND "transferOwnership(address)" $MULTISIG_ADDRESS --private-key $DEPLOYMENT_OWNER_KEY --rpc-url ETH_RPC_URL
         ```
      3. Check that the owner is the multi-sig wallet:
         ```
         cast call $RULE_PROCESSOR_DIAMOND "owner()(address)" --rpc-url ETH_RPC_URL
         ```
         If the response is the same address as MULTISIG_WALLET, the ownership transfer was successful. If not, repeat the process.


<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron
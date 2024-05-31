# Protocol Deployment
[![Project Version][version-image]][version-url]

---
Due to the architecture of the Protocol, several contracts are required to be deployed to utilize the protocol. Once these are deployed, 
several application ecosystems may utilize these contracts independently without affecting each other. The following diagram
is an overview of this deployment process:


![Protocol deployment sequence diagram](../images/ProtocolDeployment.png)

1. Open a new terminal
2. [Set environmental variables](../deployment/SET-ENVIRONMENT.md) and source the .env file (`source .env`) and then feel free 
3. In the same terminal as above, ensure that the Foundry installation is current (see troubleshooting section)
   ````
   foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
   ````

4. In the same terminal as above, navigate to the cloned repo directory and run the build script.
   ````
	bash script/deploy/DeployProtocol.sh
   ````

   If this is your first time and you're trying to deploy in a local development environment, you might run into errors with the above approach, it's recommended to set a local profile for foundry prior to deployment:

   ````
   export FOUNDRY_PROFILE=local
   ````

5. The deployment script will add the output RuleProcessorDiamond address to your .env file. Source it for the future interactions with the protocol:
   ````
   source .env
   ````
6. Set the version of the protocol:
   ```
   cast send $RULE_PROCESSOR_DIAMOND "updateVersion(string)()" <PROTOCOL_VERSION> --private-key $DEPLOYMENT_OWNER_KEY --rpc-url ETH_RPC_URL
   ```
   *substitute <PROTOCOL_VERSION> with the proper value. i.e: "1.1.0".*

7. (Optional) If a multi-sig wallet is to hold the protocol's ownership, then:
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
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

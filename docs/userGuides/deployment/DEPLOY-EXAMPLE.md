# Protocol Deployment
[![Project Version][version-image]][version-url]

---
In order to deploy an example application with tokens, the protocol must've have already been deployed on the target chain. If it has not previously been deploy, see [Deploy Protocol](./DEPLOY-PROTOCOL.md) for details. Once protocol deployment has completed, perform the following steps:


1. Open a new terminal
2. [Set environmental variables](../deployment/SET-ENVIRONMENT.md) and source the .env file (`source .env`) and then feel free 
3. In the same terminal as above, ensure that the Foundry installation is current (see troubleshooting section)
   ````
   foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
   ````

4. In the same terminal as above, navigate to the cloned repo directory and run the build script.
   ````
	bash script/deploy/DeployExampleApplication.sh
   ````

   If this is your first time and you're trying to deploy in a local development environment, you might run into errors with the above approach, it's recommended to set a local profile for foundry prior to deployment:

   ````
   export FOUNDRY_PROFILE=local
   ````

5. The deployment script will add the contract addresses to your .env file. Source it for the future interactions with the protocol:
   ````
   source .env
   ````
   

<!-- These are the body links -->
[environment-url]: ./SET-ENVIRONMENT.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.2.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

# Tron Deployment Scripts
[![Project Version][version-image]][version-url]

---

### Using the provided deployment scripts: 

The protocol and an example application architecture can be deployed using the deployment scripts in the script directory. Run the following commands from the root of the repo to do the deployment:

```bash
forge script script/DeployAllModulesPt1.s.sol --ffi --broadcast
bash script/ParseProtocolDeploy.sh
forge script script/DeployAllModulesPt2.s.sol --ffi --broadcast
forge script script/DeployAllModulesPt3.s.sol --ffi --broadcast

forge script script/clientScripts/Application_Deploy_01_AppManager.s.sol --ffi --broadcast
bash script/ParseApplicationDeploy.sh 1
forge script script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol --ffi --broadcast 
bash script/ParseApplicationDeploy.sh 2
forge script script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol --ffi --broadcast
bash script/ParseApplicationDeploy.sh 3
forge script script/clientScripts/Application_Deploy_05_Oracle.s.sol --ffi --broadcast 
bash script/ParseApplicationDeploy.sh 4
forge script script/clientScripts/Application_Deploy_06_Pricing.s.sol --ffi --broadcast
bash script/ParseApplicationDeploy.sh 5
```

(add the --rpc-url argument to the end of each of the forge commands to point the scripts to the chain you would like to deploy on)

This process can be automated by running the [DeployExampleApplication.sh](../.././script/deploy/DeployExampleApplication.sh) script.

### Contracts Deployed

The following is the list of contracts deployed by each of the above sripts:

Application_Deploy_01_AppManager.s.sol:
- ApplicationAppManager (AppManager example)
- ApplicationHandler (ProtocolApplicationHandler example)

Application_Deploy_02_ApplicationFT1.s.sol:
- ApplicationERC20 (ProtocolERC20 example)
- HandlerDiamond 

Application_Deploy_04_ApplicationNFT.s.sol:
- ApplicationERC721AdminOrOwnerMint (ProtocolERC721 example)
- HandlerDiamond

Application_Deploy_05_Oracle.s.sol 
- OracleApproved
- OracleDenied 

Application_Deploy_06_Pricing.s.sol
- ApplicationERC20Pricing (ProtocolERC20Pricing example)
- ApplicationERC721Pricing (ProtocolERC721Pricing example)
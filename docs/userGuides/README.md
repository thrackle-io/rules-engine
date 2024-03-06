# User Guide

[![Project Version][version-image]][version-url]

# *** UNDER CONSTRUCTION ***

Relevant Documentation:
- [Deployment Guides][deploymentGuide-url]
- [Rule Guide][ruleGuide-url]
- [Glossary][glossary-url]
- [Architecture Overview][archOverview-url]

## API 
API documentation can be found [here](src/src/README.md).

## Tooling
##### This is designed to be tested and deployed with Foundry. All that should be required is to install python, then install [foundry](https://book.getfoundry.sh/getting-started/installation), pull the code, and then run:

`forge build` in the project directory to install the submodules.

`pip install eth-abi`

Note: Due to an issue with the latest version of foundry at the time of writing, we are currently using a specific foundry version. To guarantee expected behavior please run the following command:
```bash
foundryup --version nightly-09fe3e041369a816365a020f715ad6f94dbce9f2
```

In order to facilitate testing and deployment, the following resources were created:

---
## Test Scripts

All tests are located inside the `test/` directory. To run a test, simply run in your terminal from inside the `Tron` directory:

```
forge test --ffi --match-path <TEST_FILE_LOCATION> -vvvv
```
---
## Deployment Scripts

---
## Deployment Test Scripts

Deployments may be tested using the provided bash scripts. These scripts will test proper deployment and configurations of:
- Protocol
   - `deployProtocolTest.sh`
- AppManager
   - `deployAppManagerTest.sh`
- Protocol Supported ERC20
   - `deployAppERC20Test.sh`
- Protocol Supported ERC721
   - `deployAppERC721Test.sh`

All the deployment scripts can be found in the root directory and all use '.env.deployTest' for environment specific variables but they can be left blank. If left blank, the scripts will prompt for entry of the necessary variables. 

To run, open a terminal in the root directory and run the following command:
```
    bash deployProtocolTest.sh
```

Repeat the process for each desired test. If a configuration error is encountered, it should notify and give instructions to fix.

---

### Local Deployments

For local deployments, use Anvil's local blockchain in combination with the deployment scripts. To run anvil simply do ` anvil` in a dedicated terminal window. then, in a separate terminal:

```
forge script <SCRIPT_FILE_LOCATION> --ffi --rpc-url <ETH_RPC_URL>  --broadcast --verify -vvvv
```

##### Note: an ETH_RPC_URL can be found in the .env file.

### Testnet Deployment

coming soon...

### Mainnet Deployment

coming soon...

### Deploy The Ecosystem

#### Deploy The Protocol

`scripts/deploy/DeployProtocol.sh`
This script is responsible for deploying all the protocol contracts. Take into account that no application-specific contracts are deployed here.

#### Deploy Some Test Game Tokens

`script/clientScripts/Application_Deploy_01_AppManager.s.sol`
`script/clientScripts/Application_Deploy_02_ApplicationFT1.s.sol`
`script/clientScripts/Application_Deploy_03_ApplicationFT2.s.sol`
`script/clientScripts/Application_Deploy_04_ApplicationNFT.s.sol`
`script/clientScripts/Application_Deploy_05_Oracle.s.sol`
`script/clientScripts/Application_Deploy_06_Pricing.s.sol`
These scripts deploy the contracts that are specific for games, emulating the steps that a application dev would follow. They will deploy 2 ERC20s and 2 ERC721 tokens, among the other setup contracts.

If anvil is not listening to the commands in the scripts, make sure you have exported the local foundry profile `export FOUNDRY_PROFILE=local`.

### Other Relevant Scripts

Besides the deployment of the whole ecosystem, you can also deploy specific parts of the protocol/games through different scripts. When it comes to the protocol scripts, the files can be found in the `script/` directory. On the other hand, `src/example/script/` will hold the files that are related to specific implementations like tokens, AppManager, AppHandler, etc.

---
## Command Tools

`.env`
This contains the basic variables needed for the deploy scripts to work properly. These are the default values for anvil so it is ok for them to be exposed. They are as follows:

```ADDRESS_01=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
PRIVATE_KEY_01=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RULE_STORAGE_DIAMOND=0x8A791620dd6260079BF849Dc5567aDC3F2FdC318
RULE_PROCESSOR_DIAMOND=0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f
ACTION_P2P_TRANSFER=0
ACTION_BUY=1
ACTION_SELL=2
ACTION_MINT=3
ACTION_BURN=4
...
```

---
## Prettier Formatter

The [solidity prettier formatter](https://github.com/prettier-solidity/prettier-plugin-solidity) is utilized within this repository.
Installation:

> npm install

Formatting at the commandline:

> npx prettier --write .

<!-- These are the body links -->
[deploymentGuide-url]: ./deployment/NFT-DEPLOYMENT.md
[archOverview-url]: ./ARCHITECTURE-OVERVIEW.md
[ruleGuide-url]: ./rules/RULE-GUIDE.md
[glossary-url]: ./GLOSSARY.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-protocol

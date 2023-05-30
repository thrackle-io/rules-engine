# Developer Guide

[![Project Version][version-image]][version-url]

# *** UNDER CONSTRUCTION ***

# API 
API documentation can be found [here](../src/src/README.md).

# Tooling
##### This is designed to be tested and deployed with Foundry. All that should be required is to install python, then install [foundry](https://book.getfoundry.sh/getting-started/installation), pull the code, and then run:

`forge build` in the project directory to install the submodules.

`pip install eth-abi`

In order to facilitate testing and deployment, the following resources were created:

---
## Test Scripts

All tests are located inside the `test/` directory. To run a test, simply run in your terminal from inside the repository directory:

```
forge test --ffi --match-path <TEST_FILE_LOCATION> -vvvv
```
---
## Deployment Scripts

### Local Test Deployment

For local deployment tests, use Anvil's local blockchain in combination with the deployment scripts. To run anvil simply do ` anvil` in a dedicated terminal window. then, in a separate terminal:

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

`scripts/DeployAllModules.s.sol`
This script is responsible for deploying the whole protocol contracts. Take into account that no game-specific contracts are deployed here.

#### Deploy Some Test Game Tokens

`src/example/script/ApplicationDeployAll.s.sol`
This script deploys the contracts that are specific for games, emulating the steps that a application dev would follow. This script deploys 2 ERC20s and 2 ERC721 tokens, among the other setup contracts.

If anvil is not listening to the commands in the scripts, make sure you have exported the local foundry profile `export FOUNDRY_PROFILE=local`.

### Other Relevant Scripts

Besides the deployment of the whole ecosystem, you can also deploy specific parts of the protocol/games through different scripts. When it comes to the protocol scripts, the files can be found in the `script/` directory. On the other hand, `src/example/script/` will hold the files that are related to specific implementations like tokens, AppManager, AppHandler, etc.

---
## Command Tools

`Makefile`
This file contains various commands that can be used to ease build, testing, and deployment. Its intended use is only for testnet testing, but especially the local foundry chain(Anvil). If using all the default foundry stuff, "make deployAll" can be used **as long as the anvil server was started in default state and no addresses have been created yet.** It always uses the same ones so you can easily deploy and test whenever needed.

- make build
    - cleans and builds all contracts with optimization
- make testAll
    - runs all test scripts with the correct parameters. NOTE: it is verbose. To run without all the extra info, remove -vvvvv or reduce number of "v"s to your like, ie -vv
- make deployAll
    - deploys the entire protocol project to localhost:8545
- make deployAllApp
    - deploys the application examples to localhost:8545

`.env`
This contains the basic variables needed for Makefile to work properly. These are the default values for anvil so it is ok for them to be exposed. They are as follows:

```ADDRESS_01=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
PRIVATE_KEY_01=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RULE_STORAGE_DIAMOND=0x8A791620dd6260079BF849Dc5567aDC3F2FdC318
RULE_PROCESSOR_DIAMOND=0xa85233C63b9Ee964Add6F2cffe00Fd84eb32338f
ACTION_PURCHASE=0
ACTION_SELL=1
ACTION_TRADE=2
ACTION_INQUIRE=3
...
```

`command_test.txt`
has some list of commands that are intended to be used with Anvil after using the `make deployAll` command which will execute the `script/ApplicationDeployAll.s.sol` file. These commands are meant to save time when testing live in the Anvil local blockchain. It has tests for positivie and negative cases (where reverts are expected). The above command can be combined with`make gameDeployAll` comand which will execute the `src/example/script/ApplicationDeployAll.s.sol` and deploy a couple ERC20 tokens and a couple NFT contracts with their respective protocol-integration contracts.Take into account that a whole new Anvil blockchain should be deployed between tests since the state of the blockchain changes with every transaction in a test, making other tests fail because the initial conditions are different to the ones expected.

---
## Prettier Formatter

The [solidity prettier formatter](https://github.com/prettier-solidity/prettier-plugin-solidity) is utilized within this repository.
Installation:

> npm install

Formatting at the commandline:

> npx prettier --write .

<!-- These are the body links -->


<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.0.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/Tron

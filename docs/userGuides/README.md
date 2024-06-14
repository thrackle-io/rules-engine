# User Guide

[![Project Version][version-image]][version-url]

## Introduction

This guide is intended to be a user-friendly introduction to the rules protocol. It will provide a walkthrough of how to get started with the protocol, as well as provide a reference for the available rules and how to create custom rules.

## Installation and Tooling
##### This is designed to be tested and deployed with Foundry. All that should be required is to install Python 3.11, Homebrew, and then install [foundry](https://book.getfoundry.sh/getting-started/installation), pull the code, and then run in the root of the project's directory:

`foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)` 

_Note: `awk` in the above command is used to ignore comments in `foundry.lock`_

`pip3 install -r requirements.txt`

` brew install jq`

Now that you have the dependencies installed, you are ready to build the project. Do:

`forge build` in the project directory to install the submodules and create the artifacts.

And you are done!


## Index

| Document | Description |
|----------|-------------|
|[Access Level Guide][accessLevel-url]| This section contains documents on access levels, a feature that allows you to enable and block access according to broadly defined conditions, useful for application onboarding and compliance processes.|
|[Admin Roles][adminRoles-url]| This section contains documentation on what admin roles are available and gives you the information you need on to configure how your application will be governed and administered.|
|[Application Handler Guide][handlerGuide-url] | This teaches you about the application handler and how it works within the context of the main protocol. This is critical to understand if you're going to go about creating your own custom rules.|
|[Architecture Overview][archOverview-url]| For pretty diagrams that show the process of the protocol and the overall architecture, look here.|
|[Deployment Guides][deploymentGuide-url] | This section contains documents on how to deploy the protocol, pricing modules, and create application rules in order to quickly get started.|
|[Fees][fees-url]| This section shows you how to write how fees can be generated in your application and how fees are generated at the protocol level.|
|[Fungible Token Handlers Guide][fungibleTokenHandlerGuide-url] | This teaches you about the fungible token handler and how it works within the context of the main protocol. If you wanted to make rules surrounding ERC20s, you'll want to take a look at this quickly just to understand how it all works together.|
|[Glossary][glossary-url]| For any terminology that might be unclear, please check here.|
|[Integration of Oracles][oracles-url]| This section contains documentation on how oracles integrate into the rules protocol and the process of integrating them.|
|[NonFungible Token Handlers Guide][nonfungibleTokenHandlerGuide-url] | This teaches you about the non fungible token handler and how it works within the context of the main protocol. If you wanted to make rules surrounding NFTs, you'll want to take a look at this quickly just to understand how it all works together.|
|[Pricing Contracts][pricing-url]| This section contains documentation on how to create and deploy pricing contracts so that your assets can be properly valuated in order to adhere to desirable rules.|
|[Risk Score][riskScore-url]| This section contains documentation on how to integrate rules that involve using risk score methodology and the integration process of them.|
|[Rule Guide][ruleGuide-url] | This section can be thought of as a reference to the available rules that come pre packaged within the protocol and their various perks and quirks. It will also contain guides on how to create custom rules.|
|[Tag Guide][tag-url]| This section contains documents on how to create and use tags within the rules protocol. Tags are a useful mechanism to allow application administrators to divide users into segments so a particular rule only applies to specific segments of users. The applicability will vary depending on the rule so see the documentation for each rule to understand how and when tags will apply.|

## API 
API documentation for the smart contract suite can be found [here](../src/src/README.md).

---

## Deployment Scripts

### Demo Application

A script is provided to allow easy deployment of the protocol as well as additional sample assets. More information can be [here](./deployment/DEPLOY-DEMO.md)

---

### Development and Production Deployments(Protocol and/or Examples)

A [Deployment Guide][deploymentGuide-url] is provided and contains step by step directions to deploy the protocol, pricing modules, and create application rules in order to quickly get started. To quickly set up The Protocol and an example application, follow these guides:

#### Deploy The Protocol 

[Deploying The Protocol](./deployment/DEPLOY-PROTOCOL.md)

#### Deploy Some Example Application Tokens

[Deploying The Example Application](./deployment/DEPLOY-EXAMPLE.md)

---

## Test Scripts

All tests are located inside the `test/` directory. To run a test, simply run in your terminal from inside the `Tron` directory:

```
forge test --ffi --match-path <TEST_FILE_LOCATION> -vvvv
```

To run all the test:

```
forge test --ffi
```
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

All the deployment scripts can be found in the root directory and all use '.env' for environment specific variables but they can be left blank. If left blank, the scripts will prompt for entry of the necessary variables. 

To run, open a terminal in the root directory and run the following command:
```
    bash deployProtocolTest.sh
```

Repeat the process for each desired test. If a configuration error is encountered, it should notify and give instructions to fix.

---

### Other Relevant Scripts

Besides the deployment of the whole ecosystem, you can also deploy specific parts of the protocol/applications through different scripts. When it comes to the protocol scripts, the files can be found in the `script/` directory. On the other hand, `src/example/script/` will hold the files that are related to specific implementations like tokens, AppManager, AppHandler, etc.

---
## Command Tools

`.env`
This contains the basic variables needed for the deploy scripts to work properly. These are the default values for anvil so it is ok for them to be exposed. They are as follows:

```ANVIL_ADDRESS_01=0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
ANVIL_PRIVATE_KEY_01=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
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
## Monitoring

Once you have deployed your smart contracts, you can monitor them using [Openzeppelin Defender](https://docs.openzeppelin.com/defender/v2/module/monitor). It helps you to keep an eye on your smart contracts and detect potential security vulnerabilities. There are some key events that we recommend you observing if you intend to create a monitoring setup for your project:


| Event | Contract Name | Description |
|-------|---------------|-------------|
| AD1467_HandlerConnected | "ApplicationAppManager/ProtocolERC20{U}/ProtocolERC721{U}"  | Emits whenever a handler is connected, whether that be an application handler or a token handler |
| AD1467_AppManagerDeployed | ApplicationAppManager | Emits whenever a new application manager is deployed |
| AD1467_AppManagerDeployedForUpgrade |	ApplicationAppManager | Emits whenever a new application manager is deployed as an upgrade to a previous application manager |
| AD1467_ApplicationHandlerDeployed	| ApplicationHandler | Emits whenever a new application handler is deployed |
| AD1467_ERC721PricingAddressSet	| ApplicationHandler | Emits whenever an ERC721 pricer is set |
| AD1467_ERC20PricingAddressSet	| ApplicationHandler | Emits whenever an ERC20 pricer is set |
| AD1467_HandlerDeployed |	"APPLICATION_ERC20_HANDLER/APPLICATION_ERC721_HANDLER" | Emits whenever a new application handler is deployed |
| AD1467_NFTValuationLimitUpdated |	APPLICATION_ERC721_HANDLER | Emits whenever the NFT valuation limit is updated |

---

## Prettier Formatter

The [solidity prettier formatter](https://github.com/prettier-solidity/prettier-plugin-solidity) is utilized within this repository.

Installation:

> npm install

Formatting at the commandline:

> npx prettier --write .

<!-- These are the body links -->
[deploymentGuide-url]: ./deployment/README.md
[archOverview-url]: ../OVERVIEW.md#Architecture-Overview
[ruleGuide-url]: ./rules/README.md
[tag-url]: ./tags/README.md
[accessLevel-url]: ./accessLevels/README.md
[adminRoles-url]: ./permissions/ADMIN-ROLES.md
[oracles-url]: ./oracles/README.md
[pricing-url]: ./pricing/README.md
[fees-url]: ./fees/README.md
[riskScore-url]: ./riskScore/README.md
[glossary-url]: ./GLOSSARY.md
[handlerGuide-url]: ./architecture/client/application/APPLICATION-HANDLER.md
[fungibleTokenHandlerGuide-url]: ./architecture/client/assetHandler/PROTOCOL-FUNGIBLE-TOKEN-HANDLER.md
[nonfungibleTokenHandlerGuide-url]: ./architecture/client/assetHandler/PROTOCOL-NONFUNGIBLE-TOKEN-HANDLER.md

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-protocol

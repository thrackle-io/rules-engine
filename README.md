# Rules Engine

[![Project Version][version-image]][version-url]

This repository contains an EVM-based protocol designed to meet the unique needs of tokenized assets and on-chain economies. The protocol enables the creation and management of economic and compliance controls for your on-chain economy at the token level, allowing for maximum flexibility while maintaining the transparency and trustlessness of Web3.

[version-image]: https://img.shields.io/badge/Version-2.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine

## Installation

To install the package, run the following command in the root of your project:

```c
npm i @thrackle-io/rules-protocol-client
```

### Dependencies

This package requires the following:

1.  Foundry

    NOTE: In order to ensure full support, run this command to get the correct Foundry version:

```c
foundryup --commit $(awk '$1~/^[^#]/' foundry.lock)
```
 
2.  Scripting Requirements
    1.  `eth-abi 4.2.1`
    2.  `jq 1.6.0`
    3.  `python-dotenv 1.0.1`

    These packages can be installed manually or through the following helper command:
```c
pip3 install -r requirements.txt
```

1. `@openzeppelin/contracts` version 4.9.6 and `@openzeppelin/contracts-upgradeable` version 4.9.6.

    If the contracts show any compiling errors, try to manually update the version of the existing openzeppelin library in your project by doing:

```c
forge install OpenZeppelin/openzeppelin-contracts
```

```c
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

## Usage

### User Guides

For complete usage information and documentation, please visit our [User Guide][userGuide-url].

### Example Application

To deploy the Rules Engine and an example application, perform the following steps: 
1. Deploy the [Rules Engine](docs/userGuides/deployment/DEPLOY-PROTOCOL.md) locally.
2. Deploy the [Example Application](docs/userGuides/deployment/DEPLOY-EXAMPLE.md) locally.

## Contributing

Please visit our [Contributor Guide][contributorGuide-url].

## Licensing

The primary license for Forte Protocol Rules Engine is the Business Source License 1.1 (`BUSL-1.1`), see [`LICENSE`](./LICENSE). However, some files are dual licensed under `GPL-2.0-or-later`:

- All files in `src/example/` may also be licensed under `GPL-2.0-or-later` (as indicated in their SPDX headers), see [`src/example/LICENSE`](./src/example/LICENSE)

### Other Exceptions

- All files in `lib/` are licensed under `MIT` (as indicated in its SPDX header), see [`lib/LICENSE_MIT`](lib/LICENSE_MIT)
- All files in `src/example/` may also be licensed under `GPL-2.0-or-later` (as indicated in their SPDX headers), see [src/example/LICENSE](src/example/LICENSE)
Other Exceptions
- All files in `contracts/test` remain unlicensed (as indicated in their SPDX headers).

<!-- These are the body links -->

[contributorGuide-url]: ./docs/contributorGuides/README.md
[userGuide-url]: ./docs/userGuides/README.md
[deploymentGuide-url]: ./docs/userGuides/deployment/NFT-DEPLOYMENT.md
[archOverview-url]: ./docs/userGuides/ARCHITECTURE-OVERVIEW.md
[ruleGuide-url]: ./docs/userGuides/rules/RULE-GUIDE.md
[glossary-url]: ./docs/userGuides/GLOSSARY.md

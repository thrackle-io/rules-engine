# Forte Rules Engine v1
> [!WARNING]
> THIS REPOSITORY IS DEPRECATED IN FAVOR OF [forte-rules-engine](https://github.com/Forte-Service-Company-Ltd/forte-rules-engine)

[![Project Version][version-image]][version-url]

Check out [our docs](https://docs.forterulesengine.io) for in-depth guides and reference information.

This repository contains an EVM-based protocol designed to meet the unique needs of tokenized assets and on-chain economies. The protocol enables the creation and management of economic and compliance controls for your on-chain economy at the token level, allowing for maximum flexibility while maintaining the transparency and trustlessness of Web3.

[version-image]: https://img.shields.io/badge/Version-2.4.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/forte-rules-engine-v1/tags

## Installation

To install the package, run the following command in the root of your project:

```bash
npm i @thrackle-io/forte-rules-engine-v1
```

### Dependencies

> numbered releases assigned to unmodified upstream binaries.

This package requires the following:

1.  [Foundry v1.2.1](https://github.com/foundry-rs/foundry?tab=readme-ov-file#installation)
 
2.  Scripting Requirements
    1.  `eth-abi 5.1.0`
    2.  `jq 1.8.0`
    3.  `python-dotenv 1.0.1`

    These packages can be installed manually or through the following helper command:

```bash
pip3 install -r requirements.txt
```

1. `@openzeppelin/contracts` version 4.9.6 and `@openzeppelin/contracts-upgradeable` version 4.9.6.

    If the contracts show any compiling errors, try to manually update the version of the existing openzeppelin library in your project by doing:

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

```bash
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

## Contributing

Please visit our [Contributor Guide](./CONTRIBUTING.md).

## Forte x Thrackle

Forte’s work is aided and supported by our ecosystem partner, Thrackle, a team of industry experts, including PhD-level engineers specializing in computer science, math, engineering, economics, and finance. Thrackle leverages its deep technical expertise to develop purpose-built, customizable products that enable the creation, growth, and stability of thriving digital asset economies. Together, Forte and Thrackle are driving innovation to build healthy, sustainable blockchain economies.

## Licensing

The primary license for Forte Protocol Rules Engine is the Business Source License 1.1 (`BUSL-1.1`), see [`LICENSE`](./LICENSE). However, some files are dual licensed under `GPL-2.0-or-later`:

- All files in `src/example/` may also be licensed under `GPL-2.0-or-later` (as indicated in their SPDX headers), see [`src/example/LICENSE`](./src/example/LICENSE)

### Other Exceptions

- All files in `lib/` are licensed under `MIT` (as indicated in its SPDX header), see [`lib/LICENSE_MIT`](lib/LICENSE_MIT)
- All files in `src/example/` may also be licensed under `GPL-2.0-or-later` (as indicated in their SPDX headers), see [src/example/LICENSE](src/example/LICENSE)
Other Exceptions
- All files in `contracts/test` remain unlicensed (as indicated in their SPDX headers).

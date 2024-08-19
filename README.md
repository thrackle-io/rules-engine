# Rules Protocol

[![Project Version][version-image]][version-url]

This repository contains an EVM-based protocol designed to meet the unique needs of tokenized assets and on-chain economies. The protocol enables the creation and management of economic and compliance controls for your on-chain economy at the token level, allowing for maximum flexibility while maintaining the transparency and trustlessness of Web3.

[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/rules-engine

## Installation

To install the package, run the following command in the root of your project:

```c
npm i @thrackle-io/rules-protocol-client
```

### Dependencies

This package requires `@openzeppelin/contracts` version 4.9.6 and `@openzeppelin/contracts-upgradeable` version 4.9.6.

If the contracts show any compiling errors, try to manually update the version of the existing openzeppelin library in your project by doing:

```c
forge install OpenZeppelin/openzeppelin-contracts
```

and

```c
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

## Usage

### User Guides

For complete usage information and documentation, please visit our [User Guide][userGuide-url].

### A Simple Example

To use the package simply import the files you are interested in. Here is an example on how to create a Rules-Protocol compatible ERC20:

```c
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@thrackle-io/rules-protocol-client/src/client/token/ERC20/ProtocolERC20.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett @mpetersoCode55
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _appManagerAddress _handlerAddress are set in constructor
 */
contract ApplicationERC20 is ProtocolERC20 {
    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol  Symbol of the token
     * @param _appManagerAddress App Manager address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _appManagerAddress
    ) ProtocolERC20(_name, _symbol, _appManagerAddress) {}

}
```

As you can see, everything is already encapsulated inside the:

```c
import "@thrackle-io/rules-protocol-client/src/client/token/ERC20/ProtocolERC20.sol";
```

All you need to do is to inherit the right contract and implement any necessary function. In this case, the `mint` function.

## Contributing

Please visit our [Contributor Guide][contributorGuide-url].

## Licensing

TBD

<!-- These are the body links -->

[contributorGuide-url]: ./docs/contributorGuides/README.md
[userGuide-url]: ./docs/userGuides/README.md
[deploymentGuide-url]: ./docs/userGuides/deployment/NFT-DEPLOYMENT.md
[archOverview-url]: ./docs/userGuides/ARCHITECTURE-OVERVIEW.md
[ruleGuide-url]: ./docs/userGuides/rules/RULE-GUIDE.md
[glossary-url]: ./docs/userGuides/GLOSSARY.md

# Rules Protocol

[![Project Version][version-image]][version-url]

This repository contains an EVM-based protocol designed to meet the unique needs of games with tokenized assets and on-chain economies. The protocol enables the creation and management of economic and compliance controls for your game’s economy at the token level, allowing for maximum flexibility while maintaining the transparency and trustlessness of Web3.

- [Architecture Overview][archOverview-url]
- [Developer Guide][developer-url]
- [Deployment Guide][deploymentGuide-url]
- [Rule Guide][ruleGuide-url]
- [Glossary][glossary-url]

## Licensing

TBD

<!-- These are the body links -->

[developer-url]: ./docs/userGuides/DEVELOPER-GUIDE.md
[deploymentGuide-url]: ./docs/userGuides/deployment/NFT-DEPLOYMENT.md
[archOverview-url]: ./docs/userGuides/ARCHITECTURE-OVERVIEW.md
[ruleGuide-url]: ./docs/userGuides/rules/RULE-GUIDE.md
[glossary-url]: ./docs/userGuides/GLOSSARY.md

<!-- These are the header links -->

[version-image]: https://img.shields.io/badge/Version-1.1.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/tron

# @thrackle-io/rules-protocol-client

## Description

This package contains everything necessary for developers to launch their own application which will be compatible with the Rules Protocol.

## Installation

To install the package simply go to the root of your project in the terminal, and do:

```c
npm i @thrackle-io/rules-protocol-client
```

That's it!

## Dependencies

This package requires `@openzeppelin/contracts` version 4.9 and `@openzeppelin/contracts-upgradeable` version 4.9.

If the contracts show any compiling errors, try to manually update the version of the existing openzeppelin library in your project by doing:

```c
npm i @openzeppelin/contracts@=4.9
```

and

```c
npm i @openzeppelin/contracts-upgradeable@=4.9
```

## Usage

To use the package simply import the files you are interested in. Here is an example on how to create a Rules-Protocol compatible ERC20:

```c
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@thrackle-io/rules-protocol-client/token/ERC20/ProtocolERC20.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
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
import "@thrackle-io/rules-protocol-client/token/ERC20/ProtocolERC20.sol";
```

All you need to do is to inherit the right contract and implement any necessary function. In this case, the `mint` function.

## Docs

Please visit the official [GitHub repository](https://github.com/thrackle-io/rules-protocol) for more information.


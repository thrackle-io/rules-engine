# Rules Protocol

[![Project Version][version-image]][version-url]

This repository contains an EVM-based protocol designed to meet the unique needs of tokenized assets and on-chain economies. The protocol enables the creation and management of economic and compliance controls for your on-chain economy at the token level, allowing for maximum flexibility while maintaining the transparency and trustlessness of Web3.

[version-image]: https://img.shields.io/badge/Version-1.3.0-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/tron

## Installation

To install the package, run the following command in the root of your project:

```c
npm i @thrackle-io/rules-protocol-client
```

### Dependencies

This package requires `@openzeppelin/contracts` version 4.9.6 and `@openzeppelin/contracts-upgradeable` version 4.9.6.

*For this example, ApplicationERC20 uses OpenZeppelin's AccessControl contract to restrict certain functions*

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

import "@thrackle-io/rules-protocol-client/src/example/ERC20/ApplicationERC20.sol";

/**
 * @title Example ERC20 ApplicationERC20
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett, @mpetersoCode55, @Palmerg4
 * @notice This is an example implementation that App Devs should use.
 * @dev During deployment _tokenName _tokenSymbol _tokenAdmin are set in constructor
 */
contract ExampleApplicationERC20 is ApplicationERC20 {
    /**
     * @dev Constructor sets params
     * @param _name Name of the token
     * @param _symbol  Symbol of the token
     * @param _tokenAdmin App Manager address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _tokenAdmin
    ) ApplicationERC20(_name, _symbol, _tokenAdmin) {}

}
```

As you can see, the ApplicationERC20 inherits the IProtocolToken interface which includes two functions:

```c
function getHandlerAddress() external view returns (address);

function connectHandlerToToken(address _deployedHandlerAddress) external;
```

ApplicationERC20 also includes the rule processor module check:

```c
function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        /// Rule Processor Module Check
        require(IProtocolTokenHandler(handlerAddress).checkAllRules(balanceOf(from), balanceOf(to), from, to, _msgSender(), amount));
        super._beforeTokenTransfer(from, to, amount);
    }
```

As well as implementation of the IProtocolToken interface functions:

```c
function getHandlerAddress() external view override returns (address) {
        return handlerAddress;
    }

function connectHandlerToToken(address _deployedHandlerAddress) external override onlyRole(TOKEN_ADMIN_ROLE) {
    if (_deployedHandlerAddress == address(0)) revert ZeroAddress();
    handlerAddress = _deployedHandlerAddress;
    handler = IProtocolTokenHandler(handlerAddress);
    emit HandlerConnected(_deployedHandlerAddress, address(this));
}
```

All you need to do is to inherit the right contract and implement any necessary functions.

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

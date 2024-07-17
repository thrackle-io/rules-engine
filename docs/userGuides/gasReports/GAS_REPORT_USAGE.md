# Individual Rule Gas Comparison ERC721 and ERC20
[![Project Version][version-image]][version-url]

---

## Purpose

The gas report is used to determine how individual active rules affect gas consumption of basic token actions.

## Overview

The gas report is the output of running the GasReport test file. Run this command to see the gas report output to the console. The output will include baseline gas used by each action. Each test has a tag associated with the action being run for easier readability during console output.

```c
forge test -vvv --ffi --match-path test/util/gasReport/GasReport.t.sol
```

## GasHelpers contract

GasHelpers.sol includes a couple helper functions to specify what should be included in the gas report.

### startMeasuringGas

This function is run after the rule setup and before the transactions desired for the gas report. Currently, only the basic actions like burn, transfer, and mint are desired and included in the gas report test file. But an arbitrary amount of actions can be done after gas measuring starts.

```c
function startMeasuringGas(string memory label) internal virtual 
```

### stopMeasuringGas

This function is run after the desired actions are run. Any actions after this function is run will not be included in the gas report console output.

```c
function stopMeasuringGas() internal virtual returns(uint256)
```

## Adding new rules/actions

To add new rules or reports, simply add a function to apply the desired rule or change. Once the helper is created, create a new test function with the rule helper being the first action run. Next, add the action which is desired using the functions included.

#### Example

This helper function applies the Token Max Buy Sell Volume rule. When including this function in a new test, it should be run before gas measuring starts.

```c
function _applyTokenMaxBuySellVolumeSetUp(address _handler) public {
        ActionTypes[] memory actionTypes = createActionTypeArray(ActionTypes.BUY, ActionTypes.SELL);
        uint32 ruleId = createTokenMaxBuySellVolumeRule(5000, 24, 100_000_000, Blocktime);
        setTokenMaxBuySellVolumeRule(address(_handler), actionTypes, ruleId);
    }

```

Gas measuring helpers for individual actions are included for both ERC721 and ERC20. For this example, I want to test how the rule affects the gas used for an ERC721 burn action.

This is the helper to start measuring gas consumption, burn an NFT, and stop measuring gas consumption. Once finished, it will output the label and gas used by the burn action.
```c
function _erc721BurnGasReport(string memory _label) public {
        switchToAppAdministrator();
        applicationNFT.safeMint(appAdministrator);

        startMeasuringGas(_label);
        applicationNFT.burn(0);
        gasUsed = stopMeasuringGas();
        console.log(_label, gasUsed);
    }
```

For this example, this is the full test function.

```c
function testERC721_TokenMaxBuySellVolume_Burn() public endWithStopPrank {
        _applyTokenMaxBuySellVolumeSetUp(address(applicationNFTHandler));
        _erc721BurnGasReport("ERC721_TokenMaxBuySellVolume_Burn");         
    }
```

The output to the console will look like this when running this individual test.

```
ERC721_TokenMaxBuySellVolume_Burn 90136
```

<!-- These are the header links -->
[version-image]: https://img.shields.io/badge/Version-1.3.1-brightgreen?style=for-the-badge&logo=appveyor
[version-url]: https://github.com/thrackle-io/aquifi-rules-v1
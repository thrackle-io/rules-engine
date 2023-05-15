// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {AppManager} from "src/application/AppManager.sol";
import {ERC173Facet} from "src/diamond/implementations/ERC173/ERC173Facet.sol";
import {ERC173Lib} from "src/diamond/implementations/ERC173/ERC173Lib.sol";
import {ApplicationRuleProcessorDiamondLib as DiamondLib, DiamondStorage, ApplicationRuleDataStorage, FacetCut} from "./ApplicationRuleProcessorDiamondLib.sol";

// When no function exists for function called
error FunctionNotFound(bytes4 _functionSelector);

// This is used in diamond constructor
// more arguments are added to this struct
// this avoids stack too deep errors
struct DiamondArgs {
    address init;
    bytes initCalldata;
}

/**
 * @title Application Rule Processor Diamond Contract
 * @notice This contract is the entry point for access action checks
 * @dev This pattern was adopted from: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen).
 * @author @ShaneDuncan602, @oscarsernarosero, @TJ-Everett
 */
contract ApplicationRuleProcessorDiamond is ERC173Facet {
    /**
     * @dev Use the facets and arguments to create a new ApplicationHandlerDiamond
     * @param diamondCut facet cuts to send through to the diamond cutter
     * @param args arguments for diamond cutter
     */
    constructor(FacetCut[] memory diamondCut, DiamondArgs memory args) payable {
        DiamondLib.diamondCut(diamondCut, args.init, args.initCalldata);
    }

    /**
     * @dev Function sets the Rule Data Diamond Address
     * @param diamondAddress Address of the Rule Data Diamond
     */
    function setRuleDataDiamond(address diamondAddress) external {
        ApplicationRuleDataStorage storage data = DiamondLib.applicationStorage();
        data.ruleDiamondAddress = diamondAddress;
    }

    /**
     * @dev Function retrieves Rule Data Diamond
     * @return taggedRules Address of the Rule Data Diamond
     */
    function getRuleDataDiamondAddress() external view returns (address) {
        ApplicationRuleDataStorage storage data = DiamondLib.applicationStorage();
        return data.ruleDiamondAddress;
    }

    /**
     * @dev Find the facet for the function called and execute it if found, then return any value.
     */
    fallback() external payable {
        DiamondStorage storage ds;
        bytes32 position = DiamondLib.DIAMOND_CUT_STORAGE_POSITION;
        // get diamond storage
        assembly {
            ds.slot := position
        }

        /// get facet from function selector
        address facet = ds.facetAddressAndSelectorPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }

        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())

            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)

            // get any return value
            returndatacopy(0, 0, returndatasize())

            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @dev Stubbed receive function.
     */
    receive() external payable {}
}

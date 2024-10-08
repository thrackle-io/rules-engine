// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {IRuleProcessorDiamondEvents} from "src/common/IEvents.sol";
import {RuleProcessorDiamondLib as DiamondLib, RuleProcessorDiamondStorage, RuleDataStorage, FacetCut} from "src/protocol/economic/ruleProcessor/RuleProcessorDiamondLib.sol";
import {ERC173} from "diamond-std/implementations/ERC173/ERC173.sol";


/// When no function exists for function called
error FunctionNotFound(bytes4 _functionSelector);
error FacetHasNoCodeOrHasBeenDestroyed();

/**
 * This is used in diamond constructor
 * more arguments are added to this struct
 * this avoids stack too deep errors
 */
struct RuleProcessorDiamondArgs {
    address init;
    bytes initCalldata;
}

/**
 * @title Rule Processors Diamond Contract
 * @author @ShaneDuncan602 @oscarsernarosero @TJ-Everett
 * @dev Main contract of the diamond pattern. Responsible for checking
 * on rules compliance.
 * @notice Contract checks the rules for success
 */
contract RuleProcessorDiamond is ERC173, IRuleProcessorDiamondEvents {

    /**
     * @dev constructor creates facets for the diamond at deployment
     * @param diamondCut Array of Facets to be created at deployment
     * @param args Arguments for the Facets Position and Addresses
     */
    constructor(FacetCut[] memory diamondCut, RuleProcessorDiamondArgs memory args) payable {
        DiamondLib.diamondCut(diamondCut, args.init, args.initCalldata);
        emit AD1467_RuleProcessorDiamondDeployed();
    }

    /**
     * @dev Function finds facet for function that is called and execute the function if a facet is found and return any value.
     */
    fallback() external payable {
        RuleProcessorDiamondStorage storage ds;
        bytes32 position = DiamondLib.DIAMOND_CUT_STORAGE;
        // get diamond storage
        assembly {
            ds.slot := position
        }

        // get facet from function selector
        address facet = ds.facetAddressAndSelectorPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert FunctionNotFound(msg.sig);
        }

        if (facet.code.length == 0) revert FacetHasNoCodeOrHasBeenDestroyed();

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
     *@dev Function for empty calldata
     */
    receive() external payable {}
}

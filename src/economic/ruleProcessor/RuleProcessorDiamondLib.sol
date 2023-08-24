// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "diamond-std/core/DiamondCut/FacetCut.sol";
import {ActionTypes} from "./ActionEnum.sol";

error NoSelectorsGivenToAdd();
error NotContractOwner(address _user, address _contractOwner);
error NoSelectorsProvidedForFacetForCut(address _facetAddress);
error CannotAddSelectorsToZeroAddress(bytes4[] _selectors);
error NoBytecodeAtAddress(address _contractAddress, string _message);
error IncorrectFacetCutAction(uint8 _action);
error CannotAddFunctionToDiamondThatAlreadyExists(bytes4 _selector);
error CannotReplaceFunctionsFromFacetWithZeroAddress(bytes4[] _selectors);
error CannotReplaceImmutableFunction(bytes4 _selector);
error CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(bytes4 _selector);
error CannotReplaceFunctionThatDoesNotExists(bytes4 _selector);
error RemoveFacetAddressMustBeZeroAddress(address _facetAddress);
error CannotRemoveFunctionThatDoesNotExist(bytes4 _selector);
error CannotRemoveImmutableFunction(bytes4 _selector);
error InitializationFunctionReverted(address initializationContractAddress, bytes data);

struct FacetAddressAndSelectorPosition {
    address facetAddress;
    uint16 selectorPosition;
}

struct RuleProcessorDiamondStorage {
    /// function selector => facet address and selector position in selectors array
    mapping(bytes4 => FacetAddressAndSelectorPosition) facetAddressAndSelectorPosition;
    bytes4[] selectors;
}

struct RuleDataStorage {
    address rules;
}

/**
 * @title Processor Diamond Library Contract
 * @author @oscarsernarosero, built on top of Nick Mudge implementation.
 * @dev Library contract of the diamond pattern. Responsible for checking
 * on rules compliance.
 * @notice Contract serves as library for the Processor Diamond
 */
library RuleProcessorDiamondLib {
    bytes32 constant DIAMOND_CUT_STORAGE = keccak256("diamond-cut.storage");
    bytes32 constant RULE_DATA_POSITION = keccak256("nontagged-ruless.rule-data.storage");

    /**
     * @dev Function for position of rules. Every rule has its own storage.
     * @return ds Data storage for Rule Processor Storage
     */
    function s() internal pure returns (RuleProcessorDiamondStorage storage ds) {
        bytes32 position = DIAMOND_CUT_STORAGE;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev Function to store rules
     * @return ds Data Storage of Rule Data Storage
     */
    function ruleDataStorage() internal pure returns (RuleDataStorage storage ds) {
        bytes32 position = RULE_DATA_POSITION;
        assembly {
            ds.slot := position
        }
    }

    event DiamondCut(FacetCut[] _diamondCut, address init, bytes data);

    /**
     * @dev Internal function version of _diamondCut
     * @param _diamondCut Facets Array
     * @param init Address of the contract or facet to execute "data"
     * @param data A function call, including function selector and arguments
     *             calldata is executed with delegatecall on "init"
     */
    function diamondCut(FacetCut[] memory _diamondCut, address init, bytes memory data) internal {
        for (uint256 facetIndex; facetIndex < _diamondCut.length; ) {
            bytes4[] memory functionSelectors = _diamondCut[facetIndex].functionSelectors;
            address facetAddress = _diamondCut[facetIndex].facetAddress;

            if (functionSelectors.length == 0) {
                revert NoSelectorsProvidedForFacetForCut(facetAddress);
            }

            FacetCutAction action = _diamondCut[facetIndex].action;
            if (action == FacetCutAction.Add) {
                addFunctions(facetAddress, functionSelectors);
            } else if (action == FacetCutAction.Replace) {
                replaceFunctions(facetAddress, functionSelectors);
            } else if (action == FacetCutAction.Remove) {
                removeFunctions(facetAddress, functionSelectors);
            } else {
                revert IncorrectFacetCutAction(uint8(action));
            }
            unchecked {
                ++facetIndex;
            }
        }
        emit DiamondCut(_diamondCut, init, data);
        initializeDiamondCut(init, data);
    }

    /**
     * @dev Add Function to Diamond
     * @param _facetAddress Address of Facet
     * @param _functionSelectors Signature array of function selectors
     */
    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        if (_facetAddress == address(0)) {
            revert CannotAddSelectorsToZeroAddress(_functionSelectors);
        }

        RuleProcessorDiamondStorage storage ds = s();
        uint16 selectorCount = uint16(ds.selectors.length);
        enforceHasContractCode(_facetAddress, "DiamondCutLib: Add facet has no code");

        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            if (oldFacetAddress != address(0)) {
                revert CannotAddFunctionToDiamondThatAlreadyExists(selector);
            }
            ds.facetAddressAndSelectorPosition[selector] = FacetAddressAndSelectorPosition(_facetAddress, selectorCount);
            ds.selectors.push(selector);
            ++selectorCount;
            unchecked {
                ++selectorIndex;
            }
        }
    }

    /**
     * @dev Replace Function from Diamond
     * @param _facetAddress Address of Facet
     * @param _functionSelectors Signature array of function selectors
     */
    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        RuleProcessorDiamondStorage storage ds = s();
        if (_facetAddress == address(0)) {
            revert CannotReplaceFunctionsFromFacetWithZeroAddress(_functionSelectors);
        }
        enforceHasContractCode(_facetAddress, "DiamondCutLib: Replace facet has no code");
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            address oldFacetAddress = ds.facetAddressAndSelectorPosition[selector].facetAddress;
            /// can't replace immutable functions -- functions defined directly in the diamond in this case
            if (oldFacetAddress == address(this)) {
                revert CannotReplaceImmutableFunction(selector);
            }
            if (oldFacetAddress == _facetAddress) {
                revert CannotReplaceFunctionWithTheSameFunctionFromTheSameFacet(selector);
            }
            if (oldFacetAddress == address(0)) {
                revert CannotReplaceFunctionThatDoesNotExists(selector);
            }
            /// replace old facet address
            ds.facetAddressAndSelectorPosition[selector].facetAddress = _facetAddress;
            unchecked {
                ++selectorIndex;
            }
        }
    }

    /**
     * @dev Remove Function from Diamond
     * @param _facetAddress Address of Facet
     * @param _functionSelectors Signature array of function selectors
     */
    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {
        RuleProcessorDiamondStorage storage ds = s();
        uint256 selectorCount = ds.selectors.length;
        if (_facetAddress != address(0)) {
            revert RemoveFacetAddressMustBeZeroAddress(_facetAddress);
        }
        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; ) {
            bytes4 selector = _functionSelectors[selectorIndex];
            FacetAddressAndSelectorPosition memory oldFacetAddressAndSelectorPosition = ds.facetAddressAndSelectorPosition[selector];
            if (oldFacetAddressAndSelectorPosition.facetAddress == address(0)) {
                revert CannotRemoveFunctionThatDoesNotExist(selector);
            }

            /// can't remove immutable functions -- functions defined directly in the diamond
            if (oldFacetAddressAndSelectorPosition.facetAddress == address(this)) {
                revert CannotRemoveImmutableFunction(selector);
            }
            /// replace selector with last selector
            selectorCount--;
            if (oldFacetAddressAndSelectorPosition.selectorPosition != selectorCount) {
                bytes4 lastSelector = ds.selectors[selectorCount];
                ds.selectors[oldFacetAddressAndSelectorPosition.selectorPosition] = lastSelector;
                ds.facetAddressAndSelectorPosition[lastSelector].selectorPosition = oldFacetAddressAndSelectorPosition.selectorPosition;
            }
            /// delete last selector
            ds.selectors.pop();
            delete ds.facetAddressAndSelectorPosition[selector];
            unchecked {
                ++selectorIndex;
            }
        }
    }

    /**
     * @dev Initialize Diamond Cut of new Facet
     * @param init The address of the contract or facet to execute "data"
     * @param data A function call, including function selector and arguments
     *             calldata is executed with delegatecall on "init"
     */
    function initializeDiamondCut(address init, bytes memory data) internal {
        if (init == address(0)) {
            return;
        }
        enforceHasContractCode(init, "DiamondCutLib: init address has no code");
        (bool success, bytes memory error) = init.delegatecall(data);
        if (!success) {
            if (error.length > 0) {
                // bubble up error
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(error)
                    revert(add(32, error), returndata_size)
                }
            } else {
                revert InitializationFunctionReverted(init, data);
            }
        }
    }

    /**
     * @dev Internal function to enforce contract has code
     * @param _contract The address of the contract be checked or enforced
     * @param _errorMessage Error for contract with non matching co
     */
    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        if (contractSize == 0) {
            revert NoBytecodeAtAddress(_contract, _errorMessage);
        }
    }
}
